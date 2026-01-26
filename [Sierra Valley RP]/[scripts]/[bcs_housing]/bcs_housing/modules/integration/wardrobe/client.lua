function OpenWardrobe(identifier)
    if IsResourceStarted('nf-skin') then
        TriggerEvent('nf-skin:client:openOutfitMenu')
    elseif IsResourceStarted('bl_appearance') then
        exports.bl_appearance:OpenMenu('outfits')
    elseif IsResourceStarted('izzy-appearance') then
        TriggerEvent('izzy-appearance:client:openClothingMenu')
    elseif IsResourceStarted('codem-appearance') then
        TriggerEvent('codem-apperance:OpenWardrobe')
    elseif IsResourceStarted('hex_clothing') then
        TriggerEvent('hex_clothing:openOutfitMenu')
    elseif IsResourceStarted('rcore_clothes') then
        TriggerEvent("rcore_clothes:openOutfits")
    elseif IsResourceStarted('onex-creation') then
        TriggerEvent("onex-creation:openOutfitMenu")
    elseif IsResourceStarted('rcore_clothing') then
        TriggerEvent('rcore_clothing:openChangingRoom')
    elseif Config.framework == 'QB' and not IsResourceStarted("illenium-appearance") then
        TriggerServerEvent("InteractSound_SV:PlayOnSource", "Clothes1", 0.4)
        TriggerEvent("qb-clothing:client:openOutfitMenu")
    elseif IsResourceStarted("illenium-appearance") then
        TriggerEvent("illenium-appearance:client:openOutfitMenu")
    else
        lib.callback("Housing:server:GetWardrobe", false, function(list)
            if GetResourceState("ox_lib") == "started" then
                local options = {}
                for i = 1, #list, 1 do
                    table.insert(options, { label = list[i] })
                end
                if #options == 0 then
                    table.insert(options, { label = locale('no_outfit') })
                end
                lib.registerMenu({
                    id = "wardrobe_change",
                    title = locale("wardrobe"),
                    position = "top-right",
                    onSideScroll = function(selected, scrollIndex, args) end,
                    onSelected = function(selected, scrollIndex, args) end,
                    onClose = function() end,
                    options = options,
                }, function(selected, scrollIndex, args)
                    if #options > 0 then
                        lib.callback("Housing:server:GetOutfit", false, function(clothes)
                            if IsResourceStarted("fivem-appearance") or IsResourceStarted("illenium-appearance") then
                                if not clothes.model then
                                    clothes.model = "mp_m_freemode_01"
                                end
                                if IsResourceStarted("fivem-appearance") then
                                    exports["fivem-appearance"]:setPlayerAppearance(clothes)
                                else
                                    TriggerEvent('illenium-appearance:client:changeOutfit', clothes)
                                end
                                Notify(locale("wardrobe"), locale("loaded_outfit"), "success", 2500)
                            else
                                TriggerEvent("skinchanger:getSkin", function(skin)
                                    TriggerEvent("skinchanger:loadClothes", skin, clothes)
                                    TriggerEvent("esx_skin:setLastSkin", skin)

                                    TriggerEvent("skinchanger:getSkin", function(skin)
                                        TriggerServerEvent("esx_skin:save", skin)
                                        Notify(locale("wardrobe"), locale("loaded_outfit"), "success", 2500)
                                    end)
                                end)
                            end
                        end, identifier, options[selected].label)
                    end
                end)
                lib.registerMenu({
                    id = "wardrobe_delete",
                    title = locale("wardrobe"),
                    position = "top-right",
                    onSideScroll = function(selected, scrollIndex, args) end,
                    onSelected = function(selected, scrollIndex, args) end,
                    onClose = function() end,
                    options = options,
                }, function(selected, scrollIndex, args)
                    if #options > 0 then
                        TriggerServerEvent("Housing:server:DeleteOutfit", identifier, options[selected].label)
                    end
                end)
                lib.showContext("wardrobe_menu")
            end
        end, identifier)
    end
end

function SaveOutfit(name)
    if IsResourceStarted("fivem-appearance") or IsResourceStarted("illenium-appearance") then
        local appearance
        if IsResourceStarted("fivem-appearance") then
            appearance = exports["fivem-appearance"]:getPedAppearance(PlayerPedId())
        else
            appearance = exports["illenium-appearance"]:getPedAppearance(PlayerPedId())
        end
        TriggerServerEvent("Housing:server:SaveOutfit", CurrentHome.identifier, name, appearance)
        Notify(locale("wardrobe"), locale("saved_outfit"), "success", 2500)
    else
        TriggerEvent("skinchanger:getSkin", function(skin)
            TriggerServerEvent("Housing:server:SaveOutfit", CurrentHome.identifier, name, skin)
            Notify(locale("wardrobe"), locale("saved_outfit"), "success", 2500)
        end)
    end
end

function WardrobePrompt(home)
    CreateThread(function()
        if home:isKeyOwner() or home:isTenant('wardrobe') then
            HelpText(true, locale("prompt_open_wardrobe"))
            while inZone do
                Wait(2)
                if IsControlJustReleased(0, 38) then
                    HelpText(false)
                    OpenWardrobe(home.identifier)
                    break
                end
            end
            while IsNuiFocused() do
                Wait(100)
            end
            Wait(1000)
            if inZone then
                WardrobePrompt(home)
            end
        end
    end)
end
