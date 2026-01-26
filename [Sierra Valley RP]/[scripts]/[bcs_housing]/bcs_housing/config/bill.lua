Config = Config or {}

Config.Bill = {
    enabled = true,
    saveInterval = '0 */2 * * *', -- every 2 hours
    interval = '0 * * * *',
    electricity = {
        label = 'Electricity',
        amount = 100,
        limit = 10000,
        account = 'bank',

        OnLimitReached = function(homeId, aptId)
            SetArtificialLightsState(true)
            HomeElectricity[homeId] = true
        end,
        Reset = function(homeId, aptId)
            SetArtificialLightsState(false)
            HomeElectricity[homeId] = false
        end,
    },
    water = {
        label = 'Water',
        amount = 50,
        limit = 5000,
        account = 'bank',
        OnLimitReached = function(homeId)
            HomeWater[homeId] = true
        end,
        Reset = function(homeId)
            HomeWater[homeId] = false
        end,
    },
}
