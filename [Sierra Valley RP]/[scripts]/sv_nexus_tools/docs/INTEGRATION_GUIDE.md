# sv_nexus_tools Integration Guide

This guide explains how to integrate existing scripts with the sv_nexus_tools system, allowing Mr. X to create dynamic missions that respond to real player activity.

---

## Quick Start

Add one line to your existing script to report activity:

```lua
-- Server-side
exports['sv_nexus_tools']:ReportActivity('robbery_completed', {
    robberyType = 'bank',
    coords = coords,
    lootValue = 50000
}, source)
```

That's it! The toolbox will now track this activity and potentially weave it into AI-generated missions.

---

## Event Types

### Criminal Activities
| Event Type | Description | Key Data |
|------------|-------------|----------|
| `robbery_started` | Robbery initiated | robberyType, coords, alarmTriggered |
| `robbery_completed` | Robbery finished | success, lootValue, policeResponded |
| `robbery_failed` | Robbery failed | reason, coords |
| `heist_started` | Major heist initiated | heistType, participants |
| `heist_completed` | Heist finished | success, totalLoot |
| `drug_sale` | Drug transaction | drugType, amount, price |
| `drug_production` | Drugs manufactured | drugType, amount, labId |
| `vehicle_theft` | Vehicle stolen | vehicleModel, plate |
| `weapon_sale` | Weapon sold | weaponType, price |
| `gang_activity` | Gang-related action | gang, activity, coords |
| `hostage_taken` | Hostage grabbed | hostageCount, demands |
| `hostage_released` | Hostage freed | resolved |

### Police Activities
| Event Type | Description | Key Data |
|------------|-------------|----------|
| `dispatch_received` | Officer took call | code, description, coords |
| `pursuit_started` | Chase initiated | suspectCitizenId, vehiclePlate |
| `pursuit_ended` | Chase concluded | outcome, duration |
| `arrest_made` | Suspect arrested | charges, fineAmount, jailTime |
| `citation_issued` | Ticket given | violation, amount |
| `evidence_collected` | Evidence gathered | evidenceType, caseId |
| `case_filed` | MDT case created | caseId, charges |
| `patrol_checkpoint` | Patrol area cleared | area, duration |

### EMS Activities
| Event Type | Description | Key Data |
|------------|-------------|----------|
| `patient_treated` | Patient healed | injuryType, outcome |
| `patient_transported` | Patient moved | destination, critical |
| `death_reported` | Death logged | cause, location |

### Civilian Activities
| Event Type | Description | Key Data |
|------------|-------------|----------|
| `job_started` | Job begun | jobType, expectedPay |
| `job_completed` | Job finished | success, pay, duration |
| `purchase_made` | Item bought | itemType, price, store |
| `business_transaction` | Business deal | transactionType, amount |
| `property_interaction` | Property action | propertyId, action |

### Economy
| Event Type | Description | Key Data |
|------------|-------------|----------|
| `large_transaction` | Big money move | amount, transactionType |
| `bank_deposit` | Money deposited | amount |
| `bank_withdrawal` | Money withdrawn | amount |

---

## Helper Functions

The toolbox provides convenience functions for common integrations:

### Robbery Scripts

```lua
-- When robbery starts
exports['sv_nexus_tools']:OnRobberyStart(source, 'bank', 'Fleeca Alta', {
    coords = vector3(148.0, -1042.0, 29.0),
    estimatedValue = 50000,
    alarmTriggered = true,
    participants = {citizenid1, citizenid2}
})

-- When robbery ends
exports['sv_nexus_tools']:OnRobberyComplete(source, 'bank', true, {
    coords = vector3(148.0, -1042.0, 29.0),
    lootValue = 45000,
    duration = 300,
    policeResponded = true
})
```

### Police Scripts

```lua
-- When dispatch is accepted
exports['sv_nexus_tools']:OnDispatchReceived(source, 'robbery', {
    code = '10-31',
    description = 'Bank robbery in progress',
    coords = vector3(148.0, -1042.0, 29.0),
    priority = 'high'
})

-- When pursuit begins
exports['sv_nexus_tools']:OnPursuitStart(source, suspectSource, {
    vehiclePlate = 'ABC123',
    vehicleModel = 'sultan',
    reason = 'Fleeing robbery scene',
    coords = GetEntityCoords(GetPlayerPed(source))
})

-- When arrest is made
exports['sv_nexus_tools']:OnArrestMade(source, suspectSource, {
    charges = {'robbery', 'evading'},
    coords = GetEntityCoords(GetPlayerPed(source)),
    fineAmount = 5000,
    jailTime = 30
})
```

### Drug Scripts

```lua
-- When drugs are sold
exports['sv_nexus_tools']:OnDrugSale(source, 'weed', 5, 250, 'npc')

-- When drugs are produced
exports['sv_nexus_tools']:OnDrugProduction(source, 'meth', 10, 'lab_sandy_shores')
```

### Gang Scripts

```lua
-- When gang activity occurs
exports['sv_nexus_tools']:OnGangActivity(source, 'vagos', 'territory_claim', {
    coords = vector3(325.0, -2040.0, 20.0),
    involvedPlayers = {citizenid1, citizenid2}
})
```

### Job Scripts

```lua
-- When job starts
exports['sv_nexus_tools']:OnJobStart(source, 'trucking', {
    coords = GetEntityCoords(GetPlayerPed(source)),
    expectedPay = 1500
})

-- When job completes
exports['sv_nexus_tools']:OnJobComplete(source, 'trucking', {
    success = true,
    pay = 1500,
    duration = 600
})
```

---

## Subscribing to Events

Your scripts can also listen for events reported by others:

```lua
-- Subscribe to specific event
local unsubscribe = exports['sv_nexus_tools']:SubscribeToEvent('robbery_started', function(activity)
    print('Robbery started at:', json.encode(activity.data.coords))
    print('By player:', activity.citizenid)

    -- Maybe spawn extra police response
    if activity.data.robberyType == 'pacific' then
        SpawnNooseResponse(activity.data.coords)
    end
end)

-- Later, to stop listening:
unsubscribe()

-- Subscribe to ALL activities
exports['sv_nexus_tools']:AddActivityHook(function(activity)
    print('Activity:', activity.type, 'by', activity.citizenid)
end)
```

---

## Requesting Contextual Missions

Scripts can request Mr. X generate a mission based on current context:

```lua
-- After player completes a series of activities, offer them a mission
exports['sv_nexus_tools']:RequestContextualMission(source, {
    missionType = 'criminal',
    difficulty = 'hard',
    additionalContext = 'Player just completed their third successful heist. Generate something challenging.'
})
```

---

## Callbacks

### Query Toolbox State

```lua
-- Check if player can do a mission
local canDo, reason = exports['sv_nexus_tools']:TriggerIntegrationCallback('canPlayerDoMission', source, 'criminal')
if not canDo then
    print('Cannot do mission:', reason)
end

-- Get player mission context
local context = exports['sv_nexus_tools']:TriggerIntegrationCallback('getPlayerMissionContext', source)
print('Player job:', context.job)
print('Recent activities:', #context.recentActivity)

-- Notify mission complete from external script
exports['sv_nexus_tools']:TriggerIntegrationCallback('notifyMissionComplete', missionId, true, {
    money = 5000,
    items = {{'gold_bar', 2}}
})
```

### Register Custom Callbacks

```lua
-- Your script can register callbacks the toolbox can call
exports['sv_nexus_tools']:RegisterIntegrationCallback('myScript:getSpecialData', function(source)
    return {
        customValue = GetPlayerCustomValue(source)
    }
end)
```

---

## Example Integrations

### qb-bankrobbery Integration

Add to `qb-bankrobbery/server/main.lua`:

```lua
-- At robbery start (in StartRobbery or similar)
RegisterNetEvent('qb-bankrobbery:server:startRobbery', function(bankId)
    local src = source
    local bankData = Config.Banks[bankId]

    -- Existing code...

    -- ADD: Report to sv_nexus_tools
    if GetResourceState('sv_nexus_tools') == 'started' then
        exports['sv_nexus_tools']:OnRobberyStart(src, 'bank', bankId, {
            coords = bankData.coords,
            estimatedValue = bankData.maxReward,
            alarmTriggered = true
        })
    end
end)

-- At robbery complete
RegisterNetEvent('qb-bankrobbery:server:robberyComplete', function(bankId, success, loot)
    local src = source

    -- ADD: Report to sv_nexus_tools
    if GetResourceState('sv_nexus_tools') == 'started' then
        exports['sv_nexus_tools']:OnRobberyComplete(src, 'bank', success, {
            coords = Config.Banks[bankId].coords,
            lootValue = loot,
            duration = robberyDuration,
            policeResponded = policeOnScene
        })
    end
end)
```

### ps-dispatch Integration

Add to `ps-dispatch/server/main.lua`:

```lua
RegisterNetEvent('ps-dispatch:server:notify', function(data)
    local src = source

    -- Existing dispatch code...

    -- ADD: Report to sv_nexus_tools
    if GetResourceState('sv_nexus_tools') == 'started' then
        exports['sv_nexus_tools']:ReportActivity('dispatch_received', {
            dispatchType = data.code,
            code = data.code,
            description = data.message,
            coords = data.coords,
            priority = data.priority or 'medium'
        }, src)
    end
end)
```

### qb-policejob Integration

Add to `qb-policejob/server/main.lua`:

```lua
-- After arrest
RegisterNetEvent('police:server:Arrest', function(playerId, time, fine)
    local src = source

    -- Existing arrest code...

    -- ADD: Report to sv_nexus_tools
    if GetResourceState('sv_nexus_tools') == 'started' then
        exports['sv_nexus_tools']:OnArrestMade(src, playerId, {
            charges = GetPlayerCharges(playerId),
            coords = GetEntityCoords(GetPlayerPed(src)),
            fineAmount = fine,
            jailTime = time
        })
    end
end)
```

### qb-drugs Integration

Add to drug selling event:

```lua
RegisterNetEvent('qb-drugs:server:sellDrugs', function(drugType, amount, price)
    local src = source

    -- Existing code...

    -- ADD: Report to sv_nexus_tools
    if GetResourceState('sv_nexus_tools') == 'started' then
        exports['sv_nexus_tools']:OnDrugSale(src, drugType, amount, price, 'npc')
    end
end)
```

---

## Reactive Triggers

The toolbox automatically creates missions based on activity patterns:

| Pattern | Trigger | Result |
|---------|---------|--------|
| 3+ successful robberies | `heist_invitation` | Mr. X offers bigger job |
| 5+ arrests | `detective_case` | Chief assigns investigation |
| High gang activity | Auto-generated | Rival gang mission |
| Multiple drug sales | Auto-generated | Supplier mission |

You can add custom triggers in `integrations.lua`:

```lua
table.insert(ReactiveTriggers, {
    name = 'custom_trigger',
    condition = function(activity, history)
        -- Return true to fire trigger
        return activity.type == 'my_event' and someCondition
    end,
    action = function(activity)
        -- What happens when triggered
        local source = Utils.GetSourceByCitizenId(activity.citizenid)
        -- Send message, start mission, etc.
    end,
    cooldown = 3600  -- 1 hour cooldown
})
```

---

## Best Practices

1. **Check Resource State** - Always check if sv_nexus_tools is running before calling exports:
   ```lua
   if GetResourceState('sv_nexus_tools') == 'started' then
       exports['sv_nexus_tools']:ReportActivity(...)
   end
   ```

2. **Include Coordinates** - Always include `coords` in your data for location-aware missions

3. **Use Consistent Event Types** - Use the standard event types when possible

4. **Don't Over-Report** - Only report significant activities, not every minor action

5. **Include Citizen ID** - When possible, include the citizenid for player tracking

6. **Add Context** - The more data you include, the better AI missions can respond

---

## API Reference

### Main Export: ReportActivity

```lua
exports['sv_nexus_tools']:ReportActivity(eventType, data, source)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| eventType | string | One of the standard event types |
| data | table | Event-specific data (must include coords) |
| source | number | Player server ID (optional) |

**Returns:** Activity object

### Get Event Types

```lua
local types = exports['sv_nexus_tools']:GetEventTypes()
-- Returns table of all valid event type strings
```

### Get Recent Activity

```lua
local activities = exports['sv_nexus_tools']:GetRecentActivity({
    limit = 20,           -- Max results (default: 20)
    eventType = 'robbery_completed',  -- Filter by type (optional)
    citizenid = 'ABC123', -- Filter by player (optional)
    since = os.time() - 3600  -- Unix timestamp (default: last hour)
})
```

### Subscribe to Event

```lua
local unsubscribe = exports['sv_nexus_tools']:SubscribeToEvent(eventType, callback)
-- callback receives: activity object
-- unsubscribe() to stop listening
```

### Add Global Hook

```lua
local unhook = exports['sv_nexus_tools']:AddActivityHook(callback)
-- callback receives: activity object for ALL events
```

### Request Contextual Mission

```lua
exports['sv_nexus_tools']:RequestContextualMission(source, {
    missionType = 'criminal',  -- or 'police', 'civilian'
    difficulty = 'medium',     -- easy, medium, hard
    additionalContext = '...'  -- Extra context for AI
})
```

---

---

## Script-Specific Integration Snippets

Pre-built integration snippets are available in `integrations/` for popular scripts:

### lb-phone Integration

**File:** `integrations/lb_phone_integration.lua`

Enables Mr. X to send messages, mission briefings, and notifications via lb-phone.

```lua
-- Send Mr. X email with mission briefing
exports['sv_nexus_tools']:SendMrXEmail(source, {
    sender = 'Mr. X',
    subject = 'New Opportunity',
    message = 'I have a job for you...'
})

-- Send phone notification
exports['sv_nexus_tools']:SendPhoneNotification(source, {
    title = 'Mission Update',
    message = 'Package secured. Proceed to drop-off.',
    icon = 'fas fa-check-circle'
})

-- Send mission briefing with accept button
exports['sv_nexus_tools']:SendMissionBriefing(source, {
    missionId = 'heist_001',
    type = 'criminal',
    subject = 'Business Proposal',
    message = 'A high-value target awaits...',
    acceptEvent = 'sv_nexus_tools:server:acceptMission'
})
```

**Key Exports:**
- `SendMail({to, sender, subject, message, actions})`
- `GetEmailAddress(phoneNumber)`
- `GetEquippedPhoneNumber(source)`

---

### lb-tablet Integration

**File:** `integrations/lb_tablet_integration.lua`

Tracks police MDT activity for mission timing and investigation generation.

```lua
-- Track dispatch response
OnDispatchResponse(source, {
    code = '10-31',
    description = 'Bank robbery in progress',
    coords = vector3(148.0, -1042.0, 29.0),
    priority = 'high'
})

-- Track warrant issued
OnWarrantIssued(source, {
    targetCitizenId = 'ABC123',
    charges = {'armed_robbery', 'assault'}
})

-- Check police pressure in area
local pressure = GetPolicePressure(coords, 500.0)
if pressure > 5 then
    -- Too hot for missions here
end
```

**Integration Points:**
- Dispatch response tracking
- Warrant/BOLO creation
- Evidence logging
- Report filing
- Police pressure mapping

---

### brutal_gangs Integration

**File:** `integrations/brutal_gangs_integration.lua`

Tracks gang activity for territory-aware missions and gang wars.

```lua
-- Get player's gang info
local gangInfo = GetPlayerGangInfo(source)
-- Returns: {name, label, rank, rankName, isLeader}

-- Get mission context for gang members
local context = GetGangMissionContext(source)
-- Returns recommended mission types based on gang status

-- Track gang activities
OnGraffitiPlaced(source, gangName, location)
OnRaidStarted(source, attackingGang, defendingGang)
OnGangTaskCompleted(source, gangName, taskType, success, reward)
```

**brutal_gangs Exports:**
- `exports.brutal_gangs:isPlayerInGangJob()`
- `exports.brutal_gangs:playerGangRank()`
- `exports.brutal_gangs:playerGangRankName()`
- `exports.brutal_gangs:getGangLabelbyName(gangName)`

**External Tasks:** Register nexus missions in `Config.ExternalTasks`:
```lua
Config.ExternalTasks = {
    ["nexus_heist"] = {
        Label = "HIGH-VALUE HEIST",
        Description = "Mr. X has a special job.",
        TimeToRestart = 1440,
        event = 'sv_nexus_tools:client:startGangMission',
    },
}
```

---

### rcore_doorlock Integration

**File:** `integrations/rcore_doorlock_integration.lua`

Control doors during heists and track lockpicking activity.

```lua
-- Lock/unlock a door
SetDoorLockState(doorId, true)  -- Lock
SetDoorLockState(doorId, false) -- Unlock

-- Get doors in area
local doors = GetDoorsInArea(coords, 50.0)

-- Lockdown area for heist
local lockedCount = LockdownArea(heistCoords, 50.0)

-- Release lockdown after mission
local unlockedCount = UnlockArea(heistCoords, 50.0)

-- Track lockpick attempts
OnLockpickAttempt(source, doorId, success)
OnDoorBreached(source, doorId, 'thermite')
```

**rcore_doorlock Exports:**
- `exports.rcore_doorlock:changeDoorState(doorId, state)`
- `exports.rcore_doorlock:addDoor(door)`
- `exports.rcore_doorlock:getLoadedDoors()`
- `exports.rcore_doorlock:getPlayerBusiness(source)`

---

### drugs_creator Integration

**File:** `integrations/drugs_creator_integration.lua`

Track drug empire building for supplier missions.

```lua
-- Track field operations
OnFieldHarvest(source, {fieldId, drugType, amount})
OnFieldPlant(source, {fieldId, drugType, amount})

-- Track lab processing
OnLabProcessStart(source, {labId, drugType, inputAmount, recipe})
OnLabProcessComplete(source, {labId, drugType, outputAmount, quality})

-- Track sales
OnNPCSale(source, {drugType, amount, price, npcType})
OnSaleInterrupted(source, {drugType, amount, reason})

-- Track large shipments
OnShipmentStart(source, {type = 'boat', drugType, amount, value})
OnShipmentDelivered(source, {type, drugType, amount, earnings})

-- Track pusher system
OnPusherActivated(source, {id, location})
OnPusherSale(source, {drugType, amount, earnings, pusherId})

-- High-level narcos deals
OnNarcosDeal(source, {drugType, amount, price})
```

**Reactive Triggers:**
- After $100k in sales → Supplier mission offered
- Successful shipments → Major player status
- Failed shipments → Competition missions

---

### pug-robberycreator Integration

**File:** `integrations/pug_robberycreator_integration.lua`

Track robbery patterns for heist escalation.

```lua
-- Track robbery lifecycle
OnRobberyStart(source, {type, id, location, estimatedValue, difficulty})
OnRobberyStepComplete(source, {robberyType, step, totalSteps, minigame, success})
OnRobberyComplete(source, {type, id, success, lootValue, duration, policeResponded})

-- Track bank truck heists
OnBankTruckStart(source, {plate, value, coords})
OnBankTruckComplete(source, {plate, lootValue})

-- Track ATM robberies
OnATMRobberyStart(source, {model, value, coords})

-- Track violence
OnGuardEngaged(source, {robberyId, killed, incapacitated, method})

-- Track vault breaches
OnVaultBreach(source, {robberyType, robberyId, method, success})

-- Track minigame performance (for skill-based missions)
OnMinigameComplete(source, {type, success, attempts, difficulty})
```

**Reactive Triggers:**
- 5+ successful robberies → Major heist offered
- $500k+ stolen → Increased heat
- Violent robber → Different mission profile

---

### nextgenfivem_crafting Integration

**File:** `integrations/crafting_integration.lua`

Track crafting for supply missions and criminal reputation.

```lua
-- Track crafting
OnCraftingStart(source, {item, amount, benchId, benchType})
OnCraftingComplete(source, {item, amount, benchId, benchType, success})
OnCraftingFailed(source, {item, amount, benchId, reason})

-- Track bench access
OnBenchAccess(source, {benchId, benchType, benchOwner})
OnPortableBenchPlaced(source, {benchType, coords})

-- Track blueprints
OnBlueprintLearned(source, {name, item, source = 'mission'})

-- Item classification helpers
IsWeaponItem(itemName)  -- Returns true for weapons/ammo
IsDrugItem(itemName)    -- Returns true for drugs
```

**Reactive Triggers:**
- 10+ weapons crafted → Arms deal mission
- 20+ drugs crafted → Distribution mission

---

## Integration Files Summary

| File | Target Script | Key Features |
|------|---------------|--------------|
| `lb_phone_integration.lua` | lb-phone | Mr. X emails, mission briefings, notifications |
| `lb_tablet_integration.lua` | lb-tablet | Police MDT tracking, pressure mapping |
| `brutal_gangs_integration.lua` | brutal_gangs | Gang status, territory, raids |
| `rcore_doorlock_integration.lua` | rcore_doorlock | Door control, lockdown areas |
| `drugs_creator_integration.lua` | drugs_creator | Drug empire tracking, shipments |
| `pug_robberycreator_integration.lua` | pug-robberycreator | Robbery patterns, heist escalation |
| `crafting_integration.lua` | nextgenfivem_crafting | Crafting tracking, supply missions |
| `robbery_integration.lua` | Generic | Bank/store robbery hooks |
| `police_integration.lua` | Generic | Police dispatch/pursuit hooks |
| `criminal_integration.lua` | Generic | Drug/gang/weapon hooks |

---

## Version Compatibility

- sv_nexus_tools: 1.0.0+
- qbx_core: 1.0.0+
- ox_lib: 3.0.0+
- lb-phone: 2.0.0+
- lb-tablet: 1.5.0+
- brutal_gangs: 1.2.0+
- rcore_doorlock: 1.10.0+
- drugs_creator: 6.0.0+
- pug-robberycreator: 1.2.0+
- nextgenfivem_crafting: 1.1.0+
