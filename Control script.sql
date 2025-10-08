USE [Tesca_ProjOLTP]
GO
CREATE PROCEDURE YOY_TOP5 AS
BEGIN 

DROP TABLE IF EXISTS ##Staging_YOY_Top5; 

-- Mapping all dataset needed into a Temporary Staging table
SELECT * INTO ##Staging_YOY_Top5 FROM(
  SELECT p.ProductID, 
       Product,Department, TransDate,UnitPrice, Quantity
  FROM  [dbo].[SalesTransaction] s
	     INNER JOIN Product p
	     ON p.ProductID = s.ProductID
		 INNER JOIN Department d
	     ON d.departmentID = p.DepartmentID
) aa;

DROP TABLE IF EXISTS ##YOY_Top5_Analysis;

/*Cleaning and analysing for top 5 product is each department for each year in the dataset. 
 And also the YOY analysis with the percentage change */
WITH Aggregation AS(
              SELECT Department, 
	                 Product, YEAR(TransDate) TransYear 
			         ,SUM(Quantity *UnitPrice) Revenue
			         ,SUM(Quantity)Quantity
	         FROM  ##Staging_YOY_Top5
	         GROUP BY Department, Product,YEAR(TransDate)
    ),
       Ranking AS( 
              SELECT DENSE_RANK() OVER(PARTITION BY Department,TransYear ORDER BY Revenue DESC, Quantity DESC) Performance_Rank, 
	                  Department, Product, TransYear, Revenue,Quantity
	          FROM Aggregation
    ),
        T_five AS(
               SELECT Performance_Rank, 
			          Department, Product, TransYear, Revenue,
			          ISNULL(LAG(Revenue) OVER(PARTITION BY Department, Product ORDER BY TransYear),0) PreviouYear_Revenue,Quantity,
	                  ISNULL(LAG(Quantity) OVER(PARTITION BY Department, Product ORDER BY TransYear),0) PreviouYear_Quantity
	           FROM Ranking
	           WHERE Performance_Rank <= 5
    )
               SELECT  Performance_Rank,
			           Department, Product, TransYear, 
					   FORMAT(Revenue,'c') Revenue,
					   FORMAT(PreviouYear_Revenue,'c') PreviouYear_Revenue,	
					   FORMAT(CASE 
					              WHEN PreviouYear_Revenue = 0 
								    THEN 1 ELSE (Revenue - PreviouYear_Revenue) / PreviouYear_Revenue
									  END,'p') AS RevPer_change,
	                   Quantity,PreviouYear_Quantity,
					   FORMAT(CASE 
					              WHEN PreviouYear_Quantity = 0 
								     THEN 1 ELSE (Quantity - PreviouYear_Quantity) / PreviouYear_Quantity 
									   END,'p') AS QtyPer_change
-- Mapping the analysed dataset into the target destination
				INTO ##YOY_Top5_Analysis
	           FROM T_five
	           ORDER BY Department, TransYear, Performance_Rank;
	 
   DROP TABLE ##Staging_YOY_Top5;

   SELECT * FROM ##YOY_Top5_Analysis
   ORDER BY Department, TransYear, Performance_Rank;
END;


EXEC YOY_TOP5
