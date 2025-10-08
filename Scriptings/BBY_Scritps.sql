/*
Dimension Tables for Both the STAGING and EDW and Scripting for Extractions

Dim_Date Table
Dim_Time Table
Retail.Store and Edw.Store 
Retail.Product and Edw.Product 
Retail.Promotion and Edw.Promotion 
Retail.Customer and Edw.Customer 
Retail.POSChannel and Edw.POSChannel
Retail.Vendor and Edw.Vendor 
Retail.Employee and Edw.Employee 
HR.Misconduct and Edw.Misconduct 
HR.Decision and Edw.Decision
HR.Absent_Category and Edw.Absent_Category

*/

-- Dim_Date Table Creation

Create Table [Tesca_ProjEdw].edw.DimDate(
                     DateKey INT,
					 [Date] Date,
					 [Day] INT,
					 [DayName] Nvarchar(50),
					 [Weekday] INT,
					 [WEEKNUMBER] INT,
				     [WEEKEND/Weekday] Nvarchar (10),
					 MonthNumber INT,
					 [MonthName] Nvarchar(50),
					 [DayOfYear] INT Default NULL,
					 [Quarter] Nvarchar(10),
					 [Year] INT,
					 LastAdjusted Datetime,
					 Constraint Edw_dimdateKey Primary key(DateKey)
					 )

-- DimDate_Table Population
 Create Procedure edw_pro @Year INT
  AS 
 BEGIN
     Declare @startdate date = (Select Min(Orderdate) from [SalesTransaction]);
     Declare @Enddate  dATE
     SET @Enddate = (Select Datefromparts(@Year, 12, 31))
    While @startdate <= @Enddate
      Begin
             Insert Into Tesca_ProjEdw.edw.DimDate (DateKey, [Date],[Day] ,[DayName] ,[Weekday] , [WEEKNUMBER] , 
	                                               [WEEKEND/Weekday], MonthNumber, [MonthName], 
												   [Quarter], [Year],LastAdjusted)
	          Select Cast(Replace(@startdate, '-','')as INT), @startdate,
	                 DATEPART(day,@startdate),
					 DATEname(weekday,@startdate), 
					 DATEpart(WEEKDAY,@startdate),
					 DATEPART(WEEK,@startdate),
	                 Case When  DATEpart(WEEKDAY,@startdate) IN (1,7) THEN 'Weekend' ELSE 'Weekday' END,
					 Month(@startdate),
					DateName(Month, @startdate), 
					'Q'+Cast(Datepart(Quarter,@startdate)as nvarchar),
			         Year(@startdate), 
				    Getdate(); 
			  set @startdate = Dateadd(day ,1 ,@startdate ) ;
   	END;
 END;
       EXEC edw_pro @Year = 2040;

-- Dim_Time Table Creation
  
  Create Table [Tesca_ProjEdw].edw.DimTime(
                                     TimeKey INT Identity(1,1),
									 [Hour] INT,
									 PeriodOfday Nvarchar(20),
									 LastAdjusted Datetime,
									 Constraint EDW_TimeKey Primary Key(TimeKey)
									 )
  -- DimTimeTable Population

  Declare @MinHour INT = 0
  Declare @MaxHour INT= 24
  While @MinHour < @MaxHour
    BEGIN
	    INSERT INTO [Tesca_ProjEdw].edw.DimTime ([Hour] ,PeriodOfday,LastAdjusted)
		SELECT @MinHour, 
		        Case WHEN @MinHour BETWEEN 0 AND 3 THEN 'MidNight'
				     WHEN @MinHour BETWEEN 4 AND 6 THEN 'Early Morning'
					 WHEN @MinHour BETWEEN 7 AND 11 THEN 'Morning'
					 WHEN @MinHour = 12 THEN 'Noon'
					 WHEN @MinHour  BETWEEN 13 AND 16 THEN 'Afternoon'
					 WHEN @MinHour BETWEEN 17 AND 20 THEN 'Evening'
					 WHEN @MinHour BETWEEN 21 AND 23 THEN 'Night'
				END,
				GETDATE()
		set @MinHour = @MinHour +1
	END;

 -------------Store------
 -- Extraction Script from the source system into staging--

 Use Tesca_ProjOLTP

 SELECT StoreID, StoreName, StreetAddress, CityName, State
 FROM Store 
    INNER JOIN City
	ON City.CityID = Store.CityID
	INNER JOIN State
	ON City.StateID = State.StateID

-----Create Staging Table for Store
Use Tesca_ProjStaging

Create Table Retail.Store(
                      StoreID INT,
					  StoreName NVARCHAR(50),
					  StreetAddress NVARCHAR (250),
					  CityName NVARCHAR (50),
					  State NVARCHAR (50),
					  LoadDate DATETIME DEFAULT GETDATE(),
					  Constraint Retail_StoreID_pk Primary Key (StoreID)
					  )
---- Truncate Retail.Store if Exist-----

If OBJECT_ID('Retail.Store') IS NOT NULL
TRUNCATE TABLE Retail.Store

------ Store Retail PreCount-------
Select Count(*) Pre_Count From Retail.Store
------- Store Retail PostCount--------
Select Count(*) Post_Count From Retail.Store

----Extraction Script from Staging into EDW-----

 SELECT StoreID, StoreName, StreetAddress, CityName, State
 FROM Retail.Store 

-----Create EDW Table for Store
Use Tesca_ProjEdw

Create Table Edw.Store(
                      StoreSK INT IDENTITY(1,1),
                      StoreID INT,
					  StoreName NVARCHAR(50),
					  StreetAddress NVARCHAR (250),
					  CityName NVARCHAR (50),
					  State NVARCHAR (50),
					  LastAdjusted DATETIME DEFAULT Getdate(),
					  Constraint EDW_StoreSK_pk Primary Key (StoreSK)
					  )
------ Store EWD PreCount-------

Select Count(*) Pre_Count From  Edw.Store
------- Store EWD PostCount--------
Select Count(*) PostCount From  Edw.Store

-------------Product------
 -- Extraction Script from the source system into staging--

 Use Tesca_ProjOLTP

 SELECT ProductID, Product, ProductNumber,UnitPrice, Department
 FROM Product 
    INNER JOIN Department
	ON Product.DepartmentID = Department.DepartmentID
	

-----Create Staging Table for Product
Use Tesca_ProjStaging

Create Table Retail.Product(
                      ProductID INT,
					  Product NVARCHAR(50),
					  ProductNumber NVARCHAR (50),
					  UnitPrice Float,
					  Department NVARCHAR (50),
					  LoadDate DATETIME DEFAULT GETDATE(),
					  Constraint Retail_ProductID_pk Primary Key (ProductID)
					  )
---- Truncate Retail.Product if Exist-----

If OBJECT_ID('Retail.Product') IS NOT NULL
TRUNCATE TABLE Retail.Product

------ Product Retail PreCount-------
Select  Count(*) Pre_Count From Retail.Product
------- Product Retail PostCount--------
Select  Count(*) Post_Count From Retail.Product

----Extraction Script from Staging into EDW-----
 SELECT ProductID, Product, ProductNumber, UnitPrice, Department
 FROM Retail.Product 

-----Create EDW Table for Product
Use Tesca_ProjEdw

Create Table Edw.Product(
                      ProductSK INT IDENTITY(1,1),
                      ProductID INT,
					  Product NVARCHAR(50),
					  ProductNumber NVARCHAR (50),
					  UnitPrice Float,
					  Department NVARCHAR (50),
					  StartDate Datetime,
					  EndDate DateTime,
					  Active BIT,
					  Constraint EDW_ProductSK_pk Primary Key (ProductSK)
					  )

------ Product Edw PreCount-------
Select  Count(*) Pre_Count From Edw.Product
------- Product Retail PostCount--------
Select  Count(*) Post_Count From Edw.Product

-------------Promotion------
 -- Extraction Script from the source system into staging--

 Use Tesca_ProjOLTP

 SELECT PromotionID,StartDate, EndDate, Promotion, DiscountPercent
 FROM Promotion 
    INNER JOIN PromotionType
	ON PromotionType.PromotionTypeID = Promotion.PromotionTypeID
	

-----Create Staging Table for Promotion
Use Tesca_ProjStaging

Create Table Retail.Promotion(
                      PromotionID INT,
					  StartDate DATE,
					  EndDate DATE,
					  Promotion NVARCHAR(50),
					  DiscountPercent Float,
					  LoadDate Datetime Default Getdate(),
					  Constraint Retail_PromotionID_pk Primary Key (PromotionID)
					  )
UPDATE Retail.Promotion SET Promotion = 'Discount' WHERE PROMOTIONID = 1

---- Truncate Retail.Promotion if Exist-----

If OBJECT_ID('Retail.Promotion') IS NOT NULL
TRUNCATE TABLE Retail.Promotion

------ Promotion Retail PreCount-------
Select Count(*) Pre_Count From  Retail.Promotion
------- Promotion Retail PostCount--------
Select  Count(*) Post_Count From Retail.Promotion

----Extraction Script from Staging into EDW-----

SELECT PromotionID,StartDate, EndDate, Promotion, DiscountPercent,
 FROM Retail.Promotion  

-----Create EDW Table for Promotion
Use Tesca_ProjEdw

Create Table Edw.Promotion(
                      PromotionSK INT IDENTITY(1,1),
                      PromotionID INT,
					  StartDate DATE,
					  EndDate DATE,
					  Promotion NVARCHAR(50),
					  DiscountPercent Float,
					  LastAjusted Datetime,
					  Constraint EDW_PromotionSK_pk Primary Key (PromotionSK)
					  )


------ Promotion Edw PreCount-------
Select  Count(*) Pre_Count From Edw.Promotion
------- Promotion Edw PostCount--------
Select  Count(*) Post_Count From Edw.Promotion

-------------Customer------
 -- Extraction Script from the source system into staging--

 Use Tesca_ProjOLTP

 SELECT CustomerID, (Upper(FirstName)+', '+ LastName) FullName, CustomerAddress, CityName,State
 FROM Customer 
    INNER JOIN City
	ON Customer.CityID = City.CityID
	INNER JOIN State
	ON State.StateID = City.StateID

-----Create Staging Table for Customer
Use Tesca_ProjStaging

Create Table Retail.Customer(
                      CustomerID INT,
					  FullName NVARCHAR(50),
					  CustomerAddress NVARCHAR(50),
					  CityName NVARCHAR (50),
					  State NVARCHAR (50),
					  LoadDate Datetime Default Getdate(),
					  Constraint Retail_CustomerID_pk Primary Key (CustomerID)
					  )

---- Truncate Retail.Customer if Exist-----

If OBJECT_ID('Retail.Customer') IS NOT NULL
TRUNCATE TABLE Retail.Customer

------ Customer Retail PreCount-------
Select Count(*) Pre_Count From Retail.Customer
------- Customer Retail PostCount--------
Select Count(*) Post_Count From Retail.Customer

----Extraction Script from Staging into EDW-----
SELECT CustomerID,FullName, CustomerAddress, CityName, State
 FROM Retail.Customer  

-----Create EDW Table for Customer
Use Tesca_ProjEdw

Create Table Edw.Customer(
                      CustomerSK INT IDENTITY(1,1),
                      CustomerID INT,
					  FullName NVARCHAR(250),
					  CustomerAddress NVARCHAR(50),
					  CityName NVARCHAR (50),
					  State NVARCHAR (50),
					  LastAdjusted Datetime Default Getdate(),
					  Constraint EDW_CustomerSK_pk Primary Key (CustomerSK)
					  )


------ Customer Edw PreCount-------
Select Count(*) Pre_Count From Edw.Customer
------- Customer Edw PostCount--------
Select Count(*) Post_Count From Edw.Customer

-------------POSChannel------
 -- Extraction Script from the source system into staging--

 Use Tesca_ProjOLTP

 SELECT ChannelID, ChannelNo, DeviceModel, SerialNo, InstallationDate
 FROM POSChannel 
    

-----Create Staging Table for POSChannel
Use Tesca_ProjStaging

Create Table Retail.POSChannel(
                      ChannelID INT,
					  ChannelNo NVARCHAR(50),
					  DeviceModel NVARCHAR(50),
					  SerialNo NVARCHAR (50),
					  InstallationDate Date,
					  LoadDate Datetime Default Getdate(),
					  Constraint Retail_ChannelID_pk Primary Key (ChannelID)
					  )

---- Truncate Retail.POSChannel if Exist-----

If OBJECT_ID('Retail.POSChannel') IS NOT NULL
TRUNCATE TABLE Retail.POSChannel

------ POSChannel Retail PreCount-------
Select Count(*) Pre_Count From Retail.POSChannel
------- POSChannel Retail PostCount--------
Select Count(*) Post_Count From Retail.POSChannel

----Extraction Script from Staging into EDW-----
 SELECT ChannelID, ChannelNo, DeviceModel, SerialNo, InstallationDate
 FROM Retail.POSChannel  

-----Create EDW Table for POSChannel
Use Tesca_ProjEdw

Create Table Edw.POSChannel(
                      ChannelSK INT IDENTITY(1,1),
                      ChannelID INT,
					  ChannelNo NVARCHAR(50),
					  DeviceModel NVARCHAR(50),
					  SerialNo NVARCHAR (50),
					  InstallationDate Date,
					  StartDate Datetime ,
					  EndDate Datetime,
					  Active BIT,
					  Constraint EDW_POSChannelSK_pk Primary Key (ChannelSK)
					  )



------ POSChannel Edw PreCount-------
Select Count(*) Pre_Count From Edw.POSChannel
------- POSChannel Edw PostCount--------
Select Count(*) Post_Count From Edw.POSChannel

-------------Vendor------
 -- Extraction Script from the source system into staging--

 Use Tesca_ProjOLTP

 SELECT VendorID, VendorNo, (Upper(FirstName)+', '+ LastName) VendorName, RegistrationNo, VendorAddress, CityName, State
 FROM Vendor 
   INNER JOIN City
   ON Vendor.CityID = City.CityID
   INNER JOIN State
   ON City.StateID = State.StateID
    

-----Create Staging Table for Vendor
Use Tesca_ProjStaging

Create Table Retail.Vendor(
                      VendorID INT,
					  VendorNo INT,
					  VendorName NVARCHAR(250),
					  RegistrationNo NVARCHAR (50),
					  VendorAddress NVARCHAR (50),
					  CityName NVARCHAR (50),
					  State NVARCHAR (50),
					  LoadDate Datetime Default Getdate(),
					  Constraint Retail_VendorID_pk Primary Key (VendorID)
					  )
					  


---- Truncate Retail.Vendor if Exist-----
If OBJECT_ID('Retail.Vendor') IS NOT NULL
TRUNCATE TABLE Retail.Vendor

------ Vendor Retail PreCount-------
Select Count(*) Pre_Count From Retail.Vendor
------- Vendor Retail PostCount--------
Select Count(*) Post_Count From Retail.Vendor

----Extraction Script from Staging into EDW-----
 SELECT VendorID, VendorNo, VendorName, RegistrationNo, VendorAddress,CityName,State
 FROM Retail.Vendor  

-----Create EDW Table for Vendor
Use Tesca_ProjEdw

Create Table Edw.Vendor(
                      VendorSK INT IDENTITY(1,1),
                      VendorID INT,
					  VendorNo INT,
					  VendorName NVARCHAR(250),
					  RegistrationNo NVARCHAR (30),
					  VendorAddress NVARCHAR (50),
					  CityName NVARCHAR (50),
					  State NVARCHAR (50),
					  StartDate Datetime ,
					  EndDate Datetime,
					  Active BIT,
					  Constraint EDW_VendorSK_pk Primary Key (VendorSK)
					  )


------ Vendor Edw PreCount-------
Select Count(*) Pre_Count From Edw.Vendor
------- Vendor Edw PostCount--------
Select Count(*) Post_Count From Edw.Vendor

-------------Employee------
 -- Extraction Script from the source system into staging--

 Use Tesca_ProjOLTP

 SELECT EmployeeID, EmployeeNo, (Upper(FirstName)+', '+ LastName) EmployeeName, DOB, M.MaritalStatus AS MaritalStatus
 FROM Employee 
   INNER JOIN MaritalStatus M
   ON Employee.Maritalstatus = M.MaritalStatusID
 
    

-----Create Staging Table for Employee
Use Tesca_ProjStaging

Create Table Retail.Employee(
                      EmployeeID INT,
					  EmployeeNo NVARCHAR (50),
					  EmployeeName NVARCHAR(250),
					  DOB Date,
					  MaritalStatus NVARCHAR (50),
					  LoadDate Datetime Default Getdate(),
					  Constraint Retail_Employee_pk Primary Key (EmployeeID)
					  )

---- Truncate Retail.Employee if Exist-----

If OBJECT_ID('Retail.Employee') IS NOT NULL
TRUNCATE TABLE Retail.Employee

------ Employee Retail PreCount-------
Select Count(*) Pre_Count From Retail.Employee
------- Employee Retail PostCount--------
Select Count(*) Post_Count From Retail.Employee

----Extraction Script from Staging into EDW-----
 SELECT EmployeeID, EmployeeNo, EmployeeName, DOB, MaritalStatus
 FROM Retail.Employee  

-----Create EDW Table for Employee
Use Tesca_ProjEdw

Create Table Edw.Employee(
                      EmployeeSK INT IDENTITY(1,1),
                      EmployeeID INT,
					  EmployeeNo NVARCHAR (50),
					  EmployeeName NVARCHAR(250),
					  DOB Date,
					  MaritalStatus NVARCHAR (50),
					  StartDate Datetime ,
					  EndDate Datetime,
					  Active BIT,
					  Constraint EDW_EmployeeSK_pk Primary Key (EmployeeSK)
					  )


------ Employee Edw PreCount-------
Select Count(*) Pre_Count From Edw.Employee
------- Employee Edw PostCount--------
Select Count(*) Post_Count From Edw.Employee


-------------Misconduct------
 -- Extraction Script from the source system (CSV) into staging Requires no scripting as Dataset is in a CSV file on a local conputer--

-----Create Staging Table for Misconduct
Use Tesca_ProjStaging

Create Table HR.Misconduct(
                      MisconductID INT,
					  Miscoductdesc NVARCHAR (50),
					  LoadDate Datetime Default Getdate(),
					  )
---- Truncate Hr.Misconduct if Exist-----

If OBJECT_ID('HR.Misconduct') IS NOT NULL
TRUNCATE TABLE HR.Misconduct

------ Misconduct HR PreCount-------
Select Count(*) Pre_Count From HR.Misconduct
------- Misconduct HR PostCount--------
Select Count(*) Post_Count From HR.Misconduct

----Extraction Script from Staging into EDW-----
---- Deduplication Script Because the CSV from Hr contains dudplicate data point---------

With Row_num AS(
           SELECT Row_Number() Over (Order by MisconductID) ID,
			    MisconductID,
			    Miscoductdesc
            From HR.Misconduct),
	Dedup AS( 
	         SELECT ID, MisconductID, Miscoductdesc
			 FROM Row_num
			 WHERE ID IN (SELECT MIN(ID) FROM Row_num GROUP BY MisconductID)
			 )
			 SELECT MisconductID, Miscoductdesc
			 FROM Dedup;

-----Create EDW Table for Misconduct
Use Tesca_ProjEdw

Create Table Edw.Misconduct(
                      MisconductSK INT IDENTITY(1,1),
                      MisconductID INT,
					  Miscoductdesc NVARCHAR (50),
					  LastAdjusted Datetime Default Getdate(),
					  Constraint Hr_MisconductSK_pk Primary Key (MisconductSK)
					  )

------ Misconduct EDW PreCount-------
Select Count(*) Pre_Count From EDW.Misconduct
------- Misconduct EDW PostCount--------
Select Count(*) Post_Count From EDW.Misconduct

 -------------Decision------
 -- Extraction Script from the source system (CSV) into staging Requires no scripting as Dataset is in a CSV file on a local conputer--

-----Create Staging Table for Decision
Use Tesca_ProjStaging

Create Table HR.Decision(
                      DecisionID INT,
					  Decision NVARCHAR (50),
					  LoadDate Datetime Default Getdate(),
					  Constraint Hr_Decision_pk Primary Key (DecisionID)
					  )
---- Truncate Hr.Decision if Exist-----

If OBJECT_ID('HR.Decision') IS NOT NULL
TRUNCATE TABLE HR.Decision

------ Decision HR PreCount-------
Select Count(*) Pre_Count From HR.Decision
------- Decision HR PostCount--------
Select Count(*) Post_Count From HR.Decision

----Extraction Script from Staging into EDW-----
---- Deduplication Script Because the CSV from Hr contains dudplicate data point---------

With Row_num AS(
           SELECT Row_Number() Over (Order by DecisionID) ID,
			    DecisionID,
			    Decision
            From HR.Decision),
	Dedup AS( 
	         SELECT ID, DecisionID, Decision
			 FROM Row_num
			 WHERE ID IN (SELECT MIN(ID) FROM Row_num GROUP BY DecisionID)
			 )
			 SELECT DecisionID, Decision
			 FROM Dedup;

-----Create EDW Table for Decision
Use Tesca_ProjEdw

Create Table Edw.Decision(
                      DecisionSK INT IDENTITY(1,1),
                      DecisionID INT,
					  Decision NVARCHAR (50),
					  LastAdjust Datetime Default Getdate(),
					  Constraint Hr_DecisionSK_pk Primary Key (DecisionSK)
					  )

  ------ Decision EDW PreCount-------
Select Count(*) Pre_Count From EDW.Decision
------- Decision EDW PostCount--------
Select Count(*) Post_Count From EDW.Decision

 -------------Absent------
 -- Extraction Script from the source system (CSV) into staging Requires no scripting as Dataset is in a CSV file on a local conputer--

-----Create Staging Table for Absent_Category
Use Tesca_ProjStaging

Create Table HR.Absent_Category(
                      Absent_CategoryID INT,
					  Absent_Category NVARCHAR (50),
					  LoadDate Datetime Default Getdate(),
					  Constraint Absent_Category_pk Primary Key (Absent_CategoryID)
					  )
---- Truncate Hr.Decision if Exist-----

If OBJECT_ID('HR.Absent_Category') IS NOT NULL
TRUNCATE TABLE HR.Absent_Category

----- Absent_Category HR PreCount-------
Select Count(*) Pre_Count From HR.Absent_Category
------- Absent_Category HR PostCount--------
Select Count(*) Post_Count From HR.Absent_Category

----Extraction Script from Staging into EDW-----
---- Deduplication Script Because the CSV from Hr contains dudplicate data point---------

With Row_num AS(
           SELECT Row_Number() Over (Order by Absent_CategoryID) ID,
			    Absent_CategoryID,
			    Absent_Category
            From HR.Absent_Category),
	Dedup AS( 
	         SELECT ID, Absent_CategoryID, Absent_Category
			 FROM Row_num
			 WHERE ID IN (SELECT MIN(ID) FROM Row_num GROUP BY Absent_CategoryID)
			 )
			 SELECT Absent_CategoryID, Absent_Category
			 FROM Dedup;

-----Create EDW Table for Absent
Use Tesca_ProjEdw

Create Table Edw.Absent_Category(
                      Absent_CategorySK INT IDENTITY(1,1),
                       Absent_CategoryID INT,
					  Absent_Category NVARCHAR (50),
					  LastAdjusted Datetime Default Getdate(),
					  Constraint Absent_CategorySK_pk Primary Key (Absent_CategorySK)
					  )

----- Absent_Category Edw PreCount-------
Select Count(*) Pre_Count From Edw.Absent_Category
------- Absent_Category Edw PostCount--------
Select Count(*) Post_Count From Edw.Absent_Category

 ---------------------------------------------------
 ------------Fact Section------------------
 ----------------------------------------------------


/*
Fact Tables For the 5 Business Processes

Dim_Date Table
Dim_Time Table


*/

-------Sales------------
 -- Extraction Script from the source system and data load into staging--
 USE Tesca_ProjOLTP

   IF(SELECT Count(*) From Tesca_ProjEdw.EDW.Salestransaction) = 0
   Begin
        Select TransactionID, TransactionNO, Convert(Date,TransDate) TrancastionDate, Cast(Datepart(Hour,TransDate) AS INT) TrasactionHour, 
				Convert(Date,OrderDate) OrderDate, Cast(Datepart(Hour,OrderDate)AS INT) Orderhour, Convert(Date,DeliveryDate) DeliveryDate, 
				Cast(Datepart(Hour,DeliveryDate) AS INT) Deliveryhour,ChannelID, CustomerID, EmployeeID, ProductID, StoreID, PromotionID, 
				Quantity, TaxAmount, LineAmount, LineDiscountAmount
		FROM [dbo].[SalesTransaction] 
		WHERE  Convert(Date,TransDate) <  Convert(Date, Getdate())
	END
	ELSE
	Begin
		 Select TransactionID, TransactionNO, Convert(Date,TransDate) TrancastionDate, Cast(Datepart(Hour,TransDate) AS INT) TrasactionHour, 
				Convert(Date,OrderDate) OrderDate, Cast(Datepart(Hour,OrderDate)AS INT) Orderhour, Convert(Date,DeliveryDate) DeliveryDate, 
				Cast(Datepart(Hour,DeliveryDate) AS INT) Deliveryhour,ChannelID, CustomerID, EmployeeID, ProductID, StoreID, PromotionID, 
				Quantity, TaxAmount, LineAmount, LineDiscountAmount
		 FROM [dbo].[SalesTransaction] 
		 WHERE  Convert(Date,TransDate)  =  Convert(Date,Dateadd(Day, -1, Getdate()))
	 END;

----------CurrentCount For Validation on Metric Table-------
   IF(SELECT Count(*) From Tesca_ProjEdw.EDW.Salestransaction) = 0
   Begin
        Select Count(*) CurrentCount
		FROM [dbo].[SalesTransaction] 
		WHERE  Convert(Date,TransDate) <  Convert(Date, Getdate())
    END
	ELSE
	Begin
		 Select Count(*) CurrentCount
		 FROM [dbo].[SalesTransaction] 
		 WHERE  Convert(Date,TransDate)  =  Convert(Date,Dateadd(Day, -1, Getdate()))
	 END;
----------- Precount for Retail.SalesTransaction -------------
Select Count(*) Pre_count from Retail.SalesTransaction
----------- Postcount for Retail.SalesTransaction -------------
Select Count(*) from Retail.SalesTransaction


 -------Create Staging Sales_Fact Table---------

 Use Tesca_ProjStaging

 Create Table Retail.SalesTransaction(
                             SalesTransactionID INT,
							 TransactionNO Nvarchar (50),
							 TrancastionDate Date,
							 TrasactionHour INT,
							 OrderDate Date,
							 Orderhour INT,
							 DeliveryDate Date,
							 Deliveryhour INT,
							 ChannelID INT,
							 CustomerID INT,
							 EmployeeID INT,
							 ProductID INT,
							 StoreID INT,
							 PromotionID INT,
							 Quantity INT,
							 TaxAmount Float,
							 LineAmount Float,
							 LineDiscountAmount Float,
							 LoadDate Datetime Default Getdate(),
							 Constraint SalesTransactionID_pk Primary Key(SalesTransactionID)
							 )

If OBJECT_ID('Retail.SalesTransaction') IS NOT NULL
TRUNCATE TABLE Retail.SalesTransaction

------ Extraction Scrpt Fron the SalesTrans------
Select SalesTransactionID, TransactionNO, TrancastionDate, TrasactionHour, OrderDate, Orderhour, DeliveryDate, Deliveryhour, ChannelID,
		CustomerID, EmployeeID, ProductID, StoreID,PromotionID, Quantity, TaxAmount, LineAmount, LineDiscountAmount
		FROM Retail.SalesTransaction

------ Create SaleTrans EDW--------
Select * from EDW.SalesTransaction
order by TransactionNO
Use Tesca_ProjEdw

    Create Table EDW.SalesTransaction(
                             SalesTransactionSK INT IDENTITY (1,1),
							 TransactionNO Nvarchar (50),
							 TrancastionDateSK INT,
							 TrasactionHourSK INT,
							 OrderDateSK INT,
							 OrderhourSK INT,
							 DeliveryDateSK INT,
							 DeliveryhouSK INT,
							 ChannelSK INT,
							 CustomerSK INT,
							 EmployeeSK INT,
							 ProductSK INT,
							 StoreSK INT,
							 PromotionSK INT,
							 Quantity INT,
							 TaxAmount Float,
							 LineAmount Float,
							 LineDiscountAmount Float,
							 LoadDate Datetime,
							 Constraint EDW_SalesTransactionSK_pk Primary Key(SalesTransactionSK),
							 Constraint EDW_TrancastionDateSK_fk Foreign Key(TrancastionDateSK) References edw.DimDate(DateKey),
							 Constraint EDW_TrasactionHourSK_fk Foreign Key(TrasactionHourSK) References edw.DimTime(TimeKey),
							 Constraint EDW_OrderDateSK_fk Foreign Key(OrderDateSK) References edw.DimDate(DateKey),
							 Constraint EDW_OrderhourSK_fk Foreign Key(OrderhourSK) References edw.DimTime(TimeKey),
							 Constraint EDW_DeliveryDateSK_fk Foreign Key(DeliveryDateSK) References edw.DimDate(DateKey),
							 Constraint EDW_DeliveryhouSK_fk Foreign Key(DeliveryhouSK) References edw.DimTime(TimeKey),
							 Constraint EDW_ChannelSK_fk Foreign Key(ChannelSK) References Edw.POSChannel(ChannelSK),
							 Constraint EDW_CustomerSK_fk Foreign Key(CustomerSK) References Edw.Customer(CustomerSK),
						     Constraint EDW_EmployeeSK_fk Foreign Key(EmployeeSK) References Edw.Employee(EmployeeSK),
							 Constraint EDW_ProductSK_fk Foreign Key(ProductSK) References Edw.Product(ProductSK),
							 Constraint EDW_StoreSK_fk Foreign Key(StoreSK) References Edw.Store(StoreSK),
							 Constraint EDW_PromotionSK_fk Foreign Key(PromotionSK) References Edw.Promotion(PromotionSK)
							 )
---------- Precount for EDW.SalesTransaction -------------
Select Count(*) Pre_Count from EDW.SalesTransaction
----------- Postcount for EDW.SalesTransaction -------------
Select Count(*) Post_Count from EDW.SalesTransaction	

Select *from EDW.SalesTransaction
Order by trancastiondatesk desc
-------Purchase------------
 -- Extraction Script from the source system and data load into staging--
 USE Tesca_ProjOLTP

   IF(SELECT Count(*) From Tesca_ProjEdw.EDW.Purchasetransaction) = 0
   Begin
        Select TransactionID, TransactionNO, Convert(Date,TransDate) TrancastionDate, CAST(Datepart(Hour,TransDate) AS INT) TrasactionHour, 
				Convert(Date,OrderDate) OrderDate, CAST(Datepart(Hour,OrderDate) AS INT) Orderhour, Convert(Date,DeliveryDate) DeliveryDate,
				CAST(Datepart(Hour,DeliveryDate) AS INT) Deliveryhour,Convert(Date,ShipDate) ShipDate, CAST(Datepart(Hour,ShipDate) AS INT) Shiphour,
				VendorID, EmployeeID, ProductID, StoreID, Quantity, TaxAmount, LineAmount
		FROM [dbo].[PurchaseTransaction] 
		WHERE  Convert(Date,TransDate) <  Convert(Date, Getdate())
	END
	ELSE
	Begin
		 Select TransactionID, TransactionNO, Convert(Date,TransDate) TrancastionDate, CAST(Datepart(Hour,TransDate) AS INT) TrasactionHour, 
				Convert(Date,OrderDate) OrderDate, CAST(Datepart(Hour,OrderDate) AS INT) Orderhour, Convert(Date,DeliveryDate) DeliveryDate,
				CAST(Datepart(Hour,DeliveryDate) AS INT) Deliveryhour,Convert(Date,ShipDate) ShipDate, CAST(Datepart(Hour,ShipDate) AS INT) Shiphour,
				VendorID, EmployeeID, ProductID, StoreID, Quantity, TaxAmount, LineAmount
		 FROM [dbo].[PurchaseTransaction] 
		 WHERE  Convert(Date,TransDate)  =  Convert(Date,Dateadd(Day, -1, Getdate()))
	 END;

----------CurrentCount For Validation on Metric Table-------
   IF(SELECT Count(*) From Tesca_ProjEdw.EDW.Purchasetransaction) = 0
   Begin
        Select Count(*) CurrentCount
		FROM [dbo].Purchasetransaction 
		WHERE  Convert(Date,TransDate) <  Convert(Date, Getdate())
    END
	ELSE
	Begin
		 Select Count(*) CurrentCount
		 FROM [dbo].Purchasetransaction 
		 WHERE  Convert(Date,TransDate)  =  Convert(Date,Dateadd(Day, -1, Getdate()))
	 END;
----------- Precount for Retail.Purchasetransaction -------------
Select Count(*) Pre_Count from Retail.Purchasetransaction
----------- Postcount for Retail.Purchasetransaction -------------
Select Count(*) Post_Count from Retail.Purchasetransaction



 -------Create Staging Purchase_Fact Table---------

 Use Tesca_ProjStaging

 Create Table Retail.PurchaseTransaction(
                             PurchaseTransactionID INT,
							 TransactionNO Nvarchar (50),
							 TrancastionDate Date,
							 TrasactionHour INT,
							 OrderDate Date,
							 Orderhour INT,
							 DeliveryDate Date,
							 Deliveryhour INT,
							 ShipDate Date,
							 Shiphour INT,
							 VendorID INT,
							 EmployeeID INT,
							 ProductID INT,
							 StoreID INT,
							 Quantity INT,
							 TaxAmount Float,
							 LineAmount Float,
							 LoadDate Datetime Default Getdate(),
							 Constraint PurchaseTransactionID_pk Primary Key(PurchaseTransactionID)
							 )

If OBJECT_ID('Retail.PurchaseTransaction') IS NOT NULL
TRUNCATE TABLE Retail.PurchaseTransaction
------ Create PurchaseTrans EDW--------

Use Tesca_ProjEdw


------ Extraction Scrpt Fron the PurchaseTrans------
Select PurchaseTransactionID, TransactionNO, TrancastionDate, TrasactionHour, OrderDate, Orderhour, DeliveryDate, Deliveryhour,ShipDate,Shiphour, VendorID,
	   EmployeeID, ProductID, StoreID, Quantity, TaxAmount, LineAmount,LoadDate
		FROM Retail.PurchaseTransaction

    Create Table EDW.PurchaseTransaction(
                             PurchaseTransactionSK INT IDENTITY (1,1),
							 TransactionNO Nvarchar (50),
							 TrancastionDateSK INT,
							 TrasactionHourSK INT,
							 OrderDateSK INT,
							 OrderhourSK INT,
							 DeliveryDateSK INT,
							 DeliveryhourSK INT,
							 ShipDateSK INT,
							 ShiphourSK INT,
							 VendorSK INT,
							 EmployeeSK INT,
							 ProductSK INT,
							 StoreSK INT,
							 Quantity INT,
							 TaxAmount Float,
							 LineAmount Float,
							 EffectiveLoadDate Datetime,
							 Constraint PurchaseTransactionSK_pk Primary Key(PurchaseTransactionSK),
							 Constraint EDW_PurTrancastionDateSK_fk Foreign Key(TrancastionDateSK) References edw.DimDate(DateKey),
							 Constraint EDW_PurTrasactionHourSK_fk Foreign Key(TrasactionHourSK) References edw.DimTime(TimeKey),
							 Constraint EDW_PurOrderDateSK_fk Foreign Key(OrderDateSK) References edw.DimDate(DateKey),
							 Constraint EDW_PurOrderhourSK_fk Foreign Key(OrderhourSK) References edw.DimTime(TimeKey),
							 Constraint EDW_PurDeliveryDateSK_fk Foreign Key(DeliveryDateSK) References edw.DimDate(DateKey),
							 Constraint EDW_PurDeliveryhouSK_fk Foreign Key(DeliveryhourSK) References edw.DimTime(TimeKey),
							 Constraint EDW_PurShipDateSK_fk Foreign Key(ShipDateSK) References edw.DimDate(DateKey),
							 Constraint EDW_PurShiphouSK_fk Foreign Key(ShiphourSK) References edw.DimTime(TimeKey),
							 Constraint EDW_PurVendorSK_fk Foreign Key(VendorSK) References Edw.Vendor(VendorSK),
						     Constraint EDW_PurEmployeeSK_fk Foreign Key(EmployeeSK) References Edw.Employee(EmployeeSK),
							 Constraint EDW_PurProductSK_fk Foreign Key(ProductSK) References Edw.Product(ProductSK),
							 Constraint EDW_PurStoreSK_fk Foreign Key(StoreSK) References Edw.Store(StoreSK)
							 )
EXEC sp_rename 'Retail.PurchaseTransaction.LoadDate', 'EffectiveLoadDate', 'Column'
---------- Precount for EDW.PurchaseTransaction -------------
Select Count(*) Pre_Count from EDW.Purchasetransaction
----------- Postcount for EDW.PurchaseTransaction -------------
Select Count(*) Post_Count from EDW.Purchasetransaction	


-------Absent Fact Table------------
 
 USE Tesca_ProjStaging
 --- Extraction Script from the source system (CSV) into staging Requires no scripting as Dataset is in a CSV file on a local computer--
 ------Create Staging Table for Absent Fact------

 Create Table Hr.Absent_Fact(
                           Absent_factID INT IDENTITY (1,1),
						   EmployeeID INT,
						   StoreID INT,
						   AbsentDate Date,
						   AbsentHour INT,
						   Absent_CategoryID INT,
						   LoadDate Datetime Default GetDate(),
						   Constraint Absent_factID_pk Primary Key(Absent_factID)
						   )

If OBJECT_ID('Hr.Absent_Fact') IS NOT NULL
TRUNCATE TABLE Hr.Absent_Fact

---------- Precount for Hr.Absent_Fact -------------
Select Count(*)Pre_count from Hr.Absent_Fact
----------- Postcount for Hr.Absent_Fact -------------
Select Count(*) Post_Count from Hr.Absent_Fact

-------Scripting to Deduplicate and Extract Data from the Hr.Absent_Fact-------

	 SELECT  EmployeeID,StoreID,AbsentDate,AbsentHour,Absent_CategoryID
	 FROM Hr.Absent_Fact
	 WHERE Absent_factID IN (SELECT MIN(Absent_factID) FROM Hr.Absent_Fact Group by EmployeeID,AbsentDate)
				   

Use Tesca_ProjEdw
 ------- Create Absent_Fact Table for EDW---------

  Create Table EDW.Absent_Fact(
                           Absent_FactSK BIGINT IDENTITY(1,1),
						   EmployeeSK INT,
						   StoreSK INT,
						   AbsentDateSK INT,
						   AbsentHour INT,
						   Absent_CategorySK INT,
						   LoadDate Datetime,
						   Constraint Absent_FactSK_pk Primary Key(Absent_FactSK ),
						   Constraint Absent_EmployeeSK_fk Foreign Key(EmployeeSK) References Edw.Employee(EmployeeSK),
						   Constraint Absent_StoreSK_fk Foreign Key(StoreSK) References Edw.Store(StoreSK),
						   Constraint AbsentDateSK_fk Foreign Key(AbsentDateSK) References edw.DimDate(DateKey),
						   Constraint Absent_CategorySK_fk Foreign Key(Absent_CategorySK) References Edw.Absent_Category(Absent_CategorySK)
						   )

---------- Precount for EDW.Absent_Fact -------------
Select Count(*) Post_Count from EDW.Absent_Fact
----------- Postcount for EDW.Absent_Fact -------------
Select Count(*) Pre_Count from EDW.Absent_Fact

-------Misconduct Fact Table------------
 
 USE Tesca_ProjStaging

 --- Extraction Script from the source system (CSV) into staging Requires no scripting as Dataset is in a CSV file on a local computer--
 ------Create Staging Table for Misconduct Fact------


 Create Table Hr.Misconduct_Fact(
                           Misconduct_FactID INT IDENTITY (1,1),
						   EmployeeID INT,
						   StoreID INT,
						   MisconductDate Date,
						   MisconductID INT,
						   DecisionID INT,
						   LoadDate Datetime Default GetDate(),
						   Constraint Misconduct_FactID_pk Primary Key(Misconduct_FactID)
						   )

If OBJECT_ID('Hr.Misconduct_Fact') IS NOT NULL
TRUNCATE TABLE Hr.Misconduct_Fact

---------- Precount for Hr.Misconduct_Fact -------------
Select Count(*) Post_Count from Hr.Misconduct_Fact
----------- Postcount for Hr.Misconduct_Fact -------------
Select Count(*) Pre_Count from Hr.Misconduct_Fact

-------Scripting to Deduplicate and Extract Data from the Hr.Misconduct_Fact-------

	 SELECT  EmployeeID, StoreID, MisconductDate , MisconductID, DecisionID
	 FROM Hr.Misconduct_Fact
	 WHERE Misconduct_FactID IN (SELECT MAX(Misconduct_FactID) FROM Hr.Misconduct_Fact Group by EmployeeID, MisconductDate)
				   

Use Tesca_ProjEdw
 ------- Create Misconduct_Fact Table for EDW---------

  Create Table EDW.Misconduct_Fact(
                           Misconduct_FactSK BIGINT IDENTITY(1,1),
						   EmployeeSK INT,
						   StoreSK INT,
						   MisconductDateSK INT,
						   MisconductHourSK INT,
						   MisconductSK INT,
						   DecisionSK INT,
						   LoadDate Datetime,
						   Constraint Misconduct_FactSK_pk Primary Key(Misconduct_FactSK ),
						   Constraint Misconduct_EmployeeSK_fk Foreign Key(EmployeeSK) References Edw.Employee(EmployeeSK),
						   Constraint Misconduct_StoreSK_fk Foreign Key(StoreSK) References Edw.Store(StoreSK),
						   Constraint MisconductDateSK_fk Foreign Key(MisconductDateSK) References edw.DimDate(DateKey),
						   Constraint MisconductHourSK_fk Foreign Key(MisconductHourSK) References edw.DimTime(TimeKey),
						   Constraint MisconductSK_fk Foreign Key(MisconductSK) References Edw.Misconduct(MisconductSK),
						   Constraint Misconduct_DecisionSK_fk Foreign Key(DecisionSK) References Edw.Decision(DecisionSK)
						   )

---------- Precount for EDW.Misconduct_Fact -------------
Select Count(*) Post_Count from EDW.Misconduct_Fact
----------- Postcount for EDW.Misconduct_Fact -------------
Select Count(*) Pre_Count  from EDW.Misconduct_Fact


-------Overtime Fact Table------------
 
 USE Tesca_ProjStaging

 --- Extraction Script from the source system (CSV) into staging Requires no scripting as Dataset is in a CSV file on a local computer--
 ------Create Staging Table for Overtime Fact------

 Create Table Hr.Overtime_Fact(
                           OvertimeID INT,
						   EmployeeNo Nvarchar (50),
						   First_Name Nvarchar (50),
						   Last_Name Nvarchar (50),
						   StartOverTime Datetime,
						   EndOverTime Datetime,
						   LoadDate Datetime Default GetDate(),
						   )

If OBJECT_ID('Hr.Overtime_Fact') IS NOT NULL
TRUNCATE TABLE Hr.Overtime_Fact

---------- Precount for Hr.Overtime_Fact -------------
Select Count(*) Post_Count from Hr.Overtime_Fact
----------- Postcount for Hr.Overtime_Fact -------------
Select Count(*) Pre_Count from Hr.Overtime_Fact

-------Scripting to Deduplicate and Extract Data from the Hr.Overtime_Fact-------

WITH Row_num AS(
	      SELECT Row_Number() Over(Order by StartOverTime) Rown, OvertimeID, EmployeeNo, Concat(Upper(First_Name), ',',Last_Name) Employee_Name, Convert(Date,StartOverTime) OverTimeDate,
	          Cast(Datepart(Hour,StartOverTime)AS INT) Overtime_StarttimeSK, Cast(Datepart(Hour,EndOverTime)AS INT) Overtime_EndtimeSK
	      FROM Hr.Overtime_Fact),
	Dedup AS(
	      SELECT Rown,OvertimeID, EmployeeNo, Employee_Name, OverTimeDate, Overtime_StarttimeSK, Overtime_EndtimeSK
	      FROM Row_num
	      WHERE EXISTS  (SELECT Min(Rown) FROM Row_num Group by EmployeeNo, OverTimeDate)
		  )
	     SELECT EmployeeNo, Employee_Name, OverTimeDate, Overtime_StarttimeSK, Overtime_EndtimeSK
		  From Dedup

				   

Use Tesca_ProjEdw
 ------- Create Overtime_Fact Table for EDW---------

  Create Table EDW.Overtime_Fact(
                           OvertimeSK BIGINT IDENTITY(1,1),
						   EmployeeSK INT,
						   Employee_Name Nvarchar (50),
						   OverTimeDateSK INT,
						   Overtime_StarttimeSK INT,
						   Overtime_EndtimeSK INT,
						   LoadDate Datetime,
						   Constraint OvertimeSK_pk Primary Key(OvertimeSK),
						   Constraint Overtime_EmployeeSK_fk Foreign Key(EmployeeSK) References Edw.Employee(EmployeeSK),
						   Constraint OverTimeDateSK_fk Foreign Key(OverTimeDateSK) References edw.DimDate(DateKey),
						   Constraint Overtime_StarttimeSK_fk Foreign Key(Overtime_StarttimeSK) References edw.DimTime(TimeKey),
						   Constraint Overtime_EndtimeSK_fk Foreign Key(Overtime_EndtimeSK) References edw.DimTime(TimeKey)
						   )
---------- Precount for EDW.Overtime_Fact -------------
Select Count(*) Post_Count from EDW.Overtime_Fact
----------- Postcount for EDW.Overtime_Fact -------------
Select Count(*) Pre_Count from EDW.Overtime_Fact
