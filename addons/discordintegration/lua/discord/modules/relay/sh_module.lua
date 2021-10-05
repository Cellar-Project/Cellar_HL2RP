local MODULE = {}
MODULE.DisplayName = 'Relay'
MODULE.Dependencies = {
    {'sv', 'classes/message.lua'},
}
MODULE.PostLoad = {
    {'sv', 'screenshot.lua'},
    {'sv', 'commands.lua'},

    {'sv', 'integrations/cac.lua'},
    {'sv', 'integrations/serverguard.lua'},
    {'sv', 'integrations/ulx.lua'},
    {'sv', 'integrations/simplac.lua'},
    {'sv', 'integrations/swiftac.lua'},
    {'sv', 'integrations/modernac.lua'},
    {'sv', 'integrations/bwhitelist.lua'},

    {'cl', 'cl_screenshot.lua'},
}

Discord.MODULE = MODULE