-- Market basket analysis --
--support, confidence and lift are called association rule in BMA which is what we will calculate
-- Support = (frequency  of productsA&B / Total number of transaction * 100 --
-- Confidence = (frequency of  both products / frequency of the product on the LHS) * 100 --
-- Lift = Support (both products) / (support(productA) * support(productB))
  


SELECT * FROM [Transaction data]

SELECT Products
FROM [Transaction data]

-- bring out the product table side by side--
-- Rename the the two product tables as T1 7 T2 which the same to make them unique
SELECT T1.Products as Product1, T2.Products as Product2
FROM [Transaction data] as T1
JOIN [Transaction data] as T2
ON T1.Transaction_ID = T2.Transaction_ID

-- to make the products not be the same on both tables
-- this will make sure that no two products are repeated on both tables
SELECT T1.Products as Product1, T2.Products as Product2
FROM [Transaction data] as T1
JOIN [Transaction data] as T2
ON T1.Transaction_ID = T2.Transaction_ID
WHERE T1.Products > T2.Products


-- Calculate the frequency or number of times both products were bought together using the COUNT --
SELECT T1.Products as Product1, T2.Products as Product2,
    COUNT(1) as frequency
FROM [Transaction data] as T1
JOIN [Transaction data] as T2
ON T1.Transaction_ID = T2.Transaction_ID
WHERE T1.Products > T2.Products
GROUP BY T1.Products, T2.Products

-- Before calculating the support--
-- First, i will calcualte the total number of transaction --
SELECT T1.Products as Product1, T2.Products as Product2,
    COUNT(1) as frequency,
	(SELECT COUNT(Transaction_ID) FROM Retail_Transactions_Dataset) as Total_transation
FROM [Transaction data] as T1
JOIN [Transaction data] as T2
ON T1.Transaction_ID = T2.Transaction_ID
WHERE T1.Products > T2.Products
GROUP BY T1.Products, T2.Products

-- Give the table of the code above a special name
WITH Market as (
SELECT T1.Products as Product1, T2.Products as Product2,
    COUNT(1) as frequency,
	(SELECT COUNT(Transaction_ID) FROM Retail_Transactions_Dataset) as Total_transaction
FROM [Transaction data] as T1
JOIN [Transaction data] as T2
ON T1.Transaction_ID = T2.Transaction_ID
WHERE T1.Products > T2.Products
GROUP BY T1.Products, T2.Products
)
-- the code below is just to confirm the market created is functioning well.
SELECT product1, product2, frequency
FROM Market

--SUPPORT CALCULATE
WITH Market as (
SELECT T1.Products as Product1, T2.Products as Product2,
    COUNT(1) as frequency,
	(SELECT COUNT(Transaction_ID) FROM Retail_Transactions_Dataset) as Total_transaction
FROM [Transaction data] as T1
JOIN [Transaction data] as T2
ON T1.Transaction_ID = T2.Transaction_ID
WHERE T1.Products > T2.Products
GROUP BY T1.Products, T2.Products
)
SELECT Product1, 
       Product2, 
	   frequency,Total_transaction,
	   FORMAT((frequency*100.00)/Total_transaction, '0.##') as support
FROM Market


-- to format it to a 2decimal point
WITH Market as (
SELECT T1.Products as Product1, T2.Products as Product2,
    COUNT(1) as frequency,
	(SELECT COUNT(Transaction_ID) FROM Retail_Transactions_Dataset) as Total_transaction
FROM [Transaction data] as T1
JOIN [Transaction data] as T2
ON T1.Transaction_ID = T2.Transaction_ID
WHERE T1.Products > T2.Products
GROUP BY T1.Products, T2.Products
)
SELECT Product1, 
       Product2, 
	   frequency,
	  CAST(((frequency*100.00)/Total_transaction) as DECIMAL(10,2)) as support

FROM Market


-- CONFIDENCE CALCULATION
-- Firstly, calcualte the frequency of the product on the LHS(lefthand side) then confidence

WITH Market as (
SELECT T1.Products as Product1, T2.Products as Product2,
    COUNT(1) as frequency,
	(SELECT COUNT(Transaction_ID) FROM Retail_Transactions_Dataset) as Total_transaction,
	(SELECT COUNT(Transaction_ID) FROM Retail_Transactions_Dataset e WHERE T1.Products = e.Product) as frequency_lhs
FROM [Transaction data] as T1
JOIN [Transaction data] as T2
ON T1.Transaction_ID = T2.Transaction_ID
WHERE T1.Products > T2.Products
GROUP BY T1.Products, T2.Products
)
SELECT Product1, 
       Product2, 
	   frequency,
	   CAST(((frequency*100.00)/Total_transaction) as DECIMAL(10,2)) as support,
	  CAST(((frequency*100.00)/Total_transaction) as DECIMAL(10,2)) as confidence

FROM Market;

--LIFT CALCULATION
-- First, calculate support(productA)
WITH Market as (
SELECT T1.Products as Product1, T2.Products as Product2,
    COUNT(1) as frequency,
	(SELECT COUNT(Transaction_ID) FROM Transaction_data) as Total_transaction,
	(SELECT COUNT(Transaction_ID) FROM Transaction_data e WHERE T1.Products = e.Products) as frequency_lhs,
	(SELECT COUNT(Transaction_ID) FROM Transaction_data e WHERE T2.Products = e.Products) as frequency_rhs
FROM [Transaction data] as T1
JOIN [Transaction data] as T2
ON T1.Transaction_ID = T2.Transaction_ID
WHERE T1.Products > T2.Products
GROUP BY T1.Products, T2.Products
)
SELECT Product1, 
       Product2, 
	   frequency,
	  frequency*100 as "frequency_%",
	  Total_transaction,
	  frequency_lhs,
	  frequency_rhs,
	 CAST(((frequency*100.00)/Total_transaction) as DECIMAL(5,2)) as support,
	 CAST(((frequency*100.00)/Total_transaction) as DECIMAL(5,2)) as confidence,
     CAST(((frequency*100.00)/Total_transaction) / 
	 ((frequency_lhs * 100) / Total_transaction) *
	 ((frequency_rhs * 100) / Total_transaction)as DECIMAL(5,2)) as lift
   FROM Market  
   ORDER BY frequency DESC;
   




