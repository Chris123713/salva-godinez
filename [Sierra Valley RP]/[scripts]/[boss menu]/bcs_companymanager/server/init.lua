function DatabaseCheck()
	Database.ConfigureBanking()
	Database.Convert()
end

function InitializeCompanyManager()
	for k, v in pairs(Config.billing) do
		local result = MySQL.query.await(
			'SELECT * FROM ' .. Config.Database.Company .. ' WHERE ' ..
			Config.Database.CompanyColumns.Job .. ' = ? LIMIT 1', { k })
		if not result then print('Job ' .. k .. ' does not exists please remove in Config/billing.lua') end
	end

	-- local companies = MySQL.query.await("SELECT * FROM " .. Config.Database.Company)
	-- for i = 1, #companies do
	-- 	local data = companies[i]
	-- 	if Config.bossmenu[data[Config.Database.CompanyColumns.Job]] or Config.gangs[data[Config.Database.CompanyColumns.Job]] then
	-- 		Companies[i] = Company:SetAccount(data)
	-- 	end
	-- end


	if Config.DeletePaid then
		for i = 1, #Companies do
			local bills = MySQL.query.await(
				'SELECT SUM(price) AS earning FROM billings WHERE company= ? AND `status`="paid"',
				{ Companies[i].name })
			if bills then
				for i = 1, #bills do
					if bills[1].earning then
						Companies[i].account:AddEarning(bills[1].earning)
						MySQL.prepare(
							"DELETE FROM " .. Config.Database.Bill .. ' WHERE `status`="paid" AND `company`= ?',
							{ Companies[i].name })
					end
				end
			end
		end
	end
end

function VersionCheck(repository)
	local currentVersion = GetResourceMetadata(cache.resource, "version", 0)

	if currentVersion then
		currentVersion = currentVersion:match("%d%.%d+%.%d+")
	end

	if not currentVersion then
		return print(("^1Unable to determine current resource version for '%s' ^0"):format(cache.resource))
	end

	SetTimeout(1000, function()
		PerformHttpRequest(
			("https://api.github.com/repos/%s/releases/latest"):format(repository),
			function(status, response)
				if status ~= 200 then
					return
				end

				response = json.decode(response)
				if response.prerelease then
					return
				end

				local latestVersion = response.tag_name:match("%d%.%d+%.%d+")
				if not latestVersion or latestVersion == currentVersion then
					return
				end

				local cMajor, cMinor = string.strsplit(".", currentVersion, 2)
				local lMajor, lMinor = string.strsplit(".", latestVersion, 2)

				if tonumber(cMajor) < tonumber(lMajor) or tonumber(cMinor) < tonumber(lMinor) then
					return print(
						("^3An update is available for %s (current version: %s)\r\n%s^0"):format(
							cache.resource,
							currentVersion,
							response.html_url
						)
					)
				end
			end,
			"GET"
		)
	end)
end

VersionCheck("baguscodestudio/bcs-companymanager-control")

MySQL.ready(function()
	CreateThread(function(threadId)
		DatabaseCheck()
		while not Database.Ready do
			Wait(100)
		end
		InitializeCompanyManager()
		Framework.Initializes()
	end)
end)
