local api_key = ""

function getTimeFromCity(zone, cb)
    if not api_key or string.len(api_key) < 5 then
        print("^3[WARNING] Please add your API Key in server/editable/_api.lua, make sure to read the docs first.^7")
        print("^3[WARNING] Please add your API Key in server/editable/_api.lua, make sure to read the docs first.^7")
        print("^3[WARNING] Please add your API Key in server/editable/_api.lua, make sure to read the docs first.^7")
        cb(nil,nil,nil)
    end
    local apiUrl = "https://api.ipgeolocation.io/timezone?apiKey="..api_key.."&tz=" .. zone 
    dbug("getTimeFromCity()...", zone)
    PerformHttpRequest(apiUrl, function(statusCode, responseText, headers)
        if statusCode == 200 then
            local responseData = json.decode(responseText)
            if responseData and responseData.time_24 then
                local datetime = responseData.time_24
                local hour, minutes, seconds = string.match(datetime, "(%d%d):(%d%d):(%d%d)")
                cb(hour, minutes, seconds)
            else
                cb(nil, nil, nil, "Error: No date/time info received")
            end
        else
            cb(nil, nil, nil, "Error: Request Error Code: " .. statusCode)
        end
    end, "GET", "", {})
end