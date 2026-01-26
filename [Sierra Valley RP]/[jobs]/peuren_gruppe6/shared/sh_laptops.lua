Config.LaptopScript = 'lb-tablet'
--Suported laptop/tablet names:
--[[
    default
    lb-tablet
    fd_laptop
]]

if not IsDuplicityVersion() then
    Config.SendAppMessage = function(event, data)
        local id = GetCurrentResourceName()

        if Config.LaptopScript == 'lb-tablet' then
            exports["lb-tablet"]:SendCustomAppMessage(id, event, {
                type = event, data = data
            })
        elseif Config.LaptopScript == 'fd_laptop' then
            exports.fd_laptop:sendAppMessage(id, {
                type = event,
                action = event,
                data = data
            })
        end
    end
end

Config.LaptopOpened = function()
    --Client-side code to run when laptop is opened
end

Config.LaptopClosed = function()
    --Client-side code to run when laptop is closed
end

CreateThread(function()
    local id = GetCurrentResourceName()
    local url = GetResourceMetadata(id, "ui_page", 0)
    local appLabel = "Gruppe sechs"
    local appDescription = "This app allows Gruppe Sechs workers to monitor and manage their contracts"

    if Config.LaptopScript == 'lb-tablet' and not IsDuplicityVersion() then
        exports["lb-tablet"]:AddCustomApp({
            identifier = id,
            name = appLabel,
            description = appDescription,
            icon = "web/dist/app_logo.png",
            ui = url,
            defaultApp = true,
            onOpen = function()
                Config.LaptopOpened()
            end,
            onClose = function()
                Config.LaptopClosed()
            end,
        })
    elseif Config.LaptopScript == 'fd_laptop' and IsDuplicityVersion() then
        local added, errorMessage = exports.fd_laptop:addCustomApp({
            id = id,
            name = appLabel,
            isDefaultApp = true,
            icon = ("https://cfx-nui-%s/web/dist/app_logo.png"):format(id),
            ui = ("https://cfx-nui-%s/web/dist/index.html"):format(id),
            keepAlive = true,
            ignoreInternalLoading = true,
            windowActions = {
                isResizable = false,
                isMaximizable = false,
                isClosable = true,
                isMinimizable = true,
                isDraggable = false
            },
            windowDefaultStates = {
                isMaximized = true,
                isMinimized = false
            },
        })
    end
end)