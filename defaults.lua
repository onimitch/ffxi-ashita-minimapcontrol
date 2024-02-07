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
    any_menu_open = false,
    left_menu_open = false,
    command_menu_open = false,
    main_menu_open = false,
    map_open = false,
    in_city = true,
    auction_open = false,
}

defaults.debug_menus = false

return defaults
