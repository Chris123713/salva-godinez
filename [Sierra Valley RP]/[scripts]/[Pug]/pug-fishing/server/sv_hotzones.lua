local ActiveHotspot = nil
local HotspotRadius = Config.HotSpotZoneRadius
local HotspotDuration = math.random(Config.HotZoneLocationActive.Min, Config.HotZoneLocationActive.Max) * 60 * 1000

local function PickRandomHotspot()
    return Config.HotspotConfig[math.random(1, #Config.HotspotConfig)]
end

local function BroadcastHotspotBlip(coords)
    TriggerClientEvent("Pug:client:CreateHotspotBlip", -1, coords, HotspotRadius)
end

local function ClearHotspotBlip()
    TriggerClientEvent("Pug:client:ClearHotspotBlip", -1)
end

CreateThread(function()
    Wait(1000)
    while true do
        local hotspot = PickRandomHotspot()
        ActiveHotspot = hotspot
        BroadcastHotspotBlip(hotspot)

        Wait(HotspotDuration)

        ClearHotspotBlip()
        ActiveHotspot = nil

        Wait(math.random(Config.HotZoneLocationCooldown.Min, Config.HotZoneLocationCooldown.Max) * 60 * 1000) 
    end
end)

function GetActiveHotspot()
    return ActiveHotspot
end

Config.FrameworkFunctions.CreateCallback("Pug:ServerCB:GetActiveHotspot", function(source, cb)
    if ActiveHotspot then
        cb({ coords = ActiveHotspot, radius = HotspotRadius })
    else
        cb(nil)
    end
end)
