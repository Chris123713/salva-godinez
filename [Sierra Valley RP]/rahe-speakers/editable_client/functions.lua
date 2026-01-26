local notifcationIcons = {
    error = 'ban',
    success = 'check',
}

local notifcationColors = {
    error = '#C53030',
    success = '#019430',
}

function ucfirst(str)
    return (str:gsub("^%l", string.upper))
end

function notifyPlayer(message, type)
    if not type then
        type = 'info'
    end

    lib.notify({
        title = ('%s!'):format(ucfirst(type)),
        description = message,
        type = type,
        icon = notifcationIcons[type],
        iconColor  = notifcationColors[type],
    })
end
RegisterNetEvent('rahe-speakers:client:notify', notifyPlayer)

function showTextUI(message, displayData)
    lib.showTextUI(message, displayData)
end

function hideTextUI()
    lib.hideTextUI()
end

lib.callback.register('rahe-speakers:client:getSafetyPreference', function(safetyPreferenceOptions, activePreference)
    return lib.inputDialog(locale('Safety preference'), {
        {type = 'select', label = locale('Safety preference'), options = safetyPreferenceOptions, default = activePreference, required = true},
    })
end)