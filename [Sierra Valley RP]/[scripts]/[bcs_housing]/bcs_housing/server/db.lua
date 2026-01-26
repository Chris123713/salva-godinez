MySQL = MySQL
local houseTables = {
    ['house'] = [[CREATE TABLE IF NOT EXISTS `house` (
        `identifier` varchar(50) NOT NULL DEFAULT '0',
        `name` varchar(50) DEFAULT NULL,
        `price` int(11) NOT NULL DEFAULT 0,
        `type` varchar(50) NOT NULL DEFAULT 'shell',
        `payment` VARCHAR(50) DEFAULT NULL,
        `furniture` MEDIUMTEXT DEFAULT NULL,
        `data` TEXT DEFAULT NULL,
        `locked` tinyint(1) NOT NULL DEFAULT 0,
        `mortgage` TINYTEXT DEFAULT NULL,
        `complex` varchar(50) DEFAULT NULL,
        `area` TEXT DEFAULT NULL,
        `configuration` TINYTEXT DEFAULT NULL,
        `permission` TINYTEXT DEFAULT NULL,
        `doors` MEDIUMTEXT DEFAULT NULL,
        `entry` VARCHAR(100) DEFAULT NULL,
        `storages` TEXT DEFAULT NULL,
        `wardrobes` TEXT DEFAULT NULL,
        `cctv` TEXT DEFAULT NULL,
        `realestate` varchar(50) DEFAULT NULL,
        `creator` varchar(50) DEFAULT NULL,
        `created_at` TIMESTAMP NOT NULL DEFAULT NOW(),
        `tebex` VARCHAR(255) DEFAULT NULL,
        `garages` TEXT DEFAULT NULL,
        `thumbnail` VARCHAR(255) DEFAULT NULL,
        `disabled` TINYINT(1) NOT NULL DEFAULT 0,
        PRIMARY KEY (`identifier`)
      )]],
    ['house_mortgage'] = [[CREATE TABLE IF NOT EXISTS `house_mortgage` (
        `identifier` varchar(50) NOT NULL,
        `apartment` int(11) NOT NULL DEFAULT 0,
        `interest` int(11) NOT NULL,
        `duration` int(11) NOT NULL,
        `type` varchar(50) NOT NULL,
        `payment` int(11) NOT NULL DEFAULT 0,
        `lastPayment` varchar(50) DEFAULT NULL,
        `remaining` int(11) DEFAULT NULL,
        PRIMARY KEY (`identifier`, `apartment`)
      )]],
    ['house_owned'] = [[CREATE TABLE IF NOT EXISTS `house_owned` (
        `identifier` varchar(50) NOT NULL DEFAULT '0',
        `owner` varchar(50) NOT NULL,
        `lastLogin` timestamp NULL DEFAULT current_timestamp(),
        `lastPayment` bigint(20) DEFAULT NULL,
        `keys` TEXT DEFAULT NULL,
        `data` TEXT DEFAULT NULL,
        `key_holders` TEXT DEFAULT NULL,
        `bought_at` TIMESTAMP NOT NULL DEFAULT NOW(),
        PRIMARY KEY (`identifier`)
      )]],
    ['house_apartment'] = [[CREATE TABLE IF NOT EXISTS `house_apartment` (
        `identifier` varchar(46) NOT NULL,
        `apartment` int(11) NOT NULL,
        `owner` varchar(46) DEFAULT NULL,
        `furniture` MEDIUMTEXT DEFAULT NULL,
        `storages` TEXT DEFAULT NULL,
        `keys` TEXT DEFAULT NULL,
        `key_holders` TEXT DEFAULT NULL,
        `wardrobes` TEXT DEFAULT NULL,
        `locked` tinyint(1) NOT NULL DEFAULT 0,
        `bought_at` TIMESTAMP NOT NULL DEFAULT NOW(),
        `last_payment` TIMESTAMP NULL,
        KEY `apartment` (`apartment`),
        KEY `identifier` (`identifier`)
      )]],
    ['house_rent'] = [[CREATE TABLE IF NOT EXISTS `house_rent` (
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
      )]],
    ['house_catalogue'] = [[CREATE TABLE IF NOT EXISTS `house_catalogue` (
        `title` varchar(255) NOT NULL,
        `interior` varchar(255) NOT NULL,
        `type` enum('ipl','shell','mlo','mlo_teleport') DEFAULT 'shell',
        `thumbnail` varchar(255) DEFAULT NULL,
        `tags` tinytext DEFAULT NULL,
        `description` tinytext DEFAULT NULL,
        `job` varchar(50) DEFAULT NULL,
        KEY `name` (`title`),
        KEY `interior` (`interior`)
      )]],
    ['house_ipl'] = [[CREATE TABLE IF NOT EXISTS `house_ipl` (
        `identifier` varchar(50) NOT NULL,
        `apartment` int(11) DEFAULT NULL,
        `data` LONGTEXT DEFAULT NULL,
        KEY `apartment` (`apartment`),
        KEY `identifier` (`identifier`)
    );]],
    ['house_teleports'] = [[
        CREATE TABLE IF NOT EXISTS `house_teleports` (
            `identifier` varchar(50) NOT NULL,
            `name` varchar(100) DEFAULT NULL,
            `inside` varchar(100) DEFAULT NULL,
            `outside` varchar(100) DEFAULT NULL,
            `locked` tinyint(1) NOT NULL DEFAULT 1,
            KEY `identifier` (`identifier`),
            KEY `name` (`name`)
        );
    ]],
    ['house_area_presets'] = [[
        CREATE TABLE IF NOT EXISTS `house_area_presets` (
            `id` INT AUTO_INCREMENT PRIMARY KEY,
            `name` VARCHAR(100) NOT NULL,
            `preset` TEXT NOT NULL,
            `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
    ]],
    ['house_bills'] = [[
        CREATE TABLE IF NOT EXISTS `house_bills` (
            `identifier` VARCHAR(50) NOT NULL,
            `electricity` INT NOT NULL DEFAULT 0,
            `water` INT NOT NULL DEFAULT 0,
            `apartment` INT NULL,
            KEY `identifier` (`identifier`)
        );
    ]],
}

function InsertHouseCatalogue(houseType)
    local function InsertShell()
        for k in pairs(Shells) do
            local exist = MySQL.scalar.await('SELECT 1 FROM house_catalogue WHERE title = ?',
                { k })

            if not exist then
                MySQL.insert.await('INSERT INTO house_catalogue (title, interior, type) VALUES (?, ?, ?)',
                    { k, k, 'shell' })
            end
        end
    end

    local function InsertIPL()
        for i = 1, #CustomizeIPL, 1 do
            local ipl = CustomizeIPL[i]
            local exist = MySQL.scalar.await('SELECT 1 FROM house_catalogue WHERE title = ?',
                { ipl.identifier, ipl.apartment })

            if not exist then
                MySQL.insert.await('INSERT INTO house_catalogue (title, interior, type) VALUES (?, ?, ?)',
                    { ipl.name, ipl.name, 'ipl' })
            end
        end
    end

    if houseType == 'shell' then
        InsertShell()
    elseif houseType == 'ipl' then
        InsertIPL()
    else
        InsertShell()
        InsertIPL()
    end
end

local function GetCollation(tableName)
    local tableData = MySQL.single.await('SHOW CREATE TABLE ' .. tableName)
    if tableData and tableData['Create Table'] then
        local data = tableData['Create Table']
        local charset = string.match(data, 'CHARSET=[^ ]+')
        local collation = string.match(data, 'COLLATE=[^ ]+')
        return charset, collation
    end
end

function InitDatabase()
    local userTable = Config.framework == 'ESX' and 'users' or 'players'
    local charset, collation = GetCollation(userTable)

    local createTable = {}

    for k in pairs(houseTables) do
        if not MySQL.scalar.await("SHOW TABLES LIKE '" .. k .. "'") then
            print('[^3HOUSING DATABASE^0] Table ' .. k .. ' does not exist, creating ' .. k)

            table.insert(createTable, k)
        end
    end

    if #createTable > 0 then
        local queries = {}
        local insertCatalogue = false

        for i = 1, #createTable do
            table.insert(queries, houseTables[createTable[i]])

            if createTable[i] == 'house_catalogue' then
                insertCatalogue = true
            end
        end

        for k, v in pairs(queries) do
            v = v:gsub(';', '')
            v = ('%s ENGINE=InnoDB DEFAULT %s %s;'):format(v, charset, collation)
            queries[k] = v
        end

        local success = MySQL.transaction.await(queries)

        if not success then
            return print('[^1HOUSING DATABASE^0]  Failed to create tables, run /inithousingdb to fix this')
        end

        if insertCatalogue then
            InsertHouseCatalogue()
        end
    end


    local user = MySQL.query.await('DESCRIBE ' .. userTable)
    local runQuery = true

    for i = 1, #user do
        if user[i].Field == 'furniture' then
            runQuery = false
            break
        end
    end

    local queries = {
        'ALTER TABLE ' .. userTable .. ' ADD IF NOT EXISTS furniture MEDIUMTEXT',
        'ALTER TABLE ' .. userTable .. ' ADD IF NOT EXISTS `last_property` varchar(50) NOT NULL DEFAULT "outside"'
    }

    if runQuery then
        MySQL.transaction.await(queries)
    end

    runQuery = true
    local aptHouse = MySQL.query.await('DESCRIBE house_apartment')

    -- check if keys and key_holders column exist
    for i = 1, #aptHouse do
        if aptHouse[i].Field == 'keys' then
            runQuery = false
            break
        end
    end

    if runQuery then
        MySQL.rawExecute.await('ALTER TABLE house_apartment ADD COLUMN `keys` TEXT DEFAULT NULL')
        MySQL.rawExecute.await('ALTER TABLE house_apartment ADD COLUMN `key_holders` TEXT DEFAULT NULL')
    end

    runQuery = true
    local catalogueTable = MySQL.query.await('DESCRIBE house_catalogue')
    for i = 1, #catalogueTable do
        if catalogueTable[i].Field == 'type' and catalogueTable[i].Type == "enum('ipl','shell','mlo_teleport','mlo')" then
            runQuery = false
            break
        end
    end
    if runQuery then
        MySQL.rawExecute.await('ALTER TABLE house_catalogue MODIFY `type` ENUM("ipl", "shell", "mlo_teleport", "mlo")')
    end

    CheckHouseColumn()
end

function CheckHouseColumn()
    local columns = {
        { name = 'creator',   type = 'VARCHAR(50)',  default = 'NULL' },
        { name = 'thumbnail', type = 'VARCHAR(255)', default = 'NULL' },
        { name = 'disabled',  type = 'TINYINT(1)',   default = '0' },
    }

    for i = 1, #columns do
        local column = columns[i]
        local runQuery = MySQL.scalar.await([[
            SELECT COUNT(*)
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_NAME = 'house'
            AND COLUMN_NAME = ']] .. column.name .. [['
        ]]) == 0

        if runQuery then
            MySQL.query.await('ALTER TABLE house ADD COLUMN ' ..
                column.name .. ' ' .. column.type .. ' DEFAULT ' .. column.default)
            print('[^3HOUSING DATABASE^0] Added ' .. column.name .. ' column to house table')
        end
    end

    -- Check and create house_area_presets table if it doesn't exist
    local presetTableExists = MySQL.scalar.await("SHOW TABLES LIKE 'house_area_presets'")
    if not presetTableExists then
        print('[^3HOUSING DATABASE^0] Table house_area_presets does not exist, creating house_area_presets')
        local userTable = Config.framework == 'ESX' and 'users' or 'players'
        local charset, collation = GetCollation(userTable)
        local query = houseTables['house_area_presets']:gsub(';', '')
        query = ('%s ENGINE=InnoDB DEFAULT %s %s;'):format(query, charset, collation)
        MySQL.rawExecute.await(query)
        print('[^3HOUSING DATABASE^0] Successfully created house_area_presets table')
    end
end

RegisterCommand('inithousingdb', function(source)
    if source ~= 0 then return end
    InitDatabase()
end, false)

function FixApartmentDupe()
    local maxes = MySQL.query.await(
        'SELECT identifier, MAX(apartment) AS highest FROM house_apartment GROUP BY identifier')
    local max = {}
    for i = 1, #maxes do
        max[maxes[i].identifier] = maxes[i].highest
    end
    local result = MySQL.query.await(
        'SELECT identifier, apartment, COUNT(*) AS `count` FROM house_apartment GROUP BY identifier, apartment HAVING COUNT(*) > 1')
    if result then
        for i = 1, #result do
            for j = 2, result[i].count do
                if max[result[i].identifier] then
                    max[result[i].identifier] += 1
                    local test = MySQL.update.await(
                        'UPDATE house_apartment SET apartment = ? WHERE identifier = ? AND apartment = ? LIMIT 1', {
                            max[result[i].identifier],
                            result[i].identifier,
                            result[i].apartment
                        })
                    print('updated housing', result[i].identifier, result[i].apartment, max[result[i].identifier])
                end
            end
        end
    end
end

RegisterCommand('fixapartmentdupe', function(source)
    if source ~= 0 then return end
    FixApartmentDupe()
end, false)
