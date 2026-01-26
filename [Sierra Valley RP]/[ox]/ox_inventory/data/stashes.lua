return {
	-- ============================================================================
	-- MRPD POLICE STATION STASHES
	-- ============================================================================
	
	-- MRPD Personal Lockers (Enhanced)
	{
		coords = vec3(460.284, -999.37, 30.68),
		target = {
			loc = vec3(459.9424, -999.8354, 30.6796),
			length = 1.2,
			width = 5.6,
			heading = 0,
			minZ = 29.49,
			maxZ = 32.09,
			label = 'Open Personal Locker'
		},
		name = 'policelocker',
		label = 'Personal Locker',
		owner = true,
		slots = 70,
		weight = 130000,
		groups = shared.police
	},

	-- MRPD Additional Locker Bank
	{
		coords = vec3(454.32, -985.75, 30.68),
		target = {
			loc = vec3(454.32, -985.75, 30.68),
			length = 1.0,
			width = 3.0,
			heading = 90,
			minZ = 30.0,
			maxZ = 32.0,
			label = 'Open Personal Locker'
		},
		name = 'policelocker2',
		label = 'Personal Locker',
		owner = true,
		slots = 50,
		weight = 100000,
		groups = shared.police
	},

	-- MRPD Personal Locker (New Location)
	{
		coords = vec3(474.555603, -988.227722, 30.689297),
		target = {
			loc = vec3(474.555603, -988.227722, 30.689297),
			length = 1.0,
			width = 1.0,
			heading = 272.281586,
			minZ = 30.0,
			maxZ = 32.0,
			label = 'Open Personal Locker'
		},
		name = 'policelocker3',
		label = 'Personal Locker',
		owner = true,
		slots = 60,
		weight = 120000,
		groups = shared.police
	},

	-- MRPD Clothing Locker
	{
		coords = vec3(475.309448, -991.253357, 30.689268),
		target = {
			loc = vec3(475.309448, -991.253357, 30.689268),
			length = 1.0,
			width = 1.0,
			heading = 2.995242,
			minZ = 30.0,
			maxZ = 32.0,
			label = 'Open Clothing Locker'
		},
		name = 'policeclothing',
		label = 'Clothing Locker',
		owner = true,
		slots = 40,
		weight = 50000,
		groups = shared.police
	},

	-- MRPD Clothing Locker 2
	{
		coords = vec3(483.357300, -1009.592102, 30.689268),
		target = {
			loc = vec3(483.357300, -1009.592102, 30.689268),
			length = 1.0,
			width = 1.0,
			heading = 272.772980,
			minZ = 30.0,
			maxZ = 32.0,
			label = 'Open Clothing Locker'
		},
		name = 'policeclothing2',
		label = 'Clothing Locker',
		owner = true,
		slots = 40,
		weight = 50000,
		groups = shared.police
	},

	-- MRPD Police Vehicle Garage
	{
		coords = vec3(451.441986, -992.423096, 25.735762),
		target = {
			loc = vec3(451.441986, -992.423096, 25.735762),
			length = 2.0,
			width = 2.0,
			heading = 179.998001,
			minZ = 25.0,
			maxZ = 27.0,
			label = 'Police Vehicle Garage'
		},
		name = 'policegarage',
		label = 'Police Vehicle Garage',
		owner = false,
		slots = 100,
		weight = 200000,
		groups = shared.police
	},

	-- MRPD Evidence Room
	{
		coords = vec3(474.1338, -994.4181, 26.5741),
		target = {
			loc = vec3(474.1338, -994.4181, 26.5741),
			length = 2.0,
			width = 1.5,
			heading = 0,
			minZ = 25.5,
			maxZ = 27.5,
			label = 'Access Evidence Storage'
		},
		name = 'evidencestorage',
		label = 'Evidence Storage',
		owner = false,
		slots = 200,
		weight = 500000,
		groups = shared.police,
		jobs = { police = 2, sheriff = 2 }
	},

	-- MRPD Tactical Storage
	{
		coords = vec3(449.2, -996.4, 30.68),
		target = {
			loc = vec3(449.2, -996.4, 30.68),
			length = 1.5,
			width = 2.0,
			heading = 270,
			minZ = 30.0,
			maxZ = 32.0,
			label = 'Access Tactical Storage'
		},
		name = 'tacticalstorage',
		label = 'Tactical Equipment',
		owner = false,
		slots = 100,
		weight = 300000,
		groups = shared.police,
		jobs = { police = 3, sheriff = 3 }
	},

	-- MRPD Vehicle Equipment
	{
		coords = vec3(444.7, -1019.2, 28.6),
		target = {
			loc = vec3(444.7, -1019.2, 28.6),
			length = 2.0,
			width = 1.5,
			heading = 0,
			minZ = 27.8,
			maxZ = 29.8,
			label = 'Access Vehicle Equipment'
		},
		name = 'vehicleequipment',
		label = 'Vehicle Equipment',
		owner = false,
		slots = 150,
		weight = 400000,
		groups = shared.police
	},

	-- MRPD Command Storage
	{
		coords = vec3(448.8, -973.2, 30.68),
		target = {
			loc = vec3(448.8, -973.2, 30.68),
			length = 1.2,
			width = 1.0,
			heading = 0,
			minZ = 30.0,
			maxZ = 32.0,
			label = 'Access Command Storage'
		},
		name = 'commandstorage',
		label = 'Command Storage',
		owner = false,
		slots = 50,
		weight = 100000,
		groups = shared.police,
		jobs = { police = 5, sheriff = 5 }
	},

	-- ============================================================================
	-- PALETO BAY SHERIFF STATION STASHES
	-- ============================================================================
	
	-- Paleto Personal Lockers
	{
		coords = vec3(-451.02, 6006.06, 31.72),
		target = {
			loc = vec3(-451.02, 6006.06, 31.72),
			length = 0.6,
			width = 1.8,
			heading = 45,
			minZ = 31.0,
			maxZ = 33.0,
			label = 'Open Personal Locker'
		},
		name = 'policelocker_paleto',
		label = 'Personal Locker',
		owner = true,
		slots = 40,
		weight = 100000,
		groups = shared.police
	},

	-- Paleto Evidence Storage
	{
		coords = vec3(-448.1252, 5989.6460, 26.9125),
		target = {
			loc = vec3(-448.1252, 5989.6460, 26.9125),
			length = 1.5,
			width = 1.5,
			heading = 0,
			minZ = 25.5,
			maxZ = 28.5,
			label = 'Access Evidence Storage'
		},
		name = 'evidencestorage_paleto',
		label = 'Evidence Storage',
		owner = false,
		slots = 80,
		weight = 200000,
		groups = shared.police,
		jobs = { police = 2, sheriff = 2 }
	},

	-- ============================================================================
	-- SPECIALIZED STORAGE (MRPD)
	-- ============================================================================
	
	-- Evidence Processing Table
	{
		coords = vec3(473.6, -992.4, 26.27),
		target = {
			loc = vec3(473.6, -992.4, 26.27),
			length = 1.5,
			width = 1.0,
			heading = 270,
			minZ = 25.5,
			maxZ = 27.5,
			label = 'Access Processing Table'
		},
		name = 'evidenceprocessing',
		label = 'Evidence Processing',
		owner = false,
		slots = 30,
		weight = 50000,
		groups = shared.police
	},

	-- Property Recovery Storage
	{
		coords = vec3(471.8, -986.2, 26.27),
		target = {
			loc = vec3(471.8, -986.2, 26.27),
			length = 2.0,
			width = 1.5,
			heading = 0,
			minZ = 25.5,
			maxZ = 27.5,
			label = 'Access Property Storage'
		},
		name = 'propertystorage',
		label = 'Property Recovery',
		owner = false,
		slots = 120,
		weight = 300000,
		groups = shared.police,
		jobs = { police = 1, sheriff = 1 }
	},

	{
		coords = vec3(301.3, -600.23, 43.28),
		target = {
			loc = vec3(301.82, -600.99, 43.29),
			length = 0.6,
			width = 1.8,
			heading = 340,
			minZ = 43.34,
			maxZ = 44.74,
			label = 'Open personal locker'
		},
		name = 'emslocker',
		label = 'Personal Locker',
		owner = true,
		slots = 70,
		weight = 70000,
		groups = {['ambulance'] = 0}
	},

	-- ============================================================================
	-- BENNY'S MECHANIC SHOP STASHES
	-- ============================================================================
	
	-- Benny's Parts Storage
	{
		coords = vec3(-216.7208, -1319.0420, 30.7281),
		target = {
			loc = vec3(-216.7208, -1319.0420, 30.7281),
			length = 1.5,
			width = 1.5,
			heading = 270,
			minZ = 29.5,
			maxZ = 32.0,
			label = 'Open Parts Storage'
		},
		name = 'bennys_storage',
		label = 'Benny\'s Parts Storage',
		owner = false,
		slots = 150,
		weight = 500000,
		groups = {['bennys'] = 0}
	},

	-- Paleto Mechanic Secondary Parts Storage
	{
		coords = vec3(80.2002, 6531.5083, 31.6309),
		target = {
			loc = vec3(80.2002, 6531.5083, 31.6309),
			length = 1.5,
			width = 1.5,
			heading = 0,
			minZ = 30.0,
			maxZ = 33.0,
			label = 'Open Parts Storage'
		},
		name = 'paleto_parts_storage_2',
		label = 'Paleto Parts Storage (Secondary)',
		owner = false,
		slots = 150,
		weight = 500000,
		groups = {['bennys'] = 0}
	},
	-- Paleto Mechanic Parts Storage
	{
		coords = vec3(75.9328, 6535.6738, 31.6066),
		target = {
			loc = vec3(75.9328, 6535.6738, 31.6066),
			length = 1.5,
			width = 1.5,
			heading = 0,
			minZ = 30.0,
			maxZ = 33.0,
			label = 'Open Parts Storage'
		},
		name = 'paleto_parts_storage',
		label = 'Paleto Parts Storage',
		owner = false,
		slots = 150,
		weight = 500000,
		groups = {['bennys'] = 0}
	},
 
	-- ============================================================================
	-- LS CUSTOMS STASHES (separate named stashes for organization)
	-- ============================================================================

	{
		coords = vec3(-319.5073, -151.9922, 38.7799),
		target = {
			loc = vec3(-319.5073, -151.9922, 38.7799),
			length = 1.0,
			width = 1.0,
			heading = 0.0,
			minZ = 38.0,
			maxZ = 39.5,
			label = 'LS Customs Stash'
		},
		name = 'ls_customs_stash_1',
		label = 'LS Customs Stash',
		owner = false,
		slots = 100,
		weight = 300000,
		groups = {['bennys'] = 0}
	},

	{
		coords = vec3(-312.9964, -141.3326, 39.1498),
		target = {
			loc = vec3(-312.9964, -141.3326, 39.1498),
			length = 1.0,
			width = 1.0,
			heading = 0.0,
			minZ = 38.8,
			maxZ = 40.0,
			label = 'LS Customs Stash'
		},
		name = 'ls_customs_stash_2',
		label = 'LS Customs Stash',
		owner = false,
		slots = 100,
		weight = 300000,
		groups = {['bennys'] = 0}
	},

	{
		coords = vec3(-308.1305, -131.5519, 39.1713),
		target = {
			loc = vec3(-308.1305, -131.5519, 39.1713),
			length = 1.0,
			width = 1.0,
			heading = 0.0,
			minZ = 38.9,
			maxZ = 40.0,
			label = 'LS Customs Stash'
		},
		name = 'ls_customs_stash_3',
		label = 'LS Customs Stash',
		owner = false,
		slots = 100,
		weight = 300000,
		groups = {['bennys'] = 0}
	},

	-- SAFR Shared Storage
	{
		coords = vec3(306.4488, -602.0802, 43.5480),
		target = {
			loc = vec3(306.45, -602.08, 43.55),
			length = 0.8,
			width = 1.8,
			heading = 340,
			minZ = 43.0,
			maxZ = 45.0,
			label = 'Open SAFR Storage'
		},
		name = 'safr_storage',
		label = 'SAFR Storage',
		owner = false,
		slots = 100,
		weight = 200000,
		groups = {['safr'] = 0}
	},
}
