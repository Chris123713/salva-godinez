-- Tommy's Radio System Configuration
-- Documentation can be found at: https://tommys-scripts.gitbook.io/fivem/paid-scripts/tommys-radio/setup-and-configuration
-- Config Version 3.6 - Use a website like https://www.diffchecker.com/ to compare configuration file changes

Config = {
    -- Available radio layouts
    radioLayouts = {
        "AFX-1500",
        "AFX-1500G",
        "ARX-4000X",
        "XPR-6500",
        "XPR-6500S",
        "ATX-8000",
        "ATX-8000G",
        "ATX-NOVA",
        "TXDF-9100",
    },

    -- Default layouts by vehicle type
    defaultLayouts = {
        ["Handheld"] = "ATX-8000",
        ["Vehicle"] = "AFX-1500",
        ["Boat"] = "AFX-1500G",
        ["Air"] = "TXDF-9100",

    -- Example default layouts by spawn code

        ["fbi2"] = "XPR-6500",
        ["police"] = "XPR-6500",
        ["lscso"] = "XPR-6500",
        ["safr"] = "XPR-6500S",
    },

    -- Control keys
    controls = {
        talkRadioKey = "B",
        toggleRadioKey = "F7",
        channelUpKey = "",
        channelDownKey = "",
        zoneUpKey = "",
        zoneDownKey = "",
        menuUpKey = "",
        menuDownKey = "",
        menuRightKey = "",
        menuLeftKey = "",
        menuHomeKey = "",
        menuBtn1Key = "",
        menuBtn2Key = "",
        menuBtn3Key = "",
        emergencyBtnKey = "",
        closeRadioKey = "",
        powerBtnKey = "",
        styleUpKey= "",
        styleDownKey= "",
        voiceVolumeUpKey = "",
        voiceVolumeDownKey = "",
        sfxVolumeUpKey = "",
        sfxVolumeDownKey = "",
        volume3DUpKey = "",
        volume3DDownKey = "",
    },

    -- Network settings
    connectionAddr = "",    -- Final connection string for clients, Including protocol (https://proxy.example.com) and/or port. (If empty, uses host ip address and port)
    serverPort = 7777,      -- Port for radio server & dispatch panel, choose a port that is not used by other resources.
    authToken = "SierraValley_R4d10_X7k9mP2nQ5wL8vB3", -- Secure token for radio authentication
    dispatchNacId = "141",  -- NAC ID / Password for dispatch channel - LEO dispatch access
    useDiscordAuth = false, -- Enable Discord authentication for dispatch panel (requires Discord setup in server/.env - see server/.env.example)

    -- General settings
    doUpdateCheck = true,  -- Enable automatic update checking on resource start
    logLevel = 3,          -- (0 = Error, 1 = Warnings, 2 = Minimal, 3 = Normal, 4 = Debug, 5 = Verbose)
    pttReleaseDelay = 350, -- Delay in milliseconds before releasing PTT to prevent cut-off (250-500ms recommended)
    panicTimeout = 60000,
    triggerProximityPTT = true, -- When true, pushing PTT on radio will also trigger proximity voice chat so nearby players can hear you in-game

    -- This function determines whether PTT (Push-to-Talk) is allowed based on player state
    -- Return true to allow talking, false to block transmission
    -- Configured for Qbox/ox_lib
    talkCheck = function()
        -- Default checks: player must not be dead or swimming
        if IsPlayerDead(PlayerId()) then
            return false
        end

        if IsPedSwimming(PlayerPedId()) then
            return false
        end

        -- Check if player is cuffed (ox_lib state)
        local isCuffed = LocalPlayer.state.cuffed
        if isCuffed then
            return false
        end

        -- Check if player is in police custody/escorted
        local isEscorted = LocalPlayer.state.escorted
        if isEscorted then
            return false
        end

        -- Allow transmission if all checks pass
        return true
    end,

    -- Audio settings
    voiceVolume = 65,                 -- Default voice volume (0-100), can be changed in radio settings menu
    sfxVolume = 35,                   -- Default sfx volume (0-100), can be changed in radio settings menu
    volumeStep = 5,                   -- Volume change increment when using volume up/down keys for all volume types (1-20 recommended, default: 5)
    playTransmissionEffects = true,   -- Play background sound effects (sirens, helis, gunshots)
    analogTransmissionEffects = true, -- Play analog transmission sound effects (static during transmission)

    -- 3D Audio settings (EXPERIMENTAL)
    enable3DAudio = true,    -- MASTER SWITCH: true = 3D audio system enabled globally, false = 3D audio system disabled entirely (hides earbuds and 3D volume settings)
    default3DAudio = false,   -- true = earbuds OFF by default (3D audio enabled), false = earbuds ON by default (3D audio disabled) [Only applies when enable3DAudio = true]
    default3DVolume = 50,    -- Default 3D audio volume (0-100), saved per user like voice/sfx volume, default is 50 [Only applies when enable3DAudio = true]
    vehicle3DActivationDistance = 5.0, -- Minimum distance (in meters) the owner must be from their vehicle for 3D audio to activate from that vehicle [Only applies when enable3DAudio = true]

    -- GPS Blip Performance Settings
    gpsBlipUpdateRate = 50,  -- Update rate in milliseconds for GPS blip updates (default: 50ms = 20 updates/sec)
                             -- PERFORMANCE NOTE: Lower values = smoother blip movement but higher CPU usage
                             -- Recommended values: 50ms (smooth), 100ms (balanced), 250ms (performance), 500ms (low-end)
                             -- If experiencing performance issues with many GPS players, increase this value

    -- Signal Tower Coordinates (for signal strength calculation) - DOES NOT affect voice quality currently. Used for signal icon display.
    signalTowerCoordinates = {
        { x = 1860.0,  y = 3677.0,  z = 33.0 },
        { x = 449.0,   y = -992.0,  z = 30.0 },
        { x = -979.0,  y = -2632.0, z = 23.0 },
        { x = -2364.0, y = 3229.0,  z = 45.0 },
        { x = -449.0,  y = 6025.0,  z = 35.0 },
        { x = 1529.0,  y = 820.0,   z = 79.0 },
        { x = -573.0,  y = -146.0,  z = 38.0 },
        { x = -3123.0, y = 1334.0,  z = 25.0 },
        { x = 5266.79, y = -5427.7, z = 139.7 },
    },

    -- Battery system configuration
    -- This function is called every second to update the battery level
    -- @param currentBattery: number - current battery level (0-100)
    -- @param deltaTime: number - time since last update in seconds
    -- @return: number - new battery level (0-100)
    batteryTick = function(currentBattery, deltaTime)
        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)

        if vehicle ~= 0 then
            -- Charge battery when in vehicle
            local chargeRate = 1.0 -- 1.0% per second
            return math.min(100.0, currentBattery + (chargeRate * deltaTime))
        else
            -- Discharge battery when on foot
            local dischargeRate = 0.01 -- 0.5% per second
            return math.max(0.0, currentBattery - (dischargeRate * deltaTime))
        end
    end,

    -- Multiple Animation Configurations
    -- Users can select which animation to use through radio settings (you can remove or add more options)
    animations = {
        [1] = {
            name = "None",
            onKeyState = function(isKeyDown)
                -- Empty function for no animations
            end,
            onRadioFocus = function(focused)
                -- Empty function for no animations
            end
        },
        [2] = {
            name = "Shoulder",
            onKeyState = function(isKeyDown)
                local playerPed = PlayerPedId()
                if not playerPed or playerPed == 0 then return end

                -- Initialize animation state tracker if it doesn't exist
                if not _radioAnimState then
                    _radioAnimState = {
                        isPlaying = false,
                        pendingStart = false,
                        dictLoaded = false
                    }
                end

                if isKeyDown then
                    -- Mark that we want to start animation
                    _radioAnimState.pendingStart = true

                    -- Animation when starting to talk (key down)
                    RequestAnimDict('random@arrests')

                    -- Non-blocking check for animation dictionary
                    Citizen.CreateThread(function()
                        local attempts = 0
                        while not HasAnimDictLoaded("random@arrests") and attempts < 50 do
                            Citizen.Wait(10)
                            attempts = attempts + 1
                        end

                        -- Only start animation if we still want to start it (user hasn't released PTT)
                        if _radioAnimState.pendingStart and HasAnimDictLoaded("random@arrests") then
                            _radioAnimState.dictLoaded = true
                            if not IsEntityPlayingAnim(playerPed, "random@arrests", "generic_radio_enter", 3) then
                                TaskPlayAnim(playerPed, "random@arrests", "generic_radio_enter", 8.0, 2.0, -1, 50, 2.0, false,
                                    false, false)
                                _radioAnimState.isPlaying = true
                            end
                        end
                    end)
                else
                    -- Animation when stopping talk (key up)
                    _radioAnimState.pendingStart = false

                    -- Stop animation immediately regardless of loading state
                    if _radioAnimState.isPlaying or IsEntityPlayingAnim(playerPed, "random@arrests", "generic_radio_enter", 3) then
                        StopAnimTask(playerPed, "random@arrests", "generic_radio_enter", -4.0)
                        _radioAnimState.isPlaying = false
                    end
                end
            end,
            onRadioFocus = function(focused)
                local playerPed = PlayerPedId()
                if not playerPed or playerPed == 0 then return end

                -- Initialize animation state tracker if it doesn't exist
                if not _radioAnimState then
                    _radioAnimState = {
                        isPlaying = false,
                        pendingStart = false,
                        dictLoaded = false,
                        radioProp = nil
                    }
                end

                if focused then
                    -- Start handheld radio animation when focused
                    if not _radioAnimState.isPlaying then
                        RequestAnimDict('cellphone@')

                        Citizen.CreateThread(function()
                            local attempts = 0
                            while not HasAnimDictLoaded("cellphone@") and attempts < 50 do
                                Citizen.Wait(10)
                                attempts = attempts + 1
                            end

                            if HasAnimDictLoaded("cellphone@") then
                                if not IsEntityPlayingAnim(playerPed, "cellphone@", "cellphone_call_to_text", 3) then
                                    TaskPlayAnim(playerPed, "cellphone@", "cellphone_call_to_text", 8.0, 2.0, -1, 50, 2.0, false, false, false)

                                    -- Create and attach radio prop
                                    _radioAnimState.radioProp = CreateObject(GetHashKey("prop_cs_hand_radio"), 0, 0, 0, true, true, true)
                                    AttachEntityToEntity(_radioAnimState.radioProp, playerPed, GetPedBoneIndex(playerPed, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
                                    SetEntityAsMissionEntity(_radioAnimState.radioProp, true, true)

                                    _radioAnimState.isPlaying = true
                                end
                            end
                        end)
                    end
                else
                    -- Stop handheld radio animation when losing focus
                    if _radioAnimState.isPlaying then
                        if IsEntityPlayingAnim(playerPed, "cellphone@", "cellphone_call_to_text", 3) then
                            StopAnimTask(playerPed, "cellphone@", "cellphone_call_to_text", -4.0)
                        end

                        -- Delete radio prop
                        if _radioAnimState.radioProp then
                            DeleteObject(_radioAnimState.radioProp)
                            _radioAnimState.radioProp = nil
                        end

                        _radioAnimState.isPlaying = false
                    end
                end
            end
        },
        [3] = {
            name = "Handheld",
            onKeyState = function(isKeyDown)
                local playerPed = PlayerPedId()
                if not playerPed or playerPed == 0 then return end

                if not _radioAnimState then
                    _radioAnimState = {
                        isPlaying = false,
                        pendingStart = false,
                        dictLoaded = false,
                        radioProp = nil
                    }
                end
                if isKeyDown then
                    _radioAnimState.pendingStart = true
                    RequestAnimDict('cellphone@')

                    Citizen.CreateThread(function()
                        local attempts = 0
                        while not HasAnimDictLoaded("cellphone@") and attempts < 50 do
                            Citizen.Wait(10)
                            attempts = attempts + 1
                        end

                        if _radioAnimState.pendingStart and HasAnimDictLoaded("cellphone@") then
                            _radioAnimState.dictLoaded = true
                            if not IsEntityPlayingAnim(playerPed, "cellphone@", "cellphone_call_to_text", 3) then
                                TaskPlayAnim(playerPed, "cellphone@", "cellphone_call_to_text", 8.0, 2.0, -1, 50, 2.0, false, false, false)

                                -- Create and attach radio prop
                                _radioAnimState.radioProp = CreateObject(GetHashKey("prop_cs_hand_radio"), 0, 0, 0, true, true, true)
                                AttachEntityToEntity(_radioAnimState.radioProp, playerPed, GetPedBoneIndex(playerPed, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
                                SetEntityAsMissionEntity(_radioAnimState.radioProp, true, true)

                                _radioAnimState.isPlaying = true
                            end
                        end
                    end)
                else
                    _radioAnimState.pendingStart = false
                    if _radioAnimState.isPlaying or IsEntityPlayingAnim(playerPed, "cellphone@", "cellphone_call_to_text", 3) then
                        StopAnimTask(playerPed, "cellphone@", "cellphone_call_to_text", -4.0)

                        -- Delete radio prop
                        if _radioAnimState.radioProp then
                            DeleteObject(_radioAnimState.radioProp)
                            _radioAnimState.radioProp = nil
                        end

                        _radioAnimState.isPlaying = false
                    end
                end
            end,
            onRadioFocus = function(focused)
            local playerPed = PlayerPedId()
            if not playerPed or playerPed == 0 then return end

            -- Initialize animation state tracker if it doesn't exist
            if not _radioAnimState then
                _radioAnimState = {
                    isPlaying = false,
                    pendingStart = false,
                    dictLoaded = false,
                    radioProp = nil
                }
            end

            if focused then
                -- Start handheld radio animation when focused
                if not _radioAnimState.isPlaying then
                    RequestAnimDict('cellphone@')

                    Citizen.CreateThread(function()
                        local attempts = 0
                        while not HasAnimDictLoaded("cellphone@") and attempts < 50 do
                            Citizen.Wait(10)
                            attempts = attempts + 1
                        end

                        if HasAnimDictLoaded("cellphone@") then
                            if not IsEntityPlayingAnim(playerPed, "cellphone@", "cellphone_call_to_text", 3) then
                                TaskPlayAnim(playerPed, "cellphone@", "cellphone_call_to_text", 8.0, 2.0, -1, 50, 2.0, false, false, false)

                                -- Create and attach radio prop
                                _radioAnimState.radioProp = CreateObject(GetHashKey("prop_cs_hand_radio"), 0, 0, 0, true, true, true)
                                AttachEntityToEntity(_radioAnimState.radioProp, playerPed, GetPedBoneIndex(playerPed, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
                                SetEntityAsMissionEntity(_radioAnimState.radioProp, true, true)

                                _radioAnimState.isPlaying = true
                            end
                        end
                    end)
                end
            else
                -- Stop handheld radio animation when losing focus
                if _radioAnimState.isPlaying then
                    if IsEntityPlayingAnim(playerPed, "cellphone@", "cellphone_call_to_text", 3) then
                        StopAnimTask(playerPed, "cellphone@", "cellphone_call_to_text", -4.0)
                    end

                    -- Delete radio prop
                    if _radioAnimState.radioProp then
                        DeleteObject(_radioAnimState.radioProp)
                        _radioAnimState.radioProp = nil
                    end

                    _radioAnimState.isPlaying = false
                end
            end
            end
        },
        [4] = {
            name = "Earpiece",
            onKeyState = function(isKeyDown)
                local playerPed = PlayerPedId()
                if not playerPed or playerPed == 0 then return end

                -- Initialize animation state tracker if it doesn't exist
                if not _radioAnimState then
                    _radioAnimState = {
                        isPlaying = false,
                        pendingStart = false,
                        dictLoaded = false
                    }
                end

                if isKeyDown then
                    -- Mark that we want to start animation
                    _radioAnimState.pendingStart = true

                    -- Animation when starting to talk (key down)
                    RequestAnimDict('cellphone@')

                    -- Non-blocking check for animation dictionary
                    Citizen.CreateThread(function()
                        local attempts = 0
                        while not HasAnimDictLoaded("cellphone@") and attempts < 50 do
                            Citizen.Wait(10)
                            attempts = attempts + 1
                        end

                        -- Only start animation if we still want to start it (user hasn't released PTT)
                        if _radioAnimState.pendingStart and HasAnimDictLoaded("cellphone@") then
                            _radioAnimState.dictLoaded = true
                            if not IsEntityPlayingAnim(playerPed, "cellphone@", "cellphone_call_listen_base", 3) then
                                TaskPlayAnim(playerPed, "cellphone@", "cellphone_call_listen_base", 8.0, 2.0, -1, 50, 2.0, false,
                                    false, false)
                                _radioAnimState.isPlaying = true
                            end
                        end
                    end)
                else
                    -- Animation when stopping talk (key up)
                    _radioAnimState.pendingStart = false

                    -- Stop animation immediately regardless of loading state
                    if _radioAnimState.isPlaying or IsEntityPlayingAnim(playerPed, "cellphone@", "cellphone_call_listen_base", 3) then
                        StopAnimTask(playerPed, "cellphone@", "cellphone_call_listen_base", -4.0)
                        _radioAnimState.isPlaying = false
                    end
                end
            end,
            onRadioFocus = function(focused)
                -- No animation on focus/unfocus for Earpiece
                -- Animation is handled by onKeyState (PTT)
            end
        },
        --[[ Check the documentation for more details on how to add these animations.
        [5] = {
            name = "Chest",
            onKeyState = function(isKeyDown)
                -- Use radio chest animation from RP Emotes
                if isKeyDown then
                    exports["rpemotes"]:EmoteCommandStart("radiochest", 0)
                else
                    exports["rpemotes"]:EmoteCancel(true)
                end
            end,
            onRadioFocus = function(focused)
                if focused then
                    exports["rpemotes"]:EmoteCommandStart("wt", 0)
                else
                    exports["rpemotes"]:EmoteCancel(true)
                end
            end
        },
        [6] = {
            name = "Handheld2",
            onKeyState = function(isKeyDown)
                -- Use radio chest animation from RP Emotes
                if isKeyDown then
                    exports["rpemotes"]:EmoteCommandStart("wt4", 0)
                else
                    exports["rpemotes"]:EmoteCancel(true)
                end
            end,
            onRadioFocus = function(focused)
                if focused then
                    exports["rpemotes"]:EmoteCommandStart("wt", 0)
                else
                    exports["rpemotes"]:EmoteCancel(true)
                end
            end
        },
        --]]
    },



    -- Interference settings
    bonkingEnabled = true,
    bonkInterval = 750,
    interferenceTimeout = 5000,
    blockAudioDuringInterference = true,

    -- Permission check for radio access (SERVER ONLY)
    -- Requires radio item AND specific job (police, lscso, safr)
    radioAccessCheck = function(playerId)
        if not playerId or playerId <= 0 then
            Logger.error("Invalid playerId in radioAccessCheck: " .. tostring(playerId))
            return false
        end

        -- Check if player has a radio item in inventory
        local hasRadio = exports.ox_inventory:Search(playerId, 'count', 'radio')
        if not hasRadio or hasRadio < 1 then
            return false
        end

        -- Check if player has an allowed job
        local allowedJobs = { ['police'] = true, ['lscso'] = true, ['safr'] = true }
        local success, player = pcall(function()
            return exports.qbx_core:GetPlayer(playerId)
        end)

        if success and player and player.PlayerData and player.PlayerData.job then
            local jobName = player.PlayerData.job.name
            if allowedJobs[jobName] then
                return true
            end
        end

        return false
    end,

    -- Get user NAC ID (SERVER ONLY)
    -- NAC IDs determine channel access permissions
    -- 141 = LEO (LSPD, LSCSO, SASP)
    -- 200 = EMS/Fire (SAFR)
    getUserNacId = function(serverId)
        if not serverId or serverId <= 0 then
            return nil
        end

        -- Qbox integration
        local success, player = pcall(function()
            return exports.qbx_core:GetPlayer(serverId)
        end)

        if success and player and player.PlayerData and player.PlayerData.job then
            local jobName = player.PlayerData.job.name
            -- LEO jobs get NAC 141
            if jobName == "police" or jobName == "lscso" or jobName == "sasp" then
                return "141"
            -- EMS/Fire gets NAC 200
            elseif jobName == "safr" then
                return "200"
            end
        end

        return "0" -- No special access
    end,

    -- Get player display name (SERVER ONLY)
    -- Configured for Qbox - uses callsign or character name
    getPlayerName = function(serverId)
        if not serverId then return "DISPATCH" end
        if serverId <= 0 then return "DISPATCH" end

        -- Qbox integration
        local success, player = pcall(function()
            return exports.qbx_core:GetPlayer(serverId)
        end)

        if success and player and player.PlayerData then
            -- Check for callsign in metadata (preferred for RP)
            if player.PlayerData.metadata and player.PlayerData.metadata.callsign then
                local callsign = player.PlayerData.metadata.callsign
                if callsign ~= "NO CALLSIGN" and callsign ~= "" then
                    return callsign
                end
            end

            -- Fallback to character last name
            if player.PlayerData.charinfo and player.PlayerData.charinfo.lastname then
                local lastname = player.PlayerData.charinfo.lastname
                if lastname ~= "" then
                    return lastname
                end
            end

            -- Last resort: first + last name initial
            if player.PlayerData.charinfo then
                local firstname = player.PlayerData.charinfo.firstname or ""
                local lastname = player.PlayerData.charinfo.lastname or ""
                if firstname ~= "" then
                    local initial = lastname ~= "" and (lastname:sub(1,1) .. ".") or ""
                    return firstname .. " " .. initial
                end
            end
        end

        -- Fallback to FiveM player name
        local name = GetPlayerName(serverId)
        if not name or name == "" then
            return "Unit " .. serverId
        end

        return name
    end,

    -- Check if player has siren on (CLIENT ONLY)
    -- ============================================================================
    -- LVC INTEGRATION - Uses export from lvc resource
    -- ============================================================================
    bgSirenCheck = function(lvcSirenState)
        -- Use the LVC export to check siren state
        local success, result = pcall(function()
            return exports["lvc"]:sirenCheck()
        end)

        if success then
            return result
        end

        -- Fallback if export fails
        return lvcSirenState and lvcSirenState > 0
    end,

    --[[
    ============================================================================
    NON-LVC FALLBACK VERSION
    ============================================================================
    Use this version if you DON'T have LVC (Luxart Vehicle Control) installed.

    How to use:
      1. Comment out the LVC version above
      2. Uncomment this entire section (remove the markers)

    Note: The lvcSirenState parameter will be nil/0 without LVC, so you can
    ignore it and use your own logic.

    WARNING: This fallback version cannot distinguish between lights-only mode
    and siren audio. It will return true whenever sirens are on (including
    lights-only), which may cause false positives.
    ============================================================================

    bgSirenCheck = function(lvcSirenState)
        local playerPed = PlayerPedId()
        if not playerPed or playerPed == 0 then return false end

        local vehicle = GetVehiclePedIsIn(playerPed, false)
        if not vehicle or vehicle == 0 then return false end

        -- Check if vehicle has sirens on
        if not IsVehicleSirenOn(vehicle) then return false end

        -- Check speed (convert m/s to mph) - lowered from 50 to 10 mph for better detection
        local speed = GetEntitySpeed(vehicle) * 2.237
        if speed <= 10 then return false end

        -- Fallback: Just check if siren is on (will return true for lights-only mode too)
        return IsVehicleSirenOn(vehicle)
    end,
    ]]

    -- Alerts configuration, the first alert is the default alert for the SGN button in-game
    alerts = {
        [1] = {
          name = "SIGNAL 100", -- Alert Name
          color = "#d19d00", -- Hex color code for alert
          isPersistent = true, -- If true, the alert stays active until cleared
          tone = "ALERT_A", -- Corrosponds to a tone defined in client/radios/default/tones.json
        },
        [2] = {
          name = "SIGNAL 3",
          color = "#0049d1", -- Hex color code for alert
          isPersistent = true, -- If true, the alert stays active until cleared
          tone = "ALERT_A", -- Corrosponds to a tone defined in client/radios/default/tones.json
        },
        [3] = {
          name = "Ping",
          color = "#0049d1", -- Hex color code for alert
          tone = "ALERT_B", -- Corrosponds to a tone defined in client/radios/default/tones.json
        },
        [4] = {
          name = "Boop",
          color = "#1c4ba3", -- Hex color code for alert
          toneOnly = true, -- If true, only plays tone without showing alert on radio
          tone = "BONK", -- Corrosponds to a tone defined in client/radios/default/tones.json
        },
    },

    -- Radio zones and channels
    -- NAC ID Reference:
    --   "141" = LEO (police, lscso, sasp)
    --   "200" = EMS/Fire (safr)
    -- NOTE: Civilian channels removed - civilians use lb-radioapp instead
    zones = {
        -- ============================================
        -- LEO STATEWIDE - All law enforcement
        -- ============================================
        [1] = {
            name = "LEO State",
            nacIds = { "141" },
            Channels = {
                [1] = {
                    name = "DISP",                                -- Statewide Dispatch
                    type = "conventional",
                    frequency = 154.755,
                    allowedNacs = { "141" },
                    scanAllowedNacs = { "200" },                  -- EMS can scan
                },
                [2] = {
                    name = "C2C",                                 -- Car-to-Car
                    type = "trunked",
                    frequency = 856.1125,
                    frequencyRange = { 856.000, 859.000 },
                    coverage = 500,
                    allowedNacs = { "141" },
                },
                [3] = {
                    name = "10-1",                                -- Bathroom break / Private
                    type = "conventional",
                    frequency = 154.785,
                    allowedNacs = { "141" },
                },
                [4] = {
                    name = "TAC-1",                               -- Tactical 1
                    type = "conventional",
                    frequency = 154.815,
                    allowedNacs = { "141" },
                },
                [5] = {
                    name = "TAC-2",                               -- Tactical 2
                    type = "conventional",
                    frequency = 154.845,
                    allowedNacs = { "141" },
                },
            },
        },
        -- ============================================
        -- LSPD - Los Santos Police Department
        -- ============================================
        [2] = {
            name = "LSPD",
            nacIds = { "141" },
            Channels = {
                [1] = {
                    name = "DISP",                                -- LSPD Dispatch
                    type = "conventional",
                    frequency = 460.250,
                    allowedNacs = { "141" },
                    scanAllowedNacs = { "200" },
                },
                [2] = {
                    name = "C2C",
                    type = "trunked",
                    frequency = 460.325,
                    frequencyRange = { 460.325, 462.325 },
                    coverage = 250,
                    allowedNacs = { "141" },
                },
                [3] = {
                    name = "10-1",
                    type = "conventional",
                    frequency = 460.275,
                    allowedNacs = { "141" },
                },
                [4] = {
                    name = "TAC-1",
                    type = "conventional",
                    frequency = 460.300,
                    allowedNacs = { "141" },
                },
            },
        },
        -- ============================================
        -- LSCSO - Los Santos County Sheriff
        -- ============================================
        [3] = {
            name = "LSCSO",
            nacIds = { "141" },
            Channels = {
                [1] = {
                    name = "DISP",                                -- LSCSO Dispatch
                    type = "conventional",
                    frequency = 155.070,
                    allowedNacs = { "141" },
                    scanAllowedNacs = { "200" },
                },
                [2] = {
                    name = "C2C",
                    type = "trunked",
                    frequency = 155.220,
                    frequencyRange = { 155.220, 157.220 },
                    coverage = 250,
                    allowedNacs = { "141" },
                },
                [3] = {
                    name = "10-1",
                    type = "conventional",
                    frequency = 155.100,
                    allowedNacs = { "141" },
                },
                [4] = {
                    name = "TAC-1",
                    type = "conventional",
                    frequency = 155.150,
                    allowedNacs = { "141" },
                },
            },
        },
        -- ============================================
        -- SASP - San Andreas State Police
        -- ============================================
        [4] = {
            name = "SASP",
            nacIds = { "141" },
            Channels = {
                [1] = {
                    name = "DISP",                                -- SASP Dispatch
                    type = "conventional",
                    frequency = 156.070,
                    allowedNacs = { "141" },
                    scanAllowedNacs = { "200" },
                },
                [2] = {
                    name = "C2C",
                    type = "trunked",
                    frequency = 156.220,
                    frequencyRange = { 156.220, 158.220 },
                    coverage = 250,
                    allowedNacs = { "141" },
                },
                [3] = {
                    name = "10-1",
                    type = "conventional",
                    frequency = 156.100,
                    allowedNacs = { "141" },
                },
                [4] = {
                    name = "TAC-1",
                    type = "conventional",
                    frequency = 156.150,
                    allowedNacs = { "141" },
                },
            },
        },
        -- ============================================
        -- SAFR - San Andreas Fire & Rescue (EMS)
        -- ============================================
        [5] = {
            name = "SAFR",
            nacIds = { "200", "141" },                            -- EMS and LEO can access
            Channels = {
                [1] = {
                    name = "DISP",                                -- SAFR Dispatch
                    type = "conventional",
                    frequency = 155.340,
                    allowedNacs = { "200" },
                    scanAllowedNacs = { "141" },                  -- LEO can scan
                },
                [2] = {
                    name = "MED-1",                               -- Medical Channel 1
                    type = "conventional",
                    frequency = 155.355,
                    allowedNacs = { "200" },
                },
                [3] = {
                    name = "MED-2",                               -- Medical Channel 2
                    type = "conventional",
                    frequency = 155.370,
                    allowedNacs = { "200" },
                },
                [4] = {
                    name = "FIRE",                                -- Fire Operations
                    type = "conventional",
                    frequency = 155.385,
                    allowedNacs = { "200" },
                },
                [5] = {
                    name = "TAC",                                 -- EMS Tactical
                    type = "trunked",
                    frequency = 155.400,
                    frequencyRange = { 155.400, 157.400 },
                    coverage = 300,
                    allowedNacs = { "200", "141" },               -- Joint ops with LEO
                },
            },
        },
        -- ============================================
        -- INTEROP - Joint Operations
        -- ============================================
        [6] = {
            name = "Interop",
            nacIds = { "141", "200" },                            -- LEO and EMS
            Channels = {
                [1] = {
                    name = "INTER-1",                             -- Interoperability 1
                    type = "conventional",
                    frequency = 155.475,
                    allowedNacs = { "141", "200" },
                },
                [2] = {
                    name = "INTER-2",                             -- Interoperability 2
                    type = "conventional",
                    frequency = 155.500,
                    allowedNacs = { "141", "200" },
                },
                [3] = {
                    name = "SCENE",                               -- On-scene coordination
                    type = "trunked",
                    frequency = 155.525,
                    frequencyRange = { 155.525, 157.525 },
                    coverage = 200,
                    allowedNacs = { "141", "200" },
                },
            },
        },
    }
}
