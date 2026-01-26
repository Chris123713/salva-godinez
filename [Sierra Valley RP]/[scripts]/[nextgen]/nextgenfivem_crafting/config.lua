--[[ Bench Options ]]
BenchOptions = {
    allowMultipleUsers = false, -- Allow multiple users to use the same bench at the same time
    isInvincible = false, -- Make the player invincible while using the bench (can only be false if allowMultipleUsers is disabled)
    removeBlueprintOnCraft = false, -- Remove the blueprint from the player after crafting
    enableSpotlight = true, -- Enable the spotlight for the bench
    enablePortableBenches = true, -- Enable portable benches. This will allow the player to place the bench themselves with items. (this needs to be setted up, check out the documentation)
    enableBlueprintItems = false, -- Enable the blueprint items. The player will need to have the blueprint item in their inventory to craft the item. (this needs to be setted up, check out the documentation)
    colors = {
        primary = '#00d9ff', -- The primary color of the bench
        neutral = 'hsl(20, 14.3%, 4.1%)' -- The neutral color of the bench
    },
    hideUnavailableRecipes = false, -- Hide the recipes that the player can't craft
    filterMissingBlueprintRecipes = false, -- Filter out the recipes that the player doesn't have the blueprint for
    blueprintDurability = { -- Only works if enableBlueprintItems and removeBlueprintOnCraft is enabled
        isEnabled = false, -- Enable or disable blueprint durability
        defaultUses = 5 -- The default uses of the blueprint
    },
    adminBenchAccess = true, -- Allow admins to use all benches
    kickPlayerOnDamage = true, -- Kick the player from the bench if they take damage
    blueprintStrictMode = false, -- The player must have a blueprint for every item they want to craft. (only works if enableBlueprintItems is enabled)
    pauseCraftingOnExit = false, -- Pause the crafting process when the player exits the bench
    pauseCraftingOnDisconnect = true, -- Pause the crafting process when the player disconnects from the server
    disableLevelSystem = false, -- Disable the levels for the bench
    queueLimit = 0, -- Maximum number of crafts a player can have in queue at the same time (0 = unlimited)
    maxCraftAmount = 0, -- Maximum number of items that can be crafted in a single craft operation (0 = unlimited)
}

--[[
    Translation - The translation file that the script will use. See what translations are available in the 'translations' folder.

    See the documentation for more information on how to add own translation.
]]
Translation = 'en-US'

--[[
    Default Keybinds

    The keybinds can be changed in the game settings.
]]
DefaultKeybinds = {
    ['interact'] = 'E', -- The key to interact with the bench
    ['pickup'] = 'G', -- The key to pickup portable benches
    ['exit'] = 'ESCAPE', -- The key to exit the bench
}

--[[
    Discord Logs

    This will log the crafting actions to a discord webhook.
]]
DiscordLogs = {
    enabled = false, -- Enable or disable the discord logs
    webhookUrl = 'https://discord.com/api/webhooks/1234567890/abcdefghijklmnopqrstuvwxyz', -- The webhook for the discord logs
}

EnableOXLibLogger = false -- Enable the ox_lib Logger.
Command = 'crafting' -- The prefix command for all sub-commands.
Debug = 'no' -- yes or no. If yes, it will print out debug messages in the console.

--[[
    Framework - The framework that the script will use. See what frameworks are available in the 'frameworks' folder.

    auto: This will automatically detect the framework.
]]
Framework = 'auto'

--[[
    Database Resource - The resource that the script will use to get the database.
    Supported resources: 'auto', 'local', 'oxmysql'

    local: This is used for storing the data inside the script itself.
    auto: This will automatically detect the database resource.
]]
DatabaseResource = 'auto'

--[[
    Inventory Resource - The resource that the script will use to handle the inventory.
    Supported resources: 'auto', 'codem-inventory', 'ox_inventory', 'ps-inventory', 'qb-inventory', 'qs-inventory', 'tgiann-inventory'

    auto: This will automatically detect the database resource.
]]
Inventory = 'auto'
