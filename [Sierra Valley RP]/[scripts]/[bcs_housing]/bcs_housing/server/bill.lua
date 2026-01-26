if not Config.Bill.enabled then
    return
end

function LoadBill(homeId, aptId)
    local result = aptId and MySQL.single.await([[
        SELECT electricity, water
        FROM house_bills WHERE identifier = ? AND apartment = ?
    ]], { homeId, aptId }) or MySQL.single.await([[
        SELECT electricity, water
        FROM house_bills WHERE identifier = ?
    ]], { homeId })

    if not result then
        MySQL.insert.await([[
            INSERT INTO house_bills (identifier, electricity, water, apartment)
            VALUES (?, ?, ?, ?)
        ]], { homeId, 0, 0, aptId })

        result = {}

        for k, v in pairs(Config.Bill) do
            if type(v) == 'table' and v.limit then
                result[k] = 0
            end
        end
    end

    return result
end

local function SaveBill(homeId)
    local home = Homes[homeId]
    if not home then return end

    MySQL.update.await([[
            UPDATE house_bills
            SET electricity = ?, water = ?
            WHERE identifier = ? AND apartment IS NULL
        ]], { home.bill.electricity, home.bill.water, homeId })
end

function SaveBills()
    if next(Homes) == nil then return end

    for _, home in pairs(Homes) do
        SaveBill(home.identifier)
        Wait(1000)
    end
end

if Config.Bill.enabled then
    lib.cron.new(Config.Bill.interval, SaveBills)

    lib.cron.new(Config.Bill.interval, function()
        for _, home in pairs(Homes) do
            if home.complex == 'Apartment' then
                for _, apt in pairs(home.apartments) do
                    if not apt.bill then
                        goto continue
                    end
                    for k in pairs(apt.bill) do
                        local amount = Config.Bill[k].amount
                        local limit = Config.Bill[k].limit

                        if not home.apartments[apt.apartment] or not home.apartments[apt.apartment].bill then
                            debugPrint('home ' .. home.identifier .. ' apartment ' .. apt.apartment .. ' has no bill')
                            goto continue
                        end

                        if not Homes[home.identifier].apartments[apt.apartment].bill[k] then
                            Homes[home.identifier].apartments[apt.apartment].bill[k] = 0
                        end

                        Homes[home.identifier].apartments[apt.apartment].bill[k] += math.min(amount,
                            limit - Homes[home.identifier].apartments[apt.apartment].bill[k])
                    end
                end
            else
                for k in pairs(home.bill) do
                    local amount = Config.Bill[k].amount
                    local limit = Config.Bill[k].limit

                    if not Homes[home.identifier].bill[k] then
                        Homes[home.identifier].bill[k] = 0
                    end

                    debugPrint(('home %s limit %s amount %s bill %s key %s'):format(home.identifier, limit, amount,
                        Homes[home.identifier].bill[k], k))

                    Homes[home.identifier].bill[k] += math.min(amount, limit - Homes[home.identifier].bill[k])
                end
            end

            local players = home:GetPlayersInside()

            if players then
                for _, src in pairs(players) do
                    TriggerClientEvent('Housing:client:UpdateBill', src, home.identifier, Homes[home.identifier].bill)
                end
            end

            ::continue::
        end
    end)
end

lib.callback.register('Housing:server:GetBill', function(_, homeId, aptId)
    local success, result = pcall(function()
        return aptId and Homes[homeId].apartments[aptId].bill or Homes[homeId].bill or {}
    end)
    if success then
        return result
    end

    return {}
end)

lib.callback.register('Housing:server:PayBill', function(_, name, homeId)
    local home = Homes[homeId]
    if not home then return false end

    local bill = home.bill

    local config = Config.Bill[name]

    if not bill or not bill[name] then
        return false
    end

    if bill[name] <= 0 then return false end

    local price = bill[name]

    local xPlayer = GetPlayerFromId(source)
    if not xPlayer then return false end

    if GetMoney(xPlayer, config.account) < price then
        TriggerClientEvent('Housing:notify', xPlayer.source, locale('housing'), locale('not_enough_money', price),
            'error', 3000)
        return false
    end

    RemoveMoney(xPlayer, config.account, price, ('Bill %s'):format(config.label), home)
    bill[name] = 0
    TriggerClientEvent('Housing:notify', xPlayer.source, locale('housing'), locale('bill_paid_success'),
        'success', 3000)
    return true
end)
