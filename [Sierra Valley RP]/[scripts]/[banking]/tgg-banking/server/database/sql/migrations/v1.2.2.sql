CREATE TABLE
    IF NOT EXISTS `tgg_banking_loans` (
        `loanId` INT AUTO_INCREMENT PRIMARY KEY,
        `playerId` VARCHAR(80) NOT NULL,
        `accountIban` VARCHAR(20) NOT NULL,
        `amount` DECIMAL(15, 2) NOT NULL,
        `interestRate` DECIMAL(5, 4) NOT NULL, -- e.g., 0.1500 for 15%
        `duration` INT NOT NULL, -- Duration in days
        `paymentFrequency` VARCHAR(20) NOT NULL, -- 'daily' or 'weekly'
        `paymentAmount` DECIMAL(15, 2) NOT NULL,
        `totalAmount` DECIMAL(15, 2) NOT NULL, -- Original amount + interest
        `remainingAmount` DECIMAL(15, 2) NOT NULL,
        `nextPaymentDate` DATETIME NOT NULL,
        `status` VARCHAR(20) DEFAULT 'active', -- 'active', 'overdue', 'paid', 'defaulted'
        `missedPayments` INT DEFAULT 0,
        `autoPayment` BOOLEAN DEFAULT FALSE,
        `createdAt` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        `updatedAt` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (`accountIban`) REFERENCES `tgg_banking_accounts` (`iban`) ON DELETE CASCADE ON UPDATE CASCADE,
        INDEX `idx_player_status` (`playerId`, `status`),
        INDEX `idx_next_payment` (`nextPaymentDate`, `status`)
    ) CHARACTER
SET
    utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE
    IF NOT EXISTS `tgg_banking_loan_payments` (
        `paymentId` INT AUTO_INCREMENT PRIMARY KEY,
        `loanId` INT NOT NULL,
        `playerId` VARCHAR(80) NOT NULL,
        `amount` DECIMAL(15, 2) NOT NULL,
        `paymentType` VARCHAR(20) NOT NULL, -- 'scheduled', 'manual', 'early', 'late'
        `status` VARCHAR(20) NOT NULL, -- 'success', 'failed', 'pending'
        `createdAt` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (`loanId`) REFERENCES `tgg_banking_loans` (`loanId`) ON DELETE CASCADE ON UPDATE CASCADE,
        INDEX `idx_loan_payments` (`loanId`, `createdAt`)
    ) CHARACTER
SET
    utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE
    IF NOT EXISTS `tgg_banking_credit_scores` (
        `playerId` VARCHAR(80) NOT NULL PRIMARY KEY,
        `score` INT NOT NULL DEFAULT 300, -- Credit score (300-850) - Default matches Config.Loans.CreditScore.DefaultScore
        `accountAge` DECIMAL(5, 2) DEFAULT 0.00, -- Factor score for account age
        `transactionHistory` DECIMAL(5, 2) DEFAULT 0.00, -- Factor score for transaction history
        `paymentHistory` DECIMAL(5, 2) DEFAULT 0.00, -- Factor score for payment history
        `accountBalance` DECIMAL(5, 2) DEFAULT 0.00, -- Factor score for account balance
        `debtToIncomeRatio` DECIMAL(5, 2) DEFAULT 0.00, -- Factor score for debt-to-income ratio
        `createdAt` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        `updatedAt` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX `idx_credit_score` (`score`)
    ) CHARACTER
SET
    utf8mb4 COLLATE utf8mb4_unicode_ci;