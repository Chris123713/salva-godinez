-- Save zones and server time before txadmin restart
AddEventHandler('txAdmin:events:scheduledRestart', function(eventData)
    if eventData.secondsRemaining and tonumber(eventData.secondsRemaining) <= 60 then
        save("zones")
        save("time")
    end
end)