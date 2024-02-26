require('common')

local defaults = T{}

defaults.opacity = T{
    map = 1,
    frame = 1,
    arrow = 1,
    monsters = 1,
    npcs = 1,
    players = 1,
}

defaults.show_when = T{
    moving = true,
    during_events = false,
    in_combat = false,
    any_menu_open = true,
    window_open = false,
    command_menu_open = true,
    main_menu_open = true,
    map_open = false,
    auction_open = false,
    chat_expanded = false,
}

defaults.debug_menus = false

defaults.default_zoom = 1
defaults.zoom = T{}

return defaults
