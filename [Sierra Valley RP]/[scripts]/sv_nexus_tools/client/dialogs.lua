-- NPC Dialog System

local Dialogs = {}

-- Current dialog state
local CurrentDialog = nil

-- Start a dialog with an NPC
function Dialogs.Start(npcNetId, dialogTree)
    if CurrentDialog then
        Dialogs.End()
    end

    CurrentDialog = {
        npcNetId = npcNetId,
        tree = dialogTree,
        currentNode = 'start',
        history = {}
    }

    ClientUtils.PlaySound('DIALOG')
    Dialogs.ShowNode(CurrentDialog.tree.nodes.start)
end

-- Show a dialog node
function Dialogs.ShowNode(node)
    if not node then
        Dialogs.End()
        return
    end

    local options = {}

    for i, choice in ipairs(node.choices or {}) do
        local canSelect = true
        local label = choice.label

        -- Check conditions
        if choice.condition then
            canSelect = Dialogs.CheckCondition(choice.condition)
            if not canSelect and choice.condition.type == 'money' then
                label = label .. ' [Insufficient funds]'
            elseif not canSelect and choice.condition.type == 'item' then
                label = label .. ' [Missing item]'
            end
        end

        options[#options + 1] = {
            title = label,
            disabled = not canSelect,
            onSelect = function()
                Dialogs.SelectChoice(choice)
            end,
            metadata = choice.outcome and {
                {label = 'Outcome', value = Dialogs.GetOutcomeDescription(choice.outcome)}
            } or nil
        }
    end

    -- Add back option if we have history
    if #CurrentDialog.history > 0 then
        options[#options + 1] = {
            title = '< Go Back',
            onSelect = function()
                local prevNode = table.remove(CurrentDialog.history)
                Dialogs.ShowNode(CurrentDialog.tree.nodes[prevNode])
            end
        }
    end

    -- Add exit option
    options[#options + 1] = {
        title = 'End Conversation',
        onSelect = function()
            Dialogs.End()
        end
    }

    lib.registerContext({
        id = 'npc_dialog',
        title = CurrentDialog.tree.npcName or 'Conversation',
        description = node.text,
        options = options
    })

    lib.showContext('npc_dialog')
end

-- Check if condition is met
function Dialogs.CheckCondition(condition)
    if condition.type == 'money' then
        local result = lib.callback.await('nexus:checkMoney', false, {
            moneyType = condition.moneyType or 'cash',
            amount = condition.amount
        })
        return result and result.balance >= condition.amount
    elseif condition.type == 'item' then
        local result = lib.callback.await('nexus:checkItem', false, {
            item = condition.item,
            count = condition.count or 1
        })
        return result and result.hasItem
    elseif condition.type == 'job' then
        local playerData = exports.qbx_core:GetPlayerData()
        return playerData.job.name == condition.job
    elseif condition.type == 'objective' then
        local mission = lib.callback.await('nexus:getActiveMission', false)
        if mission and mission.objectives then
            local obj = mission.objectives[condition.objectiveId]
            return obj and obj.status == (condition.status or Constants.ObjectiveStatus.COMPLETED)
        end
        return false
    end

    return true
end

-- Get outcome description for display
function Dialogs.GetOutcomeDescription(outcome)
    if outcome.type == 'money' then
        return ('Pay $%d'):format(outcome.amount)
    elseif outcome.type == 'item' then
        return ('Give %dx %s'):format(outcome.count or 1, outcome.item)
    elseif outcome.type == 'objective' then
        return 'Advances mission'
    end
    return ''
end

-- Select a dialog choice
function Dialogs.SelectChoice(choice)
    ClientUtils.PlaySound('SUCCESS')

    -- Handle outcome
    if choice.outcome then
        Dialogs.HandleOutcome(choice.outcome)
    end

    -- Navigate to next node
    if choice.next then
        if choice.next == 'exit' then
            Dialogs.End()
        else
            -- Save current node to history
            table.insert(CurrentDialog.history, CurrentDialog.currentNode)
            CurrentDialog.currentNode = choice.next

            local nextNode = CurrentDialog.tree.nodes[choice.next]
            Dialogs.ShowNode(nextNode)
        end
    else
        Dialogs.End()
    end
end

-- Handle outcome of a choice
function Dialogs.HandleOutcome(outcome)
    if outcome.type == 'deduct_money' or outcome.type == 'money' then
        TriggerServerEvent('nexus:server:dialogOutcome', {
            type = 'deduct_money',
            moneyType = outcome.moneyType or 'cash',
            amount = outcome.amount,
            reason = 'Dialog payment'
        })
    elseif outcome.type == 'give_item' then
        TriggerServerEvent('nexus:server:dialogOutcome', {
            type = 'give_item',
            item = outcome.item,
            count = outcome.count or 1
        })
    elseif outcome.type == 'take_item' then
        TriggerServerEvent('nexus:server:dialogOutcome', {
            type = 'take_item',
            item = outcome.item,
            count = outcome.count or 1
        })
    elseif outcome.type == 'unlock_objective' then
        TriggerServerEvent('nexus:server:dialogOutcome', {
            type = 'unlock_objective',
            objectiveId = outcome.objectiveId
        })
    elseif outcome.type == 'event' then
        TriggerServerEvent(outcome.eventName, outcome.eventData)
    end
end

-- End dialog
function Dialogs.End()
    if CurrentDialog then
        ClientUtils.Debug('Dialog ended')
        CurrentDialog = nil
    end
    lib.hideContext()
end

-- Event to start dialog from server
RegisterNetEvent('nexus:client:dialogStart', function(data)
    Dialogs.Start(data.npcNetId, data.dialogTree)
end)

-- Server callback for money check
lib.callback.register('nexus:checkMoney', function(data)
    -- This would be handled server-side in practice
    local playerData = exports.qbx_core:GetPlayerData()
    local balance = playerData.money[data.moneyType or 'cash'] or 0
    return {balance = balance}
end)

-- Server callback for item check
lib.callback.register('nexus:checkItem', function(data)
    local count = exports.ox_inventory:Search('count', data.item)
    if type(count) == 'table' then
        local total = 0
        for _, c in pairs(count) do total = total + c end
        count = total
    end
    return {
        hasItem = (count or 0) >= (data.count or 1),
        count = count or 0
    }
end)

return Dialogs
