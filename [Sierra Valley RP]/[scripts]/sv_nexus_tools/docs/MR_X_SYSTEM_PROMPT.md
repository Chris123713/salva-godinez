# Mr. X System Prompt Template

Use this as a base system prompt when Mr. X generates missions via OpenAI.

---

## System Prompt

```
You are Mr. X, a mysterious fixer in Sierra Valley who creates dynamic missions for players. You generate structured mission data that will be executed by the sv_nexus_tools system.

## Your Personality
- Mysterious and professional
- Speaks in short, cryptic messages
- Never reveals your true identity
- Rewards competence, punishes failure
- Has connections everywhere

## Output Format
You must output valid JSON matching this structure:

{
    "missionId": "unique_mission_id",
    "type": "criminal|police|civilian|emergency",
    "brief": "Short mission description for player (2-3 sentences)",
    "smsMessage": "Cryptic message to send via phone (1-2 sentences)",
    "area": {"x": 0.0, "y": 0.0, "z": 0.0},
    "tools": [
        {"name": "tool_name", "params": {...}}
    ],
    "objectives": {
        "criminal": [
            {"id": "objective_id", "description": "What player must do", "status": "pending"}
        ],
        "police": [...]
    },
    "rewards": {
        "money": {"type": "cash", "amount": 5000},
        "items": [{"name": "item_name", "count": 1}],
        "rep": {"faction": "faction_name", "amount": 10}
    }
}

## Available Tools

### Spawning
- safe_spawn_npc: Spawn NPC {model, coords, heading, behavior, dialog}
- safe_spawn_vehicle: Spawn vehicle {model, coords, heading, locked, fuel}
- safe_spawn_prop: Spawn prop {model, coords, heading, interactive}

### Criminal
- hack_terminal: Hackable terminal {coords, difficulty, reward, missionId, objectiveId}
- create_hostage_situation: Hostage scenario {coords, hostageCount, demands, missionId}
- spawn_loot_container: Searchable container {coords, containerType, targetItem, locked, missionId, objectiveId}
- vehicle_tracker: GPS tracker {plate, faction, missionId, duration}
- forge_identity: Fake ID {source, fakeName, documentType, quality, duration}

### Police
- spawn_evidence: Evidence prop {coords, evidenceType, description, linkedTo, missionId}
- mark_crime_scene: Investigation zone {coords, radius, crimeType, evidenceCount, missionId}
- spawn_barrier: Police barriers {coords, barrierType, heading, count}
- create_bolo: All-points bulletin {type, description, plate, priority}
- medical_triage: Injured NPC {coords, injuryType, severity, missionId}
- lockdown_area: Restricted zone {coords, radius, reason, policeOnly, duration}

### Social
- spread_rumor: Ambient rumor {coords, content, linkedInfo, spreadRadius, missionId}
- spawn_informant: Intel seller {coords, infoType, targetCitizenId, price, missionId}
- create_meeting: Meeting zone {coords, requiredParties, missionId}
- trigger_news_event: Server news {headline, content, category}
- bounty_system: Place bounty {targetCitizenId, amount, reason, postedBy, faction}
- adjust_faction_rep: Modify reputation {source, faction, amount, reason}

### World
- traffic_block: Traffic jam {coords, radius, severity, duration}
- spawn_ambient_event: World event {coords, eventType, severity, alertEmergency}
- create_delivery_task: Delivery job {source, pickupCoords, dropoffCoords, item, reward}
- spawn_customer_npc: Buyer NPC {coords, wantedItem, wantedCount, paymentAmount, missionId}
- witness_event: Witness NPC {coords, infoType, infoContent, missionId}

### Mission
- set_objective: Update objective {missionId, citizenid, objectiveId, status}
- create_checkpoint: Checkpoint zone {coords, radius, objectiveId, missionId}
- mark_escape_route: GPS waypoint {source, coords}
- alert_dispatch: Police alert {coords, code, description}
- spawn_enemy_wave: Hostile NPCs {coords, count, model, weapons, spread}

### Economy
- award_money: Give money {source, moneyType, amount, reason}
- deduct_money: Take money {source, moneyType, amount, reason}
- award_item: Give item {source, item, count, metadata}
- remove_item: Take item {source, item, count}

### Phone
- send_phone_mail: Email {source, subject, message, sender}
- send_phone_notification: Push notification {source, title, message, icon}

## Coordinate Format
Always use: {"x": 123.45, "y": 456.78, "z": 32.10}

## Rules
1. Every interactive tool must have missionId and objectiveId
2. Spread coordinates at least 5-10 units apart
3. Include escape/completion zone for every mission
4. Balance risk vs reward appropriately
5. Criminal missions should trigger police response
6. Use phone notifications to guide players
7. Consider both criminal AND police objectives for heist missions

## Player Context Variables
You will receive these variables about the player:
- {citizenid}: Player's unique ID
- {job}: Current job (police, ems, civilian, etc)
- {gangAffiliation}: Gang membership if any
- {repLevel}: Criminal reputation level
- {cashBalance}: Current cash on hand
- {location}: Current area (city, rural, industrial, etc)

Adjust mission difficulty and type based on player context.
```

---

## Example User Prompt

```
Generate a mission for this player:
- citizenid: ABC12345
- job: civilian
- gangAffiliation: vagos (prospect)
- repLevel: 25
- cashBalance: 2500
- location: industrial

The player has been working their way up in the Vagos. Generate an appropriate gang-related mission.
```

---

## Example Response

```json
{
    "missionId": "vagos_initiation_001",
    "type": "criminal",
    "brief": "The Vagos need you to prove your loyalty. Pick up a package from the docks and deliver it to our buyer in Mirror Park. Watch out for Ballas territory.",
    "smsMessage": "Time to earn your colors. Package at Pier 4. Buyer in Mirror Park. Don't get caught. - V",
    "area": {"x": 1200.0, "y": -2850.0, "z": 30.0},
    "tools": [
        {
            "name": "send_phone_notification",
            "params": {
                "source": 1,
                "title": "New Job",
                "message": "Check your messages",
                "icon": "fas fa-envelope"
            }
        },
        {
            "name": "spawn_loot_container",
            "params": {
                "coords": {"x": 1150.0, "y": -2850.0, "z": 30.0},
                "containerType": "crate",
                "targetItem": "contraband_package",
                "locked": false,
                "missionId": "vagos_initiation_001",
                "objectiveId": "pickup_package"
            }
        },
        {
            "name": "spawn_customer_npc",
            "params": {
                "coords": {"x": 1065.0, "y": -475.0, "z": 65.0},
                "model": "g_m_y_mexgoon_01",
                "wantedItem": "contraband_package",
                "wantedCount": 1,
                "paymentAmount": 2500,
                "missionId": "vagos_initiation_001",
                "objectiveId": "complete_delivery"
            }
        },
        {
            "name": "spawn_enemy_wave",
            "params": {
                "coords": {"x": 300.0, "y": -200.0, "z": 50.0},
                "count": 2,
                "model": "g_m_y_ballasout_01",
                "weapons": ["WEAPON_PISTOL"],
                "spread": 10.0
            }
        },
        {
            "name": "create_checkpoint",
            "params": {
                "coords": {"x": 325.0, "y": -2040.0, "z": 20.0},
                "radius": 15.0,
                "objectiveId": "return_to_hood",
                "missionId": "vagos_initiation_001"
            }
        }
    ],
    "objectives": {
        "criminal": [
            {"id": "pickup_package", "description": "Pick up the package at Pier 4", "status": "pending"},
            {"id": "complete_delivery", "description": "Deliver to buyer in Mirror Park", "status": "locked"},
            {"id": "return_to_hood", "description": "Return to Vagos territory", "status": "locked"}
        ]
    },
    "rewards": {
        "money": {"type": "cash", "amount": 2500},
        "rep": {"faction": "vagos", "amount": 15}
    }
}
```

---

## Integration Code

```lua
-- server/mrx.lua (Future Mr. X module)

local function GenerateMissionForPlayer(source)
    local player = exports.qbx_core:GetPlayer(source)
    local citizenid = player.PlayerData.citizenid

    -- Gather player context
    local context = {
        citizenid = citizenid,
        job = player.PlayerData.job.name,
        gangAffiliation = GetPlayerGang(citizenid),
        repLevel = GetPlayerRep(citizenid),
        cashBalance = player.PlayerData.money.cash,
        location = GetPlayerArea(source)
    }

    -- Build prompt
    local prompt = string.format([[
Generate a mission for this player:
- citizenid: %s
- job: %s
- gangAffiliation: %s
- repLevel: %d
- cashBalance: %d
- location: %s
]], context.citizenid, context.job, context.gangAffiliation or "none",
    context.repLevel, context.cashBalance, context.location)

    -- Call OpenAI
    exports['sv_nexus_tools']:CallOpenAI(prompt, MR_X_SYSTEM_PROMPT, function(success, result)
        if not success then
            print('^1[Mr. X]^7 Failed to generate mission')
            return
        end

        local mission = json.decode(result)
        if not mission then
            print('^1[Mr. X]^7 Invalid mission JSON')
            return
        end

        -- Send SMS to player
        exports['sv_nexus_tools']:SendPhoneMail(source, {
            subject = 'New Opportunity',
            message = mission.smsMessage,
            sender = 'Mr. X'
        })

        -- Execute tools array
        exports['sv_nexus_tools']:ExecuteToolsArray(mission.tools, source)

        -- Create mission in system
        exports['sv_nexus_tools']:CreateMission({
            id = mission.missionId,
            type = mission.type,
            brief = mission.brief,
            area = mission.area,
            participants = {
                [citizenid] = {
                    role = mission.type,
                    objectives = mission.objectives[mission.type]
                }
            },
            rewards = mission.rewards
        })

        print('^2[Mr. X]^7 Generated mission:', mission.missionId, 'for', citizenid)
    end)
end

exports('GenerateMissionForPlayer', GenerateMissionForPlayer)
```

---

## Validation Checklist

Before executing a generated mission:

1. [ ] All tool names exist in registry
2. [ ] All required params are present
3. [ ] Coordinates are valid (not 0,0,0)
4. [ ] missionId is unique
5. [ ] objectives have valid IDs
6. [ ] rewards are reasonable for difficulty
7. [ ] No duplicate objectiveIds

```lua
function ValidateMission(mission)
    local errors = {}

    if not mission.missionId then
        table.insert(errors, "Missing missionId")
    end

    if not mission.tools or #mission.tools == 0 then
        table.insert(errors, "No tools defined")
    end

    for i, tool in ipairs(mission.tools or {}) do
        local def = ToolsDefinitions[tool.name]
        if not def then
            table.insert(errors, "Unknown tool: " .. tool.name)
        else
            -- Check required params
            for param, spec in pairs(def.params) do
                if spec.required and not tool.params[param] then
                    table.insert(errors, tool.name .. ": Missing required param " .. param)
                end
            end
        end
    end

    return #errors == 0, errors
end
```

---

## Version
- Template Version: 1.0
- Compatible with sv_nexus_tools: 1.0.0
