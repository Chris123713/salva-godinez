----
-- NOTICE: This inventory integration is provided as-is.
-- TeamsGG does not provide official support for this integration.
----

if Config.Inventory ~= "qs-inventory" then return end

---@param item { info: { cardNumber: string } }
---@return string|nil
function GetCardNumberFromItem(item)
    return item?.info?.cardNumber or nil
end

---@return { cardId: string, cardNumber: string, displayName: string, expirationDate: string, slot: number }[]
function GetCardItems()
    local items = {}

    local allowed = {}
    for _, name in ipairs(Config.CardItems) do
        allowed[name] = true
    end

    local inventory = exports['qs-inventory']:getUserInventory()
    if type(inventory) ~= 'table' then return items end

    for _, itemData in pairs(inventory) do
        local name = itemData and itemData.name
        if name and allowed[name] then
            local info = itemData.info or {}
            items[#items + 1] = {
                cardId = info.cardId,
                cardNumber = info.cardNumber,
                displayName = info.displayName,
                expirationDate = info.expirationDate,
                slot = itemData.slot or info.slot
            }
        end
    end

    return items
end

RegisterNetEvent('banking:use-card-on-atm', function(cardItem)
    UseCardOnAtm(cardItem)
end)
