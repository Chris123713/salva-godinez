-- Server handler to mark a vehicle as a job vehicle
RegisterNetEvent("jg-mechanic:server:set-job-vehicle", function(plate, jobName, rank)
  local src = source
  if not plate or type(plate) ~= "string" then
    TriggerClientEvent("jg-mechanic:client:notify", src, "Invalid plate.", "error")
    return
  end

  -- Allowed department/job list
  local allowed = { police = true, lscso = true, safr = true }

  local targetJobName = nil
  local targetRank = 0

  if jobName and type(jobName) == "string" and jobName ~= "" then
    local jobNameLower = tostring(jobName):lower()
    if not allowed[jobNameLower] then
      TriggerClientEvent("jg-mechanic:client:notify", src, "Only police/sheriff/SAFR jobs can be assigned as department vehicles.", "error")
      return
    end
    targetJobName = jobName
    targetRank = tonumber(rank) or 0
  else
    local job = Framework.Server.GetPlayerJob(src)
    if not job or not job.name then
      TriggerClientEvent("jg-mechanic:client:notify", src, "You must have a job to use this.", "error")
      return
    end
    local jobNameLower = tostring(job.name):lower()
    if not allowed[jobNameLower] then
      TriggerClientEvent("jg-mechanic:client:notify", src, "Only police/sheriff/SAFR jobs can set department vehicles.", "error")
      return
    end
    targetJobName = job.name
    targetRank = job.grade or 0
  end

  local ok, err = pcall(function()
    MySQL.update.await("UPDATE " .. Framework.VehiclesTable .. " SET " .. Framework.PlayerIdentifier .. " = ?, job_vehicle = 1, job_vehicle_rank = ? WHERE plate = ?", {targetJobName, targetRank, plate})
  end)

  if not ok then
    TriggerClientEvent("jg-mechanic:client:notify", src, "Database error.", "error")
    print(("[jg-mechanic] set-job-vehicle DB error: %s"):format(tostring(err)))
    return
  end

  TriggerClientEvent("jg-mechanic:client:notify", src, (Locale and Locale.jobVehicleSet) or "Job vehicle set.", "success")
end)
