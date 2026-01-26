local resName = GetCurrentResourceName();

RegisterNetEvent('takeScreenshot', function(filename, type)
    local src = source
    local savePath = GetResourcePath(resName) .. '/html/images'
    exports['screenshot-basic']:requestClientScreenshot(
        src,
        {
            fileName = savePath .. '/' .. type .. '/' .. filename .. '.png',
            encoding = 'png',
            quality = 1.0,
        },
        function(err, fileName)
            TriggerClientEvent('continueScreenshot', src);
        end
    );
end)
