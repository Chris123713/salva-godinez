lib.versionCheck('edwardexo/rahe-speakers-version')

function notifyPlayer(playerId, message, type)
    TriggerClientEvent('rahe-speakers:client:notify', playerId, message, type)
end

function hasAdminPermissions(playerId)
    return IsPlayerAceAllowed(playerId, 'speakers.admin')
end

function hasSpeakerPermissions(playerId)
    return true
end

-- This determines if player can mark speakers as permanent
function hasPermanentPermissions(playerId)
    return true
end

-- Determines if a player can attach speakers to a vehicle
-- Can be useful if you want only certain players to be able to attach speakers to vehicles (ex mechanic roleplay)
function canAttachSpeakerToVehicle(playerId, speakerTypeId)
    return true
end

-- Determines if a player can detach speakers from vehicles
-- Can be useful if you want only certain players to be able to detach speakers from vehicles (ex mechanic roleplay)
function canDetachSpeakerFromVehicle(playerId, speakerTypeId)
    return true
end

function getPlayerAllowedSpeakerCount(playerId)
    return svConfig.speakersAllowedPerPlayer
end

function speakerItemUsed(playerId, speakerTypeId, slot)
    local speakerType = getSpeakerTypeById(speakerTypeId)

    if not speakerType then
        return
    end

    if not createSpeaker(playerId, speakerType) then
        return
    end

    local itemId, _ = getItemDataForSpeakerType(speakerType)

    framework.removeItem(playerId, itemId, 1, slot)
end
AddEventHandler('rahe-speakers:server:itemUsedBySlot', speakerItemUsed)
AddEventHandler('rahe-speakers:server:speakerItemUsed', speakerItemUsed)

AddEventHandler('rahe-speakers:server:itemUsedById', function(playerId, itemId)
    local speakerType = getSpeakerTypeByItemId(itemId)

    if not speakerType then
        return
    end

    if not createSpeaker(playerId, speakerType) then
        return
    end

    framework.removeItem(playerId, itemId, 1)
end)
