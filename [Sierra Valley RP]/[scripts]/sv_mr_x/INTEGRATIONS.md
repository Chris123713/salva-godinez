# sv_mr_x & sv_nexus_tools Integration Reference

This document preserves all custom integrations with lb-phone and lb-tablet to protect them across resource updates. **Keep this file updated when modifying integrations.**

---

## Table of Contents

1. [lb-phone Integration](#lb-phone-integration)
2. [lb-tablet Integration](#lb-tablet-integration)
3. [sv_nexus_tools Exports](#sv_nexus_tools-exports)
4. [tgg-banking Integration](#tgg-banking-integration)
5. [Database Dependencies](#database-dependencies)
6. [Recovery After Updates](#recovery-after-updates)

---

## lb-phone Integration

### Location: `sv_mr_x/server/comms.lua`

Mr. X uses lb-phone for all anonymous communication with players.

### Exports Used (lb-phone)

| Export | Purpose | Our Usage |
|--------|---------|-----------|
| `GetEquippedPhoneNumber(source)` | Get player's phone number | Required to send SMS |
| `GetEmailAddress(phoneNumber)` | Get email from phone number | Required to send emails |
| `SendMessage(from, to, msg, attachments, cb, channel)` | Send SMS | Anonymous messages from "Unknown" |
| `SendMail(data)` | Send email | Mission briefings, notifications |
| `CreateCall(caller, callee, options)` | Create phone call | Anonymous calls (not currently used) |

### Events Listened To

```lua
-- In server/comms.lua:573
AddEventHandler('lb-phone:messages:messageSent', function(message)
    -- message: {channelId, messageId, sender, recipient, message, attachments?}
    if IsMrXRecipient(message.recipient) then
        -- Handle inbound message to Mr. X
    end
end)
```

### Client Events Triggered

```lua
-- Phone notification (server -> client)
TriggerClientEvent('lb-phone:notification', source, {
    title = 'Mr. X',
    description = message,
    icon = 'fas fa-user-secret',
    duration = 5000
})
```

### Custom Functions (sv_mr_x/server/comms.lua)

```lua
-- Core messaging functions (lines 97-264)
Comms.SendMessage(source, message, queueIfBusy)  -- Send anonymous SMS
Comms.SendEmail(source, subject, body, actions)   -- Send email with optional buttons
Comms.SendNotification(source, title, message)    -- Push notification
Comms.CreateCall(source, onAnswer, voiceMessage)  -- Anonymous call (future)

-- Session management (lines 312-405)
Comms.CreateSession(citizenid, channel)
Comms.GetSession(citizenid)
Comms.UpdateSession(citizenid, context)
Comms.EndSession(citizenid, status)

-- Message queue for busy phones (lines 269-310)
Comms.QueueMessage(source, msgType, data)
Comms.DeliverQueuedMessages(source)

-- Inbound handling (lines 407-523)
Comms.HandleInbound(source, message)
Comms.CheckServiceRequest(source, citizenid, message)
```

### Mr. X Phone Identifiers (config.lua:60-67)

Players can text these to reach Mr. X:
```lua
Config.Comms.MrXIdentifiers = {
    'Unknown',
    'Anonymous',
    'Blocked Number',
    'Mr. X'
}
```

---

## lb-tablet Integration

### Location: `sv_mr_x/server/tablet.lua`

Used for HARM (creating fake police records) and HELP (clearing records for high-rep players).

### Exports Used (lb-tablet)

| Export | Purpose | Our Usage |
|--------|---------|-----------|
| `CreatePoliceWarrant(source, data)` | Create arrest warrant | HARM: Fake warrants |
| `CreatePoliceReport(source, data)` | Create incident report | HARM: Fake reports |
| `CreatePoliceCase(source, data)` | Open investigation | HARM: Fake cases |
| `AddDispatch(data)` | Create dispatch alert | HARM: Anonymous tips |
| `DeletePoliceWarrant(id)` | Remove warrant | HELP: Clear warrant ($75k) |
| `DeletePoliceReport(id)` | Remove report | HELP: Clear report ($50k) |
| `DeletePoliceCase(id)` | Close/remove case | HELP: Clear case ($150k) |
| `LogJailed(suspect, officer, reason, time)` | Log jail record | HARM: Fake jail records |

### lb-tablet Database Tables Used

```sql
-- Warrants (linked_profile_id = citizenid, warrant_status = 'active')
SELECT * FROM lbtablet_police_warrants
WHERE linked_profile_id = ? AND warrant_status = 'active';

-- Reports (uses separate _involved table, not JSON column)
SELECT r.* FROM lbtablet_police_reports r
INNER JOIN lbtablet_police_reports_involved i ON r.id = i.report_id
WHERE i.involved = ?;

-- Cases (uses separate _criminals table, closed = FALSE for open)
SELECT c.* FROM lbtablet_police_cases c
INNER JOIN lbtablet_police_cases_criminals cr ON c.id = cr.case_id
WHERE cr.id = ? AND c.closed = FALSE;

-- BOLOs (bulletin board - pinned entries)
INSERT INTO lbtablet_police_bulletin (title, content, pinned, created_by, created_at)
VALUES (?, ?, true, 'SYSTEM_MRX', NOW());
```

### lb-tablet Table Schema Reference

| Table | Key Columns |
|-------|-------------|
| `lbtablet_police_warrants` | `id`, `linked_profile_id`, `warrant_status`, `warrant_type`, `priority`, `title`, `description` |
| `lbtablet_police_reports` | `id`, `report_type`, `created_by`, `title`, `description` |
| `lbtablet_police_reports_involved` | `report_id`, `involved` (citizenid), `involvement` |
| `lbtablet_police_cases` | `id`, `title`, `description`, `closed` (boolean) |
| `lbtablet_police_cases_criminals` | `case_id`, `id` (citizenid), `fine`, `jail_time` |
| `lbtablet_police_bulletin` | `id`, `title`, `content`, `pinned`, `created_by` |

### Custom Functions (sv_mr_x/server/tablet.lua)

```lua
-- HARM: Create fake records (lines 36-218)
Tablet.CreateWarrant(suspectCid, data)     -- Fake arrest warrant
Tablet.CreateReport(suspectCid, data)      -- Fake incident report
Tablet.CreateCase(suspectCid, data)        -- Fake investigation
Tablet.CreateBOLO(data)                     -- BOLO bulletin
Tablet.CreateDispatch(data)                 -- Dispatch alert
Tablet.LogJailRecord(suspectCid, reason)    -- Fake jail record

-- HELP: Clear records (lines 220-422)
Tablet.ClearWarrant(source, warrantId)      -- $75,000
Tablet.ClearReport(source, reportId)        -- $50,000
Tablet.ClearCase(source, caseId)            -- $150,000
Tablet.GetPlayerRecords(citizenid)          -- Get all records
Tablet.ClearAllRecords(source)              -- Clean Slate ($500k+)
```

### Record Clearing Pricing (config.lua:151-199)

```lua
Config.Services = {
    ClearWarrant = { cost = 75000, minRep = 70 },
    ClearReport = { cost = 50000, minRep = 60 },
    ClearCase = { cost = 150000, minRep = 80 },
    ClearBOLO = { cost = 25000, minRep = 50 },
    ClearJailRecord = { cost = 100000, minRep = 75 },
    CleanSlate = {
        baseCost = 500000,
        perFelony = 100000,  -- +$100k per felony
        perWarrant = 50000,  -- +$50k per warrant
        perCase = 75000,     -- +$75k per case
        minRep = 95
    }
}
```

---

## sv_nexus_tools Exports

sv_nexus_tools provides shared utilities used by sv_mr_x.

### From sv_nexus_tools/server/phone.lua

```lua
exports['sv_nexus_tools']:SendPhoneMail(source, {
    subject = 'string',
    message = 'string',
    sender = 'string'
})

exports['sv_nexus_tools']:SendPhoneNotification(source, {
    title = 'string',
    message = 'string',
    icon = 'fas fa-icon'
})
```

### From sv_nexus_tools/server/openai.lua

```lua
-- Call OpenAI for mission generation
exports['sv_nexus_tools']:CallOpenAI(systemPrompt, userMessage, options)

-- Generate Mr. X mission via AI
exports['sv_nexus_tools']:GenerateMrXMission(citizenid, profile, context)
```

### Integration File Locations

| File | Purpose |
|------|---------|
| `sv_nexus_tools/integrations/lb_phone_integration.lua` | Phone wrapper functions |
| `sv_nexus_tools/integrations/lb_tablet_integration.lua` | Tablet event tracking |

---

## tgg-banking Integration

### Location: Config (config.lua:279-286)

```lua
Config.Banking = {
    PrimaryResource = 'tgg-banking',
    PaymentMethods = {'cash', 'bank'},
    DefaultMethod = 'bank',
    AllowBalanceCheck = true,
    AllowTransfers = true,
    MinBalanceForHighTier = 100000
}
```

### Exports Expected

```lua
-- Balance check
exports['tgg-banking']:GetPlayerBalance(source, accountType)

-- Money operations
exports['tgg-banking']:RemoveMoneyFromAccount(source, amount, reason)
exports['tgg-banking']:AddMoneyToAccount(source, amount, reason)
```

---

## Database Dependencies

### sv_mr_x Tables (db/mr_x_schema.sql)

```sql
-- Core tables
mr_x_profiles           -- Player profiles, archetypes, psychology metrics
mr_x_behavior_events    -- Behavior tracking for classification
mr_x_sessions           -- Conversation sessions
mr_x_events             -- Activity logging
mr_x_loans              -- Loan tracking
mr_x_bounties           -- Active bounties
mr_x_eligible_gangs     -- Gangs eligible for bounty contracts
mr_x_gang_relations     -- Gang betrayal state

-- Indexes for performance
CREATE INDEX idx_profiles_archetype ON mr_x_profiles(archetype);
CREATE INDEX idx_events_type ON mr_x_events(event_type);
CREATE INDEX idx_events_citizenid ON mr_x_events(citizenid);
```

### lb-tablet Tables Used

```sql
lbtablet_police_warrants
lbtablet_police_reports
lbtablet_police_cases
lbtablet_police_bulletin
```

---

## Recovery After Updates

### After lb-phone Update

1. Verify exports still exist:
   ```lua
   print(exports['lb-phone']:GetEquippedPhoneNumber ~= nil)
   print(exports['lb-phone']:SendMessage ~= nil)
   print(exports['lb-phone']:SendMail ~= nil)
   ```

2. Check event name hasn't changed:
   ```lua
   -- Should fire when player sends SMS
   AddEventHandler('lb-phone:messages:messageSent', function(message) end)
   ```

3. Test notification format:
   ```lua
   TriggerClientEvent('lb-phone:notification', source, {
       title = 'Test',
       description = 'Test message',
       icon = 'fas fa-check'
   })
   ```

### After lb-tablet Update

1. Verify exports still exist:
   ```lua
   print(exports['lb-tablet']:CreatePoliceWarrant ~= nil)
   print(exports['lb-tablet']:DeletePoliceWarrant ~= nil)
   ```

2. Check database table names match:
   ```sql
   SHOW TABLES LIKE 'lbtablet_%';
   ```

3. Verify JSON column format for suspects array

### Backup Commands

Before updating lb-phone or lb-tablet:

```bash
# Backup custom integrations
cp sv_mr_x/server/comms.lua sv_mr_x/server/comms.lua.backup
cp sv_mr_x/server/tablet.lua sv_mr_x/server/tablet.lua.backup
cp sv_nexus_tools/integrations/lb_phone_integration.lua sv_nexus_tools/integrations/lb_phone_integration.lua.backup
cp sv_nexus_tools/integrations/lb_tablet_integration.lua sv_nexus_tools/integrations/lb_tablet_integration.lua.backup
```

---

## Quick Reference: All Exports

### sv_mr_x Exports (comms)

```lua
exports['sv_mr_x']:SendMrXMessage(source, message)
exports['sv_mr_x']:SendMrXEmail(source, subject, body)
exports['sv_mr_x']:SendMrXNotification(source, title, message)
exports['sv_mr_x']:CreateMrXCall(source, onAnswer, voiceMessage)
exports['sv_mr_x']:GetCommsSession(citizenid)
exports['sv_mr_x']:CreateCommsSession(citizenid, channel)
exports['sv_mr_x']:EndCommsSession(citizenid, status)
exports['sv_mr_x']:HandleInboundMessage(source, message)
```

### sv_mr_x Exports (tablet)

```lua
exports['sv_mr_x']:CreateFakeWarrant(suspectCid, data)
exports['sv_mr_x']:CreateFakeReport(suspectCid, data)
exports['sv_mr_x']:CreateFakeCase(suspectCid, data)
exports['sv_mr_x']:CreateFakeBOLO(data)
exports['sv_mr_x']:CreateTabletDispatch(data)
exports['sv_mr_x']:LogFakeJailRecord(suspectCid, reason, time)
exports['sv_mr_x']:ClearWarrant(source, warrantId)
exports['sv_mr_x']:ClearReport(source, reportId)
exports['sv_mr_x']:ClearCase(source, caseId)
exports['sv_mr_x']:GetPlayerRecords(citizenid)
exports['sv_mr_x']:ClearAllRecords(source)
```

### sv_mr_x Exports (webhook)

```lua
exports['sv_mr_x']:PostWebhook(eventType, data, priority)
exports['sv_mr_x']:PostWebhookMessage(direction, citizenid, channel, content, source)
exports['sv_mr_x']:PostWebhookMission(eventType, citizenid, missionData)
exports['sv_mr_x']:PostWebhookChaos(eventType, citizenid, surpriseType, details)
exports['sv_mr_x']:PostWebhookBounty(eventType, data)
exports['sv_mr_x']:PostWebhookRepChange(citizenid, oldRep, newRep, reason)
```

---

## Version History

| Date | Changes |
|------|---------|
| 2025-01 | Initial documentation |
| 2025-01 | Added v2.0 psychology system |
| 2025-01 | Added tgg-banking integration |
| 2025-01 | Added web dashboard webhook exports |
