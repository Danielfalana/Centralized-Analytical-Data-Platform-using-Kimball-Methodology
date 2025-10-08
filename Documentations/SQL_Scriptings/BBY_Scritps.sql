WITH Groupin AS(
       SELECT YEAR(OrderDate) Year,
	          Country, ProductName, 
			  SUM(OrderQty*UnitPrice) LineAmount, 
			  SUM(OrderQty) Total_Qty
       FROM [dbo].[Purchasetrans] pt
                 INNER JOIN Products p
                 ON p.ProductID = pt.ProductID 
       GROUP BY  Country, ProductName, YEAR(OrderDate) 
),
 PreviousYear AS(
       SELECT Year,
	          Country, 
			  ProductName,LineAmount, 
			  ISNULL(LAG(LineAmount) OVER(PARTITION BY Country, ProductName Order by Year),0) PreviousYearLineTotal,
              Total_Qty, 
			  ISNULL(LAG(Total_Qty) OVER(PARTITION BY Country, ProductName Order by Year),0) PreviousYearQtyTotal
 FROM Groupin
 ),
 Diff AS(
       SELECT Year,
	          Country, ProductName,LineAmount, 
			  PreviousYearLineTotal, 
			  (LineAmount- PreviousYearLineTotal) AS LineAmount_Diff
	         ,Total_Qty, PreviousYearQtyTotal , (Total_Qty - PreviousYearQtyTotal) AS TotalQty_Diff
 FROM PreviousYear
),
 Per_Change1 AS(
      SELECT Year,Country,
	         ProductName, FORMAT(LineAmount,'c') LineAmount, 
			 FORMAT(PreviousYearLineTotal,'c') PreviousYearLineTotal, 
			 FORMAT(LineAmount_Diff,'c') LineAmount_Diff,
             FORMAT(CASE 
			          WHEN PreviousYearLineTotal  = 0 THEN 1 
			          ELSE LineAmount_Diff / PreviousYearLineTotal 
			        END,'p') AS  LineAmountPer_diff
           ,Total_Qty, PreviousYearQtyTotal, TotalQty_Diff,
		    FORMAT(CASE
		             WHEN PreviousYearQtyTotal  = 0 THEN 1
			         ELSE TotalQty_Diff / PreviousYearQtyTotal
		          END,'p') AS QtyPer_diff 
FROM Diff
)
             SELECT Year,Country, ProductName,
			 LineAmount,PreviousYearLineTotal, LineAmount_Diff,
			 LineAmountPer_diff,Total_Qty, PreviousYearQtyTotal,
			 TotalQty_Diff,QtyPer_diff,
			 CASE 
			    WHEN LineAmountPer_diff = QtyPer_diff THEN 'Passed' 
				ELSE 'INVESTIGATE' 
			END Status
FROM Per_Change1