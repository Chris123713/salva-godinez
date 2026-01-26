function ProgressOpen(isAtm)
    return lib.progressBar({
        duration = 750,
        label = isAtm and locale('open_atm_progress') or locale('open_bank_progress'),
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true,
            car = true,
            combat = true,
        },
    })
end

---@param data { atm: boolean, entity: number, cardNumber?: string }
---@param cards { cardId: string, cardNumber: string, displayName: string, expirationDate: string, slot: number }[]
function ShowCardSelectionMenu(data, cards)
    local contextOptions = {}

    for i = 1, #cards do
        local card = cards[i]
        local cardNumber = card?.cardNumber or 'Unknown'
        local displayName = card?.displayName or 'Unknown Card'
        local expirationDate = card?.expirationDate or 'N/A'

        contextOptions[#contextOptions + 1] = {
            title = displayName,
            description = locale('cards.cardNumberLabel') .. ': ' .. cardNumber,
            icon = 'credit-card',
            metadata = {
                { label = locale('cards.cardNumber'), value = cardNumber },
                { label = locale('cards.expiration'), value = expirationDate },
                { label = locale('cards.slot'),       value = card.slot }
            },
            onSelect = function()
                lib.hideContext()
                ProcessATMWithCard(data, cardNumber)
            end
        }
    end

    lib.registerContext({
        id = 'atm_card_selection',
        title = locale('cards.selectCard'),
        canClose = true,
        options = contextOptions
    })

    lib.showContext('atm_card_selection')
end

local function createPed(model, coords, bankName)
    local point = lib.points.new({
        coords = coords,
        distance = 40,
        ped = nil
    })

    function point:onEnter()
        debugPrint('onEnter: triggered')

        lib.requestModel(model)
        self.ped = CreatePed(6, model, coords.x, coords.y, coords.z - 0.9, coords.w, false, false)
        FreezeEntityPosition(self.ped, true)
        SetEntityInvincible(self.ped, true)
        SetBlockingOfNonTemporaryEvents(self.ped, true)
        SetModelAsNoLongerNeeded(model)

        CreatePedInteract(self.ped, bankName)

        debugPrint('onEnter: ped created')
    end

    function point:onExit()
        debugPrint('onExit: triggered')

        if not self.ped then return end
        DeleteEntity(self.ped)
        self.ped = nil

        debugPrint('onExit: ped deleted')
    end
end

CreateThread(function()
    lib.array.forEach(Config.BankLocations, function(location)
        local blip = AddBlipForCoord(location.coords.x, location.coords.y, location.coords.z)
        SetBlipSprite(blip, 108)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.8)
        SetBlipColour(blip, 2)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(locale('bank_label'))
        EndTextCommandSetBlipName(blip)

        createPed(location.model, location.coords, location.bankName)
    end)

    CreateModelInteract(Config.Atms)
end)
