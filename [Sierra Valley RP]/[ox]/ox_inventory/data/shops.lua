return {
	General = {
		name = 'Shop',
		blip = {
			id = 59, colour = 69, scale = 0.8
		}, inventory = {
			{ name = 'burger', price = 10 },
			{ name = 'water', price = 10 },
			{ name = 'cola', price = 10 },
		}, locations = {
			vec3(25.7, -1347.3, 29.49),
			vec3(-3038.71, 585.9, 7.9),
			vec3(-3241.47, 1001.14, 12.83),
			vec3(1728.66, 6414.16, 35.03),
			vec3(1697.99, 4924.4, 42.06),
			vec3(1961.48, 3739.96, 32.34),
			vec3(547.79, 2671.79, 42.15),
			vec3(2679.25, 3280.12, 55.24),
			vec3(2557.94, 382.05, 108.62),
			vec3(373.55, 325.56, 103.56),
		}, targets = {
			{ loc = vec3(25.06, -1347.32, 29.5), length = 0.7, width = 0.5, heading = 0.0, minZ = 29.5, maxZ = 29.9, distance = 1.5 },
			{ loc = vec3(-3039.18, 585.13, 7.91), length = 0.6, width = 0.5, heading = 15.0, minZ = 7.91, maxZ = 8.31, distance = 1.5 },
			{ loc = vec3(-3242.2, 1000.58, 12.83), length = 0.6, width = 0.6, heading = 175.0, minZ = 12.83, maxZ = 13.23, distance = 1.5 },
			{ loc = vec3(1728.39, 6414.95, 35.04), length = 0.6, width = 0.6, heading = 65.0, minZ = 35.04, maxZ = 35.44, distance = 1.5 },
			{ loc = vec3(1698.37, 4923.43, 42.06), length = 0.5, width = 0.5, heading = 235.0, minZ = 42.06, maxZ = 42.46, distance = 1.5 },
			{ loc = vec3(1960.54, 3740.28, 32.34), length = 0.6, width = 0.5, heading = 120.0, minZ = 32.34, maxZ = 32.74, distance = 1.5 },
			{ loc = vec3(548.5, 2671.25, 42.16), length = 0.6, width = 0.5, heading = 10.0, minZ = 42.16, maxZ = 42.56, distance = 1.5 },
			{ loc = vec3(2678.29, 3279.94, 55.24), length = 0.6, width = 0.5, heading = 330.0, minZ = 55.24, maxZ = 55.64, distance = 1.5 },
			{ loc = vec3(2557.19, 381.4, 108.62), length = 0.6, width = 0.5, heading = 0.0, minZ = 108.62, maxZ = 109.02, distance = 1.5 },
			{ loc = vec3(373.13, 326.29, 103.57), length = 0.6, width = 0.5, heading = 345.0, minZ = 103.57, maxZ = 103.97, distance = 1.5 },
		}
		},

	LSCustomsParts = {
		blip = {
			id = 93, colour = 69, scale = 0.8
		}, inventory = {
			{ name = 'water', price = 10 },
			{ name = 'cola', price = 10 },
			{ name = 'burger', price = 15 },
		}, locations = {
			vec3(1135.808, -982.281, 46.415),
			vec3(-1222.915, -906.983, 12.326),
			vec3(-1487.553, -379.107, 40.163),
			vec3(-2968.243, 390.910, 15.043),
			vec3(1166.024, 2708.930, 38.157),
			vec3(1392.562, 3604.684, 34.980),
			vec3(-1393.409, -606.624, 30.319)
		}, targets = {
			{ loc = vec3(1134.9, -982.34, 46.41), length = 0.5, width = 0.5, heading = 96.0, minZ = 46.4, maxZ = 46.8, distance = 1.5 },
			{ loc = vec3(-1222.33, -907.82, 12.43), length = 0.6, width = 0.5, heading = 32.7, minZ = 12.3, maxZ = 12.7, distance = 1.5 },
			{ loc = vec3(-1486.67, -378.46, 40.26), length = 0.6, width = 0.5, heading = 133.77, minZ = 40.1, maxZ = 40.5, distance = 1.5 },
			{ loc = vec3(-2967.0, 390.9, 15.14), length = 0.7, width = 0.5, heading = 85.23, minZ = 15.0, maxZ = 15.4, distance = 1.5 },
			{ loc = vec3(1165.95, 2710.20, 38.26), length = 0.6, width = 0.5, heading = 178.84, minZ = 38.1, maxZ = 38.5, distance = 1.5 },
			{ loc = vec3(1393.0, 3605.95, 35.11), length = 0.6, width = 0.6, heading = 200.0, minZ = 35.0, maxZ = 35.4, distance = 1.5 }
		}
	},

	YouTool = {
		name = 'YouTool',
		blip = {
			id = 402, colour = 69, scale = 0.8
		}, inventory = {
			{ name = 'lockpick', price = 150 },
			{ name = 'repairkit', price = 450 },
			{ name = 'surfboard', price = 2000 },
			{ name = 'tirekit', price = 250 }
		}, locations = {
			vec3(2748.0, 3473.0, 55.67),
			vec3(342.99, -1298.26, 32.51)
		}, targets = {
			{ loc = vec3(2746.8, 3473.13, 55.67), length = 0.6, width = 3.0, heading = 65.0, minZ = 55.0, maxZ = 56.8, distance = 3.0 }
		}
	},

	Ammunation = {
		name = 'Ammunation',
		blip = {
			id = 110, colour = 69, scale = 0.8
		}, inventory = {
			-- AMMUNITION
			{ name = 'ammo-9', price = 5 },
			{ name = 'ammo-45', price = 5 },
			{ name = 'ammo-50', price = 5 },
			{ name = 'ammo-38', price = 5 },
			{ name = 'ammo-44', price = 5 },
			{ name = 'ammo-shotgun', price = 8 },
			{ name = 'ammo-rifle', price = 10 },
			{ name = 'ammo-rifle2', price = 10 },

			-- PISTOLS & HANDGUNS (realistic prices)
			{ name = 'WEAPON_PISTOL', price = 2500, metadata = { registered = true }, license = 'weapon_class1' },
			{ name = 'WEAPON_PISTOL_MK2', price = 4500, metadata = { registered = true }, license = 'weapon_class1' },
			{ name = 'WEAPON_COMBATPISTOL', price = 3000, metadata = { registered = true }, license = 'weapon_class1' },
			{ name = 'WEAPON_APPISTOL', price = 3500, metadata = { registered = true }, license = 'weapon_class1' },
			{ name = 'WEAPON_PISTOL50', price = 4200, metadata = { registered = true }, license = 'weapon_class1' },
			{ name = 'WEAPON_HEAVYPISTOL', price = 3200, metadata = { registered = true }, license = 'weapon_class1' },
			{ name = 'WEAPON_SNSPISTOL', price = 2200, metadata = { registered = true }, license = 'weapon_class1' },
			{ name = 'WEAPON_SNSPISTOL_MK2', price = 3300, metadata = { registered = true }, license = 'weapon_class1' },
			{ name = 'WEAPON_VINTAGEPISTOL', price = 2800, metadata = { registered = true }, license = 'weapon_class1' },
			{ name = 'WEAPON_CERAMICPISTOL', price = 3000, metadata = { registered = true }, license = 'weapon_class1' },
			{ name = 'WEAPON_MARKSMANPISTOL', price = 5000, metadata = { registered = true }, license = 'weapon_license_class1' },
		}, locations = {
			vec3(-662.180, -934.961, 21.829),
			vec3(810.25, -2157.60, 29.62),
			vec3(1693.44, 3760.16, 34.71),
			vec3(-330.24, 6083.88, 31.45),
			vec3(252.63, -50.00, 69.94),
			vec3(22.56, -1109.89, 29.80),
			vec3(2567.69, 294.38, 108.73),
			vec3(-1117.58, 2698.61, 18.55),
			vec3(842.44, -1033.42, 28.19)
		}, targets = {
			{ loc = vec3(-660.92, -934.10, 21.94), length = 0.6, width = 0.5, heading = 180.0, minZ = 21.8, maxZ = 22.2, distance = 2.0 },
			{ loc = vec3(808.86, -2158.50, 29.73), length = 0.6, width = 0.5, heading = 360.0, minZ = 29.6, maxZ = 30.0, distance = 2.0 },
			{ loc = vec3(1693.57, 3761.60, 34.82), length = 0.6, width = 0.5, heading = 227.39, minZ = 34.7, maxZ = 35.1, distance = 2.0 },
			{ loc = vec3(-330.29, 6085.54, 31.57), length = 0.6, width = 0.5, heading = 225.0, minZ = 31.4, maxZ = 31.8, distance = 2.0 },
			{ loc = vec3(252.85, -51.62, 70.0), length = 0.6, width = 0.5, heading = 70.0, minZ = 69.9, maxZ = 70.3, distance = 2.0 },
			{ loc = vec3(23.68, -1106.46, 29.91), length = 0.6, width = 0.5, heading = 160.0, minZ = 29.8, maxZ = 30.2, distance = 2.0 },
			{ loc = vec3(2566.59, 293.13, 108.85), length = 0.6, width = 0.5, heading = 360.0, minZ = 108.7, maxZ = 109.1, distance = 2.0 },
			{ loc = vec3(-1117.61, 2700.26, 18.67), length = 0.6, width = 0.5, heading = 221.82, minZ = 18.5, maxZ = 18.9, distance = 2.0 },
			{ loc = vec3(841.05, -1034.76, 28.31), length = 0.6, width = 0.5, heading = 360.0, minZ = 28.2, maxZ = 28.6, distance = 2.0 }
		}
	},





	PoliceArmoury = {
		name = 'Police Armoury',
		groups = {
			['police'] = 0,  -- LSPD
			['lscso'] = 1,   -- Los Santos County Sheriff's Office
			['sasp'] = 0,    -- San Andreas State Police
		},
		blip = {
			id = 110,       -- Ammu-Nation blip icon
			colour = 84,    -- Light blue color
			scale = 0.8     -- Blip size
		}, 
		inventory = {
			-- ============================================================================
			-- AMMUNITION
			-- ============================================================================
			{ name = 'ammo-9', price = 5, },
			{ name = 'ammo-rifle', price = 5, },
			{ name = 'ammo-shotgun', price = 8, },
			
			-- ============================================================================
			-- BASIC EQUIPMENT (Grade 0+)
			-- ============================================================================
			{ name = 'WEAPON_FLASHLIGHT', price = 200 },
			{ name = 'WEAPON_NIGHTSTICK', price = 100 },
			{ name = 'handcuffs', price = 100 },
			{ name = 'handcuffs_key', price = 10 },
			{ name = 'radio', price = 250 },
			{ name = 'armour', price = 300 },
			{ name = 'empty_evidence_bag', price = 5 },
			{ name = 'tablet', price = 0 },
			{ name = 'barrier', price = 150 },
			{ name = 'spikes', price = 200 },
			
			-- ============================================================================
			-- SIDEARMS (Grade 0+ with weapon license)
			-- ============================================================================
			{ 
				name = 'WEAPON_PISTOL', 
				price = 500, 
				metadata = { registered = true, serial = 'POL' }, 
			},
			{ 
				name = 'WEAPON_COMBATPISTOL', 
				price = 650, 
				metadata = { registered = true, serial = 'POL' }, 
			},
			{ 
				name = 'WEAPON_STUNGUN', 
				price = 500, 
				metadata = { registered = true, serial = 'POL'} 
			},
			
			-- ============================================================================
			-- SUPERVISORY EQUIPMENT (Grade 1+)
			-- ============================================================================
			-- Removed `police_snakecam` and `tracker` per request
			{ name = 'megaphone', price = 200, grade = 1 },
			
			-- ============================================================================
			-- TACTICAL EQUIPMENT (Grade 2+)
			-- ============================================================================

			
			-- ============================================================================
			-- RIFLES AND ADVANCED WEAPONS (Grade 3+)
			-- ============================================================================
			{ 
				name = 'WEAPON_CARBINERIFLE', 
				price = 1000, 
				metadata = { registered = true, serial = 'POL' }, 
				grade = 3 
			},
			{ 
				name = 'WEAPON_PUMPSHOTGUN', 
				price = 800, 
				metadata = { registered = true, serial = 'POL' }, 
				grade = 3 
			},
			
			-- ============================================================================
			-- COMMAND EQUIPMENT (Grade 4+)
			-- ============================================================================
			{ name = 'speed_camera', price = 800, grade = 4 },
			
			
		-- Legacy compatibility items
		-- Removed `panic_button` per request
		
		-- Evidence Camera (r14-evidence)
		{ name = 'nikon', price = 200 },
		{ name = 'sdcard', price = 25 }
		}, 
		
		-- ============================================================================
		-- LOCATIONS - Your configured police stations only
		-- ============================================================================
		locations = {
			vec3(487.7509, -997.0212, 30.4940),  -- MRPD Main Armory (new location)
			vec3(-430.6113, 5991.2344, 31.2506),   -- Paleto Sheriff
			vec3(1067.27, 2725.01, 37.66), 		-- Harmony Sheriff
		},
		
		-- ============================================================================
		-- TARGETS - Define interaction zones for ox_inventory
		-- ============================================================================
		targets = {
			{
				loc = vec3(487.7509, -997.0212, 30.4940),
				length = 1.5,
				width = 1.5,
				heading = 0.0,
				minZ = 29.5,
				maxZ = 31.5,
				distance = 2.0,
				label = 'Open MRPD Armory'
			},
			{
				loc = vec3(-430.6113, 5991.2344, 31.2506),
				length = 1.0,
				width = 1.0,
				heading = 0.0,
				minZ = 30.0,
				maxZ = 32.0,
				distance = 2.0,
				label = 'Open LSCSO Armory'
			},
			{
				loc = vec3(1067.27, 2725.01, 37.66),
				length = 1.0,
				width = 1.0,
				heading = 0.0,
				minZ = 30.0,
				maxZ = 32.0,
				distance = 2.0,
				label = 'Open LSCSO Armory'
			},
		}
	},


	Medicine = {
		name = 'Medicine Cabinet',
		groups = {
			['safr'] = 0
		},
		blip = {
			id = 403, colour = 69, scale = 0.8
		}, inventory = {
			{ name = 'medikit', price = 26 },
			{ name = 'bandage', price = 5 },
			{ name = 'radio', price = 100 },
			{ name = 'weapon_flashlight', price = 100 },
			{ name = 'weapon_fireextinguisher', price = 100 },
			{ name = 'pager', price = 100 },
			{ name = 'ecg', price = 1000 },
			{ name = 'tourniquet', price = 50 },
			{ name = 'field_dressing', price = 25 },
			{ name = 'elastic_bandage', price = 25 },
			{ name = 'quick_clot', price = 25 },
			{ name = 'packing_bandage', price = 25 },
			{ name = 'sewing_kit', price = 100 },
			{ name = 'epinephrine', price = 50 },
			{ name = 'morphine', price = 50 },
			{ name = 'propofol', price = 250 },
			{ name = 'blood250ml', price = 150 },
			{ name = 'blood500ml', price = 250 },
			{ name = 'saline250ml', price = 75 },
			{ name = 'saline500ml', price = 125 },
			{ name = 'stretcher', price = 250 },
			{ name = 'wheelchair', price = 150 },
			{ name = 'crutch', price = 100 },
			{ name = 'ifak', price = 300 },
			{ name = 'revivekit', price = 1250 },
			{ name = 'legsplint', price = 300 },
			{ name = 'legcast', price = 300 },
			{ name = 'armsplint', price = 300 },
			{ name = 'armcast', price = 300 },
			{ name = 'neckbrace', price = 300 },
			{ name = 'neckcast', price = 300 },
			{ name = 'castsaw', price = 300 }
		}, locations = {
				vec3(310.089752, -599.483032, 43.291771),
				vec3(386.602722, -1403.627319, 32.936172),
				vec3(311.7464, -597.8491, 43.5592),
				vec3(311.7910, -564.0659, 43.2841),
				vec3(311.8388, -597.8828, 43.6171)
		}, targets = {
					{ loc = vec3(310.089752, -599.483032, 43.291771), length = 2.0, width = 3.0, heading = 166.707581, minZ = 42.0, maxZ = 45.0, distance = 6, debug = false, drawSprite = false },
					{ loc = vec3(386.602722, -1403.627319, 32.936172), length = 1.2, width = 1.2, heading = 331.370270, minZ = 32.4, maxZ = 33.4, distance = 2.5, debug = false, drawSprite = false },
					{ loc = vec3(311.7464, -597.8491, 43.5592), length = 2.0, width = 3.0, heading = 166.7, minZ = 42.0, maxZ = 45.0, distance = 6, debug = false, drawSprite = false },
					{ loc = vec3(311.7910, -564.0659, 43.2841), length = 2.0, width = 3.0, heading = 166.7, minZ = 42.0, maxZ = 45.0, distance = 6, debug = false, drawSprite = false },
					{ loc = vec3(311.8388, -597.8828, 43.6171), length = 2.0, width = 3.0, heading = 166.7, minZ = 42.0, maxZ = 45.0, distance = 6, debug = false, drawSprite = false }
		}
	},

	BlackMarketArms = {
		name = 'Black Market (Arms)',
		inventory = {
			{ name = 'WEAPON_DAGGER', price = 5000, metadata = { registered = false	}, currency = 'black_money' },
			{ name = 'WEAPON_CERAMICPISTOL', price = 50000, metadata = { registered = false }, currency = 'black_money' },
			{ name = 'at_suppressor_light', price = 50000, currency = 'black_money' },
			{ name = 'ammo-rifle', price = 1000, currency = 'black_money' },
			{ name = 'ammo-rifle2', price = 1000, currency = 'black_money' }
		}, locations = {
			vec3(309.09, -913.75, 56.46)
		}, targets = {

		}
	},

	VendingMachineDrinks = {
		name = 'Vending Machine',
		inventory = {
			{ name = 'water', price = 10 },
			{ name = 'cola', price = 10 },
		},
		model = {
			`prop_vend_soda_02`, `prop_vend_fridge01`, `prop_vend_water_01`, `prop_vend_soda_01`
		}
	},

	MechanicParts = {
		name = 'Mechanic Parts Store',
		groups = {
			['bennys'] = 0  -- Accessible by Benny's mechanics (all ranks)
		},
		inventory = {
			-- ============================================================================
			-- MECHANIC TABLET (FREE)
			-- ============================================================================
			{ name = 'mechanic_tablet', price = 0 },  -- FREE for mechanics
			
			-- ============================================================================
			-- SERVICING ITEMS
			-- ============================================================================
			{ name = 'engine_oil', price = 50 },
			{ name = 'tyre_replacement', price = 100 },
			{ name = 'clutch_replacement', price = 150 },
			{ name = 'air_filter', price = 30 },
			{ name = 'spark_plug', price = 40 },
			{ name = 'brakepad_replacement', price = 120 },
			{ name = 'suspension_parts', price = 200 },
			
			-- ============================================================================
			-- ENGINE UPGRADES
			-- ============================================================================
			{ name = 'i4_engine', price = 2000 },
			{ name = 'v6_engine', price = 3500 },
			{ name = 'v8_engine', price = 5000 },
			{ name = 'v12_engine', price = 8000 },
			{ name = 'turbocharger', price = 1500 },
			
			-- ============================================================================
			-- ELECTRIC VEHICLE PARTS
			-- ============================================================================
			{ name = 'ev_motor', price = 4000 },
			{ name = 'ev_battery', price = 3000 },
			{ name = 'ev_coolant', price = 100 },
			
			-- ============================================================================
			-- DRIVETRAIN
			-- ============================================================================
			{ name = 'awd_drivetrain', price = 2500 },
			{ name = 'rwd_drivetrain', price = 2000 },
			{ name = 'fwd_drivetrain', price = 1800 },
			{ name = 'manual_gearbox', price = 1200 },
			
			-- ============================================================================
			-- TUNING & PERFORMANCE
			-- ============================================================================
			{ name = 'slick_tyres', price = 800 },
			{ name = 'semi_slick_tyres', price = 600 },
			{ name = 'offroad_tyres', price = 500 },
			{ name = 'drift_tuning_kit', price = 1000 },
			{ name = 'ceramic_brakes', price = 1200 },
			{ name = 'performance_part', price = 500 },
			
			-- ============================================================================
			-- COSMETIC ITEMS
			-- ============================================================================
			{ name = 'lighting_controller', price = 250 },
			{ name = 'stancing_kit', price = 300 },
			{ name = 'cosmetic_part', price = 150 },
			{ name = 'headlight_kit', price = 200 },
			{ name = 'respray_kit', price = 500 },
			{ name = 'vehicle_wheels', price = 800 },
			{ name = 'tyre_smoke_kit', price = 400 },
			{ name = 'bulletproof_tyres', price = 1500 },
			{ name = 'extras_kit', price = 200 },
			
			-- ============================================================================
			-- NITROUS & REPAIR
			-- ============================================================================
			{ name = 'nitrous_bottle', price = 500 },
			{ name = 'empty_nitrous_bottle', price = 50 },
			{ name = 'nitrous_install_kit', price = 800 },
			{ name = 'cleaning_kit', price = 75 },
			{ name = 'repair_kit', price = 150 },
			{ name = 'duct_tape', price = 25 },
		},
		locations = {
			vec3(-195.9764, -1318.2377, 31.0892),  -- Benny's Original Motor Works - Parts Store
		},
			targets = {
				{
					loc = vec3(-195.9764, -1318.2377, 31.0892),
					length = 1.5,
					width = 1.5,
					heading = 270.0,
					minZ = 30.0,
					maxZ = 32.5,
					distance = 2.5,
					label = 'Mechanic Parts Store'
				}
			}
		},

	LSCustomsParts = {
		name = 'LS Customs Parts Store',
		groups = {
			['lscustoms'] = 0 -- Only LS Customs job (all ranks)
		},
		inventory = {
			{ name = 'mechanic_tablet', price = 0 },
			{ name = 'engine_oil', price = 50 },
			{ name = 'tyre_replacement', price = 100 },
			{ name = 'clutch_replacement', price = 150 },
			{ name = 'air_filter', price = 30 },
			{ name = 'spark_plug', price = 40 },
			{ name = 'brakepad_replacement', price = 120 },
			{ name = 'suspension_parts', price = 200 },
			{ name = 'i4_engine', price = 2000 },
			{ name = 'v6_engine', price = 3500 },
			{ name = 'v8_engine', price = 5000 },
			{ name = 'v12_engine', price = 8000 },
			{ name = 'turbocharger', price = 1500 },
			{ name = 'ev_motor', price = 4000 },
			{ name = 'ev_battery', price = 3000 },
			{ name = 'ev_coolant', price = 100 },
			{ name = 'awd_drivetrain', price = 2500 },
			{ name = 'rwd_drivetrain', price = 2000 },
			{ name = 'fwd_drivetrain', price = 1800 },
			{ name = 'manual_gearbox', price = 1200 },
			{ name = 'slick_tyres', price = 800 },
			{ name = 'semi_slick_tyres', price = 600 },
			{ name = 'offroad_tyres', price = 500 },
			{ name = 'drift_tuning_kit', price = 1000 },
			{ name = 'ceramic_brakes', price = 1200 },
			{ name = 'performance_part', price = 500 },
			{ name = 'lighting_controller', price = 250 },
			{ name = 'stancing_kit', price = 300 },
			{ name = 'cosmetic_part', price = 150 },
			{ name = 'headlight_kit', price = 200 },
			{ name = 'respray_kit', price = 500 },
			{ name = 'vehicle_wheels', price = 800 },
			{ name = 'tyre_smoke_kit', price = 400 },
			{ name = 'bulletproof_tyres', price = 1500 },
			{ name = 'extras_kit', price = 200 },
			{ name = 'nitrous_bottle', price = 500 },
			{ name = 'empty_nitrous_bottle', price = 50 },
			{ name = 'nitrous_install_kit', price = 800 },
			{ name = 'cleaning_kit', price = 75 },
			{ name = 'repair_kit', price = 150 },
			{ name = 'duct_tape', price = 25 }
		},
		locations = {
			vec3(-363.9744, -101.4810, 39.5315)   -- LS Customs Parts Shop
		},
		targets = {
			{
				loc = vec3(-363.9744, -101.4810, 39.5315),
				length = 1.5,
				width = 1.5,
				heading = 0.0,
				minZ = 38.0,
				maxZ = 41.0,
				distance = 2.5,
				label = 'LS Customs Parts Shop'
			}
		}
	},
	TMMechanicParts = {
		name = 'TM Mechanic Parts Store',
		groups = {
			['tm_mechanic'] = 0 -- Only TM mechanics (all ranks)
		},
		inventory = {
			{ name = 'mechanic_tablet', price = 0 },
			{ name = 'engine_oil', price = 50 },
			{ name = 'tyre_replacement', price = 100 },
			{ name = 'clutch_replacement', price = 150 },
			{ name = 'air_filter', price = 30 },
			{ name = 'spark_plug', price = 40 },
			{ name = 'brakepad_replacement', price = 120 },
			{ name = 'suspension_parts', price = 200 },
			{ name = 'i4_engine', price = 2000 },
			{ name = 'v6_engine', price = 3500 },
			{ name = 'v8_engine', price = 5000 },
			{ name = 'v12_engine', price = 8000 },
			{ name = 'turbocharger', price = 1500 },
			{ name = 'ev_motor', price = 4000 },
			{ name = 'ev_battery', price = 3000 },
			{ name = 'ev_coolant', price = 100 },
			{ name = 'awd_drivetrain', price = 2500 },
			{ name = 'rwd_drivetrain', price = 2000 },
			{ name = 'fwd_drivetrain', price = 1800 },
			{ name = 'manual_gearbox', price = 1200 },
			{ name = 'slick_tyres', price = 800 },
			{ name = 'semi_slick_tyres', price = 600 },
			{ name = 'offroad_tyres', price = 500 },
			{ name = 'drift_tuning_kit', price = 1000 },
			{ name = 'ceramic_brakes', price = 1200 },
			{ name = 'performance_part', price = 500 },
			{ name = 'lighting_controller', price = 250 },
			{ name = 'stancing_kit', price = 300 },
			{ name = 'cosmetic_part', price = 150 },
			{ name = 'headlight_kit', price = 200 },
			{ name = 'respray_kit', price = 500 },
			{ name = 'vehicle_wheels', price = 800 },
			{ name = 'tyre_smoke_kit', price = 400 },
			{ name = 'bulletproof_tyres', price = 1500 },
			{ name = 'extras_kit', price = 200 },
			{ name = 'nitrous_bottle', price = 500 },
			{ name = 'empty_nitrous_bottle', price = 50 },
			{ name = 'nitrous_install_kit', price = 800 },
			{ name = 'cleaning_kit', price = 75 },
			{ name = 'repair_kit', price = 150 },
			{ name = 'duct_tape', price = 25 }
		},
		locations = {
			vec3(70.8980, 6536.1577, 31.6135)
		},
		targets = {
			{
				loc = vec3(70.8980, 6536.1577, 31.6135),
				length = 1.5,
				width = 1.5,
				heading = 0.0,
				minZ = 30.5,
				maxZ = 33.0,
				distance = 2.5,
				label = 'TM Mechanic Parts Shop'
			}
		}
	},

	digitalden = {
		name = 'Digital Den',
		icon = 'fas fa-desktop',
		blip = {
			id = 521, colour = 27, scale = 0.8
		}, inventory = {
			{ name = 'phone', price = 850 },
		}, locations = {
			vec3(383.8449, -825.4649, 29.3160),    -- Mission Row
			vec3(236.5887, -1485.4922, 29.2939),   -- Davis
			vec3(-665.4786, -879.5758, 24.6491),   -- Little Seoul
			vec3(156.2228, 247.1679, 107.0564),    -- Vinewood
		}, targets = {
			{ loc = vec3(383.8449, -825.4649, 29.3160), length = 2.0, width = 2.0, heading = 0.0, minZ = 28.0, maxZ = 31.0, distance = 3.0 },
			{ loc = vec3(236.5887, -1485.4922, 29.2939), length = 2.0, width = 2.0, heading = 0.0, minZ = 28.0, maxZ = 31.0, distance = 3.0 },
			{ loc = vec3(-665.4786, -879.5758, 24.6491), length = 2.0, width = 2.0, heading = 0.0, minZ = 23.5, maxZ = 26.5, distance = 3.0 },
			{ loc = vec3(156.2228, 247.1679, 107.0564), length = 2.0, width = 2.0, heading = 0.0, minZ = 106.0, maxZ = 109.0, distance = 3.0 },
		}
	},
}
