--[[
    Mr. X Admin Menu (Client)
    =========================
    ox_lib menu interface for testing Mr. X features
]]

local AdminMenu = {}

-- ============================================
-- MAIN MENU
-- ============================================

function AdminMenu.Open()
    -- Get current status
    local testMode = lib.callback.await('mrx:admin:getTestMode', false)
    local chaosStatus = lib.callback.await('mrx:admin:getChaosStatus', false)

    lib.registerContext({
        id = 'mrx_admin_main',
        title = 'Mr. X Admin Panel',
        options = {
            {
                title = 'Test Mode: ' .. (testMode and '^2ON^7' or '^1OFF^7'),
                description = 'Toggle test mode (prevents automated actions)',
                icon = testMode and 'toggle-on' or 'toggle-off',
                onSelect = function()
                    local newState = lib.callback.await('mrx:admin:toggleTestMode', false)
                    lib.notify({
                        title = 'Mr. X',
                        description = 'Test mode ' .. (newState and 'ENABLED' or 'DISABLED'),
                        type = newState and 'warning' or 'success'
                    })
                    AdminMenu.Open()
                end
            },
            {
                title = 'Profile Management',
                description = 'View and modify your Mr. X profile',
                icon = 'user-secret',
                onSelect = AdminMenu.OpenProfileMenu
            },
            {
                title = 'Send Test Message',
                description = 'Send test SMS, email, or notification',
                icon = 'envelope',
                onSelect = AdminMenu.OpenMessageMenu
            },
            {
                title = 'Generate Mission',
                description = 'Generate and test missions',
                icon = 'crosshairs',
                onSelect = AdminMenu.OpenMissionMenu
            },
            {
                title = 'Chaos Engine',
                description = chaosStatus and chaosStatus.running and '^2Running^7' or '^1Stopped^7',
                icon = 'bolt',
                onSelect = AdminMenu.OpenChaosMenu
            },
            {
                title = 'Services (HELP/HARM)',
                description = 'Test premium services and HARM options',
                icon = 'hand-holding-dollar',
                onSelect = AdminMenu.OpenServicesMenu
            },
            {
                title = 'Opt-Out Management',
                description = 'Manage player exemptions from Mr. X',
                icon = 'user-shield',
                onSelect = AdminMenu.OpenOptOutMenu
            },
            {
                title = 'View Recent Events',
                description = 'See activity log',
                icon = 'list',
                onSelect = AdminMenu.OpenEventsMenu
            },
            {
                title = 'Phone Hack (Power Move)',
                description = 'Take selfie via player phone and send it back',
                icon = 'mobile-screen',
                onSelect = AdminMenu.OpenPhoneHackMenu
            },
            {
                title = 'Snitch Network',
                description = 'Offer intel selling service or view snitch stats',
                icon = 'user-secret',
                onSelect = AdminMenu.OpenSnitchMenu
            }
        }
    })

    lib.showContext('mrx_admin_main')
end

-- ============================================
-- PROFILE MENU
-- ============================================

function AdminMenu.OpenProfileMenu()
    local data = lib.callback.await('mrx:admin:getProfile', false)

    if not data or not data.profile then
        lib.notify({title = 'Mr. X', description = 'Could not load profile', type = 'error'})
        return
    end

    local profile = data.profile
    local rep = data.reputation

    lib.registerContext({
        id = 'mrx_admin_profile',
        title = 'Profile Management',
        menu = 'mrx_admin_main',
        options = {
            {
                title = 'Current Profile',
                description = string.format(
                    'Reputation: %d | Tier: %s | Archetype: %s',
                    profile.reputation or 0,
                    rep.tier or 'unknown',
                    profile.archetype or 'civilian'
                ),
                icon = 'info-circle',
                readOnly = true
            },
            {
                title = 'Missions',
                description = string.format(
                    'Total: %d | Successful: %d',
                    profile.total_missions or 0,
                    profile.successful_missions or 0
                ),
                icon = 'chart-bar',
                readOnly = true
            },
            {
                title = 'Set Reputation',
                description = 'Change your reputation (0-100)',
                icon = 'star',
                onSelect = function()
                    local input = lib.inputDialog('Set Reputation', {
                        {type = 'number', label = 'New Reputation', default = profile.reputation or 0, min = 0, max = 100}
                    })

                    if input and input[1] then
                        local success = lib.callback.await('mrx:admin:setReputation', false, input[1])
                        lib.notify({
                            title = 'Mr. X',
                            description = success and 'Reputation updated' or 'Failed to update',
                            type = success and 'success' or 'error'
                        })
                    end

                    AdminMenu.OpenProfileMenu()
                end
            },
            {
                title = 'Change Archetype',
                description = 'Current: ' .. (profile.archetype or 'civilian'),
                icon = 'mask',
                onSelect = function()
                    lib.registerContext({
                        id = 'mrx_admin_archetype',
                        title = 'Select Archetype',
                        menu = 'mrx_admin_profile',
                        options = {
                            {title = 'Civilian', icon = 'user', onSelect = function() AdminMenu.SetArchetype('civilian') end},
                            {title = 'Thug', icon = 'fist-raised', onSelect = function() AdminMenu.SetArchetype('thug') end},
                            {title = 'Wheeler Dealer', icon = 'handshake', onSelect = function() AdminMenu.SetArchetype('wheeler_dealer') end},
                            {title = 'Silent Pro', icon = 'user-ninja', onSelect = function() AdminMenu.SetArchetype('silent_pro') end},
                            {title = 'Wildcard', icon = 'question', onSelect = function() AdminMenu.SetArchetype('wildcard') end}
                        }
                    })
                    lib.showContext('mrx_admin_archetype')
                end
            },
            {
                title = 'Reset Profile',
                description = 'Reset all profile data to defaults',
                icon = 'trash',
                onSelect = function()
                    local confirm = lib.alertDialog({
                        header = 'Reset Profile?',
                        content = 'This will reset reputation, history, and all profile data.',
                        centered = true,
                        cancel = true
                    })

                    if confirm == 'confirm' then
                        local success = lib.callback.await('mrx:admin:resetProfile', false)
                        lib.notify({
                            title = 'Mr. X',
                            description = success and 'Profile reset' or 'Failed to reset',
                            type = success and 'success' or 'error'
                        })
                    end

                    AdminMenu.OpenProfileMenu()
                end
            }
        }
    })

    lib.showContext('mrx_admin_profile')
end

function AdminMenu.SetArchetype(archetype)
    local success = lib.callback.await('mrx:admin:setArchetype', false, archetype)
    lib.notify({
        title = 'Mr. X',
        description = success and ('Archetype set to ' .. archetype) or 'Failed to update',
        type = success and 'success' or 'error'
    })
    AdminMenu.OpenProfileMenu()
end

-- ============================================
-- MESSAGE MENU
-- ============================================

function AdminMenu.OpenMessageMenu()
    lib.registerContext({
        id = 'mrx_admin_message',
        title = 'Test Messaging',
        menu = 'mrx_admin_main',
        options = {
            {
                title = 'Send SMS',
                description = 'Send anonymous SMS from Mr. X',
                icon = 'comment-sms',
                onSelect = function()
                    local input = lib.inputDialog('Send SMS', {
                        {type = 'textarea', label = 'Message', required = true, default = 'I\'ve been watching you.'}
                    })

                    if input and input[1] then
                        local success = lib.callback.await('mrx:admin:sendTestSMS', false, input[1])
                        lib.notify({
                            title = 'Mr. X',
                            description = success and 'SMS sent' or 'Failed to send',
                            type = success and 'success' or 'error'
                        })
                    end
                end
            },
            {
                title = 'Send Email',
                description = 'Send email with optional actions',
                icon = 'envelope',
                onSelect = function()
                    local input = lib.inputDialog('Send Email', {
                        {type = 'input', label = 'Subject', required = true, default = 'New Opportunity'},
                        {type = 'textarea', label = 'Body', required = true, default = 'I have a proposition for you.'}
                    })

                    if input and input[1] and input[2] then
                        local success = lib.callback.await('mrx:admin:sendTestEmail', false, input[1], input[2])
                        lib.notify({
                            title = 'Mr. X',
                            description = success and 'Email sent' or 'Failed to send',
                            type = success and 'success' or 'error'
                        })
                    end
                end
            },
            {
                title = 'Send Notification',
                description = 'Send push notification',
                icon = 'bell',
                onSelect = function()
                    local input = lib.inputDialog('Send Notification', {
                        {type = 'input', label = 'Title', default = 'Mr. X'},
                        {type = 'input', label = 'Message', required = true, default = 'Your presence is requested.'}
                    })

                    if input and input[2] then
                        local success = lib.callback.await('mrx:admin:sendTestNotification', false, input[1], input[2])
                        lib.notify({
                            title = 'Mr. X',
                            description = success and 'Notification sent' or 'Failed to send',
                            type = success and 'success' or 'error'
                        })
                    end
                end
            },
            {
                title = 'Initiate Anonymous Call',
                description = 'Create incoming call from Unknown',
                icon = 'phone',
                onSelect = function()
                    local success = lib.callback.await('mrx:admin:initiateTestCall', false)
                    lib.notify({
                        title = 'Mr. X',
                        description = success and 'Call initiated' or 'Failed to call',
                        type = success and 'success' or 'error'
                    })
                end
            }
        }
    })

    lib.showContext('mrx_admin_message')
end

-- ============================================
-- MISSION MENU
-- ============================================

function AdminMenu.OpenMissionMenu()
    lib.registerContext({
        id = 'mrx_admin_mission',
        title = 'Mission Generation',
        menu = 'mrx_admin_main',
        options = {
            {
                title = 'Generate Based on Profile',
                description = 'Generate mission using your current profile',
                icon = 'dice',
                onSelect = function()
                    lib.notify({title = 'Mr. X', description = 'Generating mission...', type = 'info'})

                    local result = lib.callback.await('mrx:admin:generateMission', false)

                    if result and result.success and result.mission then
                        lib.notify({
                            title = 'Mission Generated',
                            description = result.mission.brief or 'Unknown mission',
                            type = 'success'
                        })
                        AdminMenu.ShowMissionDetails(result.mission)
                    else
                        lib.notify({
                            title = 'Mr. X',
                            description = 'Failed: ' .. (result and result.error or 'Unknown error'),
                            type = 'error'
                        })
                    end
                end
            },
            {
                title = 'Generate at EASY Tier',
                description = 'Simple tasks, low risk',
                icon = 'smile',
                onSelect = function() AdminMenu.GenerateAtTier('easy') end
            },
            {
                title = 'Generate at DILEMMA Tier',
                description = 'Moral choices, moderate risk',
                icon = 'balance-scale',
                onSelect = function() AdminMenu.GenerateAtTier('dilemma') end
            },
            {
                title = 'Generate at HIGH_RISK Tier',
                description = 'Complex operations, high stakes',
                icon = 'skull',
                onSelect = function() AdminMenu.GenerateAtTier('high_risk') end
            }
        }
    })

    lib.showContext('mrx_admin_mission')
end

function AdminMenu.GenerateAtTier(tier)
    lib.notify({title = 'Mr. X', description = 'Generating ' .. tier .. ' mission...', type = 'info'})

    local result = lib.callback.await('mrx:admin:generateMissionAtTier', false, tier)

    if result and result.success and result.mission then
        lib.notify({
            title = 'Mission Generated (' .. tier .. ')',
            description = result.mission.brief or 'Unknown mission',
            type = 'success'
        })
        AdminMenu.ShowMissionDetails(result.mission)
    else
        lib.notify({
            title = 'Mr. X',
            description = 'Failed: ' .. (result and result.error or 'Unknown error'),
            type = 'error'
        })
    end
end

function AdminMenu.ShowMissionDetails(mission)
    local payout = mission.rewards and mission.rewards.money and mission.rewards.money.amount or 'Unknown'

    lib.registerContext({
        id = 'mrx_admin_mission_details',
        title = 'Mission: ' .. (mission.missionId or 'Unknown'),
        menu = 'mrx_admin_mission',
        options = {
            {
                title = 'Type: ' .. (mission.type or 'Unknown'),
                icon = 'tag',
                readOnly = true
            },
            {
                title = 'Brief',
                description = mission.brief or 'No description',
                icon = 'file-alt',
                readOnly = true
            },
            {
                title = 'Payout: $' .. tostring(payout),
                icon = 'dollar-sign',
                readOnly = true
            },
            {
                title = 'Execute Mission',
                description = 'Start this mission now',
                icon = 'play',
                onSelect = function()
                    local result = lib.callback.await('mrx:admin:executeMission', false, mission)
                    lib.notify({
                        title = 'Mr. X',
                        description = result and result.success and 'Mission started' or 'Failed to start',
                        type = result and result.success and 'success' or 'error'
                    })
                end
            }
        }
    })

    lib.showContext('mrx_admin_mission_details')
end

-- ============================================
-- CHAOS MENU
-- ============================================

function AdminMenu.OpenChaosMenu()
    local status = lib.callback.await('mrx:admin:getChaosStatus', false) or {}

    lib.registerContext({
        id = 'mrx_admin_chaos',
        title = 'Chaos Engine',
        menu = 'mrx_admin_main',
        options = {
            {
                title = 'Status: ' .. (status.running and '^2Running^7' or '^1Stopped^7'),
                description = 'Test Mode: ' .. (status.testMode and 'ON' or 'OFF'),
                icon = status.running and 'circle-play' or 'circle-stop',
                readOnly = true
            },
            {
                title = status.running and 'Stop Chaos Engine' or 'Start Chaos Engine',
                description = status.running and 'Stop automatic chaos scanning' or 'Begin automatic chaos scanning',
                icon = status.running and 'stop' or 'play',
                onSelect = function()
                    local success
                    if status.running then
                        success = lib.callback.await('mrx:admin:stopChaos', false)
                    else
                        success = lib.callback.await('mrx:admin:startChaos', false)
                    end

                    lib.notify({
                        title = 'Mr. X',
                        description = success and 'Chaos engine ' .. (status.running and 'stopped' or 'started') or 'Failed',
                        type = success and 'success' or 'error'
                    })

                    Wait(500)
                    AdminMenu.OpenChaosMenu()
                end
            },
            {
                title = 'Run Manual Scan',
                description = 'Scan for chaos candidates now',
                icon = 'search',
                onSelect = function()
                    lib.notify({title = 'Mr. X', description = 'Scanning...', type = 'info'})
                    local result = lib.callback.await('mrx:admin:runChaosScan', false)

                    if result then
                        lib.notify({
                            title = 'Scan Complete',
                            description = 'Found ' .. (result.candidateCount or 0) .. ' candidates',
                            type = 'info'
                        })
                    end
                end
            },
            {
                title = 'Trigger Surprise on Self',
                description = 'Test HARM options on yourself',
                icon = 'bolt',
                onSelect = AdminMenu.OpenSurpriseMenu
            }
        }
    })

    lib.showContext('mrx_admin_chaos')
end

function AdminMenu.OpenSurpriseMenu()
    lib.registerContext({
        id = 'mrx_admin_surprise',
        title = 'Trigger Surprise',
        menu = 'mrx_admin_chaos',
        options = {
            {title = 'Fake Warrant', icon = 'gavel', onSelect = function() AdminMenu.TriggerSurprise('FAKE_WARRANT') end},
            {title = 'Fake Report', icon = 'file-alt', onSelect = function() AdminMenu.TriggerSurprise('FAKE_REPORT') end},
            {title = 'Fake Case', icon = 'folder-open', onSelect = function() AdminMenu.TriggerSurprise('FAKE_CASE') end},
            {title = 'Fake BOLO', icon = 'broadcast-tower', onSelect = function() AdminMenu.TriggerSurprise('FAKE_BOLO') end},
            {title = 'Anonymous Tip', icon = 'phone', onSelect = function() AdminMenu.TriggerSurprise('ANONYMOUS_TIP') end},
            {title = 'Hit Squad', icon = 'users', onSelect = function() AdminMenu.TriggerSurprise('HIT_SQUAD') end},
            {title = 'Debt Collector', icon = 'hand-holding-usd', onSelect = function() AdminMenu.TriggerSurprise('DEBT_COLLECTOR') end},
            {title = 'Ambush', icon = 'crosshairs', onSelect = function() AdminMenu.TriggerSurprise('AMBUSH') end},
            {title = 'Player Bounty', icon = 'bullseye', onSelect = function() AdminMenu.TriggerSurprise('PLAYER_BOUNTY') end},
            {title = 'Gang Contract', icon = 'handshake-slash', onSelect = function() AdminMenu.TriggerSurprise('GANG_CONTRACT') end},
            {title = 'Gang Betrayal', icon = 'user-slash', onSelect = function() AdminMenu.TriggerSurprise('GANG_BETRAYAL') end},
            {title = 'Leak Location', icon = 'map-marker-alt', onSelect = function() AdminMenu.TriggerSurprise('LEAK_LOCATION') end},
            {title = 'Phone Hack (Selfie)', icon = 'mobile-screen', onSelect = function() AdminMenu.TriggerSurprise('PHONE_HACK') end}
        }
    })

    lib.showContext('mrx_admin_surprise')
end

function AdminMenu.TriggerSurprise(surpriseType)
    local success = lib.callback.await('mrx:admin:triggerSurprise', false, surpriseType)
    lib.notify({
        title = 'Mr. X',
        description = success and (surpriseType .. ' triggered') or 'Failed to trigger',
        type = success and 'warning' or 'error'
    })
end

-- ============================================
-- SERVICES MENU
-- ============================================

function AdminMenu.OpenServicesMenu()
    lib.registerContext({
        id = 'mrx_admin_services',
        title = 'Services (HELP/HARM)',
        menu = 'mrx_admin_main',
        options = {
            {
                title = 'View Police Records',
                description = 'See warrants, reports, cases on you',
                icon = 'file-shield',
                onSelect = function()
                    local records = lib.callback.await('mrx:admin:getRecords', false) or {}

                    local count = (#(records.warrants or {}) + #(records.reports or {}) + #(records.cases or {}))

                    lib.notify({
                        title = 'Police Records',
                        description = string.format(
                            'Warrants: %d | Reports: %d | Cases: %d',
                            #(records.warrants or {}),
                            #(records.reports or {}),
                            #(records.cases or {})
                        ),
                        type = count > 0 and 'warning' or 'success'
                    })
                end
            },
            {
                title = 'Clear All Records (Admin)',
                description = 'Clear all police records (no cost)',
                icon = 'eraser',
                onSelect = function()
                    local cleared = lib.callback.await('mrx:admin:clearAllRecords', false)
                    lib.notify({
                        title = 'Mr. X',
                        description = 'Cleared ' .. (cleared or 0) .. ' records',
                        type = 'success'
                    })
                end
            },
            {
                title = 'Test Loan System',
                description = 'Issue test loan to yourself',
                icon = 'money-bill-wave',
                onSelect = function()
                    local result = lib.callback.await('mrx:admin:testLoan', false)
                    lib.notify({
                        title = 'Mr. X',
                        description = result and result.success and ('Loan #' .. (result.loanId or '?') .. ' issued') or 'Failed',
                        type = result and result.success and 'success' or 'error'
                    })
                end
            },
            {
                title = 'Test Bounty System',
                description = 'Post test bounty on yourself',
                icon = 'bullseye',
                onSelect = function()
                    local input = lib.inputDialog('Post Bounty', {
                        {type = 'number', label = 'Amount', default = 10000, min = 1000, max = 100000}
                    })

                    if input and input[1] then
                        local result = lib.callback.await('mrx:admin:testBounty', false, input[1])
                        lib.notify({
                            title = 'Mr. X',
                            description = result and result.bountyId and ('Bounty #' .. result.bountyId .. ' posted') or 'Failed',
                            type = result and result.bountyId and 'warning' or 'error'
                        })
                    end
                end
            },
            {
                title = 'Test Gang Betrayal',
                description = 'Initiate betrayal on yourself (requires gang)',
                icon = 'user-slash',
                onSelect = function()
                    local success = lib.callback.await('mrx:admin:testGangBetrayal', false)
                    lib.notify({
                        title = 'Mr. X',
                        description = success and 'Gang betrayal initiated' or 'Failed (no gang members online?)',
                        type = success and 'warning' or 'error'
                    })
                end
            }
        }
    })

    lib.showContext('mrx_admin_services')
end

-- ============================================
-- EVENTS MENU
-- ============================================

function AdminMenu.OpenEventsMenu()
    lib.notify({title = 'Mr. X', description = 'Loading events...', type = 'info'})

    local events = lib.callback.await('mrx:admin:getRecentEvents', false, 10)

    if not events or #events == 0 then
        lib.notify({title = 'Mr. X', description = 'No events found', type = 'info'})
        AdminMenu.Open()
        return
    end

    local options = {}

    for i, event in ipairs(events) do
        table.insert(options, {
            title = event.event_type,
            description = (event.citizenid or 'System') .. ' | ' .. (event.created_at or ''),
            icon = 'clock',
            readOnly = true
        })
    end

    lib.registerContext({
        id = 'mrx_admin_events',
        title = 'Recent Events',
        menu = 'mrx_admin_main',
        options = options
    })

    lib.showContext('mrx_admin_events')
end

-- ============================================
-- OPT-OUT MENU
-- ============================================

function AdminMenu.OpenOptOutMenu()
    local optOutInfo = lib.callback.await('mrx:admin:getOptOutInfo', false) or {}

    lib.registerContext({
        id = 'mrx_admin_optout',
        title = 'Opt-Out Management',
        menu = 'mrx_admin_main',
        options = {
            {
                title = 'Your Status',
                description = optOutInfo.isExempt
                    and ('^2EXEMPT^7 (' .. (optOutInfo.reasonLabel or optOutInfo.reason or 'Unknown') .. ')')
                    or '^1NOT EXEMPT^7 - You receive Mr. X contact',
                icon = optOutInfo.isExempt and 'shield-alt' or 'user',
                readOnly = true
            },
            {
                title = 'Toggle Your Opt-Out',
                description = optOutInfo.isExempt
                    and 'Remove manual opt-out (if applicable)'
                    or 'Add manual opt-out flag',
                icon = 'toggle-on',
                onSelect = function()
                    -- Only works for manual opt-out, not ACE/job exemptions
                    if optOutInfo.reason and optOutInfo.reason ~= 'manual_optout' and optOutInfo.isExempt then
                        lib.notify({
                            title = 'Mr. X',
                            description = 'Cannot toggle - exemption is from ' .. (optOutInfo.reasonLabel or optOutInfo.reason),
                            type = 'error'
                        })
                        return
                    end

                    local newState = not optOutInfo.isExempt
                    local success = lib.callback.await('mrx:admin:setOptOut', false, nil, newState)

                    lib.notify({
                        title = 'Mr. X',
                        description = success
                            and ('Opt-out ' .. (newState and 'ENABLED' or 'DISABLED'))
                            or 'Failed to update',
                        type = success and 'success' or 'error'
                    })

                    Wait(300)
                    AdminMenu.OpenOptOutMenu()
                end
            },
            {
                title = 'Check Player Opt-Out',
                description = 'Check exemption status for another player',
                icon = 'search',
                onSelect = function()
                    local input = lib.inputDialog('Check Player', {
                        {type = 'input', label = 'Citizen ID', required = true, placeholder = 'e.g., ABC12345'}
                    })

                    if input and input[1] then
                        local result = lib.callback.await('mrx:admin:getPlayerOptOutInfo', false, input[1])

                        if result then
                            lib.notify({
                                title = 'Opt-Out Check: ' .. input[1],
                                description = result.isExempt
                                    and ('EXEMPT: ' .. (result.reason or 'Unknown'))
                                    or 'NOT EXEMPT',
                                type = result.isExempt and 'warning' or 'info',
                                duration = 5000
                            })
                        else
                            lib.notify({
                                title = 'Mr. X',
                                description = 'Player not found',
                                type = 'error'
                            })
                        end
                    end
                end
            },
            {
                title = 'Set Player Opt-Out',
                description = 'Set opt-out status for another player',
                icon = 'user-edit',
                onSelect = function()
                    local input = lib.inputDialog('Set Player Opt-Out', {
                        {type = 'input', label = 'Citizen ID', required = true, placeholder = 'e.g., ABC12345'},
                        {type = 'checkbox', label = 'Opt-Out Enabled', checked = false}
                    })

                    if input and input[1] then
                        local success = lib.callback.await('mrx:admin:setOptOut', false, input[1], input[2])

                        lib.notify({
                            title = 'Mr. X',
                            description = success
                                and ('Player opt-out ' .. (input[2] and 'ENABLED' or 'DISABLED'))
                                or 'Failed to update',
                            type = success and 'success' or 'error'
                        })
                    end
                end
            },
            {
                title = 'Exemption Types',
                description = 'Info about how exemptions work',
                icon = 'info-circle',
                onSelect = function()
                    lib.alertDialog({
                        header = 'Mr. X Opt-Out System',
                        content = [[
**Exemption Methods (checked in order):**

1. **ACE Permission** - `sv_mr_x.optout`
2. **Exempt Jobs** - Configured in config.lua
3. **Exempt Job Grades** - e.g., Police Sergeant+
4. **Exempt Gangs** - Configured in config.lua
5. **Manual Opt-Out** - Database flag

**Effect of Exemption:**
Exempt players receive NO contact from Mr. X:
- No missions offered
- No HARM surprises (warrants, bounties, etc.)
- No HELP services (loans, intel, record clearing)
- No reputation tracking

This is intended for players bound by anti-corruption rules (PD/EMS leadership).
                        ]],
                        centered = true
                    })
                end
            }
        }
    })

    lib.showContext('mrx_admin_optout')
end

-- ============================================
-- PHONE HACK MENU
-- ============================================

function AdminMenu.OpenPhoneHackMenu()
    lib.registerContext({
        id = 'mrx_admin_phonehack',
        title = 'Phone Hack (Power Move)',
        menu = 'mrx_admin_main',
        options = {
            {
                title = 'Hack Your Own Phone',
                description = 'Test the phone hack on yourself (silent)',
                icon = 'mobile-retro',
                onSelect = function()
                    lib.notify({title = 'Mr. X', description = 'Initiating phone hack...', type = 'warning'})
                    local success = lib.callback.await('mrx:admin:phoneHackSilent', false)
                    if not success then
                        lib.notify({
                            title = 'Mr. X',
                            description = 'Phone hack failed - check server console',
                            type = 'error'
                        })
                    end
                end
            },
            {
                title = 'Hack Your Phone (With Warning)',
                description = 'Full experience with threatening message first',
                icon = 'mobile-screen-button',
                onSelect = function()
                    lib.notify({title = 'Mr. X', description = 'Initiating phone hack with warning...', type = 'warning'})
                    local success = lib.callback.await('mrx:admin:phoneHack', false)
                    if not success then
                        lib.notify({
                            title = 'Mr. X',
                            description = 'Phone hack failed - check server console',
                            type = 'error'
                        })
                    end
                end
            },
            {
                title = 'Hack Another Player',
                description = 'Target a specific player by ID',
                icon = 'users',
                onSelect = function()
                    local input = lib.inputDialog('Phone Hack Target', {
                        {type = 'number', label = 'Player Server ID', required = true, min = 1}
                    })

                    if input and input[1] then
                        lib.notify({title = 'Mr. X', description = 'Hacking player ' .. input[1] .. '...', type = 'warning'})
                        local success = lib.callback.await('mrx:admin:phoneHack', false, tonumber(input[1]))
                        lib.notify({
                            title = 'Mr. X',
                            description = success and 'Phone hack initiated' or 'Failed - player offline or error',
                            type = success and 'success' or 'error'
                        })
                    end
                end
            },
            {
                title = 'Preview Glitch Effect Only',
                description = 'Just show the screen glitch without capturing',
                icon = 'bug',
                onSelect = function()
                    TriggerEvent('mrx:client:previewHackEffect')
                end
            }
        }
    })

    lib.showContext('mrx_admin_phonehack')
end

-- ============================================
-- SNITCH NETWORK MENU
-- ============================================

function AdminMenu.OpenSnitchMenu()
    local stats = lib.callback.await('mrx:admin:getSnitchStats', false)

    lib.registerContext({
        id = 'mrx_admin_snitch',
        title = 'Snitch Network',
        menu = 'mrx_admin_main',
        options = {
            {
                title = 'Offer Snitch Service to Self',
                description = 'Mr. X offers you the intel selling service',
                icon = 'money-bill-wave',
                onSelect = function()
                    local success = lib.callback.await('mrx:admin:offerSnitchService', false)
                    lib.notify({
                        title = 'Mr. X',
                        description = success and 'Service offered via SMS' or 'Failed to send',
                        type = success and 'success' or 'error'
                    })
                end
            },
            {
                title = 'Offer to Another Player',
                description = 'Mr. X offers snitch service to a specific player',
                icon = 'users',
                onSelect = function()
                    local input = lib.inputDialog('Offer Snitch Service', {
                        {type = 'number', label = 'Player Server ID', required = true}
                    })

                    if input and input[1] then
                        local success = lib.callback.await('mrx:admin:offerSnitchServiceTo', false, tonumber(input[1]))
                        lib.notify({
                            title = 'Mr. X',
                            description = success and 'Service offered to player' or 'Failed - player not found',
                            type = success and 'success' or 'error'
                        })
                    end
                end
            },
            {
                title = 'View Snitch Stats',
                description = stats and string.format('Reports: %d | Verified: %d', stats.total or 0, stats.verified or 0) or 'Loading...',
                icon = 'chart-bar',
                onSelect = function()
                    local freshStats = lib.callback.await('mrx:admin:getSnitchStats', false)
                    if freshStats then
                        lib.alertDialog({
                            header = 'Snitch Network Statistics',
                            content = string.format([[
**Total Intel Reports:** %d
**Unique Snitches:** %d
**Unique Targets:** %d
**Verified Reports:** %d

**Verification Rate:** %.1f%%
                            ]],
                                freshStats.total or 0,
                                freshStats.snitches or 0,
                                freshStats.targets or 0,
                                freshStats.verified or 0,
                                freshStats.total > 0 and (freshStats.verified / freshStats.total * 100) or 0
                            ),
                            centered = true
                        })
                    end
                end
            },
            {
                title = 'View Recent Intel',
                description = 'See latest intel reports',
                icon = 'list',
                onSelect = function()
                    local intel = lib.callback.await('mrx:admin:getRecentIntel', false, 10)
                    if intel and #intel > 0 then
                        local content = ''
                        for _, report in ipairs(intel) do
                            content = content .. string.format('**%s** on %s\n- Type: %s | Verified: %s\n\n',
                                report.snitch or 'Unknown',
                                report.target or 'Unknown',
                                report.intel_type or 'unknown',
                                report.verified and 'Yes' or 'No'
                            )
                        end
                        lib.alertDialog({
                            header = 'Recent Intel Reports',
                            content = content,
                            centered = true
                        })
                    else
                        lib.notify({
                            title = 'Mr. X',
                            description = 'No intel reports found',
                            type = 'info'
                        })
                    end
                end
            },
            {
                title = 'How It Works',
                description = 'Info about the snitch network',
                icon = 'info-circle',
                onSelect = function()
                    lib.alertDialog({
                        header = 'Snitch Network',
                        content = [[
**How Players Use It:**
Players text Mr. X with phrases like:
- "I have info on someone"
- "I got intel to sell"
- "I saw someone doing..."

**Conversation Flow:**
1. Mr. X asks for a name
2. Player provides target name
3. Mr. X asks what they saw
4. Player describes the intel
5. Mr. X verifies (if possible) and pays

**Payment Tiers:**
- Location intel: $500-$1,000
- Vehicle/plate: $750-$1,500
- Criminal activity: $500-$5,000
- Gang associations: $1,000-$2,500

**Intel Uses:**
Mr. X stores intel as facts on targets.
Can be used for blackmail, bounties, etc.
                        ]],
                        centered = true
                    })
                end
            }
        }
    })

    lib.showContext('mrx_admin_snitch')
end

-- ============================================
-- EVENT HANDLER
-- ============================================

RegisterNetEvent('sv_mr_x:client:openAdminMenu', function()
    AdminMenu.Open()
end)

-- Return module
return AdminMenu
