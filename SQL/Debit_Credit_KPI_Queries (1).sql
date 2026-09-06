CREATE DATABASE bank_analytics;
USE bank_analytics;

CREATE TABLE transactions (
    customer_id VARCHAR(50),
    customer_name VARCHAR(100),
    account_number VARCHAR(50),
    transaction_date DATE,
    transaction_type VARCHAR(20),
    amount DECIMAL(15,2),
    balance DECIMAL(15,2),
    description VARCHAR(255),
    branch VARCHAR(100),
    transaction_method VARCHAR(50),
    currency VARCHAR(10),
    bank_name VARCHAR(100)
);

ALTER TABLE transactions MODIFY transaction_date VARCHAR(20);
TRUNCATE TABLE transactions;
LOAD DATA LOCAL INFILE 'C:/Users/Shreyash/Downloads/Debit and Credit banking_data.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(customer_id, customer_name, account_number, @transaction_date, transaction_type, amount, balance, description, branch, transaction_method, currency, bank_name)
SET transaction_date = STR_TO_DATE(@transaction_date, '%d-%m-%Y');
SET GLOBAL local_infile = 1;
TRUNCATE TABLE transactions;
TRUNCATE TABLE transactions;
SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Debit and Credit banking_data.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(customer_id, customer_name, account_number, @transaction_date, transaction_type, amount, balance, description, branch, transaction_method, currency, bank_name)
SET transaction_date = STR_TO_DATE(@transaction_date, '%d-%m-%Y');

SELECT COUNT(*) FROM transactions;
SELECT transaction_date FROM transactions LIMIT 5;
ALTER TABLE transactions MODIFY transaction_date DATE;

SELECT SUM(amount) AS total_credit_amount
FROM transactions
WHERE transaction_type = 'Credit';





-- Q1. Total Credit Amount
SELECT SUM(amount) AS total_credit_amount
FROM transactions
WHERE transaction_type = 'Credit';

-- Q2. Total Debit Amount
SELECT SUM(amount) AS total_debit_amount
FROM transactions
WHERE transaction_type = 'Debit';

-- Q3. Credit to Debit Ratio
SELECT 
    SUM(CASE WHEN transaction_type = 'Credit' THEN amount ELSE 0 END) /
    SUM(CASE WHEN transaction_type = 'Debit' THEN amount ELSE 0 END) AS credit_to_debit_ratio
FROM transactions;

-- Q4. Net Transaction Amount
SELECT 
    SUM(CASE WHEN transaction_type = 'Credit' THEN amount ELSE -amount END) AS net_transaction_amount
FROM transactions;

-- Q5. Account Activity Ratio
SELECT 
    COUNT(*) / AVG(balance) AS account_activity_ratio
FROM transactions;

-- Q6. Transactions per Day/Week/Month
SELECT 
    MONTH(transaction_date) AS txn_month,
    COUNT(*) AS transaction_count
FROM transactions
GROUP BY MONTH(transaction_date)
ORDER BY txn_month;

-- Q7. Total Transaction Amount by Branch
SELECT 
    branch,
    SUM(amount) AS total_amount
FROM transactions
GROUP BY branch
ORDER BY total_amount DESC;

-- Q8. Transaction Volume by Bank
SELECT 
    bank_name,
    SUM(amount) AS total_volume
FROM transactions
GROUP BY bank_name
ORDER BY total_volume DESC;

-- Q9. Transaction Method Distribution
SELECT 
    transaction_method,
    COUNT(*) AS transaction_count,
    COUNT(*) * 100.0 / (SELECT COUNT(*) FROM transactions) AS percentage
FROM transactions
GROUP BY transaction_method;

-- Q10. Branch Transaction Growth (H1 vs H2 2024)
SELECT 
    branch,
    SUM(CASE WHEN MONTH(transaction_date) BETWEEN 1 AND 6 THEN amount ELSE 0 END) AS h1_amount,
    SUM(CASE WHEN MONTH(transaction_date) BETWEEN 7 AND 12 THEN amount ELSE 0 END) AS h2_amount,
    (SUM(CASE WHEN MONTH(transaction_date) BETWEEN 7 AND 12 THEN amount ELSE 0 END) -
     SUM(CASE WHEN MONTH(transaction_date) BETWEEN 1 AND 6 THEN amount ELSE 0 END)) /
     SUM(CASE WHEN MONTH(transaction_date) BETWEEN 1 AND 6 THEN amount ELSE 0 END) * 100 AS growth_percent
FROM transactions
GROUP BY branch;

-- Q11. High-Risk Transaction Flag (threshold = 95th percentile of Amount)
SELECT 
    CASE WHEN amount > 4762 THEN 'High Risk' ELSE 'Normal' END AS risk_flag,
    COUNT(*) AS count
FROM transactions
GROUP BY CASE WHEN amount > 4762 THEN 'High Risk' ELSE 'Normal' END;

-- Q12. Suspicious Transaction Frequency (per Month)
SELECT 
    MONTH(transaction_date) AS txn_month,
    COUNT(*) AS flagged_count
FROM transactions
WHERE amount > 4762
GROUP BY MONTH(transaction_date)
ORDER BY txn_month;