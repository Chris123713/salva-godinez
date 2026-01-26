local CustomerRegisterTargets = {}
RegisterNetEvent('Pug:client:UseBusinessRegisters', function()
    Config.FrameworkFunctions.TriggerCallback("Pug:serverCB:GetNearbyCusomers", function(Data)
        if Data then
            if Config.Input == "ox_lib" then
                local Input = lib.inputDialog(Config.FrameworkFunctions.GetPlayer(true, false, true).PlayerData.job.name.." Cash Register", {
                    {
                        label = " ",
                        name = "cid",
                        type = "select",
                        isRequired = true ,
                        options = Data 
                    },
                    { 
                        label = 'Payment Type', 
                        name = 'currency', 
                        type = 'select', 
                        isRequired = true ,
                        options = { 
                            { value = "cash", label = "Cash" }, 
                            { value = "card", label = "Card" } 
                        } 
                    }, 
                    {
                        label = "Price Of Purchase",
                        name = "price",
                        type = "number",
                        isRequired = true
                    },
                })
                if Input then 
                    ClearPedTasksImmediately(PlayerPedId())
                    local Currency = tostring(Input[2])
                    if not Currency then
                        BusinessNotify(Config.LangT["MissingCurrency"], "error")
                        return
                    end
                    local Amount = tonumber(Input[3])
                    if not Amount then
                        BusinessNotify(Config.LangT["MissingPrice"], "error")
                        return
                    end
                    TriggerServerEvent('Pug:server:RegistersChargeCustomer', Input[1], Currency, Amount)
                else
                    ClearPedTasksImmediately(PlayerPedId())
                    BusinessNotify(Config.LangT["MissingInput"], "error")
                end
            else
                local Input = exports[Config.Input]:ShowInput({
                    header = Config.FrameworkFunctions.GetPlayer(true, false, true).PlayerData.job.name.." Cash Register",
                    submitText = "Submit",
                    inputs = {
                        {
                            text = " ",
                            name = "cid",
                            type = "select",
                            isRequired = true ,
                            options = Data 
                        },
                        { 
                            text = 'Payment Type', 
                            name = 'currency', 
                            type = 'radio', 
                            isRequired = true ,
                            options = { 
                                { value = "cash", text = "Cash" }, 
                                { value = "card", text = "Card" } 
                            } 
                        }, 
                        {
                            text = "$ Price Of Purchase",
                            name = "price",
                            type = "number",
                            isRequired = true
                        },
                    },
                })
                if Input then
                    ClearPedTasksImmediately(PlayerPedId())
                    if not Input.price then
                        BusinessNotify(Config.LangT["MissingPrice"], "error")
                        return
                    else
                        TriggerServerEvent('Pug:server:RegistersChargeCustomer', Input.cid, Input.currency, Input.price)
                    end
                else
                    ClearPedTasksImmediately(PlayerPedId())
                    BusinessNotify(Config.LangT["MissingInput"], "error")
                end
            end
        end
    end, GetEntityCoords(PlayerPedId()))
end)

RegisterNetEvent("Pug:Client:CreateCustomerRegisters", function(Job, Amount, src, Currency, Data)
    if Config.Target == "ox_target" then
        for k, v in pairs(Data) do
            local ThisJob = Data["job"]
            if tostring(k) == "registers" then
                for u, _ in pairs(CustomerRegisterTargets) do
                    local TargetName = ThisJob..u..k.."2"
                    if CustomerRegisterTargets[TargetName] ~= nil then
                        exports.ox_target:removeZone(CustomerRegisterTargets[TargetName])
                        CustomerRegisterTargets[TargetName] = nil
                    end
                end
            end
        end
    else
        for k, v in pairs(Data) do
            local ThisJob = Data["job"]
            if tostring(k) == "registers" then
                for u, _ in pairs(CustomerRegisterTargets) do
                    local TargetName = ThisJob..u..k.."2"
                    exports[Config.Target]:RemoveZone(TargetName)
                end
            end
        end
    end
	Wait(100)
	for k, v in pairs(Data) do
		ThisJob = Data["job"]
        if ThisJob == Job then
            if tostring(k) == "registers" then
                for u, i in pairs(json.decode(Data["registers"])) do
                    local TargetName = ThisJob..u..k.."2"
                    local Info = i
                    if Config.Target == "ox_target" then
                        local Data = {
                            Info = Data,
                            Amount = Amount, 
                            Source = src,
                            Currency = Currency,

                        }
                        CustomerRegisterTargets[TargetName] = exports.ox_target:addBoxZone({
                            coords = vector3(Info.Target.x,Info.Target.y,Info.Target.z),
                            size = vector3(1.5, 1, 1.5),
                            rotation = 35,
                            debug = Config.Debug,
                            options = {
                                {
                                    name= TargetName,
                                    type = "client",
                                    event = "Pug:Client:DoBusinessCustomerRegisteranLogic",
                                    args = Data,
                                    icon = "fa-solid fa-print",
                                    label = "Pay $"..Amount,
                                    distance = 2.0
                                }
                            }
                        })
                    else
                        CustomerRegisterTargets[u] = v
                        exports[Config.Target]:AddBoxZone(TargetName, vector3(Info.Target.x,Info.Target.y,Info.Target.z), 0.4, 0.4, {
                            name=TargetName,
                            heading=35,
                            debugPoly = Config.Debug,
                            minZ= Info.Target.z-0.3,
                            maxZ= Info.Target.z+0.3,
                        }, {
                            options = {
                                {
                                    icon = "fa-solid fa-print",
                                    label =  "Pay $"..Amount,
                                    event = " ",
                                    action = function()
                                        local Data = {
                                            args = {
                                                Info = Data,
                                                Amount = Amount, 
                                                Source = src,
                                                Currency = Currency,
                                            }
                                        }
                                        TriggerEvent("Pug:Client:DoBusinessCustomerRegisteranLogic", Data)
                                    end,
                                },
                            },
                            distance = 2.0
                        })
                    end
                end
            end
        end
	end
end)

RegisterNetEvent("Pug:Client:DoBusinessCustomerRegisteranLogic", function(Logic)
    local Data = Logic.args.Info
    Config.FrameworkFunctions.TriggerCallback("Pug:serverCB:GetBalanceBusinessCreator", function(result)
		if result then
            TriggerServerEvent("Pug:server:RemoveAllBuinessRegistersForEveryone", Logic)
        end
    end, Logic.args.Currency, Logic.args.Amount, Logic.args.Source)
end)
RegisterNetEvent("Pug:Client:RemoveAllBuinessRegistersForEveryone", function(Logic)
    local Data = Logic.args.Info
    if Config.Target == "ox_target" then
        for k, v in pairs(Data) do
            if tostring(k) == "registers" then
                for u, _ in pairs(CustomerRegisterTargets) do
                    local TargetName = u
                    if CustomerRegisterTargets[TargetName] then
                        exports.ox_target:removeZone(CustomerRegisterTargets[TargetName])
                        CustomerRegisterTargets[TargetName] = nil
                    end
                end
            end
        end
    else
        for k, v in pairs(Data) do
            local ThisJob = Data["job"]
            if tostring(k) == "registers" then
                for u, _ in pairs(CustomerRegisterTargets) do
                    local TargetName = ThisJob..u..k.."2"
                    exports[Config.Target]:RemoveZone(TargetName)
                    CustomerRegisterTargets[TargetName] = nil
                end
            end
        end
    end
end)