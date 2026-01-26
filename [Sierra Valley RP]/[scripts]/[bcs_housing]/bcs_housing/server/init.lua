Homes = {}
local isLoading = true

function ReduceHomeProperties(home, key)
    local apts = {}
    if home.complex == 'Apartment' then
        for i = 1, #home.apartments do
            if home.apartments[i] then
                apts[i] = {
                    locked = home.apartments[i].locked,
                    apartment = home.apartments[i].apartment,
                    owner = home.apartments[i].owner,
                    plan = home.apartments[i].plan,
                    keys = home.apartments[i].keys
                }
            else
                print('^3[^0Debug^3] Apartment is nil', i, home.identifier, home.apartments[i])
            end
        end
    end
    return {
        key = key,
        identifier = home.identifier,
        apartments = apts,
        name = home.name,
        entry = home.entry,
        price = home.price,
        owner = home.owner,
        data = home.data,
        rent = home.rent,
        configuration = home.configuration,
        permission = home.permission,
        complex = home.complex,
        realestate = home.realestate,
        locked = home.locked,
        payment = home.payment,
        type = home.type,
        area = home.area,
        plan = home.plan,
        garages = home.garages,
        -- Might not be necessary
        doors = home.doors,
        keys = home.keys,
        teleports = home.teleports,
        thumbnail = home.thumbnail,
        disabled = home.disabled
    }
end

-- Initialize
CreateThread(function()
    InitDatabase()
    ConvertGarages()
    MySQL.rawExecute(Config.SQLQueries[Config.framework].DeleteNonExistingHouseChar)
    MySQL.rawExecute(Config.SQLQueries[Config.framework].DeleteNonExistingAptChar)

    local check = MySQL.query.await("SHOW COLUMNS FROM `house` LIKE 'configuration'")
    if check and next(check) then
        local houses = MySQL.query.await([[
SELECT *,
UNIX_TIMESTAMP(created_at) AS created_at,
UNIX_TIMESTAMP(bought_at) AS bought_at,
UNIX_TIMESTAMP(last_payment) AS last_payment,
UNIX_TIMESTAMP(lastLogin) AS lastLogin,
UNIX_TIMESTAMP(rented_at) AS rented_at,
COALESCE(h.identifier, ho.identifier) AS identifier,
COALESCE(h.price, hr.price) AS price,
h.data AS housedata, ho.data AS owneddata,
hr.price AS rent_price,
h.permission AS house_permission,
hr.permission AS rent_permission,
h.garages AS garages
FROM house h
LEFT JOIN house_owned ho ON h.identifier = ho.identifier
LEFT JOIN house_rent hr ON h.identifier = hr.identifier;
        ]], {})
        debugPrint('Initializing Houses')
        for k, v in pairs(houses) do
            if not v.name then
                print(string.format(
                    "^3[VALIDATION WARNING]: ^2Fixing %s house as it does not exists in the house table",
                    v.identifier))
                print(
                    "^3[VALIDATION WARNING]: ^1Do not delete a house from the database, delete using the command")
                MySQL.query("DELETE FROM house_owned WHERE identifier = ?",
                    { v.identifier })
                goto continue
            end
            v.data = json.decode(v.housedata)
            debugPrint('[Home] Creating new house', v.identifier)
            Homes[v.identifier] = Home:new(v)
            if Homes[v.identifier].data.starter then
                AddStarterApartment(Homes[v.identifier].identifier)
            end
            ::continue::
        end
        isLoading = false
    else
        print(
            '[^3HOUSING ALERT^0] Current Schema is V2 Housing, Please update to V3 Schema using ^1converthouse^0 command in the console!')
    end
end)

RegisterNetEvent("Housing:server:LoadHomes", function()
    local source = source

    while isLoading do
        Wait(100)
    end
    local list = {}
    for homeId, v in pairs(Homes) do
        local id = #list + 1
        list[id] = Minify(ReduceHomeProperties(v, id))
        -- list[homeId] = Minify(v)
    end
    local payload = msgpack.pack(list)
    TriggerLatentClientEvent('Housing:client:LoadHomeList', source, payload:len() + 10000, payload)
end)

-- lib.callback.register('Housing:server:GetHomes', function(source)
--     while isLoading do
--         Wait(100)
--     end
--     local list = {}
--     for homeId, v in pairs(Homes) do
--         local id = #list + 1
--         list[id] = Minify(ReduceHomeProperties(v, id))
--         -- list[homeId] = Minify(v)
--     end
--     return msgpack.pack(list)
-- end)

lib.callback.register("Housing:server:GetData", function(src, homeId, aptId)
    local home = Homes[homeId]
    if home then
        if home.complex == 'Apartment' then
            local apt = home:GetApartmentById(aptId)
            if apt then
                return {
                    storages = apt.storages,
                    wardrobes = apt.wardrobes,
                    furniture = apt.furniture,
                    plan = apt.plan
                }
            end
        else
            return {
                storages = home.storages,
                wardrobes = home.wardrobes,
                furniture = home.furniture
            }
        end
    end
end)
