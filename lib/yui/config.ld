project = 'Yui'
title = 'Yui docs'
description = 'Yui is Yet another User Interface library.'
format = 'markdown' 
full_description = [[
The Yui library assists in designing menu screens, pause menus, HUDs, and such.

Source code: @{https://gitea.it/1414codeforge/yui}

Examples: @{https://gitea.it/1414codeforge/yui-examples}

Pictures: @{https://gitea.it/1414codeforge/yui-examples/src/branch/master/pics}


The main features: grid layout, widget navigation with keyboard/joystick buttons, support for managing custom
input devices (keyboard, mouse, touch, gamepad), and an easily extensible widget collection. The user interface is
described with a declarative approach: the layout is defined once, and events are handled in the callbacks.

Integrated support for localization was achieved through the use of another library: moonspeak. 
(@{https://gitea.it/1414codeforge/moonspeak})

Most of the widget and theme rendering code are re-used from Matthias Richter's SUIT library.
(@{https://github.com/vrld/suit})

]]
file = {'', exclude = {'crush.lua'}}



custom_see_handler('^https://(.+)$', function(root)
                          local url ='https://'..root
                        
                            return url,
                                url
                        end)
