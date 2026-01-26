RegisterNetEvent('rahe-speakers:server:openSpeakerShop', function()
    local playerId = source

    local shopSpeakerTypes = MySQL.query.await('SELECT id, label, description, image, price, max_volume as maxVolume, max_range as maxRange FROM ra_speaker_types WHERE in_shop = 1 AND price IS NOT NULL')

    local totalMaxRange, totalMaxVolume = getMaxRangeVolume()

    TriggerClientEvent('rahe-speakers:client:openSpeakerShop', playerId, shopSpeakerTypes, totalMaxRange, totalMaxVolume)
end)

RegisterNetEvent('rahe-speakers:server:purchaseSpeaker', function(speakerTypeId)
    local playerId = source

    local speakerType = getSpeakerTypeById(speakerTypeId)

    if not speakerType or not speakerType.inShop or not speakerType.price then
        return
    end

    local itemId, metadata = getItemDataForSpeakerType(speakerType)

    if not itemId then
        notifyPlayer(playerId, locale('Something went wrong. Try again later.'), 'error')
        print(("[^1ERROR^7] Failed to get itemId for speaker %s."):format(speakerType.id))
        return
    end

    if speakerType.price > framework.getCash(playerId) then
        notifyPlayer(playerId, locale('You don\'t have enough cash.'), 'error')
        return
    end

    if not framework.removeCash(playerId, speakerType.price) then
        notifyPlayer(playerId, locale('We couldn\'t remove cash from you.'), 'error')
        return
    end

    framework.giveItem(playerId, itemId, 1, metadata)
end)
