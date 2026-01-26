Config.billing = {
	mechanic = {
		company_grade = 3,
		employeecut = 0,
		min_grade = 2,
		cancel_bill = 3,
	},
	cardealer = {
		company_grade = 1,
		employeecut = 0,
		min_grade = 2,
		cancel_bill = 3,
	},
	safr = {
		company_grade = 3,
		employeecut = 0,
		min_grade = 2,
		cancel_bill = 3,
	},
	police = {
		company_grade = 1,
		employeecut = 0,
		min_grade = 2,
		cancel_bill = 11,  -- Commander+
	},
	lscso = {
		company_grade = 1,
		employeecut = 0,
		min_grade = 2,
		cancel_bill = 11,  -- Assistant Chief Deputy+
	},
}

-- Provide a default billing config for any job not explicitly configured
-- Prevents nil access for `billing_access` when the UI expects these fields
setmetatable(Config.billing, {
	__index = function(_, key)
		return {
			company_grade = 0,
			employeecut = 0,
			min_grade = 0,
			cancel_bill = 0,
		}
	end
})
