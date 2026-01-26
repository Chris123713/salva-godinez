Config = Config or {}

-- These settings will apply to any NEW account that you create.
-- If you want to change the settings for an existing account, you will need to do so through the UI.
Config.DefaultAccountSettings = {
    hideBalance = false,
}

-- Limit the number of accounts that can be created by a single player.
Config.LimitAccountCreation = 5

-- Savings Account Configuration
Config.Savings = {
    Enabled = true,

    -- Duration options (in days) that admins configure
    DurationOptions = {
        { days = 7,   label = "1 Week" },
        { days = 30,  label = "1 Month" },
        { days = 90,  label = "3 Months" },
        { days = 180, label = "6 Months" }
    },

    -- Interest rates based on duration tiers
    InterestRates = {
        { minDays = 1,  maxDays = 7,   rate = 0.03 }, -- 3% annual rate for 7 days
        { minDays = 8,  maxDays = 30,  rate = 0.05 }, -- 5% annual rate for 30 days
        { minDays = 31, maxDays = 90,  rate = 0.10 }, -- 10% annual rate for 90 days
        { minDays = 91, maxDays = 180, rate = 0.15 }, -- 15% annual rate for 180 days
    },

    -- Minimum hold period before reduced penalty applies (in days)
    MinimumHoldPeriod = 7, -- Before 7 days = 100% interest loss, after 7 days = 50% penalty(configured below - EarlyWithdrawalPenalty)

    -- Early withdrawal penalty (percentage of earned interest lost)
    EarlyWithdrawalPenalty = 0.50, -- 50% penalty after minimum hold period (configured above - MinimumHoldPeriod)

    -- Minimum deposit amount when creating a savings account
    MinDeposit = 1000,

    -- Maximum number of savings accounts per player
    MaxSavingsAccounts = 3,

    -- Cron expression for interest calculation (daily at noon)
    InterestCronExpression = "0 12 * * *",

}
