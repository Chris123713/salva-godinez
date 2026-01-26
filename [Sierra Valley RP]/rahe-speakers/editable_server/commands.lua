local function registerSpeakersMenuCommand()
    RegisterCommand('speakers', function(playerId, args)
        -- If the creation method is command, we check if user has speaker permissions before allowing the menu
        if svConfig.creationMethod == 'command' and not hasSpeakerPermissions(playerId) then
            notifyPlayer(playerId, locale('You don\'t have the necessary permissions.'), 'error')
            return
        end

        -- If the creation method is inventory, we check if user has admin permissions before allowing the menu
        if svConfig.creationMethod == 'inventory' and not hasAdminPermissions(playerId) then
            notifyPlayer(playerId, locale('You don\'t have the necessary permissions.'), 'error')
            return
        end

        openSpeakersMenu(playerId)
    end)
end

local function registerSpeakerTypesMenuCommand()
    RegisterCommand('speakertypes', function(playerId, args)
        if not hasAdminPermissions(playerId) then
            return notifyPlayer(playerId, locale('You don\'t have the necessary permissions.'), 'error')
        end

        openSpeakerTypesMenu(playerId)
    end)
end

local function registerSpeakerGroupMenuCommand()
    RegisterCommand('speakergroup', function(playerId, args)
        if not hasSpeakerPermissions(playerId) then
            return notifyPlayer(playerId, locale('You don\'t have the necessary permissions.'), 'error')
        end
    
        openSpeakerGroupMenu(playerId)
    end)
end

local function registerSafetyPreferenceCommand()
    local safetyPreferenceOptions = {
        {value = 'all', label = locale('Play everything')},
        {value = 'dmca', label = locale('Play only DMCA safe music')},
        {value = 'nothing', label = locale('Play nothing')},
    }

    local safetyPreferenceLabelMap = {}

    for k, v in pairs(safetyPreferenceOptions) do
        safetyPreferenceLabelMap[v.value] = v.label
    end

    RegisterCommand('safetypreference', function(playerId, args)
        local activePreference = exports['rahe-speakers']:getSafetyPreference(playerId) or 'all'

        local newPreferenceData = lib.callback.await('rahe-speakers:client:getSafetyPreference', playerId, safetyPreferenceOptions, activePreference)

        if not newPreferenceData then
            notifyPlayer(playerId, locale('Change cancelled.   \n  Safety preference remains \'%s\'.', safetyPreferenceLabelMap[activePreference]))
            return 
        end

        local newPreference = newPreferenceData[1]

        local success = exports['rahe-speakers']:setSafetyPreference(playerId, newPreference)

        if not success then
            notifyPlayer(playerId, locale('Failed to update safety preference.'))
            return 
        end

        notifyPlayer(playerId, locale('Safety preference updated to \'%s\'.', safetyPreferenceLabelMap[newPreference]))
    end)
end

local function registerChatCommands()
    if svConfig.enableSpeakersMenu then
        registerSpeakersMenuCommand()
    end

    if svConfig.enableSpeakerTypesMenu then
        registerSpeakerTypesMenuCommand()
    end

    if svConfig.enableSpeakerGroupMenu then
        registerSpeakerGroupMenuCommand()
    end

    if svConfig.enableSafetyPreference then
        registerSafetyPreferenceCommand()
    end
end

CreateThread(function()
    registerChatCommands()
end)