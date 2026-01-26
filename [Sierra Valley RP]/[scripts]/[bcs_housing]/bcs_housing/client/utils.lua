--- A simple wrapper around SendNUIMessage that you can use to
--- dispatch actions to the React frame.
---
---@param action string The action you wish to target
---@param data any The data you wish to send along with this action
function SendReactMessage(action, data)
  SendNUIMessage({
    action = action,
    data = data
  })
end

function ToggleNuiFrame(shouldShow)
  if shouldShow then
    local player = {
      identifier = GetIdentifier(),
      role = 'user'
    }
    player.role = isAdmin() and 'admin' or 'user'
    if PlayerData.job and JobConfig.jobs[PlayerData.job.name] and player.role ~= 'admin' then
      player.role = 'realestate'
      player.job = PlayerData.job.name
    end
    SendReactMessage('setPlayer', player)
  else
    SendReactMessage('setPlayer', {
      identifier = GetIdentifier(),
      role = 'user'
    })
  end
  SetNuiFocus(shouldShow, shouldShow)
  SendReactMessage('setVisible', shouldShow)
end
