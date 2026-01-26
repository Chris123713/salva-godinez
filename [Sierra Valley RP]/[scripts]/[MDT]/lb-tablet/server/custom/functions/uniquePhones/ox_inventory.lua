if not Config.LBPhone or Config.Item.Inventory ~= "ox_inventory" then
    return
end

---@param source number
---@return table
local function GetPhonesInInventory(source)
    local phoneConfig = GetPhoneConfig()

    if phoneConfig.Item.Name then
        return exports.ox_inventory:Search(source, "slots", phoneConfig.Item.Name) or {}
    end

    local phones = {}

    for i = 1, #phoneConfig.Item.Names do
        local items = exports.ox_inventory:Search(source, "slots", phoneConfig.Item.Names[i].name) or {}

        for _, phone in pairs(items) do
            phones[#phones+1] = phone
        end
    end

    return phones
end

---@param source number
---@return { phoneNumber: string, phoneName?: string }[]
function GetPhones(source)
    local phones = {}
    local items = GetPhonesInInventory(source)

    if not items or #items == 0 then
        return phones
    end

    for i = 1, #items do
        local item = items[i]

        if item and item.metadata and item.metadata.lbPhoneNumber then
            phones[#phones+1] = {
                phoneNumber = item.metadata.lbPhoneNumber,
                phoneName = item.metadata.lbPhoneName
            }
        end
    end

    return phones
end

---@param source number
---@param phoneNumber string
---@return boolean
function HasPhone(source, phoneNumber)
    local phones = GetPhonesInInventory(source)

    for i = 1, #phones do
        local item = phones[i]

        if item and item.metadata and item.metadata.lbPhoneNumber == phoneNumber then
            return true
        end
    end

    return false
end
