shConfig = {
    -- Set the framework that you're using. Possible values: 'AUTO', 'ESX', 'QB', 'CUSTOM'
    -- When using the 'AUTO' value, the system will automatically detect if you are running QB or ESX.
    -- When using the 'CUSTOM' value, you will have to fill the functions yourself in /editable_server/framework.lua.
    framework = 'AUTO',

    -- If you want to use targeting to interact with speakers. Possible values: true, false
    -- We support following targeting resources: ox_target, qb-target, qtarget.
    useTargeting = true,

    -- Default keybind configurations. User-configurable via FiveM keybind settings.
    -- NOTE: Changing this will not change the key for existing players.
    -- Certain keys may not be used when useTargeting is enabled.
    -- For comprehensive documentation, refer to https://overextended.dev/ox_lib/Modules/AddKeybind/Client
    interactDefaultKey = 'E',
    dropSpeakerDefaultKey = 'C',
    attachSpeakerDefaultKey = 'G',
    detachSpeakerDefaultKey = 'G',
    interactVehicleDefaultKey = 'E',
    shopDefaultKey = 'E',
}