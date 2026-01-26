-- Client command to mark the current vehicle as a job vehicle
RegisterCommand("setjobvehicle", function(source, args, raw)
  local ped = PlayerPedId()
  local veh = GetVehiclePedIsIn(ped, false)
  if veh == 0 then
    TriggerEvent("jg-mechanic:client:notify", "You must be in a vehicle.", "error")
    return
  end

  local plate = GetVehicleNumberPlateText(veh)
  if not plate or plate == "" then
    TriggerEvent("jg-mechanic:client:notify", "Could not read plate.", "error")
    return
  end

  plate = string.gsub(plate, "^%s*(.-)%s*$", "%1")

  -- args: [1] = jobName (e.g. safr), [2] = rank (e.g. 0)
  local jobName = args[1]
  local rank = nil
  if args[2] then
    rank = tonumber(args[2]) or 0
  end

  if jobName and type(jobName) ~= "string" then
    TriggerEvent("jg-mechanic:client:notify", "Invalid job name.", "error")
    return
  end

  TriggerServerEvent("jg-mechanic:server:set-job-vehicle", plate, jobName, rank)
end, false)

-- Optional suggestion: bind a chat suggestion if `RegisterCommand` suggestions are supported
if RegisterCommand then
  TriggerEvent('chat:addSuggestion', '/setjobvehicle', 'Mark current vehicle as a job vehicle (usage: /setjobvehicle <jobName> <rank>)')
end
