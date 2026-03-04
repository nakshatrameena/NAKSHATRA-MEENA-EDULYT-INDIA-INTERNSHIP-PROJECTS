
/*
=========================================================
EDULYT INDIA - SQL PROJECT SUBMISSION
Sanity Checks, Data Cleaning & Customer Analytics
=========================================================
*/

---------------------------------------------------------
-- 1. DATA CLEANING & SANITY CHECKS
---------------------------------------------------------

-- 1.1 Replace Blank Credit Card Entries
UPDATE Project_2
SET Credit_card = 'UNKNOWN'
WHERE Credit_card IS NULL OR Credit_card = '';

-- 1.2 Apply 5% Discount where Coupon exists but no discount applied
UPDATE Project_2
SET Selling_price = Price * 0.95
WHERE Coupon_ID IS NOT NULL
  AND Price = Selling_price;

-- 1.3 Validate Return Date
SELECT *
FROM Project_2
WHERE Return_ind = 'Yes'
  AND Return_date <= Date;

-- 1.4 If Coupon is NULL → No Discount
UPDATE Project_2
SET Selling_price = Price
WHERE Coupon_ID IS NULL;

-- 1.5 Validate Age > 18
SELECT *
FROM Customer_Info
WHERE Age <= 18;

-- 1.6 Check Transaction ID Uniqueness
SELECT `Transaction ID`, COUNT(*)
FROM Project_2
GROUP BY `Transaction ID`
HAVING COUNT(*) > 1;

---------------------------------------------------------
-- 2. CUSTOMER SEGMENTATION
---------------------------------------------------------

SELECT 
    C.C_ID,
    C.Gender,
    CASE 
        WHEN C.Age BETWEEN 18 AND 30 THEN 'Young'
        WHEN C.Age BETWEEN 31 AND 50 THEN 'Mid Age'
        ELSE 'Old'
    END AS Age_Group,
    SUM(P.Selling_price) AS Total_Spend
FROM Project_2 P
JOIN Customer_Info C
ON P.Credit_card = C.C_ID
GROUP BY C.C_ID, C.Gender, Age_Group
ORDER BY Total_Spend DESC;

---------------------------------------------------------
-- 3. SPEND ANALYSIS
---------------------------------------------------------

-- Spend by Product Category
SELECT P_CATEGORY,
       SUM(Selling_price) AS Total_Spend
FROM Project_2
GROUP BY P_CATEGORY
ORDER BY Total_Spend DESC;

-- Spend by State
SELECT C.State,
       SUM(P.Selling_price) AS Total_Spend
FROM Project_2 P
JOIN Customer_Info C
ON P.Credit_card = C.C_ID
GROUP BY C.State
ORDER BY Total_Spend DESC;

-- Spend by Payment Method
SELECT `Payment method`,
       SUM(Selling_price) AS Total_Spend
FROM Project_2
GROUP BY `Payment method`
ORDER BY Total_Spend DESC;

---------------------------------------------------------
-- 4. TOP 5 ANALYSIS
---------------------------------------------------------

-- Top 5 Customers
SELECT C.Name,
       SUM(P.Selling_price) AS Total_Spend
FROM Project_2 P
JOIN Customer_Info C
ON P.Credit_card = C.C_ID
GROUP BY C.Name
ORDER BY Total_Spend DESC
LIMIT 5;

-- Top 5 States
SELECT C.State,
       SUM(P.Selling_price) AS Total_Spend
FROM Project_2 P
JOIN Customer_Info C
ON P.Credit_card = C.C_ID
GROUP BY C.State
ORDER BY Total_Spend DESC
LIMIT 5;

-- Top 5 Product Categories
SELECT P_CATEGORY,
       SUM(Selling_price) AS Total_Spend
FROM Project_2
GROUP BY P_CATEGORY
ORDER BY Total_Spend DESC
LIMIT 5;

---------------------------------------------------------
-- 5. RETURNS ANALYSIS
---------------------------------------------------------

-- Returns by State
SELECT C.State,
       COUNT(*) AS Total_Returns
FROM Project_2 P
JOIN Customer_Info C
ON P.Credit_card = C.C_ID
WHERE Return_ind = 'Yes'
GROUP BY C.State
ORDER BY Total_Returns DESC;

-- Returns by Age Group
SELECT 
    CASE 
        WHEN C.Age BETWEEN 18 AND 30 THEN 'Young'
        WHEN C.Age BETWEEN 31 AND 50 THEN 'Mid Age'
        ELSE 'Old'
    END AS Age_Group,
    COUNT(*) AS Total_Returns
FROM Project_2 P
JOIN Customer_Info C
ON P.Credit_card = C.C_ID
WHERE Return_ind = 'Yes'
GROUP BY Age_Group;

-- Returns vs Discount
SELECT 
    CASE 
        WHEN Coupon_ID IS NULL THEN 'No Discount'
        ELSE 'Discount Applied'
    END AS Discount_Status,
    COUNT(*) AS Return_Count
FROM Project_2
WHERE Return_ind = 'Yes'
GROUP BY Discount_Status;

---------------------------------------------------------
-- 6. ORDER TIMING PROFILE
---------------------------------------------------------

-- Orders by Hour
SELECT 
    EXTRACT(HOUR FROM Time) AS Order_Hour,
    COUNT(*) AS Total_Orders
FROM Project_2
GROUP BY Order_Hour
ORDER BY Order_Hour;

-- Orders by Day
SELECT 
    DAYNAME(Date) AS Order_Day,
    COUNT(*) AS Total_Orders
FROM Project_2
GROUP BY Order_Day
ORDER BY Total_Orders DESC;

---------------------------------------------------------
-- 7. PAYMENT METHOD DISCOUNT ANALYSIS
---------------------------------------------------------

SELECT 
    `Payment method`,
    SUM(Price - Selling_price) AS Total_Discount
FROM Project_2
GROUP BY `Payment method`
ORDER BY Total_Discount DESC;

---------------------------------------------------------
-- 8. HIGH VALUE vs LOW VALUE PROFILING
---------------------------------------------------------

SELECT 
    CASE 
        WHEN Selling_price >= 1000 THEN 'High Value'
        ELSE 'Low Value'
    END AS Value_Category,
    COUNT(*) AS Total_Orders,
    SUM(Selling_price) AS Total_Revenue
FROM Project_2
GROUP BY Value_Category;

---------------------------------------------------------
-- 9. DISCOUNT IMPACT ON ORDERS
---------------------------------------------------------

SELECT 
    CASE 
        WHEN Coupon_ID IS NULL THEN 'No Discount'
        ELSE 'Discount'
    END AS Discount_Status,
    COUNT(*) AS Total_Orders,
    SUM(Selling_price) AS Total_Revenue
FROM Project_2
GROUP BY Discount_Status;

