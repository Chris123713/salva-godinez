--[[
    READ THE DOCS BEFORE USING THIS SCRIPT:
    https://docs.av-scripts.com/guides/weather-script/installation
    https://docs.av-scripts.com/guides/weather-script/installation
    https://docs.av-scripts.com/guides/weather-script/installation
]]--

Config = {}
Config.DebugFog = false -- used to debug fog
Config.Command = "weather" -- Command used to open the weather menu
Config.AdminLevel = {"group.admin", "group.god"} -- Admin group needed to access the weather menu
Config.TempUnit = "C" -- Temperature scale unit "C" or "F" (Celsius/Farenheit)
Config.NightHours = {20,6} -- Night starts at 8PM and ends 6AM (used for UI icons and smart fog, 24H format)
Config.RealTime = false -- true/false use the API to retrieve the current City time on server restart
Config.City = "America/Los_Angeles" -- Continent/Country, list of available zones in timezones.json file
Config.TimeCycleDuration = 48 -- Duration of the day cycle in real-world minutes (default is 48)
Config.ResetWeatherOnRestart = false -- If true, generates new weather after server restart; if false, retains previous weather state
Config.UnfreezeTimeOnRestart = true -- If true, time will resume after server restart; if false, time will keep the state before sv restart
Config.UseFog = true -- Fog modifier is a timecycle and can look/act weird for some ppl, if this is your case u can set this to false and use the default GTA fog
Config.GenerateFog = true -- Allow the server to generate random fog for every zone (server will only use Normal, Low and Medium options)
Config.BreathEffect = true -- Enables the breath condensation effect when the temperature is 5°C (40°F) or lower and player is outside a building
Config.isChristmas = false -- Enable XMAS weather to all zones on script start
Config.SmartFog = true -- Adjusts fog intensity for better appearance during daytime and reverts to default at night
Config.MLOFix = true -- Change to true if your MLOs interiors becomes darker when there's fog

function dbug(...) -- used for debug prints, don't modify it
    if (GlobalState['weatherSettings'] and GlobalState['weatherSettings']['debugMode']) then print ('^3[DEBUG]^7', ...) end
end