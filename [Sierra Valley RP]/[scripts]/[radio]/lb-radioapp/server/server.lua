---@param frequency string
---@return number members
RegisterCallback("getMembers", function(source, frequency)
    if Config.VoiceScript == "pma-voice" then
        local membersCount = 0
        local members = exports["pma-voice"]:getPlayersInRadioChannel(frequency)

        for _, _ in pairs(members) do
            membersCount += 1
        end

        return membersCount
    end

    return 0
end)

PerformHttpRequest("https://loaf-scripts.com/versions/", function(_, text, _)
    if text then
        print(text)
    end
end, "POST", json.encode({
    resource = "lb-radioapp",
    version = GetResourceMetadata(GetCurrentResourceName(), "version", 0) or "0.0.0",
}), { ["Content-Type"] = "application/json" })
