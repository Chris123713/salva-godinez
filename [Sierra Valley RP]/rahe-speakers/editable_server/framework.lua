
framework = nil
local frameworkObject
local detectedInventory

local supportedFrameworks = {
    ESX = {
        resourceName = 'es_extended',
        loadFramework = function()
            frameworkObject = exports['es_extended']:getSharedObject()
        end,
        prepareInventory = function()
            if detectedInventory == 'ox_inventory' then
                return
            end

            initiateSpeakerTypes()

            local speakerTypes = MySQL.query.await('SELECT id, label, item_id FROM ra_speaker_types WHERE item_id IS NOT NULL')

            for k, v in pairs(speakerTypes) do
                MySQL.query.await('INSERT INTO items (`name`, `label`) VALUES (?, ?) ON DUPLICATE KEY UPDATE label = VALUES(label)', {v.item_id, v.label})

                frameworkObject.RegisterUsableItem(v.item_id, function(source, item)
                    TriggerEvent('rahe-speakers:server:itemUsedById', source, v.item_id)
                end)
            end
        end,
        giveItem = function(playerId, itemId, amount, metadata)
            if detectedInventory == 'ox_inventory' then
                return exports.ox_inventory:AddItem(playerId, itemId, amount, metadata)
            end

            local xPlayer = frameworkObject.GetPlayerFromId(playerId)
            if xPlayer then
                return xPlayer.addInventoryItem(itemId, amount, metadata)
            end
        end,
        removeItem = function(playerId, itemId, amount, slot)
            if detectedInventory == 'ox_inventory' then
                return exports.ox_inventory:RemoveItem(playerId, itemId, amount, nil, slot)
            end

            local xPlayer = frameworkObject.GetPlayerFromId(playerId)
            if xPlayer then
                xPlayer.removeInventoryItem(itemId, amount)
                return true
            end
        end,
        getCash = function(playerId)
            local xPlayer = frameworkObject.GetPlayerFromId(playerId)
            if xPlayer then
                return xPlayer.getMoney()
            end
        end,
        removeCash = function(playerId, amount)
            local xPlayer = frameworkObject.GetPlayerFromId(playerId)
            if xPlayer then
                xPlayer.removeMoney(amount)
                return true
            end
        end,
        getIdentifier = function(playerId)
            local xPlayer = frameworkObject.GetPlayerFromId(playerId)
            if xPlayer then
                return tostring(xPlayer.identifier)
            end
        end,
        getVehicleIdentifier = function(vehicleEntityId)
            -- This is only used when you set 'vehicleSaving' to true. If you don't plan on using 'vehicleSaving', you can leave this as it is.
            -- This function should return a unique identifier for your vehicle. It can be a license plate, VIN code, or any other unique ID depending on your garage resource.
            return GetVehicleNumberPlateText(vehicleEntityId)
        end,
        getLoggingText = function(playerId, identifier)
            local xPlayer = frameworkObject.GetPlayerFromId(playerId)
            if xPlayer then
                return ('%s %s (identifier: %s) (serverId: %s)'):format(xPlayer.get('firstName'), xPlayer.get('lastName'), identifier, playerId)
            end
        end,
    },
    QB = {
        resourceName = 'qb-core',
        addedItems = {},
        loadFramework = function()
            frameworkObject = exports['qb-core']:GetCoreObject()
        end,
        prepareInventory = function()
            if detectedInventory == 'ox_inventory' then
                return
            end

            initiateSpeakerTypes()

            local itemsToAdd = {}
            local speakerTypes = MySQL.query.await('SELECT id, label, description, item_id FROM ra_speaker_types WHERE item_id IS NOT NULL')

            local function formatQBItem(itemId, label, description)
                return {name = itemId, label = label, weight = 1000, type = 'item', image = ('%s.png'):format(itemId), unique = true, useable = true, shouldClose = true, description = description}
            end

            for k, v in pairs(speakerTypes) do
                itemsToAdd[v.item_id] = formatQBItem(v.item_id, v.label, v.description)
                table.insert(framework.addedItems, {typeId = v.id, itemId = v.item_id})
            end

            local success, message, failedItem = frameworkObject.Functions.AddItems(itemsToAdd)

            if not success then
                print(("[^1ERROR^7] Failed to add items to inventory. Failed on item: %s. Failure message: %s."):format(failedItem and failedItem.name or '-', message))
            end

            for _, v in pairs(framework.addedItems) do
                frameworkObject.Functions.CreateUseableItem(v.itemId, function(source, item)
                    TriggerEvent('rahe-speakers:server:speakerItemUsed', source, v.typeId, item.slot)
                end)
            end

            AddEventHandler('rahe-speakers:server:speakerTypeUpdated', function(speakerType)
                if not speakerType.itemId then
                    print(("[^1ERROR^7] A speakerType was updated and itemId was set to nil. Errors will occur when speakerType %s is used."):format(speakerType.id))
                    return
                end

                local success, message = frameworkObject.Functions.UpdateItem(speakerType.itemId, formatQBItem(speakerType.itemId, speakerType.label, speakerType.description))

                if not success then
                    print(("[^1ERROR^7] Failed to update inventory item after speakerType was updated. Failed on item: %s. Failure message: %s."):format(speakerType.itemId, message))
                end

                frameworkObject.Functions.CreateUseableItem(speakerType.itemId, function(source, item)
                    TriggerEvent('rahe-speakers:server:speakerItemUsed', source, speakerType.id, item.slot)
                end)
            end)

            AddEventHandler('rahe-speakers:server:speakerTypeCreated', function(speakerType)
                if not speakerType.itemId then
                    print(("[^1ERROR^7] New speakerType was created without itemId. Not creating item for speakerType %s."):format(speakerType.id))
                    return
                end

                local success, message = frameworkObject.Functions.AddItem(speakerType.itemId, formatQBItem(speakerType.itemId, speakerType.label, speakerType.description))

                if not success then
                    print(("[^1ERROR^7] Failed to add item to inventory after speakerType was created. Failed on item: %s. Failure message: %s."):format(speakerType.itemId, message))
                end

                frameworkObject.Functions.CreateUseableItem(speakerType.itemId, function(source, item)
                    TriggerEvent('rahe-speakers:server:speakerItemUsed', source, speakerType.id, item.slot)
                end)
            end)
        end,
        giveItem = function(playerId, itemId, amount, metadata)
            if detectedInventory == 'ox_inventory' then
                return exports.ox_inventory:AddItem(playerId, itemId, amount, metadata)
            end

            return exports['qb-inventory']:AddItem(playerId, itemId, amount, false, metadata, 'rahe-speakers')
        end,
        removeItem = function(playerId, itemId, amount, slot)
            if detectedInventory == 'ox_inventory' then
                return exports.ox_inventory:RemoveItem(playerId, itemId, amount, nil, slot)
            end

            return exports['qb-inventory']:RemoveItem(playerId, itemId, amount, slot)
        end,
        getCash = function(playerId)
            local Player = frameworkObject.Functions.GetPlayer(playerId)
            if Player then
                return Player.Functions.GetMoney('cash')
            end
        end,
        removeCash = function(playerId, amount)
            local Player = frameworkObject.Functions.GetPlayer(playerId)
            if Player then
                Player.Functions.RemoveMoney('cash', amount)
                return true
            end
        end,
        getIdentifier = function(playerId)
            local Player = frameworkObject.Functions.GetPlayer(playerId)
            if Player then
                return tostring(Player.PlayerData.citizenid)
            end
        end,
        getVehicleIdentifier = function(vehicleEntityId)
            -- This is only used when you set 'vehicleSaving' to true. If you don't plan on using 'vehicleSaving', you can leave this as it is.
            -- This function should return a unique identifier for your vehicle. It can be a license plate, VIN code, or any other unique ID depending on your garage resource.
            return GetVehicleNumberPlateText(vehicleEntityId)
        end,
        getLoggingText = function(playerId, identifier)
            local Player = frameworkObject.Functions.GetPlayer(playerId)
            if Player then
                local charinfo = Player.PlayerData.charinfo
                return ('%s %s (identifier: %s) (serverId: %s)'):format(charinfo.firstname, charinfo.lastname, identifier, playerId)
            end
        end,
    },
    CUSTOM = {
        resourceName = '',
        loadFramework = function()
            -- This should be used and filled in when using a framework other than ESX/QB (if your framework has this).
            -- This function should load your framework's core object into the 'frameworkObject' variable, like ESX and QB are doing.
        end,
        prepareInventory = function()
            -- This should be used and filled in when you are using the tablet as an inventory item, and the item can be registered as usable in our resource.
            -- You should trigger an event rahe-speakers:server:speakerItemUsed with the player's source, metadata.typeId, item.slot, like so:
            -- TriggerEvent('rahe-speakers:server:speakerItemUsed', source, item.metadata.typeId, item.slot)
            -- This event uses function speakerItemUsed(playerId, speakerTypeId, slot) which is editable in editable/server/functions.lua
        end,
        giveItem = function(playerId, itemId, amount, metadata)
            if detectedInventory == 'ox_inventory' then
                return exports.ox_inventory:AddItem(playerId, itemId, amount, metadata)
            end

            -- Fill out for custom framework
        end,
        removeItem = function(playerId, itemId, amount, slot)
            if detectedInventory == 'ox_inventory' then
                return exports.ox_inventory:RemoveItem(playerId, itemId, amount, nil, slot)
            end

            -- Fill out for custom framework
        end,
        getCash = function(playerId)
            -- Fill out for custom framework
        end,
        removeCash = function(playerId, amount)
            -- Fill out for custom framework
        end,
        getIdentifier = function(playerId)
            -- Fill out for custom framework
            return playerId
        end,
        getVehicleIdentifier = function(vehicleEntityId)
            -- This is only used when you set 'vehicleSaving' to true. If you don't plan on using 'vehicleSaving', you can leave this as it is.
            -- This function should return a unique identifier for your vehicle. It can be a license plate, VIN code, or any other unique ID depending on your garage resource.
            return GetVehicleNumberPlateText(vehicleEntityId)
        end,
        getLoggingText = function(playerId, identifier)
            return ('%s (identifier: %s)'):format(playerId, identifier)
        end,
    }
}

if not supportedFrameworks[shConfig.framework] and shConfig.framework ~= 'AUTO' then
    print("[^1ERROR^7] Invalid framework used in ^4editable_shared/config.lua^7 - please choose a supported value (AUTO / ESX / QB / CUSTOM).")
end

CreateThread(function()
    if GetResourceState('ox_inventory') == 'started' then
        detectedInventory = 'ox_inventory'
    elseif GetResourceState('qb-inventory') == 'started' then
        detectedInventory = 'qb-inventory'
    end

    local detectedFramework
    if shConfig.framework == 'AUTO' then
        if GetResourceState(supportedFrameworks.ESX.resourceName) ~= 'missing' then
            detectedFramework = 'ESX'
        elseif GetResourceState(supportedFrameworks.QB.resourceName) ~= 'missing' then
            detectedFramework = 'QB'
        end

        if not detectedFramework then
            print("[^1ERROR^7] Framework in ^4editable_shared/config.lua^7 is set to ^4AUTO^7 but couldn't detect ESX or QB. Please follow documentation for other frameworks.")
            return
        end

        shConfig.framework = detectedFramework
    end

    framework = supportedFrameworks[shConfig.framework]
    if framework.resourceName ~= '' and GetResourceState(framework.resourceName) ~= 'started' then
        lib.waitFor(function()
            return GetResourceState(framework.resourceName) == 'started'
        end, ('Framework wasn\'t started in time (%s)!'):format(framework.resourceName), 60 * 1000)
    end

    framework.loadFramework()
    if svConfig.creationMethod == 'inventory' then
        framework.prepareInventory()
    end
end)

---------------------------------------- IMPORTANT ----------------------------------------
---- THE FUNCTIONS BELOW ARE WRAPPERS AROUND SOME FRAMEWORK FUNCTIONS FOR MORE FLEXIBILITY
---- THEY ARE MEANT FOR FURTHER CUSTOMIZATION OR EXTRA BUSINESS LOGIC
---- FOR BASIC SETUP YOU SHOULD NOT CHANGE THESE

---- INVENTORY RELATED FUNCTIONS
---- IN HERE YOU CAN CHANGE HOW YOUR ITEM METADATA WILL BE FORMATTED WHEN USING ONE ITEM FOR ALL SPEAKERS
function getItemDataForSpeakerType(speakerType)
    if svConfig.creationMethod ~= 'inventory' then
        return
    end

    local itemId = speakerType.itemId
    local metadata = {}

    if detectedInventory == 'ox_inventory' then
        itemId = svConfig.inventoryItemId

        metadata = {
            typeId = speakerType.id,
            label = speakerType.title,
            description = speakerType.description,
            imageurl = speakerType.image,
        }
    elseif detectedInventory == 'idk_inventory' then

    else
        -- TODO FILL
    end

    return itemId, metadata
end

---- DISCORD LOGGING RELATED FUNCTIONS
local loggingTextCache = {}

function getPlayerLoggingText(playerId)
    local identifier = framework.getIdentifier(playerId)

    if not loggingTextCache[identifier] then
        loggingTextCache[identifier] = framework.getLoggingText(playerId, identifier)
    end

    return loggingTextCache[identifier] or ('(identifier: %s) (serverId: %s)'):format(identifier, playerId)
end

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    if shConfig.framework ~= 'QB' then
        return
    end

    for k, v in pairs(framework.addedItems) do
        frameworkObject.Functions.RemoveItem(v.itemId)
    end
end)