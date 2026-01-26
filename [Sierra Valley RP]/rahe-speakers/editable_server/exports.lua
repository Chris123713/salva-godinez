-- EXAMPLE USAGE
-- local availableCastPoints = exports['rahe-speakers']:getAvailableCastPoints(playerId)
-- print(json.encode(availableCastPoints, {indent = true}))
exports('getAvailableCastPoints', getAvailableCastPoints)

-- EXAMPLE USAGE
-- MAKE SURE TO VALIDATE YOUTUBE URLS BEFORE USING THIS!
-- exports['rahe-speakers']:castToSpeaker(playerId, speakerId, {
--     {url = 'https://www.youtube.com/watch?v=ZCKpzP5SGYw', title = 'Testing title 1'},
--     {url = 'https://www.youtube.com/watch?v=gWju37TZfo0', title = 'Testing title 2'},
--     {url = 'https://www.youtube.com/watch?v=qtD1IpH5a5Q', title = 'Testing title 3'},
-- })
exports('castToSpeaker', castToSpeaker)

-- EXAMPLE USAGE
-- MAKE SURE TO VALIDATE YOUTUBE URLS BEFORE USING THIS!
-- exports['rahe-speakers']:castToSpeakerGroup(playerId, groupId, {
--     {url = 'https://www.youtube.com/watch?v=ZCKpzP5SGYw', title = 'Testing title 1'},
--     {url = 'https://www.youtube.com/watch?v=gWju37TZfo0', title = 'Testing title 2'},
--     {url = 'https://www.youtube.com/watch?v=qtD1IpH5a5Q', title = 'Testing title 3'},
-- })
exports('castToSpeakerGroup', castToSpeakerGroup)

-- EXAMPLE USAGE
-- local result = exports['rahe-speakers']:stopCastingToSpeaker(playerId, speakerId)
exports('stopCastingToSpeaker', stopCastingToSpeaker)

-- EXAMPLE USAGE
-- local result = exports['rahe-speakers']:stopCastingToSpeakerGroup(playerId, groupId)
exports('stopCastingToSpeakerGroup', stopCastingToSpeakerGroup)

-- EXAMPLE USAGE
-- local paused = true
-- local result = exports['rahe-speakers']:setSpeakerPaused(playerId, speakerId, paused)
exports('setSpeakerPaused', setSpeakerPaused)

-- EXAMPLE USAGE
-- local paused = true
-- local result = exports['rahe-speakers']:setSpeakerGroupPaused(playerId, groupId, paused)
exports('setSpeakerGroupPaused', setSpeakerGroupPaused)

-- EXAMPLE USAGE
-- local newVolume = 0.5
-- local result = exports['rahe-speakers']:setSpeakerVolume(playerId, speakerId, newVolume)
exports('setSpeakerVolume', setSpeakerVolume)

-- EXAMPLE USAGE
-- local newVolume = 0.5
-- local result = exports['rahe-speakers']:setSpeakerGroupVolume(playerId, groupId, newVolume)
exports('setSpeakerGroupVolume', setSpeakerGroupVolume)

-- EXAMPLE USAGE
-- local newPreference = 'dmca'
-- local success = exports['rahe-speakers']:setSafetyPreference(playerId, newPreference)
exports('setSafetyPreference', setSafetyPreference)

-- EXAMPLE USAGE
-- local safetyPreference = exports['rahe-speakers']:getSafetyPreference(playerId)
-- print('safetyPreference', safetyPreference)
exports('getSafetyPreference', getSafetyPreference)

-- OX INVENTORY EXAMPLE
exports('speaker', function(event, item, inventory, slot, data)
    if event ~= 'usingItem' then
        return
    end

    local itemSlot = exports.ox_inventory:GetSlot(inventory.id, slot)

    if itemSlot.name ~= svConfig.inventoryItemId then
        return
    end

    local metadata = itemSlot.metadata

    if not metadata or not metadata.typeId then
        notifyPlayer(inventory.id, locale('This speaker has invalid metadata 1. Contact your developer.'), 'error')
        return
    end

    local speakerType = getSpeakerTypeById(metadata.typeId)

    if not speakerType then
        notifyPlayer(inventory.id, locale('This speaker has invalid metadata 2. Contact your developer.'), 'error')
        return
    end

    if not createSpeaker(inventory.id, speakerType) then
        return
    end

    framework.removeItem(inventory.id, svConfig.inventoryItemId, 1, slot)
end)

AddEventHandler('rahe-speakers:server:startupDone', function()
    if GetResourceState('ox_inventory') ~= 'started' then
        return
    end

    if svConfig.creationMethod ~= 'inventory' then
        return
    end

    local firstSpeakerType = MySQL.single.await('SELECT id, label, description, image FROM ra_speaker_types')

    if not firstSpeakerType then
        return
    end

    local hookId = exports.ox_inventory:registerHook('createItem', function(payload)
        if not payload.metadata or not payload.metadata.typeId then
            payload.metadata.typeId = firstSpeakerType.id
            payload.metadata.label = firstSpeakerType.label
            payload.metadata.description = firstSpeakerType.description
            payload.metadata.imageurl = firstSpeakerType.image
        end

        return payload.metadata
    end, {
        itemFilter = {
            [svConfig.inventoryItemId] = true,
        }
    })
end)