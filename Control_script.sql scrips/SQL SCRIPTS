use [Tesca_ProjControl]

Create Table Control.Environment
(
  EnvironmentID INT,
  Environment NVARCHAR(50),
  Constraint Control_Environment_pk Primary Key(EnvironmentID)
)
INSERT INTO Control.Environment(EnvironmentID, Environment)
values 
(1,'Staging'),
(2,'Edw')

Create Table Control.PackageTypes
(
 PackageTypeID INT, 
 PackageType NVARCHAR(50)
 Constraint Control_PackageTypes_pk Primary Key(PackageTypeID)
)
INSERT INTO Control.PackageTypes(PackageTypeID,PackageType)
values
(1,'Dimension'),
(2,'Fact')

Create Table Control.RunFrequences
(
 FrequenceID  INT, 
 Frequence NVARCHAR(50),
 Constraint Control_RunFrequences_pk Primary Key (FrequenceID)
)
INSERT INTO Control.RunFrequences(FrequenceID,Frequence)
values
(1, 'Daily' ),
(2, 'End of Week' ),
(3, 'End of Month' ),
(4, 'End of Quarter' ),
(5, 'End of Year' )

Create Table Control.Anomalies
(
  AnomaliesSk int identity(1,1), 
  PackageID int,
  AttributeName nvarchar(255),
  AttributeData nvarchar(255),
  LoadDate datetime,
  constraint control_anomalies_pk  primary key(AnomaliesSk),
  constraint Anomalies_packdef_fk foreign key(PackageID)  References Control.PackageDefinition(packageID)
)

select * from  control.anomalies



Create Table Control.PackageDefinition
(
 PackageID INT, 
 PackageName NVARCHAR(50),
 SequenceNo INT, 
 EnvironmentID int,
 PackageTypeID int,
 FrequenceID int,
 LastRundate datetime,
 StartRunDate date,
 EndRunDate date,
 Active bit
 Constraint Control_PackageDefinition_pk Primary Key(PackageID),
 Constraint Control_PD_Environment_fk  Foreign Key(EnvironmentID) References Control.Environment(EnvironmentID),
 Constraint Control_PD_PackageType_fk  Foreign Key(PackageTypeID) References Control.PackageTypes(PackageTypeID),
 Constraint Control_PD_Frequence_fk  Foreign Key(FrequenceID) References Control.RunFrequences(FrequenceID) 
)



 
 Select * From Control.PackageDefinition

INSERT INTO Control.PackageDefinition(PackageID,PackageName,SequenceNo,EnvironmentID,PackageTypeID,FrequenceID,StartRunDate,Active)
values
(31,'EDWOvertimeFact.dtsx',4500,2,2,1,Getdate(),1)
(30,'EDWAbsentFact.dtsx',4400,2,2,1,Getdate(),1)
(29,'EDWPurchaseTransaction.dtsx',4300,2,2,1,Getdate(),1)
(28,'EDWMisconductFact.dtsx',4200,2,2,1,Getdate(),1)
(27,'EDWSalesTransaction.dtsx',4100,2,2,1,Getdate(),1)
(26,'EDWAbsent_Category.dtsx',4000,2,1,1,Getdate(),1)
(25,'EDWDecision.dtsx',3900,2,1,1,Getdate(),1)
(24,'EDWMisconduct.dtsx',3800,2,1,1,Getdate(),1)
(23,'EDWMisconduct.dtsx',3700,2,1,1,Getdate(),1)
(22,'EDWEmployee.dtsx',3600,2,1,1,Getdate(),1)
(21,'EDWVendor.dtsx',3500,2,1,1,Getdate(),1)
(20,'EDWPOSChannel.dtsx',3400,2,1,1,Getdate(),1)
(19,'EDWCustomer.dtsx',3300,2,1,1,Getdate(),1)
(18,'EDWPromotion.dtsx',3200,2,1,1,Getdate(),1)
(17,'EDWProduct.dtsx',3100,2,1,1,Getdate(),1),
(16,'EDWStore.dtsx',3000,2,1,1,Getdate(),1),
(15,'StagingOvertimeFact.dtsx',1500,1,2,1,Getdate(),1),
(14,'StagingMisconductFact.dtsx',1400,1,2,1,Getdate(),1),
(13,'StagingAbsentFact.dtsx',1300,1,2,1,Getdate(),1)
(12,'StagingPurchase.dtsx',1200,1,2,1,Getdate(),1),
(11,'StagingSales.dtsx',1100,1,2,1,Getdate(),1)
(10,'StagingAbsent.dtsx',1000,1,1,1,Getdate(),1),
(9,'StagingDecision.dtsx',900,1,1,1,Getdate(),1),
(8,'StagingMisconduct.dtsx',800,1,1,1,Getdate(),1),
(7,'StagingCustomer.dtsx',700,1,1,1,Getdate(),1),
(6,'StagingPOSChannel.dtsx',600,1,1,1,Getdate(),1),
(5,'StagingPromotion.dtsx',500,1,1,1,Getdate(),1),
(4,'StagingEmployee.dtsx',400,1,1,1,Getdate(),1),
(3,'StagingVendor.dtsx',300,1,1,1,Getdate(),1),
(2,'StagingProduct.dtsx',200,1,1,1,Getdate(),1),
(1,'StagingStore.dtsx',100,1,1,1,Getdate(),1)


 USE [Tesca_ProjControl]

Create Table Control.Metrics
( 
  Metricid Bigint Identity(1,1),
  PackageID INT,
  Pre_Count INT,
  Current_Count INT,
  Type1_Count INT,
  Type2_Count INT, 
  Post_Count INT,
  LoadDate Datetime default Getdate(),
  Constraint Control_Metric_pk Primary Key(Metricid),
  Constraint Control_Metric_Package_fk Foreign Key(PackageID) References Control.PackageDefinition(PackageID)
)

 Select * From Control.Metrics

 --------LookUp Array for Anomalies--------
SELECT VendorSK, VendorID From [Edw].[Vendor];
SELECT StoreSK,StoreID FROM [Edw].[Store];
SELECT PromotionSK, PromotionID FROM [Edw].[Promotion];
SELECT ProductSK, ProductID FROM [Edw].[Product];
SELECT CHANNELSK, CHANNELID FROM [Edw].[POSChannel];
SELECT MisconductSK, MisconductID FROM [Edw].[Misconduct];
SELECT EMPLOYEESK, EMPLOYEEno FROM [Edw].[Employee];
SELECT Timekey, Hour FROM [Edw].[DimTime];
SELECT DATEKEY, Date FROM [Edw].[DimDate];
SELECT DecisionSK, DecisionID FROM [Edw].[Decision];
SELECT CustomerSK, CUSTOMERID FROM [Edw].[Customer];
SELECT Absent_CategorySK, Absent_CategoryID FROM [Edw].[Absent_Category];

-- Capture  Staging------     
ALTER TABLE Control.Metrics ALTER Column Evaluation NVARCHAR(50)
Declare @PackageID INT = ?
Declare @PreCount INT = ?
Declare @CurrentCount INT = ?
Declare @PostCount INT = ?
Declare @Evaluation Nvarchar(50) 
SET @Evaluation = Case When (@PreCount + @CurrentCount) = @PostCount THEN 'PASSED' 
	                           ELSE 'FAILED' END 

INSERT INTO Control.Metrics (PackageID, Pre_Count, Current_Count, Post_Count,Evaluation ) 
                             SELECT @PackageID, @PreCount, @CurrentCount, @PostCount, @Evaluation	        

					         UPDATE Control.PackageDefinition
					        SET LastRundate = GETDATE()
						    WHERE PackageID = @PackageID

						    UPDATE Control.PackageDefinition
					        SET Active = 0
						    WHERE EndRunDate <= Convert(Date,Getdate()) 
							
						    UPDATE Control.PackageDefinition
					        SET Active = 1
						    WHERE EndRunDate IS Null OR EndRunDate > Convert(Date,Getdate())
							

-- Capture  Edw Dimensions Metics ------

Declare @PackageID INT=?
Declare @PreCount INT=?
Declare @CurrentCount INT=?
Declare @Type1_Count INT= ?
Declare @Type2_Count INT=?
Declare @PostCount INT=?
Declare @Evaluation Nvarchar(50) 
SET @Evaluation = Case When (@PreCount + @CurrentCount +  ISNULL(@Type2_Count,0)) = @PostCount THEN 'PASSED' 
	                           ELSE 'FAILED' END

INSERT INTO Control.Metrics (PackageID, Pre_Count, Current_Count,Type1_Count, Type2_Count, Post_Count, Evaluation) 
                       SELECT @PackageID, @PreCount, @CurrentCount,@Type1_Count, @Type2_Count, @PostCount, @Evaluation

					        UPDATE Control.PackageDefinition
					        SET LastRundate = GETDATE()
						    WHERE PackageID = @PackageID 

						    UPDATE Control.PackageDefinition
					        SET Active = 0
						    WHERE EndRunDate <= Convert(Date,Getdate()) 
							
						    UPDATE Control.PackageDefinition
					        SET Active = 1
						    WHERE EndRunDate IS Null OR EndRunDate > Convert(Date,Getdate())



------Running the staging ETL Pipeline all together-------
Create Procedure Package_list 
AS
Begin
SELECT PackageID, PackageName
 FROM
(---Daily Run
SELECT PackageID, PackageName, SequenceNo
FROM Control.PackageDefinition 
WHERE EnvironmentID = 1 AND FrequenceID = 1 AND StartRunDate <= Convert(Date,Getdate()) 
      AND EndRunDate IS NULL OR EndRunDate >= Convert(Date,Getdate())
	  UNION ALL
-----END OF WEEK Run------
SELECT PackageID, PackageName, SequenceNo
FROM Control.PackageDefinition 
WHERE EnvironmentID = 1 AND FrequenceID = 2 AND StartRunDate <= Convert(Date,Getdate()) 
      AND EndRunDate IS NULL OR EndRunDate >= Convert(Date,Getdate()) 
	  AND DATEPART(WEEKDAY, GETDATE()) = 7
     UNION ALL
-----END OF MONTH Run------
SELECT PackageID, PackageName, SequenceNo
FROM Control.PackageDefinition 
WHERE EnvironmentID = 1 AND FrequenceID = 3 AND StartRunDate <= Convert(Date,Getdate()) 
      AND EndRunDate IS NULL OR EndRunDate >= Convert(Date,Getdate()) 
	  AND EOMONTH(Getdate()) = Convert(Date,Getdate()) 
	   UNION ALL
-----END OF Quater Run------
SELECT PackageID, PackageName, SequenceNo
FROM Control.PackageDefinition 
WHERE EnvironmentID = 1 AND FrequenceID = 4 AND StartRunDate <= Convert(Date,Getdate()) 
      AND EndRunDate IS NULL OR EndRunDate >= Convert(Date,Getdate())
	  AND EOMONTH(Getdate()) = Convert(Date,Getdate()) 
	  AND Datepart(Month,Getdate()) IN (3,6,9,12)
	 UNION ALL
-----END OF Quater Run------
SELECT PackageID, PackageName, SequenceNo
FROM Control.PackageDefinition 
WHERE EnvironmentID = 1 AND FrequenceID = 5 AND StartRunDate <= Convert(Date,Getdate()) 
      AND EndRunDate IS NULL OR EndRunDate >= Convert(Date,Getdate())
	  AND EOMONTH(Getdate()) = Convert(Date,Getdate())
	  AND Datepart(Month,Getdate()) = 12
	  ) Run_Procedure
ORDER BY SequenceNo ASC
END;

EXEC Package_list


------Running the EDW ETL Pipeline all together-------

SELECT PackageID, PackageName
 FROM
(---Daily Run
SELECT PackageID, PackageName, SequenceNo
FROM Control.PackageDefinition 
WHERE EnvironmentID = 2 AND FrequenceID = 1 AND StartRunDate <= Convert(Date,Getdate()) 
      AND EndRunDate IS NULL OR EndRunDate >= Convert(Date,Getdate())
	  UNION ALL
-----END OF WEEK Run------
SELECT PackageID, PackageName, SequenceNo
FROM Control.PackageDefinition 
WHERE EnvironmentID = 2 AND FrequenceID = 2 AND StartRunDate <= Convert(Date,Getdate()) 
      AND EndRunDate IS NULL OR EndRunDate >= Convert(Date,Getdate()) 
	  AND DATEPART(WEEKDAY, GETDATE()) = 7
     UNION ALL
-----END OF MONTH Run------
SELECT PackageID, PackageName, SequenceNo
FROM Control.PackageDefinition 
WHERE EnvironmentID = 2 AND FrequenceID = 3 AND StartRunDate <= Convert(Date,Getdate()) 
      AND EndRunDate IS NULL OR EndRunDate >= Convert(Date,Getdate()) 
	  AND EOMONTH(Getdate()) = Convert(Date,Getdate()) 
	   UNION ALL
-----END OF Quater Run------
SELECT PackageID, PackageName, SequenceNo
FROM Control.PackageDefinition 
WHERE EnvironmentID = 2 AND FrequenceID = 4 AND StartRunDate <= Convert(Date,Getdate()) 
      AND EndRunDate IS NULL OR EndRunDate >= Convert(Date,Getdate())
	  AND EOMONTH(Getdate()) = Convert(Date,Getdate()) 
	  AND Datepart(Month,Getdate()) IN (3,6,9,12)
	 UNION ALL
-----END OF Quater Run------
SELECT PackageID, PackageName, SequenceNo
FROM Control.PackageDefinition 
WHERE EnvironmentID = 2 AND FrequenceID = 5 AND StartRunDate <= Convert(Date,Getdate()) 
      AND EndRunDate IS NULL OR EndRunDate >= Convert(Date,Getdate())
	  AND EOMONTH(Getdate()) = Convert(Date,Getdate())
	  AND Datepart(Month,Getdate()) = 12
	  ) Run_Procedure
ORDER BY SequenceNo ASC

-- Capture  Edw Fact Metrics-----

Declare @PackageID INT=?
Declare @PreCount INT=?
Declare @CurrentCount INT=?
Declare @PostCount INT=?

INSERT INTO Control.Metrics(PackageID, Pre_Count, Current_Count, Post_Count) 
                       SELECT @PackageID, @PreCount, @CurrentCount, @PostCount

					   UPDATE Control.PackageDefinition
					    SET LastRundate = GETDATE()
						WHERE PackageID = @PackageID






	/* EDW  pipeline control runs */

select PackageID, PackageName from 
(
	select PackageID, PackageName,sequenceNo from control.packageDefinition
	Where  FrequenceID=1 and active= 1  and envronid=2
	and  (StartRunDate<=convert(date,getdate())) 
	and (EndRundate>=convert(date,getdate()) or EndRunDate is null)
	union all 
	select PackageID, PackageName,sequenceNo  from control.packageDefinition
	Where  FrequenceID=2 and active= 1   and envronid=2
	and  (StartRunDate<=convert(date,getdate())) 
	and (EndRundate>=convert(date,getdate()) or EndRunDate is null)
	and  DATEPART(WEEKDAY, getdate()) =7
	union all 
	select PackageID, PackageName,sequenceNo  from control.packageDefinition
	Where  FrequenceID=3 and active= 1  and envronid=2
	and  (StartRunDate<=convert(date,getdate())) 
	and (EndRundate>=convert(date,getdate()) or EndRunDate is null)
	and  EOMONTH(getdate())=convert(date, getdate())
	union all 
	select PackageID, PackageName,sequenceNo  from control.packageDefinition
	Where  FrequenceID=4 and active= 1  and envronid=2
	and  (StartRunDate<=convert(date,getdate())) 
	and (EndRundate>=convert(date,getdate()) or EndRunDate is null)
	and  EOMONTH(getdate())=convert(date, getdate()) and  DATEPART(QUARTER, getdate()) in (3,6,9,12)
	and DATEPART(month,Getdate()) in (3,6,9,12)
	union all 
	select PackageID, PackageName,sequenceNo from control.packageDefinition
	Where  FrequenceID=5 and active= 1  and envronid=2
	and  (StartRunDate<=convert(date,getdate())) 
	and (EndRundate>=convert(date,getdate()) or EndRunDate is null)
	and  EOMONTH(getdate())=convert(date, getdate()) and DATEPART(month,Getdate()) =12
	) sq
	order by sq.sequenceNo




