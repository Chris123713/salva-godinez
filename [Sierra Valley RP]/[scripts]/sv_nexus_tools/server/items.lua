-- Item Tools (ox_inventory integration)

local Items = {}

-- Award item to player
function Items.AwardItem(source, item, count, metadata)
    count = count or 1

    local success = exports.ox_inventory:AddItem(source, item, count, metadata)

    if success then
        Utils.Debug('Awarded', count, 'x', item, 'to', source)

        -- Send phone notification
        pcall(function()
            exports['sv_nexus_tools']:SendPhoneNotification(source, {
                title = 'Item Received',
                message = ('Received %dx %s'):format(count, item),
                icon = 'fas fa-box'
            })
        end)

        return {success = true}
    end

    return {success = false, error = 'Failed to add item'}
end

-- Remove item from player
function Items.RemoveItem(source, item, count)
    count = count or 1

    -- Check if player has enough
    local itemCount = exports.ox_inventory:Search(source, 'count', item)
    if type(itemCount) == 'table' then
        -- Sum up all stacks
        local total = 0
        for _, c in pairs(itemCount) do
            total = total + c
        end
        itemCount = total
    end

    if (itemCount or 0) < count then
        return {success = false, error = 'Insufficient items'}
    end

    local success = exports.ox_inventory:RemoveItem(source, item, count)

    if success then
        Utils.Debug('Removed', count, 'x', item, 'from', source)
        return {success = true}
    end

    return {success = false, error = 'Failed to remove item'}
end

-- Check if player has item
function Items.CheckItem(source, item, minCount)
    minCount = minCount or 1

    local itemCount = exports.ox_inventory:Search(source, 'count', item)
    if type(itemCount) == 'table' then
        local total = 0
        for _, c in pairs(itemCount) do
            total = total + c
        end
        itemCount = total
    end

    itemCount = itemCount or 0

    return {
        hasItem = itemCount >= minCount,
        count = itemCount
    }
end

-- Register item tools
RegisterTool('award_item', {
    params = {'source', 'item', 'count', 'metadata'},
    handler = function(params)
        return Items.AwardItem(
            params.source,
            params.item,
            params.count,
            params.metadata
        )
    end
})

RegisterTool('remove_item', {
    params = {'source', 'item', 'count'},
    handler = function(params)
        return Items.RemoveItem(
            params.source,
            params.item,
            params.count
        )
    end
})

RegisterTool('check_item', {
    params = {'source', 'item', 'minCount'},
    handler = function(params)
        return Items.CheckItem(
            params.source,
            params.item,
            params.minCount
        )
    end
})

-- Exports
exports('AwardItem', Items.AwardItem)
exports('RemoveItem', Items.RemoveItem)
exports('CheckItem', Items.CheckItem)

return Items
