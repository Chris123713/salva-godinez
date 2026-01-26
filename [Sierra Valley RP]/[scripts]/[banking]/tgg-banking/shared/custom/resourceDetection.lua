-- ========================= --
--- Framework Normalization ---
-- ========================= --
debugPrint('Auto-detecting framework...')

if (Config.Framework == 'auto' and GetResourceState('qbx_core') == 'started') or Config.Framework == 'qbox' then
    Config.Framework = 'qbox'
elseif (Config.Framework == 'auto' and GetResourceState('qb-core') == 'started') or Config.Framework == 'qb' then
    Config.Framework = 'qb'
elseif (Config.Framework == 'auto' and GetResourceState('es_extended') == 'started') or Config.Framework == 'esx' then
    Config.Framework = 'esx'
elseif Config.Framework == 'standalone' then
    print(
        "^6[BANKING] ^1[INFO]^7: shared:resourceDetection.lua: You are using the standalone framework. Make sure to implement the functions in `(client/server)/custom/frameworks/standalone.lua`.")
else
    print(
        "^6[BANKING] ^1[WARNING]^7: shared:resourceDetection.lua: No framework resource found. Make sure to install one of the supported frameworks or set the Config.Framework to \'standalone\'.")
end

debugPrint('Auto-detected framework: ' .. Config.Framework)
-- ========================= --
--- Framework Normalization ---
-- ========================= --



-- ========================= --
--- Interact Normalization ---
-- ========================= --
if Config.InteractOption == 'auto' then
    debugPrint('Auto-detecting interact option...')

    local interactOptions = {
        'ox_target',
        'qb-target',
        'interact',
        'sleepless_interact',
    }

    for i = 1, #interactOptions do
        if GetResourceState(interactOptions[i]):find('start') then
            Config.InteractOption = interactOptions[i]
            break
        end
    end

    if Config.InteractOption == 'auto' then
        Config.InteractOption = 'drawtext'
    end

    debugPrint('Auto-detected interact option: ' .. Config.InteractOption)
end
-- ========================= --
--- Interact Normalization ---
-- ========================= --



-- ========================= --
--- Inventory Normalization ---
-- ========================= --
if Config.Inventory == 'auto' then
    debugPrint('Auto-detecting inventory option...')

    local inventories = {
        'ox_inventory',
        'qb-inventory',
        'lj-inventory',
        'ps-inventory',
    }

    for i = 1, #inventories do
        if GetResourceState(inventories[i]):find('start') then
            Config.Inventory = inventories[i]
            break
        end
    end

    if Config.Inventory == 'auto' then
        Config.Inventory = 'standalone'
    end

    debugPrint('Auto-detected inventory option: ' .. Config.Inventory)
end
-- ========================= --
--- Inventory Normalization ---
-- ========================= --
