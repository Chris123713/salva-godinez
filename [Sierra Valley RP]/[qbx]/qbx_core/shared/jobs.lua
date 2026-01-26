---Job names must be lower case (top level table key)
---@type table<string, Job>
return {
    ['unemployed'] = {
        label = 'Civilian',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Unemployed',
                payment = 10
            },
        },
    },
 ['skateshop'] = {
        label = 'Civilian',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'owner',
                payment = 10
            },
        },
    },

    ['police'] = {
        label = 'LSPD',
        type = 'leo',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [1] = {
                name = 'Cadet',
                payment = 25
            },
            [2] = {
                name = 'Probationary Officer',
                payment = 50
            },
            [3] = {
                name = 'Officer',
                payment = 75
            },
            [4] = {
                name = 'Senior Officer',
                payment = 100
            },
            [5] = {
                name = 'Corporal',
                payment = 125
            },
            [6] = {
                name = 'Sergeant',
                payment = 150
            },
            [7] = {
                name = 'Staff Sergeant',
                payment = 175
            },
            [8] = {
                name = 'Lieutenant',
                payment = 200
            },
            [9] = {
                name = 'Captain',
                payment = 225
            },
            [10] = {
                name = 'Major',
                payment = 250
            },
            [11] = {
                name = 'Commander',
                isboss = true,
                bankAuth = true,
                payment = 275
            },
            [12] = {
                name = 'Deputy Chief',
                isboss = true,
                bankAuth = true,
                payment = 300
            },
            [13] = {
                name = 'Assistant Chief',
                isboss = true,
                bankAuth = true,
                payment = 325
            },
            [14] = {
                name = 'Chief',
                isboss = true,
                bankAuth = true,
                payment = 350
            },
        },
    },
    ['lscso'] = {
        label = 'LSCSO',
        type = 'leo',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [1] = {
                name = 'Cadet',
                payment = 25
            },
            [2] = {
                name = 'Deputy',
                payment = 50
            },
            [3] = {
                name = 'Senior Deputy',
                payment = 75
            },
            [4] = {
                name = 'Corporal',
                payment = 100
            },
            [5] = {
                name = 'Sergeant',
                payment = 125
            },
            [6] = {
                name = 'Staff Sergeant',
                payment = 150
            },
            [7] = {
                name = 'Master Sergeant',
                payment = 175
            },
            [8] = {
                name = 'Lieutenant',
                payment = 200
            },
            [9] = {
                name = 'Captain',
                payment = 225
            },
            [10] = {
                name = 'Major',
                payment = 250
            },
            [11] = {
                name = 'Assistant Chief Deputy',
                isboss = true,
                bankAuth = true,
                payment = 275
            },
            [12] = {
                name = 'Chief Deputy',
                isboss = true,
                bankAuth = true,
                payment = 300
            },
            [13] = {
                name = 'Assistant Sheriff',
                isboss = true,
                bankAuth = true,
                payment = 325
            },
            [14] = {
                name = 'Under Sheriff',
                isboss = true,
                bankAuth = true,
                payment = 350
            },
            [15] = {
                name = 'Sheriff',
                isboss = true,
                bankAuth = true,
                payment = 375
            },
        },
    },
    ['sasp'] = {
        label = 'SASP',
        type = 'leo',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [1] = {
                name = 'Cadet',
                payment = 25
            },
            [2] = {
                name = 'Trooper',
                payment = 50
            },
            [3] = {
                name = 'Senior Trooper',
                payment = 75
            },
            [4] = {
                name = 'Corporal',
                payment = 100
            },
            [5] = {
                name = 'Sergeant',
                payment = 125
            },
            [6] = {
                name = 'Staff Sergeant',
                payment = 150
            },
            [7] = {
                name = 'Master Sergeant',
                payment = 175
            },
            [8] = {
                name = 'Lieutenant',
                payment = 200
            },
            [9] = {
                name = 'Captain',
                payment = 225
            },
            [10] = {
                name = 'Major',
                payment = 250
            },
            [11] = {
                name = 'Assistant Chief',
                isboss = true,
                bankAuth = true,
                payment = 275
            },
            [12] = {
                name = 'Chief',
                isboss = true,
                bankAuth = true,
                payment = 300
            },
            [13] = {
                name = 'Assistant Commissioner',
                isboss = true,
                bankAuth = true,
                payment = 325
            },
            [14] = {
                name = 'Deputy Commissioner',
                isboss = true,
                bankAuth = true,
                payment = 350
            },
            [15] = {
                name = 'Commissioner',
                isboss = true,
                bankAuth = true,
                payment = 375
            },
        },
    },
    ['safr'] = {
        label = 'SAFR',
        type = 'ems',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [1] = {
                name = 'EMT',
                payment = 50
            },
            [2] = {
                name = 'Paramedic',
                payment = 75
            },
            [3] = {
                name = 'Doctor',
                payment = 100
            },
            [4] = {
                name = 'Captain',
                payment = 125
            },
            [5] = {
                name = 'Medical Coordinator',
                payment = 150
            },
            [6] = {
                name = 'Assistant Chief',
                isboss = true,
                bankAuth = true,
                payment = 175
            },
            [7] = {
                name = 'Deputy Chief',
                isboss = true,
                bankAuth = true,
                payment = 200
            },
            [8] = {
                name = 'Chief',
                isboss = true,
                bankAuth = true,
                payment = 250
            },
        },
    },
    ['realestate'] = {
        label = 'Real Estate',
        type = 'realestate',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [1] = {
                name = 'Recruit',
                payment = 50
            },
            [2] = {
                name = 'House Sales',
                payment = 75
            },
            [3] = {
                name = 'Business Sales',
                payment = 100
            },
            [4] = {
                name = 'Broker',
                payment = 125
            },
            [5] = {
                name = 'Manager',
                isboss = true,
                bankAuth = true,
                payment = 150
            },
        },
    },
    ['taxi'] = {
        label = 'Taxi',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [1] = {
                name = 'Recruit',
                payment = 50
            },
            [2] = {
                name = 'Driver',
                payment = 75
            },
            [3] = {
                name = 'Event Driver',
                payment = 100
            },
            [4] = {
                name = 'Sales',
                payment = 125
            },
            [5] = {
                name = 'Manager',
                isboss = true,
                bankAuth = true,
                payment = 150
            },
        },
    },
    ['bus'] = {
        label = 'Bus',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [1] = {
                name = 'Driver',
                payment = 50
            },
        },
    },
    ['cardealer'] = {
        label = 'Vehicle Dealer',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [1] = {
                name = 'Recruit',
                payment = 50
            },
            [2] = {
                name = 'Showroom Sales',
                payment = 75
            },
            [3] = {
                name = 'Business Sales',
                payment = 100
            },
            [4] = {
                name = 'Finance',
                payment = 125
            },
            [5] = {
                name = 'Manager',
                isboss = true,
                bankAuth = true,
                payment = 150
            },
        },
    },
    ['mechanic'] = {
        label = 'Mechanic',
        type = 'mechanic',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [1] = {
                name = 'Recruit',
                payment = 50
            },
            [2] = {
                name = 'Novice',
                payment = 75
            },
            [3] = {
                name = 'Experienced',
                payment = 100
            },
            [4] = {
                name = 'Advanced',
                payment = 125
            },
            [5] = {
                name = 'Manager',
                isboss = true,
                bankAuth = true,
                payment = 150
            },
        },
    },
    ['lscustoms'] = {
        label = 'LS Customs',
        type = 'mechanic',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [1] = {
                name = 'Recruit',
                payment = 50
            },
            [2] = {
                name = 'Novice',
                payment = 75
            },
            [3] = {
                name = 'Experienced',
                payment = 100
            },
            [4] = {
                name = 'Advanced',
                payment = 125
            },
            [5] = {
                name = 'Manager',
                isboss = true,
                bankAuth = true,
                payment = 150
            },
        },
    },
    ['bennys'] = {
        label = 'Bennys',
        type = 'mechanic',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [1] = {
                name = 'Recruit',
                payment = 50
            },
            [2] = {
                name = 'Novice',
                payment = 75
            },
            [3] = {
                name = 'Experienced',
                payment = 100
            },
            [4] = {
                name = 'Advanced',
                payment = 125
            },
            [5] = {
                name = 'Manager',
                isboss = true,
                bankAuth = true,
                payment = 150
            },
        },
    },
    ['judge'] = {
        label = 'Honorary',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [1] = {
                name = 'Judge',
                payment = 100
            },
        },
    },
    ['lawyer'] = {
        label = 'Law Firm',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [1] = {
                name = 'Associate',
                payment = 50
            },
        },
    },
    ['reporter'] = {
        label = 'Reporter',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [1] = {
                name = 'Journalist',
                payment = 50
            },
        },
    },
    ['trucker'] = {
        label = 'Trucker',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [1] = {
                name = 'Driver',
                payment = 50
            },
        },
    },
    ['tow'] = {
        label = 'Towing',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [1] = {
                name = 'Driver',
                payment = 50
            },
        },
    },
    ['garbage'] = {
        label = 'Garbage',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [1] = {
                name = 'Collector',
                payment = 50
            },
        },
    },
    ['vineyard'] = {
        label = 'Vineyard',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [1] = {
                name = 'Picker',
                payment = 50
            },
        },
    },
    ['hotdog'] = {
        label = 'Hotdog',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [1] = {
                name = 'Sales',
                payment = 50
            },
        },
    },
    ['pizzathis'] = {
        label = 'Pizza This',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [1] = {
                name = 'Recruit',
                payment = 50
            },
            [2] = {
                name = 'Driver',
                payment = 75
            },
            [3] = {
                name = 'Senior Driver',
                payment = 100
            },
            [4] = {
                name = 'Supervisor',
                payment = 125
            },
            [5] = {
                name = 'Manager',
                isboss = true,
                bankAuth = true,
                payment = 150
            },
        },
    },
    ['miner'] = {
        label = 'Miner',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [1] = {
                name = 'Apprentice',
                payment = 50
            },
            [2] = {
                name = 'Miner',
                payment = 75
            },
            [3] = {
                name = 'Expert Miner',
                payment = 100
            },
            [4] = {
                name = 'Foreman',
                isboss = true,
                bankAuth = true,
                payment = 150
            },
        },
    },
    ['fisherman'] = {
        label = 'Fisherman',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [1] = {
                name = 'Apprentice',
                payment = 50
            },
            [2] = {
                name = 'Fisherman',
                payment = 75
            },
            [3] = {
                name = 'Expert Fisherman',
                payment = 100
            },
            [4] = {
                name = 'Boat Captain',
                isboss = true,
                bankAuth = true,
                payment = 150
            },
        },
    },
    ['farmer'] = {
        label = 'Farmer',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [1] = {
                name = 'Apprentice',
                payment = 50
            },
            [2] = {
                name = 'Farmer',
                payment = 75
            },
            [3] = {
                name = 'Expert Farmer',
                payment = 100
            },
            [4] = {
                name = 'Farm Owner',
                isboss = true,
                bankAuth = true,
                payment = 150
             },
        },
    },
    ['route68motorcycles'] = {
        label = 'route 68 motorcycles',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [1] = {
                name = 'sales',
                payment = 50
            },
            [2] = {
                name = 'senior sales',
                payment = 75
            },
            [3] = {
                name = 'manager',
                payment = 100
            },
            [4] = {
                name = 'owner',
                isboss = true,
                bankAuth = true,
                payment = 200
            },
        },
    },
    ['uwucafe'] = {
        label = 'Cat Cafe',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [1] = {
                name = 'Barista',
                payment = 50
            },
            [2] = {
                name = 'Senior Barista',
                payment = 75
            },
            [3] = {
                name = 'Supervisor',
                payment = 100
            },
            [4] = {
                name = 'Manager',
                payment = 150
            },
            [5] = {
                name = 'Owner',
                isboss = true,
                bankAuth = true,
                payment = 250
            },
        },
    },
    ['burgershot'] = {
        label = 'Burgershot',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [1] = {
                name = 'Trainee',
                payment = 50
            },
            [2] = {
                name = 'Employee',
                payment = 75
            },
            [3] = {
                name = 'Shift Supervisor',
                payment = 100
            },
            [4] = {
                name = 'Manager',
                isboss = true,
                bankAuth = true,
                payment = 150
            },
        },
    },
    ['tm_mechanic'] = {
        label = 'TM mechanic shop',
        type = 'mechanic',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [1] = {
                name = 'Recruit',
                payment = 50
            },
            [2] = {
                name = 'Novice',
                payment = 75
            },
            [3] = {
                name = 'Experienced',
                payment = 100
            },
            [4] = {
                name = 'Advanced',
                payment = 125
            },
            [5] = {
                name = 'Manager',
                isboss = true,
                bankAuth = true,
                payment = 150
            },
        },
    },
}
