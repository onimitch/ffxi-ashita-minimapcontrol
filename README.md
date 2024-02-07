# minimapcontrol

An ashita v4 addon to control the visiblity of the Ashita v4 minimap plugin. 
Based on atom0s minimapmon (bundled with Ashita v4) with extra functionality.

## How to install:
1. Download the latest Release from the [Releases page](https://github.com/onimitch/ffxi-ashita-minimapcontrol/releases)
2. Extract the **_minimapcontrol_** folder to your **_Ashita4/addons_** folder

## How to have Ashita load it automatically:
1. Go to your Ashita v4 folder
2. Open the file **_Ashita4/scripts/default.txt_**
3. Add `/addon load minimapcontrol` to the list of addons to load under "Load Plugins and Addons"
4. Make sure that minimapmon is not loaded, as the two addons won't work together.

## Config
1. Edit **_Ashita4/config/addons/minimapcontrol/<character>/settings.lua_**
2. Make and save changes.
3. Reload the plugin: `/addon reload minimapcontrol`

## Settings options

### Opacity
Set the following values to the opacity you want when the minimap is displayed, in a range of 0-1.

* `settings["opacity"]["arrow"]`
* `settings["opacity"]["monsters"]`
* `settings["opacity"]["map"]`
* `settings["opacity"]["frame"]`
* `settings["opacity"]["players"]`
* `settings["opacity"]["npcs"]`

### show_when

* `settings["show_when"]["command_menu_open"]` - If false, the minimap will be hidden when a command menu is open (e.g menus that appear above the chat window and cause the compass to dissapear).
* `settings["show_when"]["main_menu_open"]` - If false, the minimap will be hidden when a main menu is open (menus that appear on the right).
* `settings["show_when"]["left_menu_open"]` - If false, the minimap will be hidden when a window is open (menus that appear on the left).
* `settings["show_when"]["any_menu_open"]` - If false, the minimap will be hidden when any window is open.
* `settings["show_when"]["moving"]` - If false, the minimap will be hidden when the character is moving (same behaviour as atom0s minimapmon).
* `settings["show_when"]["during_events"]` - If false, the minimap will be hidden when an event is being played.
* `settings["show_when"]["auction_open"]` - If false, the minimap will be hidden when the auction window is open.
* `settings["show_when"]["map_open"]` - If false, the minimap will be hidden when the map or region map is open.
* `settings["show_when"]["in_combat"]` - If false, the minimap will be hidden when in combat.

## Issues/Support

I only have limited time available to offer support, but if you have a problem, have discovered a bug or want to request a feature, please [create an issue on GitHub](https://github.com/onimitch/ffxi-ashita-minimapcontrol/issues).
