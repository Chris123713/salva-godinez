# sv_nexus_tools Integration Reference

This document preserves all custom integrations with external resources (lb-phone, lb-tablet, etc.) to protect them across updates.

---

## Table of Contents

1. [lb-phone Integration](#lb-phone-integration)
2. [lb-tablet Integration](#lb-tablet-integration)
3. [Other Integrations](#other-integrations)
4. [Exports Provided](#exports-provided)
5. [Recovery After Updates](#recovery-after-updates)

---

## lb-phone Integration

### Location: `integrations/lb_phone_integration.lua` & `server/phone.lua`

### Exports Used (lb-phone)

| Export | Purpose | Our Usage |
|--------|---------|-----------|
| `GetEquippedPhoneNumber(source)` | Get player's phone number | Mission notifications |
| `GetEmailAddress(phoneNumber)` | Get email from phone | Mission briefings |
| `SendMail(data)` | Send email | Mission details with action buttons |

### Custom Functions (server/phone.lua)

```lua
-- Get player phone info
Phone.GetPlayerPhone(source) -- Returns: phoneNumber, email

-- Send mail via lb-phone
Phone.SendMail(source, {
    subject = 'string',
    message = 'string',
    sender = 'string'
})

-- Send notification (fallback to ox_lib if lb-phone unavailable)
Phone.SendNotification(source, {
    title = 'string',
    message = 'string',
    icon = 'fas fa-icon'
})
```

### Registered Tools (for AI agent use)

```lua
-- Send mail tool
RegisterTool('send_phone_mail', {
    params = {'source', 'subject', 'message', 'sender'},
    async = true,
    handler = function(params)
        return Phone.SendMail(params.source, {...})
    end
})

-- Send notification tool
RegisterTool('send_phone_notification', {
    params = {'source', 'title', 'message', 'icon'},
    handler = function(params)
        return Phone.SendNotification(params.source, {...})
    end
})
```

### Integration Snippet (integrations/lb_phone_integration.lua)

This file provides wrapper functions for Mr. X specifically:

```lua
-- Send Mr. X email with optional action buttons
SendMrXEmail(source, {
    sender = 'Mr. X',
    subject = 'Business Proposal',
    message = '...',
    actions = {{
        label = 'Accept Job',
        data = {
            event = 'sv_nexus_tools:server:acceptMission',
            isServer = true,
            data = {missionId = '...'}
        }
    }}
})

-- Send mission briefing (email + action buttons)
SendMissionBriefing(source, {
    missionId = 'uuid',
    type = 'delivery',
    subject = 'New Opportunity',
    message = 'Mission details...',
    acceptEvent = 'sv_nexus_tools:server:acceptMission',
    acceptLabel = 'Accept Job'
})

-- Quick phone notification
SendPhoneNotification(source, {
    title = 'New Message',
    message = 'Mr. X has a business proposal.',
    icon = 'fas fa-user-secret',
    duration = 5000
})
```

### Client Event (notification)

```lua
TriggerClientEvent('lb-phone:notification', source, {
    title = 'Alert',
    description = 'Message content',
    icon = 'fas fa-info-circle',
    duration = 5000
})
```

---

## lb-tablet Integration

### Location: `integrations/lb_tablet_integration.lua`

### Purpose

Track police MDT activity for:
- Reactive criminal content timing (avoid hot zones)
- Investigation missions for detectives
- Linking criminal activity to MDT records
- Police pressure tracking

### Event Hooks (add to lb-tablet custom folder)

```lua
-- Track dispatch responses
RegisterNetEvent('lb-tablet:dispatch:response', function(dispatchId, dispatchData)
    local src = source
    if GetResourceState('sv_nexus_tools') == 'started' then
        exports['sv_nexus_tools']:ReportActivity('dispatch_received', {
            dispatchType = dispatchData.code,
            code = dispatchData.code,
            description = dispatchData.message,
            coords = dispatchData.coords,
            priority = dispatchData.priority or 'medium'
        }, src)
    end
end)

-- Track warrant creation
RegisterNetEvent('lb-tablet:warrant:create', function(warrantData)
    local src = source
    if GetResourceState('sv_nexus_tools') == 'started' then
        exports['sv_nexus_tools']:ReportActivity('police_investigation', {
            type = 'warrant_issued',
            targetCitizenId = warrantData.citizenid,
            charges = warrantData.charges,
            issuedBy = GetCitizenId(src)
        }, src)
    end
end)

-- Track report filing
RegisterNetEvent('lb-tablet:report:create', function(reportData)
    local src = source
    if GetResourceState('sv_nexus_tools') == 'started' then
        exports['sv_nexus_tools']:ReportActivity('police_report', {
            reportType = reportData.type,
            caseId = reportData.id,
            title = reportData.title
        }, src)
    end
end)
```

### Custom Functions

```lua
-- Report dispatch event
OnDispatchCreated(source, dispatchData)
OnDispatchResponse(source, responseData)

-- Report warrant/BOLO
OnWarrantIssued(source, warrantData)
OnBOLOCreated(source, boloData)

-- Report evidence/reports
OnEvidenceLogged(source, evidenceData)
OnReportFiled(source, reportData)
OnRecordLookup(source, lookupData)

-- Police pressure tracking
GetPolicePressure(coords, radius)  -- Returns pressure level 0-100
AddPolicePressure(coords, weight)  -- Add pressure to area
```

### Police Pressure System

Used to avoid spawning criminal content in high police activity areas:

```lua
-- Check if area is safe for criminal mission
local pressure = GetPolicePressure(vector3(x, y, z), 500.0)
if pressure >= 50 then
    print('High police activity - choosing different location')
end

-- Pressure decays over 10 minutes
-- Dispatch events add pressure weight to their location
```

---

## Other Integrations

### brutal_gangs Integration
Location: `integrations/brutal_gangs_integration.lua`
- Gang territory tracking
- Gang relation queries

### rcore_doorlock Integration
Location: `integrations/rcore_doorlock_integration.lua`
- Door lock state queries
- Lockpicking event tracking

### drugs_creator Integration
Location: `integrations/drugs_creator_integration.lua`
- Drug production tracking
- Drug sale monitoring

### pug_robberycreator Integration
Location: `integrations/pug_robberycreator_integration.lua`
- Robbery event tracking
- Heist progress monitoring

### crafting Integration
Location: `integrations/crafting_integration.lua`
- Crafting activity tracking
- Illegal item creation monitoring

---

## Exports Provided

### Phone Exports

```lua
exports['sv_nexus_tools']:SendPhoneMail(source, {
    subject = 'string',
    message = 'string',
    sender = 'string'  -- optional, defaults to Config.Phone.DefaultSender
})

exports['sv_nexus_tools']:SendPhoneNotification(source, {
    title = 'string',
    message = 'string',
    icon = 'string'  -- Font Awesome class
})
```

### Activity Reporting

```lua
exports['sv_nexus_tools']:ReportActivity(eventType, data, source)
-- eventType: 'dispatch_received', 'police_investigation', 'police_report', etc.
-- data: event-specific data table
-- source: player source or nil for system events

exports['sv_nexus_tools']:SubscribeToEvent(eventType, callback)
-- Subscribe to activity events for reactive content
```

### OpenAI Integration

```lua
exports['sv_nexus_tools']:CallOpenAI(systemPrompt, userMessage, options)
-- Returns AI response for mission generation, NPC dialogue, etc.

exports['sv_nexus_tools']:GenerateMrXMission(citizenid, profile, context)
-- Generate a mission specifically for Mr. X character
```

---

## Recovery After Updates

### After lb-phone Update

1. Check if export names changed:
   ```lua
   -- Test in server console
   print(exports['lb-phone']:GetEquippedPhoneNumber ~= nil)
   print(exports['lb-phone']:SendMail ~= nil)
   ```

2. Verify notification event still works:
   ```lua
   TriggerClientEvent('lb-phone:notification', testSource, {
       title = 'Test',
       description = 'Test',
       icon = 'fas fa-check'
   })
   ```

### After lb-tablet Update

1. Verify event names haven't changed:
   - `lb-tablet:dispatch:response`
   - `lb-tablet:warrant:create`
   - `lb-tablet:report:create`

2. Check database table structure:
   ```sql
   DESCRIBE lbtablet_police_warrants;
   DESCRIBE lbtablet_police_reports;
   ```

### Backup Commands

```bash
# Before updating external resources
cp integrations/lb_phone_integration.lua integrations/lb_phone_integration.lua.backup
cp integrations/lb_tablet_integration.lua integrations/lb_tablet_integration.lua.backup
cp server/phone.lua server/phone.lua.backup
```

---

## Version History

| Date | Changes |
|------|---------|
| 2025-01 | Initial documentation |
| 2025-01 | Added police pressure system |
| 2025-01 | Added OpenAI integration exports |
