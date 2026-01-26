--------------------------------------
--<!>-- ASTUDIOS | DEVELOPMENT --<!>--
--------------------------------------
local QBCore = exports['qb-core']:GetCoreObject()
local surfboardItem = Config.BoardItem

QBCore.Functions.CreateUseableItem(surfboardItem, function(source)
    TriggerClientEvent('astudios-surfboarding:client:use', source)
end)