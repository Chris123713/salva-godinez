local Interiors = { -- https://wiki.rage.mp/index.php?title=Interiors_and_Locations
    ["modern_apartment_1"] = {
        label = "Modern apartment 1",
        coords = vector3(-786.8663, 315.7642, 216.6385),
        ipl = "apa_v_mp_h_01_a",
        heading = 268.6115,
        disableFurnishing = true,
        lockpick = 1,
        locations = {
            -- the key here is a unique identifier which will be used for storage
            ["location_1"] = {
                coords = vector3(-795.96, 327.43, 217.04),
                scale = vector3(3.0, 3.0, 0.5),
                storage = true,
                wardrobe = false,
                weight = 50000, -- storage weight limit
            },
            ["location_2"] = {
                coords = vector3(-797.58, 328.29, 220.44),
                scale = vector3(3.0, 3.0, 0.5),
                storage = false,
                wardrobe = true,
            },
        },
    },
}

local tempIdentifiers = {}

RegisterCommand('convert_loaf', function(source, args)
    if source ~= 0 then return end
    if check and next(check) == nil then
        return print(
            '[^3HOUSING CONVERTION^0] ^1Please use ^2converthouse ^1command first to have v3 database structure')
    end
    local loafHouses = MySQL.query.await("SELECT * FROM loaf_houses")
    for i = 1, #loafHouses do
        local data = loafHouses[i]
        local configuration = {
            garage = data.garage_entrance and true or false,
            rename = true,
            area = false,
            cctv = false,
            storage = Config.configuration.DefaultMaxStorage,
            keys = Config.configuration.LimitKeys
        }
        local houseTypes = {
            ['shell'] = 'shell',
            ['walkin'] = 'mlo',
            ['interior'] = 'ipl'
        }
        local GetUniqueIdentifier = function()
            local id = GenerateHomeIdentifier()
            repeat
                id = GenerateHomeIdentifier()
            until not tempIdentifiers[id]
            return id
        end
        local home = {
            identifier = GetUniqueIdentifier(),
            name = data.label,
            price = data.price,
            type = houseTypes[data.interior_type],
            payment = 'Sale',
            furniture = {},
            data = {
                garage = data.garage_entrance and ConvertToTable(data.garage_entrance) or {}
            },
            entry = data.entrance and ConvertToTable(data.entrance) or {},
            configuration = configuration,
        }
        tempIdentifiers[home.identifier] = true
        home.data.placement = table.clone(home.entry)
        home.data.placement.w = 0.0
        home.data.placement.z = 2000.0
        if configuration.garage then home.data.garage.w = 0.0 end
        if houseTypes[data.interior_type] == 'shells' then
            home.data.interior = LoafShells[data.interior].object
        elseif houseTypes[data.interior_type] == 'ipl' then
            local ipl = Interiors[data.interior]
            home.data.interior = {
                name = ipl.ipl,
                entry = ipl.coords,
                heading = ipl.heading
            }
        end
        MySQL.insert(
            'INSERT INTO house (`identifier`,`name`,`price`,`type`,`payment`,`data`, `locked`, `complex`, `configuration`, `entry`) VALUES (?, ?, ?, ?, ?,?, ?, ?, ?, ?)',
            {
                home.identifier, home.name, home.price, home.type, home.payment, json.encode(home.data), true,
                'Individual', json
                .encode(home.configuration), json.encode(home.entry)
            })
    end
    print('[^3HOUSING CONVERTION^0][LOAF] House converted successfully.')
    print('[^3HOUSING CONVERTION^0][LOAF] Please restart the script once more.')
end, true)
