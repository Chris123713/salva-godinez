Config.Licenses = {
    class1 = {
        id_length = 5,                          -- random number generated
        label = "Class 1 Weapon's License",
        manager = { 'police', 'lscso' }, -- the shop or manager menu in Config.Manager
        job = { 'police', 'lscso' },       -- the job that can revoke the license
        validFor = 60,                          -- valid for how many days?
        price = 1500,
        lostPrice = 2500,                       -- Price to retrieve the license when the card is lost (will be enabled if Config.inventory is true)
        illegalPrice = 3000
    },
    class2 = {
        id_length = 5,                          -- random number generated
        label = "Class 2 Weapon's License",
        manager = { 'police', 'lscso' }, -- the shop or manager menu in Config.Manager
        job = { 'police', 'lscso' },       -- the job that can revoke the license
        validFor = 60,                          -- valid for how many days?
        price = 2500,
        lostPrice = 2500,                       -- Price to retrieve the license when the card is lost (will be enabled if Config.inventory is true)
        illegalPrice = 3000
    },
     class3 = {
        id_length = 5,                          -- random number generated
        label = "Class 3 Weapon's License",
        manager = { 'police', 'lscso' }, -- the shop or manager menu in Config.Manager
        job = { 'police', 'lscso' },       -- the job that can revoke the license
        validFor = 60,                          -- valid for how many days?
        price = 5000,
        lostPrice = 2500,                       -- Price to retrieve the license when the card is lost (will be enabled if Config.inventory is true)
        illegalPrice = 3000
    },
     special_attach = {
        id_length = 5,                          -- random number generated
        label = "Special Weapon's Attachment's License",
        manager = { 'police', 'lscso' }, -- the shop or manager menu in Config.Manager
        job = { 'police', 'lscso' },       -- the job that can revoke the license
        validFor = 60,                          -- valid for how many days?
        price = 5000,
        lostPrice = 2500,                       -- Price to retrieve the license when the card is lost (will be enabled if Config.inventory is true)
        illegalPrice = 3000
    },
     surgeon_license = {
        id_length = 5,
        label = "Surgeon License",
        manager = 'ambulance',
        job = 'ambulance',
        validFor = 31,
        price = 1000,
        lostPrice = 500
    },
    nurse_license = {
        id_length = 5,
        label = "Nurse License",
        manager = 'ambulance',
        job = 'ambulance',
        validFor = 31,
        price = 1000,
        lostPrice = 500
    },
    identification = {
        id_length = 10,
        label = "Identification Card",
        manager = 'public',
        job = 'police',
        validFor = 31,
        price = 100,
        lostPrice = 50
    },
    work_permit = {
        id_length = 5,
        label = "Work Permit",
        manager = 'public',
        job = 'police',
        validFor = 31,
        price = 200,
        lostPrice = 100
    },
     driver_car = {
        id_length = 8,
        label = "Car Driving License",
        manager = 'dmv', -- must belong to one of Config.Manager list
        requires = {
            'dmv',       -- this license requires dmv license to have first
        },
        job = 'police',
        validFor = 31,
        price = 2500,
        lostPrice = 1000
    },
    driver_bike = {
        id_length = 8,
        label = "Bike Driving License",
        manager = 'dmv',
        job = 'police',
        validFor = 31,
        price = 2500,
        lostPrice = 1000
    },
    driver_truck = {
        id_length = 8,
        label = "Truck Driving License",
        manager = 'dmv',
        job = 'police',
        validFor = 31,
        price = 2500,
        lostPrice = 1000
    },
    driver_helicopter = {
        id_length = 8,
        label = "Helicopter Driving License",
        manager = 'dmv',
        job = 'police',
        validFor = 31,
        price = 2500,
        lostPrice = 1000
    },
    driver_boat = {
        id_length = 8,
        label = "Boat Driving License",
        manager = 'dmv',
        job = 'police',
        validFor = 31,
        price = 2500,
        lostPrice = 1000
    },
    driver_plane = {
        id_length = 8,
        label = "Plane Driving License",
        manager = 'dmv',
        job = 'police',
        validFor = 31,
        price = 2500,
        lostPrice = 1000
    },
    theory_driver_car = {
        id_length = 8,
        label = "Car Theory License",
        manager = 'dmv', -- must belong to one of Config.Manager list
        job = 'police',
        validFor = 31,
        price = 2500,
        nonItem = true,
        lostPrice = 1000
    },
    theory_driver_bike = {
        id_length = 8,
        label = "Bike Theory License",
        manager = 'dmv',
        job = 'police',
        validFor = 31,
        price = 2500,
        nonItem = true,
        lostPrice = 1000
    },
    theory_driver_truck = {
        id_length = 8,
        label = "Truck Theory License",
        manager = 'dmv',
        job = 'police',
        validFor = 31,
        price = 2500,
        nonItem = true,
        lostPrice = 1000
    },
    theory_driver_helicopter = {
        id_length = 8,
        label = "Helicopter Theory License",
        manager = 'dmv',
        job = 'police',
        validFor = 31,
        price = 2500,
        nonItem = true,
        lostPrice = 1000
    },
    theory_driver_boat = {
        id_length = 8,
        label = "Boat Theory License",
        manager = 'dmv',
        job = 'police',
        validFor = 31,
        price = 2500,
        nonItem = true,
        lostPrice = 1000
    },
    theory_driver_plane = {
        id_length = 8,
        label = "Plane Theory License",
        manager = 'dmv',
        job = 'police',
        validFor = 31,
        price = 2500,
        nonItem = true,
        lostPrice = 1000
    },
}

Config.JobLicenses = {}

for k, v in pairs(Config.Licenses) do
    if type(v.job) == 'string' and Config.JobLicenses[v.job] then
        Config.JobLicenses[v.job][#Config.JobLicenses[v.job] + 1] = k
    elseif type(v.job) == 'string' then
        Config.JobLicenses[v.job] = { k }
    elseif type(v.job) == 'table' then
        for _, job in pairs(v.job) do
            if Config.JobLicenses[job] then
                Config.JobLicenses[job][#Config.JobLicenses[job] + 1] = k
            else
                Config.JobLicenses[job] = { k }
            end
        end
    end
    if type(v.manager) == 'string' and Config.Manager[v.manager] then
        if Config.Manager[v.manager].licenses then
            Config.Manager[v.manager].licenses[k] = v
            Config.Manager[v.manager].licenses[k].illegalPrice = v.illegalPrice or v.price
        elseif Config.Manager[v.manager] then
            Config.Manager[v.manager].licenses = {}
            Config.Manager[v.manager].licenses[k] = v
            Config.Manager[v.manager].licenses[k].illegalPrice = v.illegalPrice or v.price
        end
    elseif type(v.manager) == 'table' then
        for _, manager in pairs(v.manager) do
            if Config.Manager[manager].licenses then
                Config.Manager[manager].licenses[k] = v
                Config.Manager[manager].licenses[k].illegalPrice = v.illegalPrice or v.price
            elseif Config.Manager[manager] then
                Config.Manager[manager].licenses = {}
                Config.Manager[manager].licenses[k] = v
                Config.Manager[manager].licenses[k].illegalPrice = v.illegalPrice or v.price
            end
        end
    else
        print(string.format('[^1ERROR^0]: Please make sure ^2%s^0 in the license ^2%s^0 exists in the ^3manager.lua',
            v.manager, k))
    end
end
