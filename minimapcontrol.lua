addon.name      = 'minimapcontrol'
addon.author    = 'onimitch'
addon.version   = '1.2.0'
addon.desc      = 'Controls the visiblity of the Ashita v4 minimap plugin. Based on atom0s minimapmon with extra functionality.'
addon.link      = 'https://github.com/onimitch/ffxi-ashita-minimapcontrol'

-- Ashita libs
require('common')
local settings = require('settings')
local chat = require('chat')

-- Minimapcontrol files
local default_settings = require('defaults')
local defines = require('defines')
require('helpers')

local minimapcontrol = {
    settings = T{},
    last_update = 0,
    update_interval = 0.05,
    opacity = {
        current = T{},
        previous = T{},
    },
    player_pos = { 0, 0, 0 },
    visible = true,
    zoning = false,

    player_moving = false,
    combat_engaged = false,
    enemy_list = T{},

    current_menu = '',
    is_menu_open = false,
    is_map_open = false,
    is_window_open = false,
    is_main_menu_open = false,
    is_config_menu_open = false,
    is_helpdesk_menu_open = false,
    is_command_menu_open = false,
    is_auction_menu_open = false,
}

local pGameMenu = ashita.memory.find('FFXiMain.dll', 0, '8B480C85C974??8B510885D274??3B05', 16, 0)
local function get_game_menu_name()
    local menu_pointer = ashita.memory.read_uint32(pGameMenu)
    local menu_val = ashita.memory.read_uint32(menu_pointer)
    if (menu_val == 0) then
        return ''
    end
    local menu_header = ashita.memory.read_uint32(menu_val + 4)
    local menu_name = ashita.memory.read_string(menu_header + 0x46, 16)
    return menu_name:gsub('\x00', ''):gsub('menu[%s]+', ''):trimex()
end

local pEventSystem = ashita.memory.find('FFXiMain.dll', 0, 'A0????????84C0741AA1????????85C0741166A1????????663B05????????0F94C0C3', 0, 0)
local function is_event_system_active()
    if (pEventSystem == 0) then
        return false
    end
    local ptr = ashita.memory.read_uint32(pEventSystem + 1)
    if (ptr == 0) then
        return false
    end

    return (ashita.memory.read_uint8(ptr) == 1)
end

local pInterfaceHidden = ashita.memory.find('FFXiMain.dll', 0, '8B4424046A016A0050B9????????E8????????F6D81BC040C3', 0, 0)
local function is_game_interface_hidden()
    if (pInterfaceHidden == 0) then
        return false
    end
    local ptr = ashita.memory.read_uint32(pInterfaceHidden + 10)
    if (ptr == 0) then
        return false
    end

    return (ashita.memory.read_uint8(ptr + 0xB4) == 1)
end

local pChatExpanded = ashita.memory.find('FFXiMain.dll', 0, '83EC??B9????????E8????????0FBF4C24??84C0', 0x04, 0)
local function is_chat_expanded()
    local ptr = ashita.memory.read_uint32(pChatExpanded)
    if ptr == 0 then
        return false
    end

    return ashita.memory.read_uint8(ptr + 0xF1) ~= 0
end

local minimap_ini = AshitaCore:GetInstallPath() .. '/config/minimap/minimap.ini'


minimapcontrol.initialize = function()
    minimapcontrol.opacity.current = minimapcontrol.settings.opacity:clone()
    minimapcontrol.opacity.previous = T{}
end

minimapcontrol.update_menu_state = function()
    local menu_now = get_game_menu_name()
    if menu_now == minimapcontrol.current_menu then
        return
    end
    minimapcontrol.current_menu = menu_now

    if minimapcontrol.settings.debug_menus then
        print(chat.header(addon.name):append(chat.message('Menu: ' .. menu_now)))
    end

    if menu_now == '' then
        minimapcontrol.is_menu_open = false
        minimapcontrol.is_config_menu_open = false
        minimapcontrol.is_helpdesk_menu_open = false
        minimapcontrol.is_auction_menu_open = false
    end

    -- Any menu entry points
    if menu_now:match(defines.menus.menu1) or menu_now:match(defines.menus.menu2) then
        minimapcontrol.is_menu_open = true
        minimapcontrol.is_config_menu_open = false
        minimapcontrol.is_helpdesk_menu_open = false
        minimapcontrol.is_auction_menu_open = false
    end

    -- Inside config menu
    if menu_now:match(defines.menus.config_menu) then
        minimapcontrol.is_config_menu_open = true
    end

    -- Inside help desk menu
    if menu_now:match(defines.menus.helpdesk_menu) then
        minimapcontrol.is_helpdesk_menu_open = true
    end

    -- Inside command menu
    minimapcontrol.is_command_menu_open = false
    for _, v in ipairs(defines.command_menu) do
        if menu_now:match(v) then
            minimapcontrol.is_command_menu_open = true
            break
        end
    end

    -- Inside auction menu
    if menu_now:match(defines.menus.auction_menu) then
        minimapcontrol.is_auction_menu_open = true
    end  

    -- Main menu only (menu that appears on the right)
    minimapcontrol.is_main_menu_open = minimapcontrol.is_config_menu_open or minimapcontrol.is_helpdesk_menu_open
    if not minimapcontrol.is_main_menu_open then
        for _, v in ipairs(defines.main_menu) do
            if menu_now:match(v) then
                minimapcontrol.is_main_menu_open = true
                break
            end
        end
    end

    -- Windows
    minimapcontrol.is_window_open = minimapcontrol.is_config_menu_open or minimapcontrol.is_helpdesk_menu_open
    for _, v in ipairs(defines.window) do
        if menu_now:match(v) then
            minimapcontrol.is_window_open = true
            break
        end
    end
    -- Fix false positive
    if menu_now:match(defines.menus.misson_category) then
        minimapcontrol.is_window_open = false
    end

    -- Map we can just check map or region
    minimapcontrol.is_map_open = menu_now:match(defines.menus.map) or menu_now:match(defines.menus.region_map) or menu_now:match(defines.menus.widescan)
end

minimapcontrol.update_visiblity = function()
    minimapcontrol.visible = true

    -- Always hide if interface is hidden
    if is_game_interface_hidden() then
        minimapcontrol.visible = false
        return
    end

    -- Hide if moving
    if not minimapcontrol.settings.show_when.moving and minimapcontrol.player_moving then
        minimapcontrol.visible = false
        return
    end

    -- Hide during events
    if not minimapcontrol.settings.show_when.during_events and is_event_system_active() then
        minimapcontrol.visible = false
        return
    end

    -- Hide if (any) menu open
    if not minimapcontrol.settings.show_when.any_menu_open and minimapcontrol.is_menu_open then
        minimapcontrol.visible = false
        return
    end

    -- Hide if map open
    if not minimapcontrol.settings.show_when.map_open and minimapcontrol.is_map_open then
        minimapcontrol.visible = false
        return
    end

    -- Hide if left menu open
    if not minimapcontrol.settings.show_when.window_open and minimapcontrol.is_window_open then
        minimapcontrol.visible = false
        return
    end

    -- Hide if command menu open
    if not minimapcontrol.settings.show_when.command_menu_open and minimapcontrol.is_command_menu_open then
        minimapcontrol.visible = false
        return
    end

    -- Hide if main menu open
    if not minimapcontrol.settings.show_when.main_menu_open and minimapcontrol.is_main_menu_open then
        minimapcontrol.visible = false
        return
    end

    -- Hide if auction open
    if not minimapcontrol.settings.show_when.auction_open and minimapcontrol.is_auction_menu_open then
        minimapcontrol.visible = false
        return
    end

    -- Hide if in combat
    if not minimapcontrol.settings.show_when.in_combat and (minimapcontrol.combat_engaged or #minimapcontrol.enemy_list > 0) then
        minimapcontrol.visible = false
        return
    end

    -- Hide if chat expanded
    if not minimapcontrol.settings.show_when.chat_expanded and is_chat_expanded() then
        minimapcontrol.visible = false
        return
    end
end

minimapcontrol.update_enemy_list = function()
    local updated_enemy_list = T{}

    for _, user_index in ipairs(minimapcontrol.enemy_list) do
        local ent = GetEntity(user_index)
        if ent ~= nil and GetIsValidMob(user_index) and ent.HPPercent > 0 then
            table.insert(updated_enemy_list, user_index)
        end
    end

    minimapcontrol.enemy_list = updated_enemy_list
end

minimapcontrol.update_player_state = function()
    minimapcontrol.player_moving = false
    minimapcontrol.combat_engaged = false

    local player_entity = GetPlayerEntity()
    if player_entity == nil then
        return
    end

    -- Check if player moved
    local x = player_entity.Movement.LocalPosition.X
    local y = player_entity.Movement.LocalPosition.Y
    local z = player_entity.Movement.LocalPosition.Z

    minimapcontrol.player_moving = minimapcontrol.player_pos[1] ~= x or minimapcontrol.player_pos[2] ~= y or minimapcontrol.player_pos[3] ~= z
    minimapcontrol.player_pos = { x, y, z }

    -- Check if player in combat
    local entity = AshitaCore:GetMemoryManager():GetEntity()
    local party = AshitaCore:GetMemoryManager():GetParty()
    local player_index = party:GetMemberTargetIndex(0)
    minimapcontrol.combat_engaged = entity:GetStatus(player_index) == defines.entity_status.enganged
end

minimapcontrol.set_zoom_level = function(zoom_level)
    AshitaCore:GetChatManager():QueueCommand(1, '/minimap zoom ' .. zoom_level)
end

minimapcontrol.on_zone_changed = function(zone_id)
    minimapcontrol.zone_id = tonumber(zone_id)
    local zoom_level = minimapcontrol.settings.zoom[minimapcontrol.zone_id] or minimapcontrol.settings.default_zoom
    minimapcontrol.set_zoom_level(zoom_level)
end

minimapcontrol.record_zoom_level = function()
    if minimapcontrol.zone_id == nil then
        return
    end

    local f = io.open(minimap_ini, 'r')
    if (f == nil) then
        return
    end

    for line in f:lines() do
        local _, _, zoom_level = string.find(line, 'zoom[%s]*=[%s]*([%d%.]+)')
        if zoom_level ~= nil then
            minimapcontrol.settings.zoom[minimapcontrol.zone_id] = zoom_level
            settings.save()
            break
        end
    end
end

minimapcontrol.reset_state = function()
    minimapcontrol.enemy_list = T{}
    minimapcontrol.player_moving = false
    minimapcontrol.combat_engaged = false
    minimapcontrol.current_menu = ''
    minimapcontrol.is_menu_open = false
    minimapcontrol.is_map_open = false
    minimapcontrol.is_window_open = false
    minimapcontrol.is_main_menu_open = false
    minimapcontrol.is_config_menu_open = false
    minimapcontrol.is_helpdesk_menu_open = false
    minimapcontrol.is_command_menu_open = false
    minimapcontrol.is_auction_menu_open = false
end

ashita.events.register('load', 'minimapcontrol_load', function()
    minimapcontrol.settings = settings.load(default_settings)
    minimapcontrol.initialize()

    local zone_id = AshitaCore:GetMemoryManager():GetParty():GetMemberZone(0)
    minimapcontrol.on_zone_changed(zone_id)

    -- Register for future settings updates
    settings.register('settings', 'minimapcontrol_settings_update', function(s)
        if (s ~= nil) then
            minimapcontrol.settings = s
            minimapcontrol.initialize()
        end
    end)

    print(chat.header(addon.name):append(chat.message('Loaded')))
end)

ashita.events.register('packet_in', 'packet_in_cb', function(e)
    if (e.id == defines.packets.inc.zone_out) then
        minimapcontrol.zoning = true
        minimapcontrol.reset_state()
        minimapcontrol.record_zoom_level()
        return
    end

    if (e.id == defines.packets.inc.zone_in) then
        minimapcontrol.zoning = false
        local zone_id = struct.unpack('H', e.data, 0x30 + 1)
        minimapcontrol.on_zone_changed(zone_id)
        return
    end

    if (e.id == defines.packets.inc.npc_update) then
        local user_index = struct.unpack('H', e.data, 0x08 + 1)
        local flags = struct.unpack('B', e.data, 0x0A + 1)
        if bit.band(flags, 0x02) == 0x02 then
            local claim_id = struct.unpack('L', e.data, 0x2C + 1)
            if claim_id == nil or not GetIsValidMob(user_index) then
                return
            end

            local partyMemberIds = GetPartyMemberIds()
            if partyMemberIds:contains(e.newClaimId) and not minimapcontrol.enemy_list:contains(user_index) then
                table.insert(minimapcontrol.enemy_list, user_index)
                -- print('Enemy list: ' .. #minimapcontrol.enemy_list .. ' (npc update)')
            end
        end
        return
    end

    if (e.id == defines.packets.inc.action) then
        local packet_data = ParseActionPacket(e)
        if packet_data == nil then
            return
        end

        local user_index = packet_data.UserIndex
        if GetIsMobByIndex(user_index) and GetIsValidMob(user_index) then
            local partyMemberIds = GetPartyMemberIds()
            for i = 0, #packet_data.Targets do
                if packet_data.Targets[i] ~= nil and partyMemberIds:contains(packet_data.Targets[i].Id) and not minimapcontrol.enemy_list:contains(user_index) then
                    table.insert(minimapcontrol.enemy_list, user_index)
                    -- print('Enemy list: ' .. #minimapcontrol.enemy_list .. ' (npc action)')
                    break
                end
            end
        end
        return
    end
end)

ashita.events.register('d3d_beginscene', 'beginscene_cb', function(isRenderingBackBuffer)
    if not isRenderingBackBuffer then
        return
    end

    minimapcontrol.update_player_state()
    minimapcontrol.update_menu_state()
    minimapcontrol.update_enemy_list()
    minimapcontrol.update_visiblity()
end)

ashita.events.register('d3d_present', 'present_cb', function()
    -- Throttle the events we send to the plugin
    local clock_time = os.clock()
    if (clock_time >= minimapcontrol.last_update + minimapcontrol.update_interval) then
        minimapcontrol.last_update = clock_time

        local fade_dir = minimapcontrol.visible and 1 or -1
        local update_per_frame = 0.4 * fade_dir
        local current_opacity = minimapcontrol.opacity.current
        local visible_opacity = minimapcontrol.settings.opacity

        current_opacity.map = math.clamp(current_opacity.map + update_per_frame, 0, visible_opacity.map)
        current_opacity.frame = math.clamp(current_opacity.frame + update_per_frame, 0, visible_opacity.frame)
        current_opacity.arrow = math.clamp(current_opacity.arrow + update_per_frame, 0, visible_opacity.arrow)
        current_opacity.monsters = math.clamp(current_opacity.monsters + update_per_frame, 0, visible_opacity.monsters)
        current_opacity.npcs = math.clamp(current_opacity.npcs + update_per_frame, 0, visible_opacity.npcs)
        current_opacity.players = math.clamp(current_opacity.players + update_per_frame, 0, visible_opacity.players)

        -- Send event to minimap if opacity actually changed
        if (not current_opacity:equals(minimapcontrol.opacity.previous)) then
            minimapcontrol.opacity.previous = current_opacity:clone()

            -- Raise the minimap event
            local data = struct.pack('Lffffff', 0x01, current_opacity.map, current_opacity.frame, current_opacity.arrow, current_opacity.monsters, current_opacity.npcs, current_opacity.players)
            AshitaCore:GetPluginManager():RaiseEvent('minimap', data:totable())
        end
    end
end)
