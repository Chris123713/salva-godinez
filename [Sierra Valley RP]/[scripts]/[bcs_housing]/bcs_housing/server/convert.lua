RegisterCommand('converthouse', function(source)
    if source ~= 0 then return end
    local check = MySQL.query.await("SHOW COLUMNS FROM `house` LIKE 'configuration'")
    if check and next(check) == nil then
        MySQL.query.await([[ALTER TABLE house
            ADD COLUMN complex VARCHAR(50),
            ADD COLUMN `area` TEXT,
            ADD COLUMN configuration TINYTEXT,
            ADD COLUMN permission TINYTEXT,
            ADD COLUMN doors MEDIUMTEXT,
            ADD COLUMN entry VARCHAR(100),
            ADD COLUMN storages TEXT,
            ADD COLUMN wardrobes TEXT,
            ADD COLUMN cctv TEXT,
            ADD COLUMN realestate VARCHAR(50),
            ADD COLUMN `created_at` TIMESTAMP NOT NULL DEFAULT NOW();
        ]])
        MySQL.query.await([[ALTER TABLE house_owned ADD COLUMN key_holders TEXT,
        ADD COLUMN `bought_at` TIMESTAMP NOT NULL DEFAULT NOW();]])
        MySQL.update.await([[UPDATE house_owned SET lastLogin = NULL;]])
        MySQL.rawExecute([[ALTER TABLE house_owned MODIFY COLUMN lastLogin timestamp NOT NULL DEFAULT NOW();]])
        MySQL.rawExecute([[CREATE TABLE IF NOT EXISTS `house_rent` (
  `identifier` varchar(46) NOT NULL,
  `price` int(11) NOT NULL DEFAULT 50,
  `duration` int(11) NOT NULL DEFAULT 7,
  `duration_type` enum('day','week') NOT NULL DEFAULT 'day',
  `permission` tinytext DEFAULT NULL,
  `can_rent` tinyint(1) NOT NULL DEFAULT 0,
  `tenant` varchar(255) DEFAULT NULL,
  `last_payment` timestamp NULL DEFAULT NULL,
  `rented_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`identifier`)
);]])
        MySQL.rawExecute([[CREATE TABLE IF NOT EXISTS `house_apartment` (
  `identifier` varchar(46) NOT NULL,
  `apartment` int(11) NOT NULL,
  `owner` varchar(46) DEFAULT NULL,
  `furniture` MEDIUMTEXT DEFAULT NULL,
  `storages` TEXT DEFAULT NULL,
  `wardrobes` TEXT DEFAULT NULL,
  `locked` tinyint(1) NOT NULL DEFAULT 0,
  `bought_at` TIMESTAMP NOT NULL DEFAULT NOW(),
  `last_payment` TIMESTAMP,
  KEY `apartment` (`apartment`),
  KEY `identifier` (`identifier`)
);]])
    else
        return print('[^3HOUSING CONVERTION^0] ^1You have converted the house table!')
    end
    local house = MySQL.query.await("SELECT * FROM house")
    for _, home in pairs(house) do
        home.data = json.decode(home.data)
        home.furniture = json.decode(home.furniture)
        local configuration = {
            garage = false,
            rename = true,
            area = false,
            cctv = false,
            storage = Config.configuration.DefaultMaxStorage,
            keys = Config.configuration.LimitKeys,
            wardrobes = Config.configuration.LimitWardrobes
        }
        if home.furniture then
            for k, v in pairs(home.furniture) do
                local furniture = {
                    coords = v.coords,
                    rotation = v.rotation,
                    area = v.frontyard,
                    model = v.model,
                    heading = v.heading,
                }
                if v.data and v.data.identifier then
                    furniture.identifier = v.data.identifier
                end
                home.furniture[k] = furniture
            end
        end
        if home.data.garage and next(home.data.garage) then configuration.garage = true end
        if home.data.cctv and home.data.cctv.enabled then configuration.cctv = true end
        if home.data.points and next(home.data.points) then
            configuration.area = true
            home.area = {}
            home.area.points = home.data.points
            home.area.height = home.data.maxZ - home.data.minZ
        elseif home.data.frontyard and next(home.data.frontyard) then
            configuration.area = true
            home.area = {}
            home.area.points = home.data.frontyard.points
            home.area.height = home.data.frontyard.maxZ - home.data.frontyard.minZ
        end
        if home.data.doors and next(home.data.doors) then
            home.doors = home.data.doors
            for i = 1, #home.doors do
                if (home.doors[i].type == 'double' and home.doors[i].double) or home.doors[i].doors then
                    home.doors[i].doors = home.doors[i].double or home.doors[i].doors
                    local firstDoor = ToVector3(home.doors[i].doors[1].coords)
                    local secondDoor = ToVector3(home.doors[i].doors[2].coords)
                    home.doors[i].coords = RoundCoordinates(firstDoor - ((firstDoor - secondDoor) / 2))
                    home.doors[i].double = nil
                end
                home.doors[i].type = nil
                home.doors[i].permission = 1
                home.doors[i].name = 'Door ' .. i
                home.doors[i].locked = false
                home.doors[i].home = nil
            end
        else
            home.doors = nil
        end
        if home.data.complex == 'Apartment' then
            home.entry = home.data.apartment.coords
        else
            home.entry = home.data.entry
        end
        home.complex = home.data.complex
        if not home.complex and home.type == 'mlo' then
            home.complex = 'Individual'
        end
        if home.complex == 'Apartment' then
            home.complex = 'Flat'
        end
        if home.data.zplacement then
            home.data.placement = vec3(home.entry.x, home.entry.y, home.data.zplacement)
        end
        home.data = {
            flat = home.data.apartment,
            interior = home.data.interior,
            downpayment = home.data.downpayment,
            placement = home.data.placement,
            garage = home.data.garage,
        }
        print('Converting home ' .. home.identifier, home.complex)
        MySQL.update(
            'UPDATE house SET `furniture` = ?, `data` = ?, `area` = ?, `complex` = ?, `configuration` = ?, `permission` = ?, `doors` = ?, `entry` = ? WHERE `identifier` = ?',
            { json.encode(home.furniture), json.encode(home.data), json.encode(home.area), home.complex, json.encode(
                configuration), json.encode(Config.configuration.DefaultOwnerPermission),
                json.encode(home.doors),
                json.encode(home.entry)
                , home.identifier })
    end
    print('[^3HOUSING CONVERTION^0] house table conversion completed')
    local owned = MySQL.query.await('SELECT `identifier`, `keys` FROM house_owned')
    for _, home in pairs(owned) do
        home.keys = json.decode(home.keys)
        local key_holders = {}
        for k, v in pairs(home.keys) do
            if k ~= 'amount' then
                key_holders[k] = v
                key_holders[k].key = 'Default'
            end
        end
        MySQL.update("UPDATE house_owned SET `key_holders` = ?, `keys` = ? WHERE identifier = ?",
            { json.encode(key_holders), json.encode({ Default = { 1, 2, 3, 6, 10, 11 } }), home.identifier })
    end
    print('[^3HOUSING CONVERTION^0] house_owned table conversion completed')
end, true)

RegisterCommand('storageconvertion', function(source, args)
    if source ~= 0 then
        return TriggerClientEvent('Housing:notify', source, locale('housing'), locale('not_allowed'), 'error', 3000)
    end
    print('[STORAGE CONVERTION] Starting convertion')
    MySQL.query(
        'SELECT *, SUBSTRING_INDEX(`name`, ":", 2) AS identifier FROM ox_inventory WHERE SUBSTRING_INDEX(`name`, ":", 1) = "storage" AND SUBSTRING_INDEX(`name`, ":", -1) = "default";',
        {}, function(result)
            if result then
                for i = 1, #result do
                    print('^0[STORAGE CONVERTION] Starting convertion of ' .. result[i].name)
                    local id = math.random(100, 999)
                    local storage = {
                        id = id,
                        type = 'zone',
                        area = false,
                        weight = Config.FurnitureStorage.weight,
                        slots = Config.FurnitureStorage.slots
                    }
                    local storages = MySQL.scalar.await('SELECT storages FROM house WHERE identifier = ?',
                        { result[i].identifier })
                    storages = storages and ConvertToTable(storages) or {}
                    storages[id] = storage
                    local homeId = string.sub(result[i].identifier, 9)
                    local row = MySQL.update.await('UPDATE house SET storages = ? WHERE identifier = ?',
                        { json.encode(storages), homeId })
                    Wait(500)
                    local row2 = MySQL.update.await("UPDATE ox_inventory SET `name` = ? WHERE `name` = ?",
                        { result[i].identifier .. ':' .. id, result[i].name })
                    print('^0[STORAGE CONVERSION] Affected rows ', row, row2)
                    if row and row > 0 and row2 and row2 > 0 then
                        print('^0[STORAGE CONVERSION] Done converting', result[i].identifier .. ':' .. id)
                    else
                        print('^1[STORAGE CONVERSION] Failed converting', result[i].identifier .. ':' .. id)
                    end
                end
            end
        end)
end, false)

RegisterCommand('convertapartment', function(source, args, raw)
    if source ~= 0 then return end
    local check = MySQL.query.await("SHOW COLUMNS FROM `house` LIKE 'configuration'")
    if check and next(check) == nil then
        return print('[^3HOUSING CONVERTION^0] Please convert to v3 first using ^1converthouse')
    end
    MySQL.query('SELECT `data`, `identifier` FROM `house` WHERE `complex` = "Apartment"', {}, function(result)
        if result then
            for i = 1, #result do
                local data = json.decode(result[i].data)
                data.flat = data.apartment
                data.apartment = nil
                MySQL.update('UPDATE `house` SET `data` = ?, `complex` = "Flat" WHERE identifier = ?',
                    { json.encode(data), result[i].identifier })
            end
            print('[^3HOUSING CONVERTION^0] complex apartment to flat conversion complete')
        end
    end)
end, false)

function ConvertGarages() -- convert garage to multiple garages
    local check = MySQL.scalar.await("SHOW COLUMNS FROM `house` LIKE 'garages'")
    if not check then
        MySQL.prepare.await([[ALTER TABLE house ADD COLUMN `garages` TEXT]])
    end
    local result = MySQL.query.await(
        [[SELECT JSON_EXTRACT(`data`, '$.garage') as `garage`, `data`, `identifier`FROM `house` WHERE JSON_CONTAINS_PATH(`data`, 'one', '$.garage')]])
    if result and #result > 0 then
        for i = 1, #result do
            local garage = json.decode(result[i].garage)
            local data = json.decode(result[i].data)
            if garage and garage.x then
                local newGarage = {
                    {
                        coords = vec4(garage.x, garage.y, garage.z, garage.w),
                        name = 'garage',
                        type = { 'car', 'mo' }
                    }
                }
                data.garage = nil
                MySQL.update.await('UPDATE house SET `data` = ?, `garages`= ? WHERE identifier = ?',
                    { json.encode(data), json.encode(newGarage), result[i].identifier })
            end
        end
    end
end

function ConvertIPLtoMLOteleport()
    for i = 1, #MLOTeleport, 1 do
        local name = MLOTeleport[i].name
        local homeIPL = MySQL.query.await(
            "SELECT `identifier`, `data` FROM `house` WHERE JSON_UNQUOTE(JSON_EXTRACT(`data`, '$.interior.name')) = ?",
            { name }
        )

        print(("Converting %s"):format(name))

        if homeIPL and #homeIPL > 0 then
            for j = 1, #homeIPL, 1 do
                local home = homeIPL[j]
                home.data = json.decode(home.data)

                if home.data.interior then
                    home.data.interior = name

                    local rowChanges = MySQL.update.await(
                        'UPDATE `house` SET `data` = ?, `type` = "mlo_teleport" WHERE `identifier` = ?',
                        { json.encode(home.data), home.identifier })

                    if rowChanges and rowChanges > 0 then
                        print(("Converted %s"):format(home.identifier))
                    else
                        print(("Failed to convert %s"):format(home.identifier))
                        break
                    end
                end
            end

            print(("Finished converting ipl %s to mlo_teleport"):format(name))
        end
    end
    if IPL then
        local list = {
            ["apa_v_mp_h_02_a"] = 'Apartment 3',
            ["apa_v_mp_h_01_c"] = 'Apartment 3',
            ["apa_v_mp_h_01_b"] = 'Apartment 2',
            ['ex_dt1_02_office_02b'] = 'Office 1 (Arcadius Business Centre)',
            ['ex_dt1_11_office_02b'] = 'Office 2 (Maze Bank Building)',
            ['ex_sm_13_office_02b'] = 'Office 3 (Lom Bank)',
            ['ex_sm_15_office_02b'] = 'Office 4 (Maze Bank West)',
            ['bkr_biker_interior_placement_interior_0_biker_dlc_int_01_milo'] = 'Clubhouse1',
            ['bkr_biker_interior_placement_interior_1_biker_dlc_int_02_milo'] = 'Clubhouse2',
            ['bkr_biker_interior_placement_interior_2_biker_dlc_int_ware01_milo'] = 'Methlab',
            ['bkr_biker_interior_placement_interior_3_biker_dlc_int_ware02_milo'] = 'Weed Farm',
            ['bkr_biker_interior_placement_interior_4_biker_dlc_int_ware03_milo'] = 'Cocaine lockup',
            ['bkr_biker_interior_placement_interior_5_biker_dlc_int_ware04_milo'] = 'Counterfeit cash factory',
            ['bkr_biker_interior_placement_interior_6_biker_dlc_int_ware05_milo'] = 'Document forgery',
            ['imp_impexp_interior_placement_interior_1_impexp_intwaremed_milo'] = 'Vehicle warehouse',
            ['apa_v_mp_h_03_a'] = 'Apartment 1'
        }
        for i = 1, #IPL, 1 do
            local name = IPL[i].name
            local homeIPL = MySQL.query.await(
                "SELECT `identifier`, `data` FROM `house` WHERE JSON_UNQUOTE(JSON_EXTRACT(`data`, '$.interior.name')) = ?",
                { name }
            )

            if list[name] then
                print(("Converting %s"):format(name))

                if homeIPL and #homeIPL > 0 then
                    for j = 1, #homeIPL, 1 do
                        local home = homeIPL[j]
                        home.data = json.decode(home.data)

                        if home.data.interior then
                            home.data.interior = list[name]

                            local rowChanges = MySQL.update.await(
                                'UPDATE `house` SET `data` = ?, `type` = "ipl" WHERE `identifier` = ?',
                                { json.encode(home.data), home.identifier })

                            if rowChanges and rowChanges > 0 then
                                print(("Converted %s"):format(home.identifier))
                            else
                                print(("Failed to convert %s"):format(home.identifier))
                                break
                            end
                        end
                    end

                    print(("Finished converting ipl %s to mlo_teleport"):format(name))
                end
            end
        end
    end
end

RegisterCommand('convertipltomlot', function(source, args)
    ConvertIPLtoMLOteleport()
end, false)

RegisterCommand('createiplcatalogue', function(source)
    if source ~= 0 then return end
    InsertHouseCatalogue('ipl')
end, false)

RegisterCommand('cleaniplcatalogue', function(source)
    if source ~= 0 then return end
    local ipls = {}
    for i = 1, #CustomizeIPL, 1 do
        local ipl = CustomizeIPL[i]
        if ipl.name ~= 'Vehicle Warehouse' then
            table.insert(ipls, ipl.name)
        end
    end
    MySQL.query.await('DELETE FROM house_catalogue WHERE title NOT IN (?) AND type = "ipl"', { ipls })
end, false)

-- RegisterCommand('fixstorage', function(source)
--     if source ~= 0 then return end
--     -- modify the identifier to only take the middle part
--     local oxinv = MySQL.query.await(
--         "SELECT *, SUBSTRING_INDEX(`name`, ':', -1) AS id, SUBSTRING_INDEX(`name`, ':', 2) AS identifier FROM ox_inventory WHERE SUBSTRING_INDEX(`name`, ':', 1) = 'storage' AND SUBSTRING_INDEX(`name`, ':', -1) != 'default';"
--     )
--     local houses = MySQL.query.await(
--         'SELECT identifier, furniture FROM house WHERE storages IS NOT NULL and furniture IS NOT NULL')
--     for i = 1, #houses do
--         local home = houses[i]
--         local furnitures = ConvertToTable(home.furniture)
--         if home.complex == 'Apartment' then goto continue end
--         for j = 1, #furnitures do
--             local furniture = furnitures[j]
--             if furniture and (ModelList[furniture.model].slots or ModelList[furniture.model].weight) and not furniture.identifier then
--                 local found = false
--                 for h = 1, #oxinv do
--                     local inv = oxinv[h]
--                     if inv and inv.identifier == 'storage:' .. home.identifier then
--                         print('Adding furniture identifier for ' .. home.identifier, inv.id)
--                         furniture.identifier = inv.id
--                         found = true
--                         break
--                     end
--                 end
--                 if not found then
--                     furniture.identifier = math.random(100, 999)
--                     print('Could not find furniture identifier for ' .. home.identifier .. ', adding random id',
--                         furniture.identifier)
--                 end
--             end
--         end
--         MySQL.update.await('UPDATE house SET furniture = ? WHERE identifier = ?',
--             { json.encode(furnitures), home.identifier })
--         ::continue::
--     end
--     local apts = MySQL.query.await(
--         'SELECT identifier, furniture, owner, storages FROM house_apartment WHERE storages IS NOT NULL and furniture IS NOT NULL')
--     for i = 1, #apts do
--         local apt = apts[i]
--         local furnitures = ConvertToTable(apt.furniture)
--         local storages = ConvertToTable(apt.storages)
--         for j = 1, #furnitures do
--             local furniture = furnitures[j]
--             if furniture and (ModelList[furniture.model].slots or ModelList[furniture.model].weight) and not furniture.identifier then
--                 local found = false
--                 for h = 1, #storages do
--                     local storage = storages[h]
--                     if storage and storage.type == 'furniture' then
--                         print('Adding furniture identifier for ' .. home.identifier, storage.id)
--                         furniture.identifier = storage.id
--                         found = true
--                         break
--                     end
--                 end
--                 if not found then
--                     furniture.identifier = math.random(100, 999)
--                     print('Could not find furniture identifier for ' .. home.identifier .. ', adding random id',
--                         furniture.identifier)
--                 end
--             end
--         end
--         MySQL.update.await('UPDATE house_apartment SET furniture = ? WHERE identifier = ? AND owner = ?',
--             { json.encode(furnitures), apt.identifier, apt.owner })
--     end
-- end)


RegisterCommand('convertshell', function(source)
    if source ~= 0 then return end

    local shellsData = lib.loadJson('config.shells_k4mb1')
    if not shellsData then
        return print('[^1SHELL CONVERSION^0] Failed to load config.shells_k4mb1')
    end

    for i = 1, #shellsData, 1 do
        local packName = shellsData[i].name
        print(('[^3SHELL CONVERSION^0] Processing pack: %s'):format(packName))

        local shells = shellsData[i].shells
        for j = 1, #shells, 1 do
            local from = shells[j].from
            local to = shells[j].to

            if from == to then
                goto continue
            end

            local homes = MySQL.query.await(
                "SELECT `identifier`, `data` FROM `house` WHERE JSON_UNQUOTE(JSON_EXTRACT(`data`, '$.interior')) = ?",
                { from }
            )

            if homes and #homes > 0 then
                print(('[^3SHELL CONVERSION^0] Converting %s -> %s (%d homes)'):format(from, to, #homes))

                for k = 1, #homes, 1 do
                    local home = homes[k]
                    local data = json.decode(home.data)

                    if data and data.interior == from then
                        data.interior = to

                        local rowChanges = MySQL.update.await(
                            'UPDATE `house` SET `data` = ? WHERE `identifier` = ?',
                            { json.encode(data), home.identifier }
                        )

                        if rowChanges and rowChanges > 0 then
                            print(('[^2SHELL CONVERSION^0] Converted home %s'):format(home.identifier))
                        else
                            print(('[^1SHELL CONVERSION^0] Failed to convert home %s'):format(home.identifier))
                        end
                    end
                end
            end

            ::continue::
        end
    end
end, false)
