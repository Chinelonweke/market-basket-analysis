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
   





