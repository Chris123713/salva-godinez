CustomizeIPL = {
    -- dlc_biker
    {
        name = 'Clubhouse1',
        ipl = function()
            if not IsDuplicityVersion() then
                return exports.bob74_ipl:GetBikerClubhouse1Object()
            end
        end,
        entry = vec4(1121.0194, -3152.7607, -37.0627, 4.4515),
        prices = {
            Walls = 1000,
            Mural = 500
        },
    },
    {
        name = 'Clubhouse2',
        ipl = function()
            if not IsDuplicityVersion() then
                return exports.bob74_ipl:GetBikerClubhouse2Object()
            end
        end,
        entry = vec4(997.4394, -3158.2883, -38.9072, 268.2064),
        prices = {
            Walls = 1000,
            Mural = 500
        },
    },
    {
        name = 'Cocaine lockup',
        ipl = function()
            if not IsDuplicityVersion() then
                return exports.bob74_ipl:GetBikerCocaineObject()
            end
        end,
        entry = vec4(1088.5812, -3187.5027, -38.9935, 179.0399),
        prices = {},
    },
    {
        name = 'Counterfeit cash factory',
        ipl = function()
            if not IsDuplicityVersion() then
                return exports.bob74_ipl:GetBikerCounterfeitObject()
            end
        end,
        entry = vec4(1138.1580, -3199.1880, -39.6657, 354.3823),
        prices = {},
    },
    {
        name = 'Document forgery',
        ipl = function()
            if not IsDuplicityVersion() then
                return exports.bob74_ipl:GetBikerDocumentForgeryObject()
            end
        end,
        entry = vec4(1173.7865, -3196.7373, -39.0080, 91.1098),
        prices = {},
    },
    {
        name = 'Meth Lab',
        ipl = function()
            if not IsDuplicityVersion() then
                return exports.bob74_ipl:GetBikerMethLabObject()
            end
        end,
        entry = vec4(996.8154, -3200.7463, -36.3937, 272.8946),
        prices = {},
    },
    {
        name = 'Weed Farm',
        ipl = function()
            if not IsDuplicityVersion() then
                return exports.bob74_ipl:GetBikerWeedFarmObject()
            end
        end,
        entry = vec4(1066.2996, -3183.4114, -39.1635, 92.4208),
        prices = {},
    },
    -- dlc_afterhours
    {
        name = 'Nightclub',
        ipl = function()
            if not IsDuplicityVersion() then
                return exports.bob74_ipl:GetAfterHoursNightclubsObject()
            end
        end,
        entry = vec4(-1569.3912, -3017.6309, -74.4062, 2.2517),
        prices = {},
    },
    -- dlc_casino
    {
        name = 'Penthouse',
        ipl = function()
            if not IsDuplicityVersion() then
                return exports.bob74_ipl:GetDiamondPenthouseObject()
            end
        end,
        entry = vec4(980.6793, 56.5234, 116.1642, 51.8893),
        prices = {},
    },
    -- dlc_cayoperico
    {
        name = 'The Music Locker',
        ipl = function()
            if not IsDuplicityVersion() then
                return exports.bob74_ipl:GetCayoPericoNightclub()
            end
        end,
        entry = vec4(1545.2987, 254.1307, -46.0061, 0.6308),
        prices = {},
    },
    --   dlc_doomsday
    {
        name = 'DoomsdayFacility',
        ipl = function()
            if not IsDuplicityVersion() then
                return exports.bob74_ipl:GetDoomsdayFacilityObject()
            end
        end,
        entry = vec4(325.9854, 4882.3374, -58.9995, 129.2806),
        prices = {},
    },
    -- dlc_executive
    {
        name = 'Apartment 1',
        ipl = function()
            if not IsDuplicityVersion() then
                return exports.bob74_ipl:GetExecApartment1Object()
            end
        end,
        entry = vec4(-787.4127, 315.6659, 217.6386, 267.6566),
        prices = {},
    },
    {
        name = 'Apartment 2',
        ipl = function()
            if not IsDuplicityVersion() then
                return exports.bob74_ipl:GetExecApartment2Object()
            end
        end,
        entry = vec4(-773.5239, 341.9679, 196.6861, 91.4199),
        prices = {},
    },
    {
        name = 'Apartment 3',
        ipl = function()
            if not IsDuplicityVersion() then
                return exports.bob74_ipl:GetExecApartment3Object()
            end
        end,
        entry = vec4(-787.4062, 315.6622, 187.9134, 272.1406),
        prices = {},
    },
    -- dlc_finance
    {
        name = 'Office 1 (Arcadius Business Centre)',
        ipl = function()
            if not IsDuplicityVersion() then
                return exports.bob74_ipl:GetFinanceOffice1Object()
            end
        end,
        entry = vec4(-139.4779, -617.4788, 168.8203, 99.2815),
        prices = {},
    },
    {
        name = 'Office 2 (Maze Bank Building)',
        ipl = function()
            if not IsDuplicityVersion() then
                return exports.bob74_ipl:GetFinanceOffice2Object()
            end
        end,
        entry = vec4(-78.9695, -829.3524, 243.3857, 252.6773),
        prices = {},
    },
    {
        name = 'Office 3 (Lom Bank)',
        ipl = function()
            if not IsDuplicityVersion() then
                return exports.bob74_ipl:GetFinanceOffice3Object()
            end
        end,
        entry = vec4(-1579.5333, -561.0135, 108.5229, 134.1342),
        prices = {},
    },
    {
        name = 'Office 4 (Maze Bank West)',
        ipl = function()
            if not IsDuplicityVersion() then
                return exports.bob74_ipl:GetFinanceOffice4Object()
            end
        end,
        entry = vec4(-1396.3055, -478.6074, 72.0421, 193.9121),
        prices = {},
    },
    -- dlc_highlife
    {
        name = 'Apartment 1 (Dell Perro Heights, Apt 4)',
        ipl = function()
            if not IsDuplicityVersion() then
                return exports.bob74_ipl:GetHLApartment1Object()
            end
        end,
        entry = vec4(-1452.1353, -540.7191, 74.0443, 33.9719),
        prices = {},
    },
    {
        name = 'Apartment 2 (Richard Majestic, Apt 2)',
        ipl = function()
            if not IsDuplicityVersion() then
                return exports.bob74_ipl:GetHLApartment2Object()
            end
        end,
        entry = vec4(-912.3753, -365.0459, 114.2748, 118.4509),
        prices = {},
    },
    {
        name = 'Apartment 3 (Tinsel Towers, Apt 42)',
        ipl = function()
            if not IsDuplicityVersion() then
                return exports.bob74_ipl:GetHLApartment3Object()
            end
        end,
        entry = vec4(-602.8840, 58.9586, 98.2002, 93.4696),
        prices = {},
    },
    {
        name = 'Apartment 4 (EclipseTowers, Apt 3)',
        ipl = function()
            if not IsDuplicityVersion() then
                return exports.bob74_ipl:GetHLApartment4Object()
            end
        end,
        entry = vec4(-785.1733, 323.7633, 211.9971, 269.4448),
        prices = {},
    },
    {
        name = 'Apartment 5 (4 Integrity Way, Apt 28)',
        ipl = function()
            if not IsDuplicityVersion() then
                return exports.bob74_ipl:GetHLApartment5Object()
            end
        end,
        entry = vec4(-785.1733, 323.7633, 211.9971, 269.4448),
        prices = {},
    },
    {
        name = 'Apartment 6',
        ipl = function()
            if not IsDuplicityVersion() then
                return exports.bob74_ipl:GetHLApartment5Object()
            end
        end,
        entry = vec4(-602.9776, 58.8669, -182.3809, 93.2367),
        prices = {},
    },
    -- dlc_import
    {
        name = 'Vehicle warehouse',
        ipl = function()
            if not IsDuplicityVersion() then
                return exports.bob74_ipl:GetImportVehicleWarehouseObject()
            end
        end,
        entry = vec4(1004.8318, -2992.3586, -39.6470, 92.5176), -- upper
        prices = {},
    },
    -- dlc_smuggler
    {
        name = 'SmugglerHangar',
        ipl = function()
            if not IsDuplicityVersion() then
                return exports.bob74_ipl:GetSmugglerHangarObject()
            end
        end,
        entry = vec4(-1267.0985, -3012.9551, -48.4902, 357.4053),
        prices = {},
    },
    -- gta_online
    {
        name = 'High end apartment 1',
        ipl = function()
            if not IsDuplicityVersion() then
                return exports.bob74_ipl:GetGTAOApartmentHi1Object()
            end
        end,
        entry = vec4(-18.2889, -590.9544, 90.1147, 334.6050),
        prices = {},
    },
    {
        name = 'High end apartment 2',
        ipl = function()
            if not IsDuplicityVersion() then
                return exports.bob74_ipl:GetGTAOApartmentHi2Object()
            end
        end,
        entry = vec4(-1450.0377, -525.8071, 56.9290, 33.0834),
        prices = {},
    },
    {
        name = 'High end house 1',
        ipl = function()
            if not IsDuplicityVersion() then
                return exports.bob74_ipl:GetGTAOHouseHi1Object()
            end
        end,
        entry = vec4(-174.3500, 497.8789, 137.6535, 189.5455),
        prices = {},
    },
    {
        name = 'High end house 2',
        ipl = function()
            if not IsDuplicityVersion() then
                return exports.bob74_ipl:GetGTAOHouseHi2Object()
            end
        end,
        entry = vec4(342.2078, 437.9602, 149.3806, 104.9856),
        prices = {},
    },
    {
        name = 'High end house 3',
        ipl = function()
            if not IsDuplicityVersion() then
                return exports.bob74_ipl:GetGTAOHouseHi3Object()
            end
        end,
        entry = vec4(373.7228, 423.9125, 145.8997, 170.3039),
        prices = {},
    },
    {
        name = 'High end house 4',
        ipl = function()
            if not IsDuplicityVersion() then
                return exports.bob74_ipl:GetGTAOHouseHi4Object()
            end
        end,
        entry = vec4(-682.5748, 592.7130, 145.3795, 222.5850),
        prices = {},
    },
    {
        name = 'High end house 5',
        ipl = function()
            if not IsDuplicityVersion() then
                return exports.bob74_ipl:GetGTAOHouseHi5Object()
            end
        end,
        entry = vec4(-758.1348, 619.1015, 144.1405, 111.8842),
        prices = {},
    },
    {
        name = 'High end house 6',
        ipl = function()
            if not IsDuplicityVersion() then
                return exports.bob74_ipl:GetGTAOHouseHi6Object()
            end
        end,
        entry = vec4(-859.8599, 691.4716, 152.8525, 186.1947),
        prices = {},
    },
    {
        name = 'High end house 7',
        ipl = function()
            if not IsDuplicityVersion() then
                return exports.bob74_ipl:GetGTAOHouseHi7Object()
            end
        end,
        entry = vec4(117.2493, 560.1372, 184.2967, 188.7763),
        prices = {},
    },
    {
        name = 'High end house 8',
        ipl = function()
            if not IsDuplicityVersion() then
                return exports.bob74_ipl:GetGTAOHouseHi8Object()
            end
        end,
        entry = vec4(-1289.9720, 449.9252, 97.8944, 183.8566),
        prices = {},
    },
    {
        name = 'Middle end house 1',
        ipl = function()
            if not IsDuplicityVersion() then
                return exports.bob74_ipl:GetGTAOHouseMid1Object()
            end
        end,
        entry = vec4(346.6476, -1013.2401, -99.1963, 0.7962),
        prices = {},
    },
}

-- dlc_tuner GAME BUILD  2372
if GetGameBuildNumber() >= 2372 then
    CustomizeIPL[#CustomizeIPL + 1] = {
        name = 'Bail office',
        ipl = function()
            if not IsDuplicityVersion() then
                return exports.bob74_ipl:GetSummerOfficeObject()
            end
        end,
        entry = vec4(570.3802, -2675.7354, -49.0000, 91.3974),
        prices = {},
    }
end

-- dlc_drugwars GAME BUILD 2802
if GetGameBuildNumber() >= 2802 then
    CustomizeIPL[#CustomizeIPL + 1] = {
        name = 'Freakshop',
        ipl = function()
            if not IsDuplicityVersion() then
                return exports.bob74_ipl:GetDrugWarsFreakshopObject()
            end
        end,
        entry = vec4(555.6788, -433.1870, -69.6471, 283.7341),
        prices = {},
    }
    CustomizeIPL[#CustomizeIPL + 1] = {
        name = 'Eclipse Boulevard Garage',
        ipl = function()
            if not IsDuplicityVersion() then
                return exports.bob74_ipl:GetDrugWarsGarageObject()
            end
        end,
        entry = vec4(531.8565, -2637.7612, -49.0000, 86.1326),
        prices = {},
    }
    CustomizeIPL[#CustomizeIPL + 1] = {
        name = 'Acid Lab',
        ipl = function()
            if not IsDuplicityVersion() then
                return exports.bob74_ipl:GetDrugWarsLabObject()
            end
        end,
        entry = vec4(482.5064, -2625.8789, -49.0640, 356.6367),
        prices = {},
    }
end

-- dlc_mercenaries GAME BUILD 2944
if GetGameBuildNumber() >= 2944 then
    CustomizeIPL[#CustomizeIPL + 1] = {
        name = 'Vinewood Car Club',
        ipl = function()
            if not IsDuplicityVersion() then
                return exports.bob74_ipl:GetMercenariesClubObject()
            end
        end,
        entry = vec4(1180.8115, -3261.0137, -47.9999, 1.7485),
        prices = {},
    }
    CustomizeIPL[#CustomizeIPL + 1] = {
        name = 'Fort Zancudo Lab',
        ipl = function()
            if not IsDuplicityVersion() then
                return exports.bob74_ipl:GetMercenariesLabObject()
            end
        end,
        entry = vec4(-1922.3163, 3749.7444, -99.6459, 266.2562),
        prices = {},
    }
end

-- dlc_chopshop GAME BUILD 3095
if GetGameBuildNumber() >= 3095 then
    CustomizeIPL[#CustomizeIPL + 1] = {
        name = 'Cartel Garage',
        ipl = function()
            if not IsDuplicityVersion() then
                return exports.bob74_ipl:GetChopShopCartelGarageObject()
            end
        end,
        entry = vec4(1203.3193, -2297.6094, -47.8996, 277.7933),
        prices = {},
    }
    CustomizeIPL[#CustomizeIPL + 1] = {
        name = 'Cartel Garage',
        ipl = function()
            if not IsDuplicityVersion() then
                return exports.bob74_ipl:GetChopShopCartelGarageObject()
            end
        end,
        entry = vec4(1203.3193, -2297.6094, -47.8996, 277.7933),
        prices = {},
    }
    CustomizeIPL[#CustomizeIPL + 1] = {
        name = 'Salvage Yard',
        ipl = function()
            if not IsDuplicityVersion() then
                return exports.bob74_ipl:GetChopShopSalvageObject()
            end
        end,
        entry = vec4(1098.5929, -2266.0334, -48.9999, 183.2450),
        prices = {},
    }
end

-- dlc_summer GAME BUILD 3258
if GetGameBuildNumber() >= 3258 then
    CustomizeIPL[#CustomizeIPL + 1] = {
        name = 'Bail office',
        ipl = function()
            if not IsDuplicityVersion() then
                return exports.bob74_ipl:GetSummerOfficeObject()
            end
        end,
        entry = vec4(570.3802, -2675.7354, -49.0000, 91.3974),
        prices = {},
    }
end

if GetGameBuildNumber() >= 3407 then
    -- dlc_agents -- GAME BUILD 3407
    CustomizeIPL[#CustomizeIPL + 1] = {
        name = 'Garment Factory',
        ipl = function()
            if not IsDuplicityVersion() then
                return exports.bob74_ipl:GetAgentsFactory()
            end
        end,
        entry = vec4(755.4099, -998.0137, -46.3767, 93.6736),
        prices = {},
    }
    CustomizeIPL[#CustomizeIPL + 1] = {
        name = 'McKenzie Field Hangar Office',
        ipl = function()
            if not IsDuplicityVersion() then
                return exports.bob74_ipl:GetAgentsOffice()
            end
        end,
        entry = vec4(2147.2131, 4789.7134, -46.3750, 186.3166),
        prices = {},
    }
end
