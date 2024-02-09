local defines = T{}

defines.packets = {
    inc = {
        zone_in = 0x00A,
        zone_out = 0x00B,
        inventory_update = 0x01D,
        npc_update = 0x00E,
        action = 0x028,
    },
    out = {
        action = 0x01A,
    },
}

defines.actions = {
    engage_monster = 0x02,
    disengage = 0x04,
}

defines.entity_status = {
    idle = 0,
    enganged = 1,
    dead = 2,
    dead2 = 3,
    zoning = 4,
    resting = 33,
}

defines.menus = {
    menu1 = 'menuwind',
    menu2 = 'socialme',
    inventory = 'inventor',
    equip = 'equip',
    aux_inv = 'bank',
    key_items = 'evitem',
    item_sort = 'itmsort',
    item_sort_yn = 'sortyn',
    item_quantity = 'itemctrl',
    item_switch = 'itmstora',
    item_use = 'iuse',
    map = 'map',
    mission = 'miss',
    quest = 'quest',
    region_map = 'cnqframe',
    region_list = 'region',
    search_result = 'scresult',
    command = 'playermo',
    trade = 'handover',
    shop = 'shop',
    macro = 'mcr[%d]pall',
    config_menu = 'configwi',
    config_window = 'conf[%d]win',
    moghouse = 'mogcont',
    command_moghouse = 'myroom',
    query = 'query',
    misson_category = 'missionm',
    profile = 'statcom',
    auction_list = 'auclist',
    auction_history = 'auchisto',
    auction_menu = 'auc[%d]',
    command_magic = 'magic',
    command_ability = 'ability',
    command_mount = 'mount',
    synth_history = 'cmbhlst',
    linkshell = 'link[%d]',
    comment = 'comment',
    helpdesk_menu = 'faqsub',
    emote = 'emote',
    widescan = 'scanlist',
    merit = 'merit[%d]',
    merit_categories = 'meritcat',
    confirm_yn = 'comyn',
    ability_select = 'abiselec',
}

defines.command_menu = {
    defines.menus.command_moghouse,
    defines.menus.query,
    defines.menus.command,
    defines.menus.command_magic,
    defines.menus.command_ability,
    defines.menus.command_mount,
    defines.menus.comment,
    defines.menus.emote,
    defines.menus.ability_select,
}

defines.window = {
    defines.menus.inventory,
    defines.menus.equip,
    defines.menus.aux_inv,
    defines.menus.key_items,
    defines.menus.mission,
    defines.menus.quest,
    defines.menus.search_result,
    defines.menus.trade,
    defines.menus.shop,
    defines.menus.profile,
    defines.menus.auction_list,
    defines.menus.auction_history,
    defines.menus.item_sort,
    defines.menus.item_sort_yn,
    defines.menus.item_quantity,
    defines.menus.item_switch,
    defines.menus.item_use,
    defines.menus.synth_history,
    defines.menus.linkshell,
    defines.menus.config_window,
    defines.menus.merit,
    defines.menus.merit_categories,
    defines.menus.confirm_yn,
    defines.menus.macro,
}

defines.main_menu = {
    defines.menus.menu1,
    defines.menus.menu2,
    defines.menus.config_menu,
    defines.menus.moghouse,
    defines.menus.misson_category,
    defines.menus.auction_menu,
    defines.menus.item_switch,
    defines.menus.item_sort,
    defines.menus.item_sort_yn,
    defines.menus.region_list,
    defines.menus.merit,
}

return defines