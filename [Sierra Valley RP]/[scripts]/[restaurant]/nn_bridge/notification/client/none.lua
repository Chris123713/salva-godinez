func = {}

func.show = function(data)
    Lib.print(data.message, data.style)
end

RegisterNetEvent("pd_bridge:client:showNotify", function(data)
    bridge.notification.show(data)
end)

return func