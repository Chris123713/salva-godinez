if Config.Language ~= "en" then
    return
end

Locales = {
    ["title"] = "Radio",
    ["description"] = "Connect to a radio channel and talk with your friends",
    ["frequency"] = "Frequency",
    ["recent"] = "Recent connections",
    ["connect_to"] = "Connect to",
    ["remove_history"] = "Remove from history",
    ["connect"] = "Connect",
    ["disconnect"] = "Disconnect",
    ["no_access"] = "You can't connect to this channel",

    ["clear_history"] = {
        ["title"] = "Clear History",
        ["desc"] = "Do you want to remove all frequencies from your history?",
        ["confirm"] = "Clear History",
        ["cancel"] = "Cancel",
    },
}
