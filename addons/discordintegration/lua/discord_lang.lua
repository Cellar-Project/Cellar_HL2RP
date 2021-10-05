--[[
    There's no specific language support, but currently just ability to change all phrases.
]]
Discord.Lang = {
    --[[

        Start of Lang configuration

    ]]


    --[[
        Extra supported strings for ANY language string:
        <server_ip> -> Server's IP
        <join_url> -> steam://connect/<server_ip>
        <hostname> -> Server's Hostname
        <map> -> Server's Map
        <gamemode> -> Server's Gamemode
    ]]

    --[[
        Online Message
    ]]
    ONLINE_MESSAGE_TITLE = 'Server is now online!',
    ONLINE_MESSAGE_DESCRIPTION = 'Join now at <join_url>!',

    --[[
        Player Join/Leave Event

        Extra supported strings for PLAYER_JOIN and PLAYER_DISCONNECT:
        <steam_id> -> Player's steamid32
        <name> -> Player's name

        Only for PLAYER_DISCONNECT:
        <reason> -> Disconnect reason
    ]]
    PLAYER_JOIN = 'Player <name> (<steam_id>) is connecting to the server!',
    PLAYER_DISCONNECT = 'Player <name> (<steam_id>) disconnected (<reason>)',

    --[[
        Discord RPC
    ]]
    CHECK_DISCORD = 'Check your discord instance.',
    RPC_ABORTED = 'Aborted.',
    SOMETHING_WENT_WRONG = 'Whoops! Something went wrong, check console for more details.',
    DISCORD_NOT_FOUND = 'Discord instance not found installed on your computer. As alternative, you can authenticate through the website we\'ve prompted you.',

    --[[
        Joining Discord
    ]]
    JOINED_DISCORD = 'Thank you for joining our discord!',
    JOINED_DISCORD_ALREADY = 'Thank you for joining our discord! As this wasn\'t your first time joining, you won\'t be awarded.',

    --[[
        Linking accounts

        Extra supported strings for ACCOUNT_LINKED:
        <tag> -> Discord tag (eg username#0001) of the linked account
    ]]
    ACCOUNT_LINKED = 'Your account has been successfully linked! Linked with the account <tag>.',
    CONNECTIONS_NOT_FOUND = 'No linked steam accounts were found. You will be prompted with steam login to verify your account ownership.',

    --[[
        Syncing rank

        Extra supported strings for SYNCED_RANK_DISCORD:
        <role> -> Discord role that was given

        Extra supported strings for NONEXISTANT_ROLE, NOT_CONFIGURED_FOR_USERGROUP:
        <usergroup> -> In-game rank
    ]]
    SYNCED_RANK_DISCORD = 'Updated your role in Discord to <role>.',
    NONEXISTANT_ROLE = 'The configured role for the usergroup <usergroup> does not exist in Discord. Please tell this to owner of the server.',
    NOT_CONFIGURED_FOR_USERGROUP = 'The usergroup <usergroup> is not configured to have a role in Discord. Please tell this to the owner of the server.',
    NO_LINKED_ACCOUNTS = 'You don\'t have any linked accounts to sync with!',

    --[[
        Ratelimit message

        Extra supported strings for RATELIMITED:
        <seconds> -> Duration in seconds until ratelimit expires
    ]]
    RATELIMITED = 'You\'re being ratelimited. Please try again in <seconds> seconds.',

    --[[
        Discord Messages

        Extra supported strings for NO_STEAM_CONNECTIONS:
        <linkchatcommand> -> Chat command in-game for linking your steam account

        Extra supported strings for SYNCED_USERGROUP_GMOD:
        <usergroup> -> The synced rank in-game
    ]]
    INTERNAL_SERVER_ERROR = 'Internal Server Error happened. Try again later.',
    NO_STEAM_CONNECTIONS = 'You don\'t have any linked steam accounts. Link your steam account by typing <linkchatcommand> in the game chat.',
    SYNCED_USERGROUP_GMOD = 'Updated your usergroup in-game to ``<usergroup>``.',

    --[[
        Popup UI
    ]]
    CENTER_TEXT = 'Would you like to join our Discord?',
    CENTER_BELOW_TEXT = 'You will be awarded with $5000',
    JOIN_BUTTON = 'Yes',
    LATER_BUTTON = 'No',

    --[[
        Clientside Errors
    ]]
    JOIN_REWARDS_NOT_CONFIGURED = 'Join Rewards is not configured properly on the server. Report to the server owner.',
    COULDNT_RETRIEVE_TOKEN_DATA = 'Couldn\'t retrieve token data from Discord. Try again later.',
    ACCESS_TOKEN_HAS_NO_REQUIRED_PERMS = 'Access token has no required permission.',
    COULDNT_RETRIEVE_USER_DATA = 'Couldn\'t retrieve user data from Discord. Try again later.',
    COULDNT_MAKE_YOU_JOIN = 'Couldn\'t make you join the discord. Try again later.',
    SOMETHING_WENT_WRONG_CHECKING_PREVIOUS_JOIN_DATA = 'Something went wrong while trying to check for previous joins into the discord. Try again later.',
    SOMETHING_WENT_WRONG_CONFIRMING_JOIN = 'Something went wrong while trying to confirm your joining into the discord. Try again later.',
    RANK_SYNC_NOT_CONFIGURED = 'Rank Sync is not configured properly on the server. Report to the server owner.',
    INTERNAL_ERROR_WHILE_LINKING_ACCOUNT = 'Internal error happened while trying to link your account, try again later.',

    --[[
        Discord Commands

        Extra supported strings for SAID_AS_CONSOLE, RAN_IN_CONSOLE, RAN_CODE_ON_SERVER:
        <cmd> -> The provided argument to say/run

        Extra supported strings for KICKED_PLAYER, KICKED_PLAYER_WITH_REASON:
        <player> -> The name of the kicked player
        (ONLY FOR KICKED_PLAER_WITH_REASON) <reason> -> The kick reason

        Extra supported strings for FAILED_SCREENSHOTTING, SCREENSHOT_OF_PLAYER:
        <name> -> The name of the target for the screenshot
        (ONLY FOR FAILED_SCREENSHOTTING) <error> -> The reason why screenshotting failed
        (ONLY FOR SCREENSHOT_OF_PLAYER) <sid64> -> The steamid64 of the target of the screenshot
    ]]
    COMMAND_EVENT = 'Command Event',
    COMMAND_ERROR = 'Command Error',
    NO_PERMISSIONS = 'You do not have the permission to run this command.',
    IP = 'IP',
    GAMEMODE = 'Gamemode',
    MAP = 'Map',
    PLAYERS = 'Players',
    STAFF_ONLINE = 'Staff Online',
    NO_ARGUMENT_PROVIDED = 'No argument provided.',
    PLAYER_COULDNT_BE_FOUND = 'Player couldn\'t be found.',
    SAID_AS_CONSOLE = 'Said ``<cmd>`` as console in chat.',
    RAN_IN_CONSOLE = 'Ran ``<cmd>`` in console.',
    RAN_CODE_ON_SERVER = 'Ran code on the server:\n```lua\n<cmd>\n```',
    KICKED_PLAYER_WITH_REASON = 'Kicked the player "<name>" with the reason "<reason>".',
    KICKED_PLAYER = 'Kicked the player "<name>".',
    FAILED_SCREENSHOTTING = 'Failed screenshotting the player "<name>": <err>',
    SCREENSHOT_OF_PLAYER = 'Screenshot of the player "<name>" (<sid64>)',
    HELP_TITLE = 'Discord Integration - Help',
    HELP_DESCRIPTION = [[status - Server Info
rcon <STRING> - Runs the specified string in the console
lua <STRING> - Runs the specified string serverside
kick <PLAYER> - Kicks the specified player
ss <PLAYER> - Screenshots the specified player]],

    --[[
        Screenshotting errors
    ]]
    INVALID_PLAYER = 'Invalid player.',
    ALREADY_BEING_SCREENSHOTTED = 'The player is already being screenshotted.',

    --[[
        CAC Integration

        Extra supported strings for CAC_DESCRIPTION and CAC_DESCRIPTION_ERROR:
        <detections> -> All detections seperated by a comma

        Extra supported strings for CAC_DESCRIPTION:
        <url> -> URL to the screenshot

        Extra supported strings for CAC_DESCRIPTION_ERROR:
        <error> -> Error that happened while screenshotting
    ]]
    CAC_DESCRIPTION = '**__CAC Detection__**: <detections> - [Original](<url>)',
    CAC_DESCRIPTION_ERROR = '**__CAC Detection__**: <detections> - Failed taking screenshot with the error: <error>',

    --[[
        SimpLAC Integration

        Extra supported strings for SIMPLAC_DESCRIPTION and SIMPLAC_DESCRIPTION_ERROR:
        <detections> -> All detections seperated by a comma

        Extra supported strings for SIMPLAC_DESCRIPTION:
        <url> -> URL to the screenshot

        Extra supported strings for SIMPLAC_DESCRIPTION_ERROR:
        <error> -> Error that happened while screenshotting
    ]]
    SIMPLAC_DESCRIPTION = '**__SimpLAC Detection__**: <detections> - [Original](<url>)',
    SIMPLAC_DESCRIPTION_ERROR = '**__SimpLAC Detection__**: <detections> - Failed taking screenshot with the error: <error>',

    --[[
        SwiftAC Integration

        Extra supported strings for SWIFTAC_DESCRIPTION and SWIFTAC_DESCRIPTION_ERROR:
        <detections> -> All detections seperated by a comma

        Extra supported strings for SWIFTAC_DESCRIPTION:
        <url> -> URL to the screenshot

        Extra supported strings for SWIFTAC_DESCRIPTION_ERROR:
        <error> -> Error that happened while screenshotting
    ]]
    SWIFTAC_DESCRIPTION = '**__SwiftAC Detection__**: <detections> - [Original](<url>)',
    SWIFTAC_DESCRIPTION_ERROR = '**__SwiftAC Detection__**: <detections> - Failed taking screenshot with the error: <error>',

    --[[
        ModernAC Integration

        <reason> -> The detection reason
    ]]
    MODERNAC_DESCRIPTION = '**__ModernAC Detection__**: <reason> - [Original](<url>)',
    MODERNAC_DESCRIPTION_ERROR = '**__ModernAC Detection__**: <reason> - Failed taking screenshot with the error: <error>',

    --[[
        ULX Integration
    ]]
    ULX_TITLE = 'ULX Log',

    --[[
        ServerGuard Integration
    ]]
    SG_TITLE = 'SG Log',

    --[[
        bWhitelist Integration

        Extra supported strings for BWHITELIST_(WHITELIST|BLACKLIST)_ADDED, BWHITELIST_(WHITELIST|BLACKLIST)_REMOVED:
        <name> -> The name of the target
        <job> -> The job name
    ]]
    BWHITELIST_HELP_TEXT = 'job <whitelist/blacklist> <PLAYER> <job - in TEAM_ format or its name>',
    BWHITELIST_WRONG_METHOD = 'Wrong method provided, can only be whitelist/blacklist (e.g. !job whitelist/blacklist Trixter citizen)',
    BWHITELIST_NO_PLAYER_NAME = 'No player name provided.',
    BWHITELIST_NO_JOB_NAME = 'No job name provided.',
    BWHITELIST_JOB_COULDNT_BE_FOUND = 'Job couldn\'t be found with that name.',
    BWHITELIST_WHITELIST_DISABLED = 'Whitelist for this job is disabled.',
    BWHITELIST_BLACKLIST_DISABLED = 'Blacklist for this job is disabled.',

    BWHITELIST_WHITELIST_ADDED = 'Added player <name> to the whitelist of job <job>!',
    BWHITELIST_WHITELIST_REMOVED = 'Removed player <name> from the whitelist of job <job>!',
    BWHITELIST_BLACKLIST_ADDED = 'Added player <name> to the blacklist of job <job>!',
    BWHITELIST_BLACKLIST_REMOVED = 'Removed player <name> from the blacklist of job <job>!',

    --[[

        End of Lang configuration

    ]]
}