local Framework = nil
local FrameworkName = nil

local function DetectFramework()
    if Config and Config.Framework and Config.Framework ~= 'auto' then
        return string.lower(Config.Framework)
    end
    
    -- Auto detection
    if GetResourceState('es_extended') == 'started' then
        return 'esx'
    elseif GetResourceState('qb-core') == 'started' or GetResourceState('qbx_core') == 'started' then
        return 'qbcore'
    end
    
    -- Fallback
    return 'qbcore'
end

local function SetFramework()
    FrameworkName = DetectFramework()

    if FrameworkName == "qbcore" then
        local core = exports['qb-core']:GetCoreObject()
        if core then
            Framework = core
            return true
        else
            return false
        end
    elseif FrameworkName == "esx" then
        local core = exports['es_extended']:getSharedObject()
        if core then
            Framework = core
            return true
        else 
            return false
        end
    else
        return false
    end
end

SetFramework()

local function TableExists(tableName)
    local result = MySQL.Sync.fetchAll("SELECT COUNT(*) as count FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = ?", {tableName})
    return result and result[1] and result[1].count > 0
end

local function CreateDatabaseTables()
   
    local success, _ = MySQL.Sync.execute([[
        CREATE TABLE IF NOT EXISTS sw_player_trucking_data (
            player_identifier VARCHAR(100) NOT NULL,
            trucker_level INT DEFAULT 1,
            trucker_xp INT DEFAULT 0,
            withdrawable_cash INT DEFAULT 0,
            distance_driven FLOAT DEFAULT 0,
            missions_done INT DEFAULT 0,
            language VARCHAR(5) DEFAULT 'en',
            active_loans TEXT DEFAULT NULL,
            loan_balance INT DEFAULT 0,
            simulator_credit INT DEFAULT 0,
            nickname VARCHAR(20) DEFAULT NULL,
            motto VARCHAR(50) DEFAULT NULL,
            skill_points INT DEFAULT 0,
            daily_withdrawal_amount INT DEFAULT 0,
            last_withdrawal_date INT DEFAULT 0,
            credit_blacklisted TINYINT(1) DEFAULT 0,
            daily_special_loads INT DEFAULT 0,
            special_loads_reset_time INT DEFAULT 0,
            PRIMARY KEY (player_identifier)
        )
    ]], {})
    
    if not success then
        print("^1[SW-TRUCKSIMULATOR]^7 Failed to create main table.")
        return
    end
    
    if TableExists("sw_player_trucking_data") then
        MySQL.Sync.execute([[ALTER TABLE sw_player_trucking_data MODIFY COLUMN player_identifier VARCHAR(100) NOT NULL]], {})
        MySQL.Sync.execute([[ALTER TABLE sw_player_trucking_data DROP COLUMN IF EXISTS mugshot_txd]], {})
        MySQL.Sync.execute([[ALTER TABLE sw_player_trucking_data ADD COLUMN IF NOT EXISTS active_loans TEXT DEFAULT NULL]], {})
        MySQL.Sync.execute([[ALTER TABLE sw_player_trucking_data ADD COLUMN IF NOT EXISTS loan_balance INT DEFAULT 0]], {})
        MySQL.Sync.execute([[ALTER TABLE sw_player_trucking_data DROP COLUMN IF EXISTS total_income]], {})
        MySQL.Sync.execute([[ALTER TABLE sw_player_trucking_data ADD COLUMN IF NOT EXISTS withdrawable_cash INT DEFAULT 0]], {})
        MySQL.Sync.execute([[ALTER TABLE sw_player_trucking_data ADD COLUMN IF NOT EXISTS simulator_credit INT DEFAULT 0]], {})
        MySQL.Sync.execute([[ALTER TABLE sw_player_trucking_data ADD COLUMN IF NOT EXISTS nickname VARCHAR(20) DEFAULT NULL]], {})
        MySQL.Sync.execute([[ALTER TABLE sw_player_trucking_data ADD COLUMN IF NOT EXISTS motto VARCHAR(50) DEFAULT NULL]], {})
        MySQL.Sync.execute([[ALTER TABLE sw_player_trucking_data ADD COLUMN IF NOT EXISTS skill_points INT DEFAULT 0]], {})
        MySQL.Sync.execute([[ALTER TABLE sw_player_trucking_data ADD COLUMN IF NOT EXISTS daily_withdrawal_amount INT DEFAULT 0]], {})
        MySQL.Sync.execute([[ALTER TABLE sw_player_trucking_data ADD COLUMN IF NOT EXISTS last_withdrawal_date INT DEFAULT 0]], {})
        MySQL.Sync.execute([[ALTER TABLE sw_player_trucking_data ADD COLUMN IF NOT EXISTS credit_blacklisted TINYINT(1) DEFAULT 0]], {})
        MySQL.Sync.execute([[ALTER TABLE sw_player_trucking_data ADD COLUMN IF NOT EXISTS daily_special_loads INT DEFAULT 0]], {})
        MySQL.Sync.execute([[ALTER TABLE sw_player_trucking_data ADD COLUMN IF NOT EXISTS special_loads_reset_time INT DEFAULT 0]], {})
        MySQL.Sync.execute([[ALTER TABLE sw_player_trucking_data ADD COLUMN IF NOT EXISTS diamonds INT DEFAULT 0]], {})
    end
    
 
    MySQL.Sync.execute([[
        CREATE TABLE IF NOT EXISTS sw_player_vehicles (
            id INT PRIMARY KEY AUTO_INCREMENT,
            player_identifier VARCHAR(100) NOT NULL,
            vehicle_spawn_name VARCHAR(50) NOT NULL,
            purchase_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            last_used DATETIME DEFAULT NULL,
            vehicle_status VARCHAR(50) DEFAULT 'parked',
            selected TINYINT(1) DEFAULT 0,
            engine_health FLOAT DEFAULT 1000.0,
            body_health FLOAT DEFAULT 1000.0,
            fuel_level FLOAT DEFAULT 100.0,
            wheels_health FLOAT DEFAULT 1000.0,
            transmission_health FLOAT DEFAULT 1000.0,
            FOREIGN KEY (player_identifier) REFERENCES sw_player_trucking_data(player_identifier)
        )
    ]], {})
    
    if TableExists("sw_player_vehicles") then
        MySQL.Sync.execute([[ALTER TABLE sw_player_vehicles MODIFY COLUMN player_identifier VARCHAR(100) NOT NULL]], {})
        MySQL.Sync.execute([[ALTER TABLE sw_player_vehicles MODIFY COLUMN vehicle_spawn_name VARCHAR(50) NOT NULL]], {})
        MySQL.Sync.execute([[ALTER TABLE sw_player_vehicles MODIFY COLUMN vehicle_status VARCHAR(50) DEFAULT 'parked']], {})
        MySQL.Sync.execute([[ALTER TABLE sw_player_vehicles ADD COLUMN IF NOT EXISTS plate VARCHAR(15) NULL DEFAULT NULL AFTER vehicle_spawn_name]], {})
        MySQL.Sync.execute([[ALTER TABLE sw_player_vehicles ADD UNIQUE INDEX IF NOT EXISTS plate_UNIQUE (plate)]], {})
        MySQL.Sync.execute([[ALTER TABLE sw_player_vehicles ADD COLUMN IF NOT EXISTS assigned_to_driver_id INT NULL DEFAULT NULL]], {})
        MySQL.Sync.execute([[ALTER TABLE sw_player_vehicles ADD COLUMN IF NOT EXISTS total_mileage FLOAT DEFAULT 0.0]], {})
        MySQL.Sync.execute([[ALTER TABLE sw_player_vehicles ADD COLUMN IF NOT EXISTS primary_color_r INT DEFAULT NULL]], {})
        MySQL.Sync.execute([[ALTER TABLE sw_player_vehicles ADD COLUMN IF NOT EXISTS primary_color_g INT DEFAULT NULL]], {})
        MySQL.Sync.execute([[ALTER TABLE sw_player_vehicles ADD COLUMN IF NOT EXISTS primary_color_b INT DEFAULT NULL]], {})
        MySQL.Sync.execute([[ALTER TABLE sw_player_vehicles ADD COLUMN IF NOT EXISTS primary_color_type VARCHAR(20) DEFAULT 'normal']], {})
        MySQL.Sync.execute([[ALTER TABLE sw_player_vehicles ADD COLUMN IF NOT EXISTS secondary_color_r INT DEFAULT NULL]], {})
        MySQL.Sync.execute([[ALTER TABLE sw_player_vehicles ADD COLUMN IF NOT EXISTS secondary_color_g INT DEFAULT NULL]], {})
        MySQL.Sync.execute([[ALTER TABLE sw_player_vehicles ADD COLUMN IF NOT EXISTS secondary_color_b INT DEFAULT NULL]], {})
        MySQL.Sync.execute([[ALTER TABLE sw_player_vehicles ADD COLUMN IF NOT EXISTS wheels_health FLOAT DEFAULT 1000.0]], {})
        MySQL.Sync.execute([[ALTER TABLE sw_player_vehicles ADD COLUMN IF NOT EXISTS transmission_health FLOAT DEFAULT 1000.0]], {})
    end
    
    MySQL.Sync.execute([[
        CREATE TABLE IF NOT EXISTS sw_player_skills (
            id INT PRIMARY KEY AUTO_INCREMENT,
            player_identifier VARCHAR(100) NOT NULL,
            skill_type VARCHAR(50) NOT NULL,
            skill_level INT DEFAULT 0,
            FOREIGN KEY (player_identifier) REFERENCES sw_player_trucking_data(player_identifier),
            UNIQUE KEY unique_player_skill (player_identifier, skill_type)
        )
    ]], {})
    
    MySQL.Sync.execute([[
        CREATE TABLE IF NOT EXISTS sw_truckconvoy (
            id VARCHAR(10) PRIMARY KEY NOT NULL,
            name VARCHAR(50) NOT NULL,
            has_password TINYINT(1) DEFAULT 0,
            password VARCHAR(50) DEFAULT NULL,
            max_members INT DEFAULT 4,
            leader_id VARCHAR(100) NOT NULL,
            members TEXT NOT NULL,
            selected_mission TEXT DEFAULT NULL,
            mission_started TINYINT(1) DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        )
    ]], {})
    

    MySQL.Sync.execute([[
        CREATE TABLE IF NOT EXISTS sw_vehicle_marketplace (
            id INT PRIMARY KEY AUTO_INCREMENT,
            seller_identifier VARCHAR(100) NOT NULL,
            vehicle_purchase_id INT NOT NULL,
            price BIGINT NOT NULL,
            description TEXT DEFAULT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            status ENUM('active', 'sold', 'removed') DEFAULT 'active',
            FOREIGN KEY (seller_identifier) REFERENCES sw_player_trucking_data(player_identifier),
            FOREIGN KEY (vehicle_purchase_id) REFERENCES sw_player_vehicles(id),
            UNIQUE KEY unique_vehicle_listing (vehicle_purchase_id)
        )
    ]], {})
end

function GetFramework()
    if not Framework then
        SetFramework()
    end
    return Framework, FrameworkName
end

function GetAllJobs()
    math.randomseed(os.time() + math.random(1, 1000))
    
    local jobsData = {}
    
    for level = 1, 30 do
        jobsData[level] = {
            missions = {}
        }
    end
    
    if not Config.Jobs or not Config.Jobs.available_loads then
        return jobsData
    end
    for _, job in pairs(Config.Jobs.available_loads) do
        local level = job.level or 1
        if not jobsData[level] then
            jobsData[level] = { missions = {} }
        end
        local cargoType = job.cargoType or "general"
        
        local truckModel = "hauler"
        
        if job.trucks and job.trucks ~= "" then
            local truckModels = {}
            for model in string.gmatch(job.trucks, "([^,]+)") do
                table.insert(truckModels, model:match("^%s*(.-)%s*$"))
            end
            
            if #truckModels > 0 then
                local randomIndex = math.random(1, #truckModels)
                truckModel = truckModels[randomIndex]
            end
        end

        table.insert(jobsData[level].missions, {
            id = job.id or (#jobsData[level].missions + 1),
            name = job.name,
            description = job.description or job.name,
            difficulty = job.difficulty or "normal",
            level = level,
            truckModel = truckModel,
            trailerModel = job.trailer,
            cargoType = cargoType,
            distance = job.distance or 0,
            destination_coords = job.destination or "RANDOM"
        })
    end
    
    for i = 1, 30 do
        if not jobsData[i] then
            jobsData[i] = { missions = {} }
        end
    end
    return jobsData
end

function GetJobById(id)
    if not id or not Config.Jobs or not Config.Jobs.available_loads then
        return nil
    end
    for _, job in pairs(Config.Jobs.available_loads) do
        if job.id == id then
            local cargoType = job.cargoType or "general"
            
            local truckModel = "hauler"
            
            if job.trucks and job.trucks ~= "" then
                local truckModels = {}
                for model in string.gmatch(job.trucks, "([^,]+)") do
                    table.insert(truckModels, model:match("^%s*(.-)%s*$"))
                end
                
                if #truckModels > 0 then
                    local randomIndex = math.random(1, #truckModels)
                    truckModel = truckModels[randomIndex]
                end
            end
            
            local job_to_return = {
                id = job.id,
                name = job.name,
                description = job.description or job.name,
                level = job.level or 1,
                difficulty = job.difficulty or "normal",
                truckModel = truckModel,
                trailerModel = job.trailer,
                cargoType = cargoType,
                distance = job.distance or 0,
                destination_coords = job.destination or "RANDOM"
            }
            return job_to_return
        end
    end
    
    return nil
end

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        Citizen.CreateThread(function()
            CreateDatabaseTables()
        end)
    end
end)

exports('GetAllJobs', GetAllJobs)
exports('GetJobById', GetJobById)
exports('GetFramework', GetFramework)