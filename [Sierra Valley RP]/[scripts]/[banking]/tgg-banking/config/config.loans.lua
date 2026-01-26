Config = Config or {}

-- Loan System Configuration
Config.Loans = {
    -- Enable/Disable loan system
    Enabled = true,

    -- Credit Score System
    CreditScore = {
        DefaultScore = 500, -- Starting credit score for new players. Range (300-850)

        -- Credit score requirements for loan approval. Range (300-850)
        MinScoreForLoan = 450,

        -- Credit score calculation factors
        Factors = {
            AccountAge = 0.15,         -- 15% - How long the account has existed
            TransactionHistory = 0.25, -- 25% - Volume and frequency of transactions
            PaymentHistory = 0.35,     -- 35% - Loan payment history (most important)
            AccountBalance = 0.15,     -- 15% - Current account balance stability
            DebtToIncomeRatio = 0.10   -- 10% - Current debt vs estimated income
        },

        -- Account age settings
        MaxAccountAgeForScore = 90, -- Days - Account reaches max age score after this many days (3 months default)

        -- Account balance settings
        MaxBalanceForScore = 100000, -- Balance - Account reaches max balance score at this amount ($100k default)

        -- Credit score abuse prevention
        MinLoanDurationForBonus = 0.33,  -- Minimum loan duration percentage before credit bonus (33% = 1/3)
        MaxCreditBonusPerMonth = 3,      -- Maximum credit bonuses per 30-day period
        CreditBonusCooldown = 86400 * 7, -- Cooldown between credit bonuses in seconds (7 days)
        MinLoanAmountForBonus = 5000     -- Minimum loan amount to be eligible for credit bonuses
    },

    -- Loan Parameters
    LoanSettings = {
        -- Minimum and maximum loan amounts
        MinAmount = 1000,   -- $1k *default
        MaxAmount = 100000, -- $100k *default

        -- Maximum loan duration in days
        MaxDuration = 90, -- 90 days *default
        MinDuration = 7,  -- 7 days *default

        -- Interest rates based on credit score tiers
        -- Same total cost regardless of payment frequency (daily vs weekly)
        -- Rates are realistic for FiveM universe while still being higher than real-world
        InterestRates = {
            { minScore = 750, maxScore = 850, rate = 0.12 }, -- 12% for excellent credit score *default
            { minScore = 700, maxScore = 749, rate = 0.18 }, -- 18% for good credit score *default
            { minScore = 650, maxScore = 699, rate = 0.24 }, -- 24% for fair credit score *default
            { minScore = 600, maxScore = 649, rate = 0.36 }, -- 36% for poor credit score *default
            { minScore = 450, maxScore = 599, rate = 0.60 }, -- 60% for bad credit score *default
        },

        -- Maximum number of active loans per player
        MaxActiveLoans = 3, -- 3 active loans simultaneously *default

        -- Payment frequency options.
        -- !!! We do not recommend touching this unless you know what you are doing. !!!
        PaymentFrequency = {
            daily = {
                label = "Daily",
                multiplier = 1,
                cronExpression = "0 12 * * *" -- Daily at 12:00 PM
            },
            weekly = {
                label = "Weekly",
                multiplier = 7,
                cronExpression = "0 12 * * 1" -- Weekly on Monday at 12:00 PM
            }
        },

        -- Default payment frequency
        DefaultFrequency = "weekly" -- or "daily"
    },

    -- Penalty System
    Penalties = {
        -- Late payment fee (percentage of payment amount)
        LatePaymentFee = 0.05, -- 5% of payment amount

        -- Credit score reduction for missed payments
        CreditScoreReduction = {
            FirstMissed = 10,  -- -10 points for first missed payment
            SecondMissed = 20, -- -20 points for second consecutive missed payment
            ThirdMissed = 30,  -- -30 points for third consecutive missed payment
            Default = 50       -- -50 points when loan goes into default
        },

        -- Grace period before marking payment as late (in hours)
        GracePeriod = 24,

        -- Number of missed payments before loan goes into default
        DefaultThreshold = 3
    },

    -- Loan approval criteria
    Approval = {
        -- Minimum account balance required (as percentage of loan amount)
        MinBalancePercentage = 0.1, -- 10% of loan amount

        -- Minimum account age in days
        MinAccountAge = 7,

        -- Maximum loan amount based on credit score
        MaxLoanByCredit = {
            { minScore = 750, maxAmount = 100000 }, -- Adjust LoanSettings.MaxAmount as well to ensure the max loan amount is consistent
            { minScore = 700, maxAmount = 75000 },
            { minScore = 650, maxAmount = 50000 },
            { minScore = 600, maxAmount = 25000 },
            { minScore = 450, maxAmount = 10000 } -- Adjust LoanSettings.MinAmount as well to ensure the min loan amount is consistent
        }
    },

    -- Notifications
    Notifications = {
        -- Notify player when payment is overdue
        OverdueNotification = true,
    },

    ---Interest calculation function - customize this to change how loan payments are calculated
    ---@param principal number The loan amount
    ---@param interestRate number The ANNUAL interest rate (as decimal, e.g., 0.12 for 12% per year)
    ---@param duration number Loan duration in days
    ---@param frequency string Payment frequency ('daily' or 'weekly')
    ---@return table Returns table with { paymentAmount, totalAmount, totalInterest }
    CalculateInterest = function(principal, interestRate, duration, frequency)
        local frequencyMultiplier = Config.Loans.LoanSettings.PaymentFrequency[frequency].multiplier
        local periodsTotal = duration / frequencyMultiplier

        if periodsTotal <= 0 then
            return {
                paymentAmount = 0,
                totalAmount = math.ceil(principal),
                totalInterest = 0
            }
        end

        local annualInterestRate = interestRate
        local durationInYears = duration / 365
        local totalInterest = principal * annualInterestRate * durationInYears
        local totalAmount = principal + totalInterest

        -- Round up all values to next whole dollar
        totalAmount = math.ceil(totalAmount)
        totalInterest = math.ceil(totalInterest)
        local paymentAmount = math.ceil(totalAmount / periodsTotal)

        return {
            paymentAmount = paymentAmount,
            totalAmount = totalAmount,
            totalInterest = totalInterest
        }
    end
}
