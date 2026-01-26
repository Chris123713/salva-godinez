function AddCompanyMoney(job, account, amount, identifier, reason, isPaying)
	local company = Core.GetCompany(job)

	if company then
		company.account:AddMoney(account, amount, identifier, reason, isPaying)
	else
		Utils.DebugWarn(('\27[31m[%s] ^0Trying to add money to a company that does not exist! please add %s in config/bossmenu.lua')
			:format('AddCompanyMoney', job))
	end
end

exports('AddCompanyMoney', AddCompanyMoney)

function RemoveCompanyMoney(job, account, amount, identifier, reason, isPaying)
	local company = Core.GetCompany(job)

	if company then
		company.account:RemoveMoney(account, amount, identifier, reason, isPaying)
	else
		Utils.DebugWarn(('\27[31m[%s] ^0Trying to remove money to a company that does not exist! please add %s in config/bossmenu.lua')
			:format('RemoveCompanyMoney', job))
	end
end

exports('RemoveCompanyMoney', RemoveCompanyMoney)

function GetCompanyMoney(job, account)
	local company = Core.GetCompany(job)

	if company then
		return company.account:GetMoney(account)
	else
		Utils.DebugWarn(('\27[31m[%s] ^0Trying to get money from a company that does not exist! Please add %s in config/bossmenu.lua\27[0m')
			:format('GetCompanyMoney', job))
	end
end

exports('GetCompanyMoney', GetCompanyMoney)

function math.round(num, idp)
	return tonumber(string.format("%." .. (idp or 0) .. "f", num))
end

local function CountTotalSalary(salary, duration)
	if Config.PayCheck.PerHour then
		return math.round((salary / 60) * duration)
	else
		return math.round(salary * duration)
	end
end

function DutyPaycheck(source, job, identifier, duration, isDisconnect)
	if duration < 1 then
		return
	end

	local xPlayer = Framework.GetPlayerFromId(source)
	local salary, name

	if not isDisconnect and xPlayer then
		local playerData = xPlayer.data
		local grade = playerData.job.grade
		salary = Jobs[job].grades[tostring(grade)].salary

		salary = CountTotalSalary(salary, duration)

		name = playerData.name

		xPlayer.Functions.AddMoney(Config.PayCheck.Account, salary)

		Utils.Notify(xPlayer.source, locale("company"),
			(locale("paycheck_paid")):format(salary, duration), "success", 3000)
	else
		local grade = Framework.GetOfflineJobGrade(identifier)
		salary = Jobs[job].grades[tostring(grade)].salary

		salary = CountTotalSalary(salary, duration)

		name = Framework.GetOfflineName(identifier)
		local accounts = Framework.GetOfflineAccount(identifier)
		if accounts then
			accounts[Config.PayCheck.Account] = accounts[Config.PayCheck.Account] + salary
			Framework.UpdateOfflineAccount(accounts, identifier)
		end
	end

	RemoveCompanyMoney(job, "money", salary, identifier, (locale("paycheck_duty")):format(name, duration), true)

	Utils.DebugPrint(('[Paycheck] Job %s paid %s salary to %s for %s minutes'):format(job, salary, identifier, duration))
end
