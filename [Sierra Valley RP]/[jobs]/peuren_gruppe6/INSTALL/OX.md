1. Add this to ox_inventory/data/items.lua:

	['money_bag'] = {
		label = 'Money bag',
		description = "Gruppe 6 money bag",
		weight = 250,
		stack = true
	},

	['money_crate'] = {
		label = 'Money crate',
		description = "Gruppe 6 money crate",
		weight = 500,
		stack = true
	},

	["black_money"] = {
		label = "Black Money",
		weight = 0,
		stack = true,
		close = false,
		description = "Dirty money that needs to be cleaned",
		client = {
			image = "black_money.png",
		}
	},

	['gruppe6_tablet'] = {
		label = 'Gruppe 6 tablet',
		description = "",
		weight = 500,
		stack = true
	},