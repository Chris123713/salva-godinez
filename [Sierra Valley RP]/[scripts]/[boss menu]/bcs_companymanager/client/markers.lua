CreateThread(function()
    for job, coords in pairs(Config.Points) do
        for i = 1, #coords do
            if Config.Target then
                Utils.Target.AddTargetBoxZone(job .. '-BossMenu-' .. i, {
                    coords = vec3(coords[i].x, coords[i].y, coords[i].z),
                    length = 1.5,
                    width = 1.5,
                    heading = coords[i].w,
                    debugPoly = Config.Debug,
                    minZ = coords[i].z - (2.2 / 2),
                    maxZ = coords[i].z + (2.2 / 2),
                }, {
                    options = {
                        {
                            action = function()
                                TriggerEvent('CompanyManager:client:OpenBossMenu', job)
                            end,
                            icon = "fas fa-sign-in-alt",
                            label = locale('open_boss_menu'),
                            canInteract = function()
                                return IsJobAllowed(job)
                            end,
                        }
                    },
                    distance = 3.5,
                })
            else
                lib.points.new({
                    coords = vec3(coords[i].x, coords[i].y, coords[i].z),
                    distance = 3.0,
                    onEnter = function()
                        if IsJobAllowed(job) then
                            Framework.HelpText(true, locale('bossmenu_prompt'))
                        end
                    end,
                    nearby = function(self)
                        if IsJobAllowed(job) then
                            DrawMarker(1, coords[i], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 1.0, 255, 128, 0, 255, false,
                                false, 2, nil, nil, false)
                            if self.currentDistance <= 1.5 and IsControlJustReleased(0, 38) then
                                TriggerEvent('CompanyManager:client:OpenBossMenu', job)
                            end
                        end
                    end,
                    onExit = function()
                        if IsJobAllowed(job) then
                            Framework.HelpText(false)
                        end
                    end
                })
            end
        end
    end

    for job, v in pairs(Config.Duty) do
        local coords = v.coords
        for i = 1, #coords do
            if Config.Target then
                Utils.Target.AddTargetBoxZone(job .. '-Duty-' .. i, {
                    coords = vec3(coords[i].x, coords[i].y, coords[i].z),
                    length = 1.5,
                    width = 1.5,
                    heading = coords[i].w,
                    debugPoly = Config.Debug,
                    minZ = coords[i].z - (2.2 / 2),
                    maxZ = coords[i].z + (2.2 / 2),
                }, {
                    options = {
                        {
                            icon = "fas fa-sign-in-alt",
                            label = locale('on_off_duty'),
                            action = function()
                                TriggerServerEvent('CompanyManager:server:ToggleDuty')
                            end,
                            canInteract = function()
                                return IsJobAllowed(job, true)
                            end,
                        }
                    },
                    distance = 3.5,
                })
            else
                lib.points.new({
                    coords = vec3(coords[i].x, coords[i].y, coords[i].z),
                    distance = 3.0,
                    onEnter = function()
                        while not IsJobAllowed do
                            Wait(150)
                        end
                        if IsJobAllowed(job, true) then
                            Framework.HelpText(true, locale('duty_prompt'))
                        end
                    end,
                    nearby = function(self)
                        if IsJobAllowed(job, true) then
                            DrawMarker(1, vec3(coords[i].x, coords[i].y, coords[i].z), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5,
                                1.5,
                                1.0, 255, 128, 0, 255, false,
                                false, 2, nil, nil, false)
                            if self.currentDistance <= 1.5 and IsControlJustReleased(0, 38) then
                                TriggerServerEvent('CompanyManager:server:ToggleDuty')
                            end
                        end
                    end,
                    onExit = function()
                        if IsJobAllowed(job, true) then
                            Framework.HelpText(false)
                        end
                    end
                })
            end
        end
    end
end)
