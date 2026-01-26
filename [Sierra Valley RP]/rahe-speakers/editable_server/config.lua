svConfig = {
    -- Define the principal which will be given the ACE permission to pass the admin check.
    -- You may override or customize the admin permissions check however you want in /editable_server/functions.lua.
    -- In order for this to work, make sure you allow ox_lib to grant permissions (https://overextended.dev/ox_lib) ('You'll also need to grant ace permissions to the resource.')
    adminPrincipal = 'group.admin',

    -- How should the the speakers bt created. Possible values: 'command', 'inventory'
    -- When using the 'command' value, players can create speakers with command '/speakers'.
    -- When using the 'inventory' value, each speaker is created by an inventory item (name configurable below).
    creationMethod = 'inventory',

    -- What should the usable inventory item be called. (create this in your inventory system)
    -- Note that this is only necessary when using creationMethod 'inventory' and your inventory supports metadata
    -- See https://docs.rahe.dev/our-scripts/speakers/integration#id-1-speaker-creation for more info
    inventoryItemId = 'speaker',

    -- Set this to true if you want to save attached speakers on player owned vehicles and automatically recreate them on vehicle spawn.
    -- Possible values: true, false
    vehicleSaving = false,

    -- Restrict vehicle detachment to speaker owners only. Possible values: true, false
    -- This configuration option controls who can remove a speaker from a vehicle.
    -- When set to true, only the owner of the speaker and admins are allowed to detach it from a vehicle. When set to false, anyone can detach the speaker.
    onlyOwnerCanDetachFromVehicle = false,

    -- Determines whether speakers are public by default. Possible values: true, false
    speakersPublicByDefault = false,

    -- Determines whether speakers are permanent by default. Possible values: true, false
    speakersPermanentByDefault = false,

    -- Speaker shop
    shopEnabled = true,
    shopLocation = vector4(-42.53, -1039.37, 27.41, 23.18),
    shopPedModel = `s_m_y_shop_mask`,
    shopBlip = {
        enabled = true,
        sprite = 52,
        color = 2,
        scale = 0.75,
        text = 'Speaker shop',
    },

    -- How many active speakers do we allow per player by default.
    -- You may override or customize this in /editable_server/functions.lua (getPlayerAllowedSpeakerCount).
    speakersAllowedPerPlayer = 4,

    -- What should be the default volume for newly created speakers.
    defaultVolume = 0.3,

    -- What should be the default range for newly created speakers.
    defaultRange = 25.0,

    -- Enable or disable '/speakers' command.
    -- By default, this command is enabled for everyone when creationMethod is 'command'.
    -- If creationMethod is 'inventory' then this command will be only enabled for admins.
    -- You can also add your own custom logic for what players are authorized to use this command in /editable_server/commands.lua. 
    enableSpeakersMenu = true,

    -- Enable or disable '/speakertypes' command.
    -- You can also add your own custom logic for what players are authorized to use this command in /editable_server/commands.lua. 
    enableSpeakerTypesMenu = true,

    -- Enable or disable '/speakergroup' command.
    -- You can also add your own custom logic for what players are authorized to use this command in /editable_server/commands.lua. 
    enableSpeakerGroupMenu = true,

    -- Enable or disable '/safetypreference' command.
    -- It lets players choose what music they hear:
    --   1. All music
    --   2. Only music that's safe to stream (DMCA free)
    --   3. No music at all
    -- You can also add your own custom logic to this command in /editable_server/commands.lua. 
    enableSafetyPreference = true,

    -- If this is not defined, some functionality (for example - queues, music history, music names) won't work.
    -- You can look at out step-by-step tutorial how to obtain your own Youtube API key at our docs.
    -- https://docs.rahe.dev/our-scripts/speakers/integration#id-2-obtaining-youtube-api-key
    youtubeApiKey = '',

    -- Discord webhook where all speaker related actions will be logged
    logWebhook = '',

    -- What actions are logged to Discord
    logActions = {
        ['Speaker created'] = true,
        ['Speaker stored'] = true,
        ['Speaker picked up'] = true,
        ['Speaker placed down'] = true,
        ['Song played'] = true,
        ['Volume/range changed'] = true,
        ['Pause/resume clicked'] = true,
        ['Speaker attached to a vehicle'] = true,
        ['Speaker detached from a vehicle'] = true,
        ['Speaker group created'] = true,
        ['Speaker group accessed'] = true,
        ['Speaker connected to a group'] = true,
        ['Speaker disconnected from a group'] = true,
        ['Song played (group)'] = true,
        ['Pause/resume clicked (group)'] = true,
        ['Speaker created and attached to a vehicle'] = true,
    },
}

-- What filters types are available when creating new speaker types.
-- For each filter type you can change what parameters can be changed by players.
-- Please see https://developer.mozilla.org/en-US/docs/Web/API/BiquadFilterNode for more info.
svConfig.filters = {
    lowpass = {'frequency', 'quality', 'detune'},
    highpass = {'frequency', 'quality', 'detune'},
    bandpass = {'frequency', 'quality', 'detune'},
    lowshelf = {'frequency', 'gain', 'detune'},
    highshelf = {'frequency', 'gain', 'detune'},
    peaking = {'frequency', 'quality', 'gain', 'detune'},
    notch = {'frequency', 'quality', 'detune'},
    allpass = {'frequency', 'quality', 'detune'},
}

-- You can limit filter type parameters.
-- Please see https://developer.mozilla.org/en-US/docs/Web/API/BiquadFilterNode for more info.
svConfig.filterLimits = {
    frequency = {
        min = 10,
        max = 10000, 
        default = 350,
        units = 'Hz',
        step = 1,
    },
    quality = {
        min = 0.0001,
        max = 1000,
        default = 1,
        units = 'units',
        step = 0.1,
        precision = 2,
    },
    gain = {
        min = -40,
        max = 40,
        default = 0,
        units = 'dB',
        step = 0.1,
        precision = 1,
    },
    detune = {
        min = -4800,
        max = 4800,
        default = 0,
        units = 'cents',
        step = 1,
    },
}

-- If you're not sure what this does, leave it as is.
-- It's here if you need extra customization for your server.

-- These permissions are allowed for everyone on public speakers.
-- By default all actions are only allowed for speaker owner or admins.
-- If a speaker is public, these actions will be allowed for all players.
svConfig.publicSpeakerPermissions = {
    [PERMISSION_PLAY_MUSIC] = true,
    [PERMISSION_QUEUE] = true,
    [PERMISSION_PAUSE_RESUME] = true,
    [PERMISSION_VOLUME_RANGE] = true,
    [PERMISSION_ADD_GROUP] = true,
}

-- Here's a list of all permissions
-- If you want a certain action to be allowed on a public speaker, just add it to svConfig.publicSpeakerPermissions

--          PERMISSION_QUEUE
--          PERMISSION_CARRY
--          PERMISSION_STORE
--          PERMISSION_PUBLIC
--          PERMISSION_RENAME
--          PERMISSION_FILTERS
--          PERMISSION_SETTINGS
--          PERMISSION_PERMANENT
--          PERMISSION_ADD_GROUP
--          PERMISSION_PLAY_MUSIC
--          PERMISSION_PAUSE_RESUME
--          PERMISSION_VOLUME_RANGE
--          PERMISSION_VEHICLE_ATTACH
--          PERMISSION_GIZMO