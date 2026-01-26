local TargetSystem = {}
local targetResource = nil
local isTargetSystemReady = false


local function detectTargetSystem()
    if Config.TargetSystem == false then
        targetResource = nil
        isTargetSystemReady = false
        return nil
    elseif Config.TargetSystem and Config.TargetSystem ~= 'auto' then
        if Config.TargetSystem == 'ox_target' and GetResourceState('ox_target') == 'started' then
            targetResource = 'ox_target'
            isTargetSystemReady = true
            return 'ox_target'
        elseif Config.TargetSystem == 'qb-target' and GetResourceState('qb-target') == 'started' then
            targetResource = 'qb-target'
            isTargetSystemReady = true
            return 'qb-target'
        elseif Config.TargetSystem == 'bt-target' and GetResourceState('bt-target') == 'started' then
            targetResource = 'bt-target'
            isTargetSystemReady = true
            return 'bt-target'
        elseif Config.TargetSystem == 'qtarget' and GetResourceState('qtarget') == 'started' then
            targetResource = 'qtarget'
            isTargetSystemReady = true
            return 'qtarget'
        elseif Config.TargetSystem == 'nh-context' and GetResourceState('nh-context') == 'started' then
            targetResource = 'nh-context'
            isTargetSystemReady = true
            return 'nh-context'
        end
    end
    
    -- Auto detection 
    if GetResourceState('ox_target') == 'started' then
        targetResource = 'ox_target'
        isTargetSystemReady = true
        return 'ox_target'
    elseif GetResourceState('qb-target') == 'started' then
        targetResource = 'qb-target'
        isTargetSystemReady = true
        return 'qb-target'
    elseif GetResourceState('bt-target') == 'started' then
        targetResource = 'bt-target'
        isTargetSystemReady = true
        return 'bt-target'
    elseif GetResourceState('qtarget') == 'started' then
        targetResource = 'qtarget'
        isTargetSystemReady = true
        return 'qtarget'
    elseif GetResourceState('nh-context') == 'started' then
        targetResource = 'nh-context'
        isTargetSystemReady = true
        return 'nh-context'
    else
        return nil
    end
end


function TargetSystem.AddNPCTarget(ped)
    if not isTargetSystemReady or not DoesEntityExist(ped) then
        return false
    end

    local options = {
        {
            type = "client",
            event = "siberwin_trucksimulator:openJobMenu",
            icon = "fas fa-truck",
            label = locale('start_job')
        }
    }

    if targetResource == 'ox_target' then
        -- ox_target 
        exports.ox_target:addLocalEntity(ped, options)
    elseif targetResource == 'qb-target' then
        -- qb-target 
        exports['qb-target']:AddTargetEntity(ped, {
            options = options,
            distance = 2.5
        })
    elseif targetResource == 'bt-target' then
        -- bt-target 
        exports['bt-target']:AddTargetEntity(ped, {
            options = options,
            distance = 2.5
        })
    elseif targetResource == 'qtarget' then
        -- qtarget
        exports.qtarget:AddTargetEntity(ped, {
            options = options,
            distance = 2.5
        })
    elseif targetResource == 'nh-context' then
        -- nh-context 
        exports['nh-context']:AddTargetEntity(ped, {
            options = options,
            distance = 2.5
        })
    end
    
    return true
end

function TargetSystem.RemoveNPCTarget(ped)
    if not isTargetSystemReady or not DoesEntityExist(ped) then
        return false
    end

    if targetResource == 'ox_target' then
       
        exports.ox_target:removeLocalEntity(ped)
    elseif targetResource == 'qb-target' then
     
        exports['qb-target']:RemoveTargetEntity(ped)
    elseif targetResource == 'bt-target' then
        
        exports['bt-target']:RemoveTargetEntity(ped)
    elseif targetResource == 'qtarget' then
      
        exports.qtarget:RemoveTargetEntity(ped)
    elseif targetResource == 'nh-context' then
      
        exports['nh-context']:RemoveTargetEntity(ped)
    end
    
    return true
end


function TargetSystem.CleanupAllTargets()
    if not isTargetSystemReady then
        return
    end

    if locationPeds and type(locationPeds) == "table" then
        for _, ped in ipairs(locationPeds) do
            if DoesEntityExist(ped) then
                TargetSystem.RemoveNPCTarget(ped)
            end
        end
    end
end


function TargetSystem.IsReady()
    return isTargetSystemReady
end

-- Generic AddTargetEntity function for custom entities
function TargetSystem.AddTargetEntity(ped, targetOptions)
    if not isTargetSystemReady or not DoesEntityExist(ped) then
        return false
    end

    if targetResource == 'ox_target' then
        exports.ox_target:addLocalEntity(ped, targetOptions.options)
    elseif targetResource == 'qb-target' then
        exports['qb-target']:AddTargetEntity(ped, targetOptions)
    elseif targetResource == 'bt-target' then
        exports['bt-target']:AddTargetEntity(ped, targetOptions)
    elseif targetResource == 'qtarget' then
        exports.qtarget:AddTargetEntity(ped, targetOptions)
    elseif targetResource == 'nh-context' then
        exports['nh-context']:AddTargetEntity(ped, targetOptions)
    end
    
    return true
end

-- Generic RemoveTargetEntity function for custom entities
function TargetSystem.RemoveTargetEntity(ped)
    if not isTargetSystemReady or not DoesEntityExist(ped) then
        return false
    end

    if targetResource == 'ox_target' then
        exports.ox_target:removeLocalEntity(ped)
    elseif targetResource == 'qb-target' then
        exports['qb-target']:RemoveTargetEntity(ped)
    elseif targetResource == 'bt-target' then
        exports['bt-target']:RemoveTargetEntity(ped)
    elseif targetResource == 'qtarget' then
        exports.qtarget:RemoveTargetEntity(ped)
    elseif targetResource == 'nh-context' then
        exports['nh-context']:RemoveTargetEntity(ped)
    end
    
    return true
end

function TargetSystem.GetTargetResource()
    return targetResource
end


function TargetSystem.Initialize()
    Citizen.Wait(1000) 
    
    detectTargetSystem()
    
    if isTargetSystemReady then
        
        RegisterNetEvent('siberwin_trucksimulator:openJobMenu')
        AddEventHandler('siberwin_trucksimulator:openJobMenu', function()
            local jobStatus = exports.siberwin_trucksimulator:GetJobStartedStatus()
            local canShow = exports.siberwin_trucksimulator:GetCanShowUiStatus()
            
            if not jobStatus and canShow then
            
                OpenTruckerMenu()
                
                local NuiAPI = exports.siberwin_trucksimulator:GetNuiAPI()
                if NuiAPI and NuiAPI.SetMenuOpen then
                    NuiAPI.SetMenuOpen(true)
                end
            else
                if jobStatus then
                    if lib and lib.notify then
                        lib.notify({
                            title = "Error",
                            description = "You already have an active job",
                            type = 'error'
                        })
                    end
                else
                    if lib and lib.notify then
                        lib.notify({
                            title = "Error", 
                            description = "You don't have access to start jobs",
                            type = 'error'
                        })
                    end
                end
            end
        end)
    end
end

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        TargetSystem.CleanupAllTargets()
    end
end)

return TargetSystem