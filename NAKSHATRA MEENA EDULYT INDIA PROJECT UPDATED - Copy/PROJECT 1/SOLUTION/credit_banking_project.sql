-- =========================================
-- CREDIT BANKING PROJECT - FULL SQL SCRIPT
-- =========================================

-- 1️⃣ Create Database
DROP DATABASE IF EXISTS credit_banking_project;
CREATE DATABASE credit_banking_project;
USE credit_banking_project;

-- =========================================
-- 2️⃣ Create Tables
-- =========================================

CREATE TABLE customer_acquisition (
    sl_no INT,
    customer_id INT PRIMARY KEY,
    age INT,
    city VARCHAR(50),
    credit_card_product VARCHAR(50),
    limits VARCHAR(50),   -- Import as VARCHAR first
    company VARCHAR(50),
    segment VARCHAR(50)
);

CREATE TABLE spend (
    sl_no INT,
    customer_id INT,
    month VARCHAR(20),
    type VARCHAR(50),
    amount DECIMAL(12,2)
);

CREATE TABLE repayment (
    sl_no INT,
    customer_id INT,
    month VARCHAR(20),
    amount DECIMAL(12,2)
);

-- =========================================
-- 3️⃣ IMPORT CSV FILES
-- =========================================

-- CUSTOMER ACQUISITION
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Customer Acquisition.csv'
INTO TABLE customer_acquisition
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- SPEND
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Spend.csv'
INTO TABLE spend
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- REPAYMENT
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Repayment.csv'
INTO TABLE repayment
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- =========================================
-- 4️⃣ CLEAN LIMIT COLUMN (Indian format fix)
-- =========================================

UPDATE customer_acquisition
SET limits = REPLACE(limits, ',', '');

ALTER TABLE customer_acquisition
MODIFY limits DECIMAL(12,2);

-- =========================================
-- 5️⃣ SANITY CHECK - AGE < 18
-- =========================================

UPDATE customer_acquisition
SET age = (
    SELECT avg_age FROM (
        SELECT AVG(age) AS avg_age
        FROM customer_acquisition
        WHERE age >= 18
    ) AS temp
)
WHERE age < 18;

-- =========================================
-- 6️⃣ SURPLUS CREDIT (2%)
-- =========================================

SELECT s.customer_id,
       s.month,
       SUM(r.amount) AS total_repayment,
       SUM(s.amount) AS total_spend,
       (SUM(r.amount) - SUM(s.amount)) * 0.02 AS credit_next_month
FROM spend s
JOIN repayment r
  ON s.customer_id = r.customer_id
 AND s.month = r.month
GROUP BY s.customer_id, s.month
HAVING SUM(r.amount) > SUM(s.amount);

-- =========================================
-- 7️⃣ MONTHLY SPEND
-- =========================================

SELECT customer_id,
       month,
       SUM(amount) AS monthly_spend
FROM spend
GROUP BY customer_id, month;

-- =========================================
-- 8️⃣ MONTHLY REPAYMENT
-- =========================================

SELECT customer_id,
       month,
       SUM(amount) AS monthly_repayment
FROM repayment
GROUP BY customer_id, month;

-- =========================================
-- 9️⃣ TOP 10 HIGHEST PAYING CUSTOMERS
-- =========================================

SELECT customer_id,
       SUM(amount) AS total_repayment
FROM repayment
GROUP BY customer_id
ORDER BY total_repayment DESC
LIMIT 10;

-- =========================================
-- 🔟 SEGMENT SPENDING MORE
-- =========================================

SELECT c.segment,
       SUM(s.amount) AS total_spend
FROM spend s
JOIN customer_acquisition c
ON s.customer_id = c.customer_id
GROUP BY c.segment
ORDER BY total_spend DESC;

-- =========================================
-- 1️⃣1️⃣ AGE GROUP SPENDING MORE
-- =========================================

SELECT 
CASE
    WHEN age BETWEEN 18 AND 25 THEN '18-25'
    WHEN age BETWEEN 26 AND 35 THEN '26-35'
    WHEN age BETWEEN 36 AND 45 THEN '36-45'
    WHEN age BETWEEN 46 AND 60 THEN '46-60'
    ELSE '60+'
END AS age_group,
SUM(s.amount) AS total_spend
FROM spend s
JOIN customer_acquisition c
ON s.customer_id = c.customer_id
GROUP BY age_group
ORDER BY total_spend DESC;

-- =========================================
-- 1️⃣2️⃣ MOST PROFITABLE SEGMENT
-- =========================================

SELECT c.segment,
       SUM(s.amount) - SUM(r.amount) AS profit
FROM spend s
JOIN repayment r
ON s.customer_id = r.customer_id
AND s.month = r.month
JOIN customer_acquisition c
ON s.customer_id = c.customer_id
GROUP BY c.segment
ORDER BY profit DESC;

-- =========================================
-- 1️⃣3️⃣ CATEGORY SPENDING MORE
-- =========================================

SELECT type,
       SUM(amount) AS total_spend
FROM spend
GROUP BY type
ORDER BY total_spend DESC;

-- =========================================
-- 1️⃣4️⃣ MONTHLY BANK PROFIT
-- =========================================

SELECT s.month,
       SUM(s.amount) - SUM(r.amount) AS monthly_profit
FROM spend s
JOIN repayment r
ON s.customer_id = r.customer_id
AND s.month = r.month
GROUP BY s.month;

-- =========================================
-- 1️⃣5️⃣ 2.9% INTEREST ON DUE
-- =========================================

SELECT s.customer_id,
       s.month,
       SUM(s.amount) AS total_spend,
       SUM(r.amount) AS total_repayment,
       CASE
           WHEN SUM(s.amount) > SUM(r.amount)
           THEN (SUM(s.amount) - SUM(r.amount)) * 0.029
           ELSE 0
       END AS interest_amount
FROM spend s
JOIN repayment r
ON s.customer_id = r.customer_id
AND s.month = r.month
GROUP BY s.customer_id, s.month;

-- =========================================
-- END
-- =========================================