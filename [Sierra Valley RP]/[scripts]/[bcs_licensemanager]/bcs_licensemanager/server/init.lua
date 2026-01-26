local initialQueries = {
    string.format([[
    CREATE TABLE IF NOT EXISTS `%s` (
      `cardid` varchar(50) NOT NULL,
      `owner` varchar(255) NOT NULL,
      `name` varchar(70) DEFAULT NULL,
      `license` varchar(50) NOT NULL,
      `data` longtext DEFAULT NULL,
      PRIMARY KEY (`cardid`) USING BTREE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]], Config.Database.license),

    string.format([[
    CREATE TABLE IF NOT EXISTS `%s` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `name` varchar(50) DEFAULT NULL,
      `identifier` varchar(255) DEFAULT NULL,
      `date` varchar(50) DEFAULT NULL,
      `license` varchar(50) DEFAULT NULL,
      `issuer` varchar(50) DEFAULT NULL,
      `action` varchar(50) DEFAULT NULL,
      PRIMARY KEY (`id`)
    ) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4;
    ]], Config.Database.license_history),

    string.format([[
    CREATE TABLE IF NOT EXISTS `%s` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `owner` varchar(255) COLLATE armscii8_bin NOT NULL,
      `firstname` varchar(20) NOT NULL,
      `lastname` varchar(20) NOT NULL,
      `callsign` varchar(10) NOT NULL,
      `rank` varchar(50) NOT NULL,
      `department` varchar(10) NOT NULL,
      `mugshot` mediumtext DEFAULT NULL,
      `created_at` datetime NOT NULL DEFAULT current_timestamp(),
      PRIMARY KEY (`id`)
    );
    ]], Config.Database.badge)
}

local tables = {
    [Config.Database.license] = {
        'cardid',
        'owner',
        'name',
        'license',
        'data',
    },
    [Config.Database.license_history] = {
        'id',
        'name',
        'identifier',
        'date',
        'license',
        'issuer',
        'action',
    },
    [Config.Database.badge] = {
        'id',
        'owner',
        'firstname',
        'lastname',
        'callsign',
        'rank',
        'department',
        'mugshot',
        'created_at',
    }
}

MySQL.ready(function()
    for i = 1, #initialQueries, 1 do
        MySQL.prepare.await(initialQueries[i])
    end
    if Config.debug then
        Wait(1000)
        for k, v in pairs(tables) do
            Wait(1000)
            print(string.format('[DEBUG](LicenseManager): Checking table "%s"', k))
            local data = MySQL.query.await(
                'SELECT COLUMN_NAME AS columnName FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ?',
                { k }
            )

            if data then
                local columns = {}

                for _, row in ipairs(data) do
                    columns[row.columnName] = true
                end

                for i = 1, #v, 1 do
                    if not columns[v[i]] then
                        print(string.format('[WARNING](LicenseManager): Missing column "%s" in table "%s"', v[i], k))
                        break
                    end
                end
                Wait(1000)
                print(string.format('[DEBUG](LicenseManager): Table "%s" checked', k))
            else
                print(string.format('[ERROR](LicenseManager): Table "%s" does not exist or is invalid', k))
            end
        end
    end
end)
