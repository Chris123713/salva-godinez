if not Config.LBPhone or Config.Item.Inventory ~= "qb-inventory" then
    return
end

---@param source number
---@return table
local function GetPhonesInInventory(source)
    local phoneConfig = GetPhoneConfig()
    local phones = {}
    local items = QB.Functions.GetPlayer(source).PlayerData.items

    ---@type { [string]: boolean }
    local phoneItemNames = {}

    if phoneConfig.Item.Name then
        phoneItemNames[phoneConfig.Item.Name] = true
    end

    if phoneConfig.Item.Names then
        for i = 1, #phoneConfig.Item.Names do
            phoneItemNames[phoneConfig.Item.Names[i].name] = true
        end
    end

    for _, item in pairs(items) do
        if phoneItemNames[item.name] then
            phones[#phones+1] = item
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

    debugprint(items)

    for i = 1, #items do
        local item = items[i]

        if item and item.info and item.info.lbPhoneNumber then
            phones[#phones+1] = {
                phoneNumber = item.info.lbPhoneNumber,
                phoneName = item.info.lbPhoneName
            }
        end
    end

    debugprint("???", phones)

    return phones
end

---@param source number
---@param phoneNumber string
---@return boolean
function HasPhone(source, phoneNumber)
    local items = GetPhonesInInventory(source)

    for i = 1, #items do
        local item = items[i]

        if item and item.info and item.info.lbPhoneNumber == phoneNumber then
            return true
        end
    end

    return false
end
