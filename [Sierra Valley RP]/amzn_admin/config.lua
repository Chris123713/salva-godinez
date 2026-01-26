--- 919 ADMIN SERVER CONFIGURATION
---
--- Please note that there are not many options for the server config,
--- this is because the resource is designed to be plug-and-play as much
--- as possible. All permissions and configurable options are inside the
--- admin menu itself, which is accessed in-game.
---
--- Frameworks and third-party resource integration is designed with
--- an auto-detect feature to make installing and running 919ADMIN
--- as painless as possible.
Config = {
    --- Disable Reports
    --- This is used to disable the reports system.
    --- If you want to disable the reports system, set this to true.
    --- This will only disable the /report command however, the reports menu will still be accessible.
    DisableReports = false,

    --- Report Command
    --- This is used for the player /report command.
    ReportCommand = "report",

    --- Disable IP Display
    --- When true, IP addresses are not shown in the admin menu identifiers
    DisableIPDisplay = true,

    --- Hide Player In NoClip
    --- When true, the player ped will be invisible while in noclip mode
    HidePlayerInNoClip = true,

    Logging = {
        --- Logging Type
        --- You can choose between "fivemanage" and "discord" for logging.
        --- If you choose "fivemanage", you must set the FiveManageAPIKey config.
        --- If you choose "discord", you must set the DiscordWebhooks config.
        LoggingType = "discord",
        
        FiveManage = {
            --- FiveManage API Key
            --- This is used to log player actions, quick actions, and offline actions to FiveManage.
            --- You can get the API key by going to the FiveManage website and creating a new API key.
            --- Then copy the API key and paste it here.
            FiveManageAPIKey = "",

            --- FiveManage Dataset
            --- Here you can set which dataset to use for logging. The default value is "default".
            FiveManageDataset = "default",
        },
        
        --- Discord Webhooks
        --- This is used to log player actions, quick actions, and screenshots to a Discord webhook.
        --- You can get the webhook url by creating a new channel, and then
        --- creating a webhook in the channel settings under the "Integrations" tab.
        --- Then copy the url and paste it here.
        Discord = {
            -- Enter the discord web hook to log player actions.
            PlayerActionsWebhook = "https://discord.com/api/webhooks/1456904945335926962/XwYd25HYy0ipPMTdo6CopeDcEPWgVhnIQ1woDhP3mFtTzg49Lx_JFShwRUpU53UJaqtP",
            -- Enter the discord web hook to log quick actions (self actions).
            QuickActionsWebhook = "https://discord.com/api/webhooks/1456904945335926962/XwYd25HYy0ipPMTdo6CopeDcEPWgVhnIQ1woDhP3mFtTzg49Lx_JFShwRUpU53UJaqtP",

            --- Additional webhook routing
            --- Use this to forward specific logs to any additional webhook(s) based on filters.
            --- Use "*" to match all Categories/Actions.
            UseDefaultWebhooks = true,
            WebhookRoutes = {
                {
                    Webhook = "https://discord.com/api/webhooks/1456904945335926962/XwYd25HYy0ipPMTdo6CopeDcEPWgVhnIQ1woDhP3mFtTzg49Lx_JFShwRUpU53UJaqtP",
                    Categories = { "*" }, -- forward all categories
                    Actions = { "*" }, -- forward all actions
                },
            },
        },
    },
    

    --- Discord Role Permissions
    --- This is used to add a player to a 919ADMIN User Group based on their Discord Role.
    --- This is optional and not required for the resource to work.
    --- If you want to use this feature, you must have a bot in your Discord server.
    --- You can get the bot token by going to the Discord Developer Portal and creating a new application.
    --- Then create a bot and copy the token.
    --- You can then add the bot to your server and use the following config.
    DiscordRolePermissions = {
        Enabled = false,
        --- Bot token
        DiscordToken = "",
        --- Server ID 
        GuildID = "",
    
        --- Discord roles you want to map to a 919ADMIN User Group.
        --- ORDER MATTERS: Highest priority first; the first match wins.
        --- Make sure you first create the User Group in the 919ADMIN menu, and use the exact name.
        --- It is case-sensitive. Also make sure your role ids are strings.
        --- Example:
        --- DiscordRoles = {
        ---     { role = "123456789012345678", group = "SuperAdmin" },
        ---     { role = "234567890123456789", group = "Admin" },
        ---     { role = "345678901234567890", group = "Moderator" },
        --- }
        DiscordRoles = {
            { role = "", group = "SuperAdmin" },
            -- { role = "DiscordRoleId", group = "PanelGroupName" },
        },
    },

    --- Manually disable pages in the admin menu
    --- Set to true to hide/disable a specific page from the UI
    DisabledPages = {
        AdminChat = false,
        Reports = false,
        Map = false,
        Items = false,
        Vehicles = false,
        Resources = false,
        Analytics = false,
        Tebex = false,
        Addons = false,
        Characters = false,
    }
}