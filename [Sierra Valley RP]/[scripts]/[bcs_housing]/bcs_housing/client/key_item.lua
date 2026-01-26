if not Config.KeyAsItem.Enable then return end
Config.KeyAsItem.Blip.coords = Config.KeyAsItem.Coords
createBlip('key', Config.KeyAsItem.Blip)

function CheckKeyItem(home, permission, aptId)
    if type(home) == 'string' then
        home = Homes[home]
    end

    local keyItems = GetKeyItems()

    for _, item in pairs(keyItems) do
        if item.homeId == home.identifier then
            if aptId then
                if item.aptId ~= aptId then
                    goto continue
                end
            end
            local owner = home.properties.owner

            if permission then
                local keyPermissions = item.permissions or {}
                for _, permIndex in pairs(keyPermissions) do
                    if KeyPermissions[permIndex] == permission then
                        if home.properties.complex == 'Apartment' and aptId then
                            for _, apt in pairs(home.apartments or {}) do
                                if apt.apartment == aptId then
                                    owner = apt.owner
                                    break
                                end
                            end
                        end

                        return item.owner == owner
                    end
                end
            end

            return item.owner == owner
        end

        ::continue::
    end

    return false
end

lib.callback.register('Housing:client:CheckKeyItem', CheckKeyItem)

function CreateKey()
    local homes = exports[cache.resource]:GetOwnedHomes()
    local options = {}
    for _, home in pairs(homes) do
        local name = ('(%s) - %s'):format(home.identifier, home.properties.name)

        local aptId = nil

        if home.properties.complex == 'Apartment' then
            aptId = Apartments[home.identifier] and Apartments[home.identifier]:GetOwnedApartmentId()
            name = ('(%s) - (Apt %s) - %s'):format(home.identifier, aptId, home.properties.name)
        end

        table.insert(options, {
            title = name,
            description = locale('create_key_for', name),
            icon = 'house',
            onSelect = function()
                local permission = {}

                for k, v in pairs(KeyPermissions) do
                    table.insert(permission, {
                        label = v,
                        value = k,
                    })
                end

                local input = lib.inputDialog(locale('create_key_for', name), {
                    { type = 'input',        label = locale('name'),           required = true },
                    { type = 'multi-select', label = locale('ui.permissions'), options = permission, required = true },
                })

                if not input then
                    return
                end

                TriggerServerEvent('Housing:server:CreateKeyItem', home.identifier, aptId, input[1], input[2])
            end,
        })
    end

    lib.registerContext({
        id = 'create_key_menu',
        title = locale('create_key'),
        options = options,
    })

    lib.showContext('create_key_menu')
end

function DuplicateKey()
    local items = GetKeyItems()
    local options = {}

    for _, item in pairs(items) do
        local name = item.label

        table.insert(options, {
            title = name,
            description = locale('duplicate_key_for', name),
            icon = 'key',
            onSelect = function()
                TriggerServerEvent('Housing:server:DuplicateKeyItem', item)
            end,
        })
    end

    lib.registerContext({
        id = 'duplicate_key_menu',
        title = locale('duplicate_key'),
        options = options,
    })

    lib.showContext('duplicate_key_menu')
end

lib.registerContext({
    id = 'key_item_menu',
    title = 'Key Menu',
    options = {
        {
            title = locale('create_key'),
            description = locale('create_key_description'),
            icon = 'key',
            onSelect = CreateKey,
        },
        {
            title = locale('duplicate_key'),
            description = locale('duplicate_key_description'),
            icon = 'key',
            onSelect = DuplicateKey,
        }
    },
})

if Config.target then
    local options = {
        {
            icon = "fas fa-key",
            label = "Key Menu",
            action = function()
                lib.showContext('key_item_menu')
            end,
        },
    }

    CreateThread(function()
        if Config.KeyAsItem.Ped then
            spawnPed('key_item', Config.KeyAsItem.Ped, Config.KeyAsItem.Coords)
            AddTargetEntity('key_item', spawnedPeds['key_item'], {
                options = options,
                distance = 3.5,
            })
        else
            AddTargetBoxZone('key_item', Config.KeyAsItem.Coords, {
                options = options,
                distance = 3.5,
            })
        end
    end)
else
    if Config.KeyAsItem.Ped then
        spawnPed('key_item', Config.KeyAsItem.Ped, Config.KeyAsItem.Coords)
    end
    lib.points.new({
        coords = Config.KeyAsItem.Coords,
        distance = 3.5,
        onEnter = function()
            HelpText(true, locale('prompt_key'))
        end,
        onExit = function()
            HelpText(false)
        end,
        nearby = function()
            if IsControlJustReleased(0, 38) then
                lib.showContext('key_item_menu')
            end
        end,
    })
end
