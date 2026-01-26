local tempIdentifiers = {}
local shells = {}

function insertInteriors(interiors)
    for i = 1, #interiors do
        shells[#shells + 1] = interiors[i]
    end
end

RegisterCommand('convert_qs', function(source)
    if source ~= 0 then return end
    local check = MySQL.query.await("SHOW COLUMNS FROM `house` LIKE 'configuration'")
    if check and next(check) == nil then
        return print(
            '[^3HOUSING CONVERTION^0] ^1Please use ^2converthouse ^1command first to have v3 database structure')
    end
    local qs_houses = MySQL.query.await('SELECT * FROM houselocations')
    for i = 1, #qs_houses do
        local data = qs_houses[i]
        data.coords = ConvertToTable(data.coords)
        local configuration = {
            garage = data.garage and true or false,
            rename = true,
            area = false,
            cctv = false,
            storage = Config.configuration.DefaultMaxStorage,
            keys = Config.configuration.LimitKeys
        }
        local GetUniqueIdentifier = function()
            local id = GenerateHomeIdentifier()
            repeat
                id = GenerateHomeIdentifier()
            until not tempIdentifiers[id]
            return id
        end
        data.garage = data.garage and ConvertToTable(data.garage) or {}
        local home = {
            identifier = GetUniqueIdentifier(),
            name = data.label,
            price = data.price,
            payment = 'Sale',
            furniture = {},
            data = {
                garage = next(data.garage) and vec4(data.garage.x, data.garage.y, data.garage.z, data.garage.h) or nil
            },
            entry = vec4(data.coords.enter.x, data.coords.enter.y, data.coords.enter.z, data.coords.enter.h),
            configuration = configuration,
        }
        tempIdentifiers[home.identifier] = true
        data.ipl = ConvertToTable(data.ipl)
        if data.tier and not data.mlo then
            home.type = 'shell'
            home.data.placement = data.coords.interiorCoords
            local GetQuasarShell = function(tier)
                for i = 1, #shells do
                    print(shells[i].label, shells[i].nameTier, tier)
                    if shells[i].nameTier == tier then
                        return shells[i].label
                    end
                end
            end
            home.data.interior = GetQuasarShell(data.tier)
        elseif data.ipl then
            home.type = 'ipl'
            home.data.interior = {
                entry = data.ipl.exit,
                heading = 0.0
            }
        elseif data.mlo then
            data.mlo = ConvertToTable(data.mlo)
            home.type = 'mlo'
            home.area = {
                points = {},
                height = data.coords.PolyZone.maxZ - data.coords.PolyZone.minZ
            }
            for i = 1, #data.coords.PolyZone.points do
                home.area.points[#home.area.points + 1] = {
                    x = data.coords.PolyZone.points[i].x,
                    y = data.coords.PolyZone.points[i].y,
                    z = data.coords.enter.z
                }
            end
            home.doors = {}
            if type(data.mlo) == 'table' then
                for i = 1, #data.mlo do
                    local id = #home.doors + 1
                    home.doors[id] = {
                        name = 'Door ' .. i,
                        permission = 1,
                        distance = 1,
                        locked = data.mlo[i][1].locked and 1 or 0,
                    }
                    if data.mlo[i][2] then
                        home.doors[id].doors = {
                            {
                                coords = vec3(data.mlo[i][1].coords.x, data.mlo[i][1].coords.y, data.mlo[i][1].coords.z),
                                heading = data.mlo[i][1].h,
                                model = data.mlo[i][1].hash
                            },
                            {
                                coords = vec3(data.mlo[i][2].coords.x, data.mlo[i][2].coords.y, data.mlo[i][2].coords.z),
                                heading = data.mlo[i][2].h,
                                model = data.mlo[i][2].hash
                            }
                        }
                        home.doors[id].coords = home.doors[id].doors[1].coords -
                            ((home.doors[id].doors[1].coords - home.doors[id].doors[2].coords) / 2)
                    else
                        home.doors[id].coords = data.mlo[i][1].coords
                        home.doors[id].heading = data.mlo[i][1].h
                        home.doors[id].model = data.mlo[i][1].hash
                    end
                end
            end
        end
        if home.type == 'shell' and not home.data.interior then
            print(('[^3HOUSING CONVERTION^0][QUASAR] ^1Home %s shell was not found! Please put your custom shell list of quasar inside ^2server/convertion/quasar_interiors ^1folder!')
                :format(home.name))
        else
            MySQL.insert(
                'INSERT INTO house (`identifier`,`name`,`price`,`type`,`payment`,`data`, `locked`, `complex`, `configuration`, `entry`, `area`, `doors`) VALUES (?, ?, ?, ?, ?,?, ?, ?, ?, ?, ?, ?)',
                {
                    home.identifier, home.name, home.price, home.type, home.payment, json.encode(home.data), true,
                    'Individual', json
                    .encode(home.configuration), json.encode(home.entry), json.encode(home.area), json.encode(home.doors)
                })
        end
    end
    print('[^3HOUSING CONVERTION^0][QUASAR] House converted successfully.')
    print('[^3HOUSING CONVERTION^0][QUASAR] Please restart the script once more.')
end)

RegisterCommand('checkshells', function()
    for i = 1, #shells do
        print(shells[i].label, GetHashKey(shells[i].label), shells[i].nameTier)
    end
end)
