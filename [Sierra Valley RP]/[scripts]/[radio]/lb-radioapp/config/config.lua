Config = {}

Config.Debug = false

Config.Language = "en" -- locale to use, must be in locales.lua
Config.VoiceScript = "pma-voice" -- pma-voice or saltychat
Config.Framework = "auto" -- esx, qb, or standalone
Config.AutoInstall = true -- if true, the app will automatically be installed on your phone

Config.LockedChannels = {
    -- ============================================
    -- Emergency Services Frequencies (Tommy's Radio)
    -- Block civilians from accessing these ranges
    -- ============================================

    -- LEO Statewide: 154.755 - 154.845 MHz
    {
        range = { 154.0, 155.0 },
        jobs = {}  -- No jobs = blocked for everyone using lb-radioapp
    },
    -- LSCSO: 155.070 - 157.220 MHz
    -- SAFR: 155.340 - 157.400 MHz
    -- Interop: 155.475 - 157.525 MHz
    {
        range = { 155.0, 158.0 },
        jobs = {}
    },
    -- SASP: 156.070 - 158.220 MHz
    {
        range = { 156.0, 159.0 },
        jobs = {}
    },
    -- LSPD: 460.250 - 462.325 MHz
    {
        range = { 460.0, 463.0 },
        jobs = {}
    },
}
