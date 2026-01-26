loaded = false
CreateThread(function()
    if Config.framework ~= 'ESX' then return end
    ESX = exports[Config.exportname.es_extended]:getSharedObject()

    function RegisterServerCallback(func, ...)
        ESX.RegisterServerCallback(func, ...)
    end

    function RegisterUsableItem(name, func)
        ESX.RegisterUsableItem(name, func)
    end

    function GetPlayerFromId(source)
        return ESX.GetPlayerFromId(source)
    end

    function GetPlayerFromIdentifier(identifier)
        return ESX.GetPlayerFromIdentifier(identifier)
    end

    loaded = true

    function GetMoney(Player, type, home)
        return Player.getAccount(type).money
    end

    function RemoveMoney(xPlayer, type, amount, reason, home)
        TriggerEvent('okokBanking:AddNewTransaction', 'Bank', 'bank', xPlayer.getName(), xPlayer.identifier,
            amount, reason)
        xPlayer.removeAccountMoney(type, amount, home)
    end

    function AddMoney(xPlayer, type, amount)
        xPlayer.addAccountMoney(type, amount)
    end

    function GetName(xPlayer)
        return xPlayer.getName()
    end

    function GetOfflineName(identifier)
        local result = MySQL.single.await('SELECT firstname, lastname FROM users WHERE identifier = ?', { identifier })
        return result and result.firstname .. ' ' .. result.lastname or ''
    end

    function GetOfflineJobLabel(name)
        local result = MySQL.scalar.await('SELECT label FROM jobs WHERE name = ?', { name })
        return result or ''
    end

    function GetJobName(xPlayer)
        return xPlayer.job.name
    end

    function GetJobLabel(xPlayer)
        return xPlayer.job.label
    end

    function GetJobGrade(xPlayer)
        return xPlayer.job.grade
    end

    -- Returns the number of online players of a job
    ---@return number
    function CountJob(job)
        return #ESX.GetExtendedPlayers('job', job)
    end

    ---@param job string
    ---@return table[]
    function GetFrameworkPlayers(job)
        if job then
            return ESX.GetExtendedPlayers('job', job)
        else
            return ESX.GetExtendedPlayers()
        end
    end

    function GetOfflineAccount(identifier)
        local result = MySQL.single.await('SELECT accounts FROM users WHERE identifier=?', { identifier })
        return next(result) and json.decode(result.accounts) or {}
    end

    function UpdateOfflineAccount(account, identifier)
        return MySQL.update.await("UPDATE users SET accounts=? WHERE identifier=?", { json.encode(account), identifier })
    end

    ---@param xPlayer table
    ---@param admin string
    function CheckAdminGroup(xPlayer, admin)
        return xPlayer.getGroup() == admin
    end

    AddEventHandler('esx:playerLoaded', function(source, xPlayer)
        Player(source).state:set('firstSpawn', true)
        TriggerClientEvent('Housing:client:RegisterDoors', source, doors, doorState)
        TriggerClientEvent('Housing:initialize', xPlayer.source)
        MySQL.update("UPDATE house_owned SET `lastLogin` = ? WHERE `owner` = ?",
            { os.date('%Y-%m-%d %H:%M:%S', os.time()), xPlayer.identifier })

        if Config.EnableLastProperty then
            local homeId, aptId = GetLastProperty(xPlayer)
            if homeId then
                Wait(2500)
                TriggerClientEvent('Housing:client:EnterHome', source, homeId, false, tonumber(aptId))
            end
        end
    end)

    RegisterNetEvent('esx:playerLogout', function(source)
        TriggerClientEvent('Housing:client:OnLogout', source)
    end)

    Config.SQLQueries[Config.framework] = {
        DeleteNonExistingHouseChar = [[DELETE a
FROM house_owned a
LEFT JOIN users b ON b.identifier = a.`owner`
WHERE b.identifier IS NULL]],
        DeleteNonExistingAptChar = [[DELETE a
FROM house_apartment a
LEFT JOIN users b ON b.identifier = a.`owner`
WHERE b.identifier IS NULL]],
        GetAptPlayerNames = [[SELECT b.identifier, b.apartment, a.firstname, a.lastname FROM house_apartment b
LEFT JOIN users a ON a.identifier = b.`owner`]],
        GetHomePlayerNames = [[SELECT b.identifier, a.firstname, a.lastname FROM house_owned b
LEFT JOIN users a ON a.identifier = b.`owner`]],
        SaveFurniture = "UPDATE users SET furniture = ? WHERE identifier = ?",
        GetFurniture = 'SELECT furniture FROM users WHERE identifier = ?',
        SelectFurniture = 'SELECT furniture FROM users WHERE identifier = @identifier',
        UpdateLastProperty = 'UPDATE users SET last_property=? WHERE identifier=?',
        GetLastProperty = 'SELECT last_property FROM users WHERE identifier=?',
        GetPlayerNameByIdentifier = 'SELECT `firstname`, `lastname` FROM `users` WHERE `identifier` = ?',
        UpdateConfiguration = 'UPDATE house SET configuration = ? WHERE identifier = ?',
        UpdatePermission = 'UPDATE house SET permission = ? WHERE identifier = ?',
        SaveEditHome = 'UPDATE house SET price = ?, payment = ?, data = ? WHERE identifier = ?',
        UpdateData = 'UPDATE house SET data = ? WHERE identifier = ?',
        UpdateEntry = 'UPDATE house SET entry = ? WHERE identifier = ?',
        DeletePlayerOutfit = 'DELETE FROM player_outfits WHERE outfitname = ? AND citizenid = ?',
        SelectPlayerOutfit =
        'SELECT props, components, model FROM player_outfits WHERE citizenid = ? and outfitname = ?',
        GetPlayerOutfits = 'SELECT outfitname as label FROM player_outfits WHERE citizenid = ?'
    }
end)
