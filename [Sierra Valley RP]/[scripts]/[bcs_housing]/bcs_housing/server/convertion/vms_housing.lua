RegisterCommand('convert_vms', function(source, args)
    if source ~= 0 then return end
    local check = MySQL.query.await("SHOW COLUMNS FROM `house` LIKE 'configuration'")
    if check and next(check) == nil then
        return print(
            '[^3HOUSING CONVERTION^0] ^1Please use ^2converthouse ^1command first to have v3 database structure')
    end
    local houses = MySQL.query.await("SELECT * FROM `houses`")

    for i = 1, #houses do
        local house = houses[i]
        if house.type ~= 'shell' then goto continue end
        local enter = json.decode(house.metadata.enter)
        local data = {
            identifier = GenerateHomeIdentifier(),
            name = house.address,
            price = house.sale.price,
            type = house.type,
            data = {
                interior = house.metadata.shell,
                downpayment = 0,
                expiry = 0,
                placement = vec4(0.0, 0.0, 100.0, 0.0),
            },
            configuration = {
                garage = false,
                upgrades = Config.configuration.Upgrades,
                rename = false,
                cctv = false,
                area = false,
                disableBuy = false,
                rentable = false,
                storage = Config.configuration.DefaultMaxStorage,
                keys = Config.configuration.LimitKeys,
                wardrobes = Config.configuration.LimitWardrobes,
                garages = Config.configuration.DefaultMaxGarages,
                rentTimer = Config.configuration.RentTimer,
                autoRemove = Config.configuration.AutoRemove
            },
            permission = {
                sell = Config.configuration.DefaultOwnerPermission.sell,
                transfer = Config.configuration.DefaultOwnerPermission.transfer,
                moveGarage = Config.configuration.DefaultOwnerPermission.moveGarage,
                doorlock = Config.configuration.DefaultOwnerPermission.doorlock,
            },
            entry = vec4(enter.x, enter.y, enter.z,
                0.0)
        }
        MySQL.insert.await(
            'INSERT INTO `house` (identifier, `name`, price, `type`, data, configuration, permission, entry)', {
                data.identier,
                data.name,
                data.price,
                data.type,
                json.encode(data.data),
                json.encode(data.configuration),
                json.encode(data.permission),
                json.encode(data.entry)
            })
        ::continue::
    end
end)
