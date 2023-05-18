

---Assignment 4&5---
--Basavraj Jaliminche 8800149--



/* REQUIREMENT 1 */

/* REQUIREMENT 1 */
CREATE TABLE DimDate(
DateKey NUMBER(10),
DateValue DATE NOT NULL,
Year NUMBER(10) NOT NULL,
Month NUMBER(2) NOT NULL,
Day NUMBER(2) NOT NULL,
Quarter NUMBER(1) NOT NULL,
StartOfMonth DATE NOT NULL,
EndOfMonth DATE NOT NULL,
MonthName VARCHAR2(9) NOT NULL,
DayOfWeekName VARCHAR2(9) NOT NULL,
CONSTRAINT PK_DimDate PRIMARY KEY (DateKey)
);


CREATE TABLE DimCities(–Type 1 SCD
CityKey NUMBER(10),
CityName NVARCHAR2(50) NULL,
StateProvCode NVARCHAR2(5) NULL,
StateProvName NVARCHAR2(50) NULL,
CountryName NVARCHAR2(60) NULL,
CountryFormalName NVARCHAR2(60) NULL,
CONSTRAINT PK_DimCities PRIMARY KEY (CityKey)
);

CREATE TABLE DimCustomers( –Type 2 SCD
CustomerKey NUMBER(10),
CustomerName NVARCHAR2(100) NULL,
CustomerCategoryName NVARCHAR2(50) NULL,
DeliveryCityName NVARCHAR2(50) NULL,
DeliveryStateProvCode NVARCHAR2(5) NULL,
DeliveryCountryName NVARCHAR2(50) NULL,
PostalCityName NVARCHAR2(50) NULL,
PostalStateProvCode NVARCHAR2(5) NULL,
PostalCountryName NVARCHAR2(50) NULL,
StartDate DATE NOT NULL,
EndDate DATE NULL,
CONSTRAINT PK_DimCustomers PRIMARY KEY (CustomerKey )
);



CREATE TABLE DimSalesPeople( –Type 1 SCD
SalesPersonKey NUMBER(10),
FullName NVARCHAR2(50) NULL,
PreferredName NVARCHAR2(50) NULL,
LogonName NVARCHAR2(50) NULL,
PhoneNumber NVARCHAR2(20) NULL,
FaxNumber NVARCHAR2(20) NULL,
EmailAddress NVARCHAR2(256) NULL,
CONSTRAINT PK_DimSalesPeople PRIMARY KEY (SalesPersonKey)
);

CREATE TABLE DimProducts( –Type 2 SCD
ProductKey NUMBER(10),
ProductName NVARCHAR2(100) NULL,
ProductColour NVARCHAR2(20) NULL,
ProductBrand NVARCHAR2(50) NULL,
ProductSize NVARCHAR2(20) NULL,
StartDate DATE NOT NULL,
EndDate DATE NULL,
CONSTRAINT PK_DimProducts PRIMARY KEY (ProductKey)
);

CREATE TABLE DimSuppliers( –Type 2 SCD
SupplierKey NUMBER(10),
FullName NVARCHAR2(50) NULL,
PhoneNumber NVARCHAR2(20) NULL,
FaxNumber NVARCHAR2(50) NULL,
WebsiteURL NVARCHAR2(20) NULL,
StartDate DATE NOT NULL,
EndDate DATE NULL,
CONSTRAINT PK_DimSuppliers PRIMARY KEY (SupplierKey)
);

CREATE TABLE FactSales( 
CustomerKey NUMBER(10) NOT NULL,
CityKey NUMBER(10) NOT NULL,
ProductKey NUMBER(10) NOT NULL,
SalesPersonKey NUMBER(10) NOT NULL,
SupplierKey NUMBER(10) NOT NULL,
DateKey NUMBER(10) NOT NULL,
Quantity NUMBER(4) NOT NULL,
UnitPrice NUMBER(18,2) NOT NULL,
TaxRate NUMBER(18,3) NOT NULL,
TotalBeforeTax NUMBER(18,2) NOT NULL,
TotalAfterTax NUMBER(18,2) NOT NULL,
CONSTRAINT FK_FactSales_CustomerKey FOREIGN KEY (CustomerKey) REFERENCES DimCustomers ( CustomerKey),
CONSTRAINT FK_FactSales_CityKey  FOREIGN KEY (CityKey) REFERENCES DimCities ( CityKey),
CONSTRAINT FK_FactSales_ProductKey  FOREIGN KEY (ProductKey ) REFERENCES DimProducts (ProductKey),
CONSTRAINT FK_FactSales_SalesPersonKey  FOREIGN KEY (SalesPersonKey  ) REFERENCES DimSalesPeople(SalesPersonKey),
CONSTRAINT FK_FactSales_SupplierKey  FOREIGN KEY (SupplierKey) REFERENCES DimSuppliers(SupplierKey),
CONSTRAINT FK_FactSales_DateKey  FOREIGN KEY (DateKey) REFERENCES DimDate(DateKey)
);

CREATE INDEX IN_FactSales_CustomerKey ON FactSales(CustomerKey);
CREATE INDEX IN_FactSales_CityKey ON FactSales(CityKey);
CREATE INDEX IN_FactSales_ProductKey ON FactSales(ProductKey);
CREATE INDEX IN_FactSales_SalesPersonKey ON FactSales(SalesPersonKey);
CREATE INDEX IN_FactSales_SupplierKey ON FactSales(SupplierKey);
CREATE INDEX IN_FactSales_DateKey ON FactSales(DateKey);








/* REQUIREMENT 2 */
CREATE OR REPLACE PROCEDURE DimDate_Load ( DateValue IN DATE )
IS
BEGIN
INSERT INTO DimDate
SELECT
EXTRACT(YEAR FROM DateValue) * 10000 + EXTRACT(Month FROM DateValue) * 100 + EXTRACT(Day FROM DateValue) DateKey
,DateValue DateValue
,EXTRACT(YEAR FROM DateValue) Year
,CAST(TO_CHAR(DateValue, 'Q') AS INT) Quarter
,EXTRACT(Month FROM DateValue) Month
,EXTRACT(Day FROM DateValue) "Day"
,TRUNC(DateValue) - (TO_NUMBER (TO_CHAR(DateValue,'DD')) - 1) StartOfMonth
,ADD_Months(TRUNC(DateValue) - (TO_NUMBER(TO_CHAR(DateValue,'DD')) - 1), 1) -1 EndOfMonth
,TO_CHAR(DateValue, 'MONTH') MonthName
,TO_CHAR(DateValue, 'DY') DayOfWeekName
FROM dual;
END;

EXECUTE DimDate_Load (‘2018-12-01’);

BEGIN 
 DimDate_Load (‘2018-12-02’);
END;


/* REQUIREMENT 3 */

SELECT * FROM factsales fs
LEFT JOIN dimcustomers dc
ON fs.customerkey=dc.customerkey
LEFT JOIN dimsuppliers ds
ON fs.supplierkey=ds.supplierkey
LEFT JOIN dimsalespeople dsp
ON fs.salespersonkey=dsp.salespersonkey
LEFT JOIN dimcities dci
ON fs.citykey=dci.citykey
LEFT JOIN dimproducts dp
ON fs.productkey= dp.productkey
LEFT JOIN dimdate dd
ON fs.datekey=dd.datekey;







/* REQUIREMENT 4 */
CREATE TABLE Customers_Stage (
CustomerName NVARCHAR2(100),
CustomerCategoryName NVARCHAR2(50),
DeliveryCityName NVARCHAR2(50),
DeliveryStateProvinceCode NVARCHAR2(5),
DeliveryStateProvinceName NVARCHAR2(50),
DeliveryCountryName NVARCHAR2(50),
DeliveryFormalName NVARCHAR2(60),
PostalCityName NVARCHAR2(50),
PostalStateProvinceCode NVARCHAR2(5),
PostalStateProvinceName NVARCHAR2(50),
PostalCountryName NVARCHAR2(50),
PostalFormalName NVARCHAR2(60)
);


SET SERVEROUT ON;

CREATE OR REPLACE PROCEDURE Customers_Extract 
IS
    RowCt NUMBER(10):=0;
    v_sql VARCHAR(255) := 'TRUNCATE TABLE wwidmuser.Customers_Stage DROP STORAGE';
BEGIN
    EXECUTE IMMEDIATE v_sql;

    INSERT INTO midterm.Customers_Stage
    WITH CityDetails AS (
        SELECT ci.CityID,
               ci.CityName,
               sp.StateProvinceCode,
               sp.StateProvinceName,
               co.CountryName,
               co.FormalName
        FROM wwidbuser.Cities ci
        LEFT JOIN wwidbuser.StateProvinces sp
            ON ci.StateProvinceID = sp.StateProvinceID
        LEFT JOIN wwidbuser.Countries co
            ON sp.CountryID = co.CountryID 
    )

SELECT cust.CustomerName,
           cat.CustomerCategoryName,
           dc.CityName,
           dc.StateProvinceCode,
           dc.StateProvinceName,
           dc.CountryName,
           dc.FormalName,
           pc.CityName,
           pc.StateProvinceCode,
           pc.StateProvinceName,
           pc.CountryName,
           pc.FormalName
    FROM wwidbuser.Customers cust
    LEFT JOIN wwidbuser.CustomerCategories cat
        ON cust.CustomerCategoryID = cat.CustomerCategoryID
    LEFT JOIN CityDetails dc
        ON cust.DeliveryCityID = dc.CityID
    LEFT JOIN CityDetails pc
        ON cust.PostalCityID = pc.CityID;

    RowCt := SQL%ROWCOUNT;
    DBMS_OUTPUT.PUT_LINE('Number of employees added: ' || TO_CHAR(SQL%ROWCOUNT));
END;

-- EXECUTE PROCEDURE
EXECUTE Customers_Extract;
SELECT * FROM customers_stage;



--*************2. Staging Table and Extract Procedure - Products*********************
--Products – Query that joins StockItems and Colours

  CREATE TABLE Products_Stage (
    ColorName nvarchar2(20)  NULL, -- Colors
    Brand nvarchar2(50) NULL, -- StockItems
	ItemSize nvarchar2(20) NULL, -- StockItems
    StockItemName    NVARCHAR2(100)  -- StockItems
);

CREATE OR REPLACE PROCEDURE Products_Extract
AS
    RowCt NUMBER(10);
    v_sql VARCHAR(255) := 'TRUNCATE TABLE midterm.Products_Stage DROP STORAGE';
BEGIN
    EXECUTE IMMEDIATE v_sql;
    
    INSERT INTO midterm.Products_Stage (ColorName,Brand,ItemSize,StockItemName)
    SELECT col.ColorName,si.Brand,si.ItemSize,si.StockItemName
    FROM wwidbuser.StockItems si
    LEFT JOIN wwidbuser.Colors col
        ON si.ColorId = col.ColorId;

    RowCt := SQL%ROWCOUNT;
    IF sql%notfound THEN
       dbms_output.put_line('No records found. Check with source system.');
    ELSIF sql%found THEN
       dbms_output.put_line(TO_CHAR(RowCt) ||' Rows have been inserted!');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
       dbms_output.put_line(SQLERRM);
       dbms_output.put_line(v_sql);
END;

-- EXECUTE PROCEDURE
EXECUTE Products_Extract;
SELECT * FROM Products_Stage;

--*************3. Staging Table and Extract Procedure - SalesPeople*********************

--Salespeople – Query of People where IsSalesperson is 1

CREATE TABLE SalesPeople_Stage(
    FULLNAME NVARCHAR2(50)  NULL,
    PREFERREDNAME NVARCHAR2(50),
    LOGONNAME NVARCHAR2(50),
    PHONENUMBER NVARCHAR2(20), 
	FAXNUMBER NVARCHAR2(20), 
	EMAILADDRESS NVARCHAR2(256)
    
);


CREATE OR REPLACE PROCEDURE SalesPeople_Extract
AS
    RowCt NUMBER(10);
    v_sql VARCHAR(255) := 'TRUNCATE TABLE midterm.SalesPeople_Stage DROP STORAGE';
BEGIN
    EXECUTE IMMEDIATE v_sql;
    
    INSERT INTO midterm.SalesPeople_Stage
    SELECT FULLNAME,PREFERREDNAME,LOGONNAME,PHONENUMBER,FAXNUMBER,EMAILADDRESS
    FROM wwidbuser.People pe
    WHERE pe.IsSalesPerson = 1;

    RowCt := SQL%ROWCOUNT;
    IF sql%notfound THEN
       dbms_output.put_line('No records found. Check with source system.');
    ELSIF sql%found THEN
       dbms_output.put_line(TO_CHAR(RowCt) ||' Rows have been inserted!');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
       dbms_output.put_line(SQLERRM);
       dbms_output.put_line(v_sql);
END;

-- EXECUTE PROCEDURE
EXECUTE SalesPeople_Extract;
SELECT * FROM SalesPeople_Stage;




--*************5. Staging Table and Extract Procedure - Suppliers*********************

--Suppliers  - Suppliers and SuppliersCategories

CREATE TABLE Suppliers_Stage (
SupplierCategoryName    NVARCHAR2(100),  --  SupplierCategories  
FullName NVARCHAR2(50)  , --  Suppliers
PhoneNumber NVARCHAR2(20) , --Suppliers
FaxNumber nvarchar2(20) , --Suppliers
WebsiteURL NVARCHAR2(256)   --Suppliers
);


CREATE OR REPLACE PROCEDURE Suppliers_Extract
AS
    RowCt NUMBER(10);
    v_sql VARCHAR(255) := 'TRUNCATE TABLE midterm.Suppliers_Stage DROP STORAGE';
BEGIN
    EXECUTE IMMEDIATE v_sql;
    
    INSERT INTO midterm.Suppliers_Stage 
    SELECT  sc.SupplierCategoryName,s.SupplierName,s.PhoneNumber,s.FaxNumber,s.WebsiteURL 
    FROM wwidbuser.Suppliers s
    LEFT JOIN wwidbuser.SupplierCategories sc
        ON s.SupplierCategoryID = sc.SupplierCategoryID;
	 
	RowCt := SQL%ROWCOUNT;
    IF sql%notfound THEN
       dbms_output.put_line('No records found. Check with source system.');
    ELSIF sql%found THEN
       dbms_output.put_line(TO_CHAR(RowCt) ||' Rows have been inserted!');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
       dbms_output.put_line(SQLERRM);
       dbms_output.put_line(v_sql);
END;

-- EXECUTE PROCEDURE
EXECUTE Suppliers_Extract;
SELECT * FROM Suppliers_Stage;


--*************6. Staging Table and Extract Procedure - Orders*********************

--Orders - Orders,OrderLines,Customers and People
-- DROP TABLE Orders_Stage;
CREATE TABLE Orders_Stage (
    OrderDate       DATE, 
    Quantity        NUMBER(3),
    UnitPrice       NUMBER(18,2),
    TaxRate         NUMBER(18,3),
    CustomerName    NVARCHAR2(100),
    CityName        NVARCHAR2(50),
    StateProvinceName   NVARCHAR2(50),
    CountryName     NVARCHAR2(60),
    StockItemName   NVARCHAR2(100),
    LogonName       NVARCHAR2(50),
    SupplierName NVARCHAR2(100)
);

CREATE OR REPLACE PROCEDURE Orders_Extract(var_OrderDate DATE)
AS
    RowCt NUMBER(10);
    v_sql VARCHAR(255) := 'TRUNCATE TABLE midterm.Orders_Stage DROP STORAGE';
BEGIN
    EXECUTE IMMEDIATE v_sql;
    
    INSERT INTO midterm.Orders_Stage 
    WITH CityDetails AS (
        SELECT ci.CityID,
               ci.CityName,
               sp.StateProvinceCode,
               sp.StateProvinceName,
               co.CountryName,
               co.FormalName
        FROM wwidbuser.Cities ci
        LEFT JOIN wwidbuser.StateProvinces sp
            ON ci.StateProvinceID = sp.StateProvinceID
        LEFT JOIN wwidbuser.Countries co
            ON sp.CountryID = co.CountryID 
    )
SELECT o.OrderDate
        ,ol.Quantity
        ,ol.UnitPrice
        ,ol.TaxRate
        ,c.CustomerName
        ,dc.cityname
        ,dc.stateprovincename
        ,dc.countryname
        ,stk.StockItemName
        ,p.LogonName
        ,su.SupplierName
    FROM wwidbuser.Orders o
        LEFT JOIN wwidbuser.OrderLines ol
            ON o.OrderID = ol.OrderID
        LEFT JOIN wwidbuser.customers c
            ON o.CustomerID = c.CustomerID
        LEFT JOIN CityDetails dc
            ON c.DeliveryCityID = dc.CityID
        LEFT JOIN wwidbuser.stockitems stk
            ON ol.Stockitemid = stk.StockItemID
        LEFT JOIN wwidbuser.People p
            ON o.salespersonpersonid = p.personid 
        LEFT JOIN wwidbuser.Suppliers su
            ON su.PrimaryContactPersonID = p.personid
        WHERE o.OrderDate = var_OrderDate;

RowCt := SQL%ROWCOUNT;
    IF sql%notfound THEN
       dbms_output.put_line('No records found. Check with source system.');
    ELSIF sql%found THEN
       dbms_output.put_line(TO_CHAR(RowCt) ||' Rows have been inserted!');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
       dbms_output.put_line(SQLERRM);
       dbms_output.put_line(v_sql);
END;


EXECUTE Orders_Extract ('2013-01-01');
SELECT * FROM Orders_Stage;





/* REQUIREMENT 5 */
DROP SEQUENCE LocationKey ;
CREATE SEQUENCE LocationKey START WITH 1 CACHE 10;


CREATE TABLE Locations_Preload (
    LocationKey NUMBER(10) NOT NULL,	
    CityName NVARCHAR2(50) NULL,
    StateProvCode NVARCHAR2(5) NULL,
    StateProvName NVARCHAR2(50) NULL,
    CountryName NVARCHAR2(60) NULL,
    CountryFormalName NVARCHAR2(60) NULL,
    CONSTRAINT PK_Location_Preload PRIMARY KEY (LocationKey)
);



CREATE OR REPLACE PROCEDURE Locations_Transform
AS
  RowCt NUMBER(10);
  v_sql VARCHAR(255) := 'TRUNCATE TABLE Locations_Preload DROP STORAGE';
BEGIN
    EXECUTE IMMEDIATE v_sql;
    INSERT INTO Locations_Preload /* Column list excluded for brevity */
    SELECT LocationKey.NEXTVAL AS LocationKey,
           cu.DeliveryCityName,
           cu.DeliveryStateProvinceCode,
           cu.DeliveryStateProvinceName,
           cu.DeliveryCountryName,
           cu.DeliveryFormalName
    FROM Customers_Stage cu
    WHERE NOT EXISTS
	( SELECT 1
              FROM DimLocation ci
              WHERE cu.DeliveryCityName = ci.CityName
                AND cu.DeliveryStateProvinceName = ci.STATEPROVNAME
                AND cu.DeliveryCountryName = ci.CountryName 
        );
            RowCt := SQL%ROWCOUNT;
INSERT INTO Locations_Preload /* Column list excluded for brevity */
    SELECT ci.LocationKey,
           cu.DeliveryCityName,
           cu.DeliveryStateProvinceCode,
           cu.DeliveryStateProvinceName,
           cu.DeliveryCountryName,
           cu.DeliveryFormalName
    FROM Customers_Stage cu
    JOIN DimLocation ci
        ON cu.DeliveryCityName = ci.CityName
        AND cu.DeliveryStateProvinceName = ci.STATEPROVNAME
        AND cu.DeliveryCountryName = ci.CountryName;

    RowCt := RowCt+SQL%ROWCOUNT;
dbms_output.put_line(RowCt ||' Rows have been inserted!');
COMMIT;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
         dbms_output.put_line('No records found. Check with source system.');
WHEN OTHERS THEN
       dbms_output.put_line(SQLERRM);
       dbms_output.put_line(v_sql);
       ROLLBACK;
  
END;
/*



*/


EXECUTE Locations_Transform;
SELECT * FROM Locations_Preload;



--*************2. Preload Table and Transform Procedure - Customers*********************
SET SERVEROUT ON;
DROP SEQUENCE CustomerKey;
CREATE SEQUENCE CustomerKey START WITH 1 CACHE 10;

CREATE TABLE Customers_Preload (
   CustomerKey NUMBER(10) NOT NULL,
   CustomerName NVARCHAR2(100) NULL,
   CustomerCategoryName NVARCHAR2(50) NULL,
   DeliveryCityName NVARCHAR2(50) NULL,
   DeliveryStateProvCode NVARCHAR2(5) NULL,
   DeliveryCountryName NVARCHAR2(50) NULL,
   PostalCityName NVARCHAR2(50) NULL,
   PostalStateProvCode NVARCHAR2(5) NULL,
   PostalCountryName NVARCHAR2(50) NULL,
   StartDate DATE NOT NULL,
   EndDate DATE NULL,
   CONSTRAINT PK_Customers_Preload PRIMARY KEY ( CustomerKey )
);


CREATE OR REPLACE PROCEDURE Customers_Transform
AS
    RowCt NUMBER(10);
    v_sql VARCHAR(255) := 'TRUNCATE TABLE Customers_Preload DROP STORAGE';
    v_StartDate DATE := SYSDATE; 
    v_EndDate DATE := ((SYSDATE) - 1);
BEGIN
    EXECUTE IMMEDIATE v_sql;
    -- Add updated records
    INSERT INTO Customers_Preload -- Column list excluded for brevity 
        SELECT CustomerKey.NEXTVAL AS CustomerKey,--
            stg.CustomerName,
            stg.CustomerCategoryName,
            stg.DeliveryCityName,
            stg.DeliveryStateProvinceCode,
            stg.DeliveryCountryName,
            stg.PostalCityName,
            stg.PostalStateProvinceCode,
            stg.PostalCountryName,
            StartDate,
            NULL
        FROM Customers_Stage stg
        JOIN DimCustomers cu
            ON stg.CustomerName = cu.CustomerName AND cu.EndDate IS NULL
        WHERE stg.CustomerCategoryName <> cu.CustomerCategoryName
            OR stg.DeliveryCityName <> cu.DeliveryCityName
            OR stg.DeliveryStateProvinceCode <> cu.DeliveryStateProvCode
            OR stg.DeliveryCountryName <> cu.DeliveryCountryName
            OR stg.PostalCityName <> cu.PostalCityName
            OR stg.PostalStateProvinceCode <> cu.PostalStateProvCode
            OR stg.PostalCountryName <> cu.PostalCountryName;
            
                      RowCt := SQL%ROWCOUNT;
  
    -- Add existing records, and expire as necessary
    INSERT INTO Customers_Preload -- Column list excluded for brevity 
        SELECT cu.CustomerKey,
            cu.CustomerName,
            cu.CustomerCategoryName,
            cu.DeliveryCityName,
            cu.DeliveryStateProvCode,
            cu.DeliveryCountryName,
            cu.PostalCityName,
            cu.PostalStateProvCode,
            cu.PostalCountryName,
            cu.StartDate,
            (CASE WHEN pl.CustomerName IS NULL THEN NULL
                ELSE cu.EndDate
            END) AS EndDate
        FROM DimCustomers cu
        LEFT JOIN wwidmuser.Customers_Preload pl 
            ON pl.CustomerName = cu.CustomerName
            AND cu.EndDate IS NULL;
            
                         RowCt := RowCt+SQL%ROWCOUNT;


        -- Create new records
    INSERT INTO Customers_Preload -- Column list excluded for brevity 
        SELECT CustomerKey.NEXTVAL AS CustomerKey, 
            stg.CustomerName,
            stg.CustomerCategoryName,
            stg.DeliveryCityName,
            stg.DeliveryStateProvinceCode,
            stg.DeliveryCountryName,
            stg.PostalCityName,
            stg.PostalStateProvinceCode,
            stg.PostalCountryName,
            (v_StartDate),
            NULL
        FROM Customers_Stage stg
        WHERE NOT EXISTS ( SELECT 1 FROM DimCustomers cu WHERE stg.CustomerName = cu.CustomerName );
        
        RowCt := RowCt+SQL%ROWCOUNT;

    -- Expire missing records
    INSERT INTO Customers_Preload -- Column list excluded for brevity 
        SELECT cu.CustomerKey,
            cu.CustomerName,
            cu.CustomerCategoryName,
            cu.DeliveryCityName,
            cu.DeliveryStateProvCode,
            cu.DeliveryCountryName,
            cu.PostalCityName,
            cu.PostalStateProvCode,
            cu.PostalCountryName,
            cu.StartDate,
            (v_EndDate)
        FROM DimCustomers cu
        WHERE NOT EXISTS ( SELECT 1 FROM Customers_Stage stg WHERE stg.CustomerName = cu.CustomerName )
            AND cu.EndDate IS NULL;
    
      RowCt := RowCt+SQL%ROWCOUNT;

     
dbms_output.put_line(RowCt ||' Rows have been inserted!');
COMMIT;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
         dbms_output.put_line('No records found. Check with source system.');
WHEN OTHERS THEN
       dbms_output.put_line(SQLERRM);
       dbms_output.put_line(v_sql);
       ROLLBACK;
END;



EXECUTE Customers_Transform;
SELECT * FROM Customers_preload;



--*************3. Preload Table and Transform Procedure - SalesPeople*********************
SET SERVEROUT ON;

DROP SEQUENCE SalespersonKey;
CREATE SEQUENCE SalespersonKey START WITH 1 CACHE 10;


CREATE TABLE SalesPeople_Preload (
SalespersonKey INT NOT NULL,
FullName NVARCHAR2(50) NULL,
PreferredName NVARCHAR2(50) NULL,
LogonName NVARCHAR2(50) NULL,
PhoneNumber NVARCHAR2(20) NULL,
FaxNumber NVARCHAR2(20) NULL,
EmailAddress NVARCHAR2(256) NULL,
CONSTRAINT PK_SalesPeople_Preload PRIMARY KEY (SalespersonKey )
);




CREATE OR REPLACE PROCEDURE SalesPeople_Transform
AS
RowCt NUMBER(10);
v_sql VARCHAR(255) := 'TRUNCATE TABLE SalesPeople_Preload DROP STORAGE';
BEGIN
EXECUTE IMMEDIATE v_sql;

INSERT INTO SalesPeople_Preload /* Column list excluded for brevity */
SELECT SalespersonKey.NEXTVAL AS SalespersonKey,
sp.FullName,
sp.PreferredName,
sp.LogonName,
sp.PhoneNumber,
sp.FaxNumber,
sp.EmailAddress
FROM SalesPeople_Stage sp
WHERE NOT EXISTS
( SELECT 1
FROM DimSalesPeople dsp
WHERE sp.FullName = dsp.FullName
AND sp.PreferredName = dsp.PreferredName
AND sp.LogonName = dsp.LogonName
AND sp.PhoneNumber = dsp.PhoneNumber
AND sp.FaxNumber = dsp.FaxNumber
AND sp.EmailAddress = dsp.EmailAddress
);

 RowCt := SQL%ROWCOUNT;
INSERT INTO SalesPeople_Preload /* Column list excluded for brevity */
SELECT SalespersonKey.NEXTVAL AS SalespersonKey,
sp.FullName,
sp.PreferredName,
sp.LogonName,
sp.PhoneNumber,
sp.FaxNumber,
sp.EmailAddress
FROM SalesPeople_Stage sp
JOIN DimSalesPeople dsp
ON sp.FullName = dsp.FullName
AND sp.PreferredName = dsp.PreferredName
AND sp.LogonName = dsp.LogonName
AND sp.PhoneNumber = dsp.PhoneNumber
AND sp.FaxNumber = dsp.FaxNumber
AND sp.EmailAddress = dsp.EmailAddress;

 RowCt := RowCt+SQL%ROWCOUNT;

dbms_output.put_line(RowCt ||' Rows have been inserted!');
COMMIT;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
         dbms_output.put_line('No records found. Check with source system.');
WHEN OTHERS THEN
       dbms_output.put_line(SQLERRM);
       dbms_output.put_line(v_sql);
       ROLLBACK;

END;

EXECUTE SalesPeople_Transform;
SELECT * FROM SalesPeople_Preload;


--*************4. Preload Table and Transform Procedure - Products*********************
SET SERVEROUT ON;

DROP SEQUENCE ProductsKey;
CREATE SEQUENCE ProductsKey START WITH 1 CACHE 10;

CREATE TABLE Products_Preload (
ProductKey INT NOT NULL,
ProductName NVARCHAR2(100) NULL,
ProductColour NVARCHAR2(20) NULL,
ProductBrand NVARCHAR2(50) NULL,
ProductSize NVARCHAR2(20) NULL,
StartDate DATE NOT NULL,
EndDate DATE NULL,
CONSTRAINT PK_Products_Preload PRIMARY KEY ( ProductKey )
);


CREATE OR REPLACE PROCEDURE Products_Transform
AS
    RowCt NUMBER(10);
    v_sql VARCHAR(255) := 'TRUNCATE TABLE Products_Preload DROP STORAGE';
    v_StartDate DATE := SYSDATE; 
    v_EndDate DATE := ((SYSDATE) - 1);
BEGIN
    EXECUTE IMMEDIATE v_sql;
    -- Add updated records
    INSERT INTO Products_Preload -- Column list excluded for brevity 
        SELECT ProductsKey.NEXTVAL AS ProductsKey,
            stg.StockItemName,
            stg.ColorName,
            stg.Brand,
            stg.ItemSize,
            StartDate,
            NULL
        FROM Products_Stage stg
        JOIN DimProducts cu
            ON stg.StockItemName = cu.ProductName 
            AND stg.ColorName = cu.ProductColour
            AND stg.Brand = cu.ProductBrand
            AND stg.ItemSize = cu.ProductSize
            AND cu.EndDate IS NULL;
    
            
            RowCt := SQL%ROWCOUNT;
  
    -- Add existing records, and expire as necessary
    INSERT INTO Products_Preload -- Column list excluded for brevity 
        SELECT cu.ProductKey,
            cu.ProductName,
            cu.ProductColour,
            cu.ProductBrand,
            cu.ProductSize,
            cu.StartDate,
            (CASE WHEN pl.ProductName IS NULL THEN NULL
                ELSE cu.EndDate
            END) AS EndDate
        FROM DimProducts cu
        LEFT JOIN midterm.Products_Preload pl 
            ON pl.ProductName = cu.ProductName
            AND cu.EndDate IS NULL;
            
            RowCt := RowCt+SQL%ROWCOUNT;


        -- Create new records
    INSERT INTO Products_Preload -- Column list excluded for brevity 
        SELECT ProductsKey.NEXTVAL AS ProductsKey,
            stg.StockItemName,
            stg.ColorName,
            stg.Brand,
            stg.ItemSize,
            (v_StartDate),
            NULL
        FROM Products_Stage stg
        WHERE NOT EXISTS ( SELECT 1 FROM DimProducts cu WHERE stg.StockItemName = cu.ProductName );
        
        RowCt := RowCt+SQL%ROWCOUNT;

    -- Expire missing records--------correct ythi
     INSERT INTO Products_Preload -- Column list excluded for brevity 
        SELECT cu.ProductKey,
            cu.ProductName,
            cu.ProductColour,
            cu.ProductBrand,
            cu.ProductSize,
            cu.StartDate,
            (v_EndDate)
        FROM DimProducts cu
        WHERE NOT EXISTS ( SELECT 1 FROM Products_Stage stg WHERE stg.StockItemName = cu.ProductName )
            AND cu.EndDate IS NULL;
    
      RowCt := RowCt+SQL%ROWCOUNT;

     
dbms_output.put_line(RowCt ||' Rows have been inserted!');
COMMIT;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
         dbms_output.put_line('No records found. Check with source system.');
WHEN OTHERS THEN
       dbms_output.put_line(SQLERRM);
       dbms_output.put_line(v_sql);
       ROLLBACK;
END;


EXECUTE Products_Transform;
SELECT * FROM Products_preload;


--*************5. Preload Table and Transform Procedure - Suppliers*********************
 SET SERVEROUT ON;

DROP SEQUENCE Key;
CREATE SEQUENCE SuppliersKey START WITH 1 CACHE 10;

CREATE TABLE Suppliers_Preload(
SupplierKey NUMBER(10) NOT NULL,
SupplierCategoryName    NVARCHAR2(50),
FullName NVARCHAR2(50)  NULL,
PhoneNumber NVARCHAR2(20) NULL,
FaxNumber NVARCHAR2(20) NULL,
WebsiteURL NVARCHAR2(256) NULL,
StartDate DATE NOT NULL,
EndDate DATE NULL,
CONSTRAINT PK_Suppliers_Preload PRIMARY KEY (SupplierKey)
);


CREATE OR REPLACE PROCEDURE Suppliers_Transform
AS
    RowCt NUMBER(10);
    v_sql VARCHAR(255) := 'TRUNCATE TABLE Suppliers_Preload DROP STORAGE';
    v_StartDate DATE := SYSDATE; 
    v_EndDate DATE := ((SYSDATE) - 1);
BEGIN
    EXECUTE IMMEDIATE v_sql;
    -- Add updated records
    INSERT INTO Suppliers_Preload -- Column list excluded for brevity 
        SELECT SuppliersKey.NEXTVAL AS SuppliersKey,
            stg.SupplierCategoryName,
            stg.FullName,
            stg.PhoneNumber,
            stg.FaxNumber,
            stg.WebsiteURL,
            StartDate,
            NULL
        FROM Suppliers_Stage stg
        JOIN DimSuppliers cu
            ON stg.SupplierCategoryName = cu.SupplierCategoryName 
            AND stg.FullName = cu.FullName
            AND stg.PhoneNumber = cu.PhoneNumber
            AND stg.FaxNumber = cu.FaxNumber
            AND stg.WebsiteURL = cu.WebsiteURL
            AND cu.EndDate IS NULL;
    
            
            RowCt := SQL%ROWCOUNT;
  
    -- Add existing records, and expire as necessary
    INSERT INTO Suppliers_Preload -- Column list excluded for brevity 
        SELECT cu.SupplierKey,
            cu.SupplierCategoryName,
            cu.FullName,
            cu.PhoneNumber,
            cu.FaxNumber,
            cu.WebsiteURL,
            cu.StartDate,
            (CASE WHEN pl.SupplierCategoryName IS NULL THEN NULL
                ELSE cu.EndDate
            END) AS EndDate
        FROM DimSuppliers cu
        LEFT JOIN midterm.Suppliers_Preload pl 
            ON pl.FullName = cu.FullName
            AND cu.EndDate IS NULL;
            
            RowCt := RowCt+SQL%ROWCOUNT;


        -- Create new records
    INSERT INTO Suppliers_Preload -- Column list excluded for brevity 
        SELECT SuppliersKey.NEXTVAL AS SuppliersKey,
            stg.SupplierCategoryName,
            stg.FullName,
            stg.PhoneNumber,
            stg.FaxNumber,
            stg.WebsiteURL,
            (v_StartDate),
            NULL
        FROM Suppliers_Stage stg
        WHERE NOT EXISTS ( SELECT 1 FROM DimSuppliers cu WHERE stg.FullName = cu.FullName );
        
        RowCt := RowCt+SQL%ROWCOUNT;

    -- Expire missing records
     
    INSERT INTO Suppliers_Preload -- Column list excluded for brevity 
        SELECT cu.SupplierKey,
            cu.SupplierCategoryName,
            cu.FullName,
            cu.PhoneNumber,
            cu.FaxNumber,
            cu.WebsiteURL,
            cu.StartDate,
            (v_EndDate)
        FROM DimSuppliers cu
        WHERE NOT EXISTS ( SELECT 1 FROM Suppliers_Stage stg WHERE stg.FullName = cu.FullName )
            AND cu.EndDate IS NULL;
    
      RowCt := RowCt+SQL%ROWCOUNT;

     
dbms_output.put_line(RowCt ||' Rows have been inserted!');
COMMIT;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
         dbms_output.put_line('No records found. Check with source system.');
WHEN OTHERS THEN
       dbms_output.put_line(SQLERRM);
       dbms_output.put_line(v_sql);
       ROLLBACK;
END;


EXECUTE Suppliers_Transform;
SELECT * FROM Suppliers_Preload;


--*************6. Preload Table and Transform Procedure - Orders*********************


CREATE TABLE Orders_Preload (
CustomerKey NUMBER(10) NOT NULL,
LocationKey NUMBER(10) NOT NULL,
ProductKey NUMBER(10) NOT NULL,
SalespersonKey NUMBER(10) NOT NULL,
DateKey NUMBER(8) NOT NULL,
Quantity NUMBER(3) NOT NULL,
UnitPrice NUMBER(18, 2) NOT NULL,
TaxRate NUMBER(18, 3) NOT NULL,
TotalBeforeTax NUMBER(18, 2) NOT NULL,
TotalAfterTax NUMBER(18, 2) NOT NULL
);


CREATE OR REPLACE PROCEDURE Orders_Transform
AS
RowCt NUMBER(10);
v_sql VARCHAR(255) := 'TRUNCATE TABLE Orders_Preload DROP STORAGE';
BEGIN
EXECUTE IMMEDIATE v_sql;
INSERT INTO Orders_Preload /* Columns excluded for brevity */
SELECT cu.CustomerKey,
ci.LocationKey,
pr.ProductKey,
sp.SalespersonKey,
EXTRACT(YEAR FROM ord.OrderDate)*10000 + EXTRACT(Month FROM ord.OrderDate)*100 + EXTRACT(Day FROM ord.OrderDate),
SUM(ord.Quantity) AS Quantity,
AVG(ord.UnitPrice) AS UnitPrice,
AVG(ord.TaxRate) AS TaxRate,
SUM(ord.Quantity * ord.UnitPrice) AS TotalBeforeTax,
SUM(ord.Quantity * ord.UnitPrice * (1 + ord.TaxRate/100)) AS TotalAfterTax
FROM Orders_Stage ord
JOIN Customers_Preload cu
ON ord.CustomerName = cu.CustomerName
JOIN Locations_Preload ci
ON ord.CityName = ci.CityName AND ord.StateProvinceName = ci.StateProvName
AND ord.CountryName = ci.CountryName
JOIN Products_Preload pr
ON ord.StockItemName = pr.ProductName
JOIN SalesPeople_Preload sp
ON ord.LogonName = sp.LogonName;
END;

EXECUTE Orders_Transform;
SELECT * FROM Orders_Preload;







/* REQUIREMENT 6 */
CREATE OR REPLACE PROCEDURE Orders_Load()
AS
rowCnt NUMBER(10);
v_sql VARCHAR(255) := '';
BEGIN

INSERT INTO FactSales (customerkey, citykey, productkey, salespersonkey, datekey, quantity, unitprice, taxrate, totalbeforetax, totalaftertax)
SELECT customerkey, locationkey, productkey, salespersonkey, datekey, quantity, unitprice, taxrate, totalbeforetax, totalaftertax
FROM Orders_Preload;

rowCnt := SQL%ROWCOUNT;

dbms_output.put_line('Number of inserted records: ' || rowCnt);

END;

EXECUTE Orders_Load();

CREATE OR REPLACE PROCEDURE Customers_Load
AS
rowCnt NUMBER(10);
v_sql VARCHAR(255) := '';
BEGIN

    DELETE FROM  dimcustomers where customerkey in (select cust.customerkey
    from dimcustomers cust join customers_Preload pre on cust.customerkey = pre.customerkey);
    insert into dimcustomers 
    select * 
    from customers_Preload;

rowCnt := SQL%ROWCOUNT;

dbms_output.put_line('Number of inserted records: ' || rowCnt);

END;

EXECUTE Customers_Load();

CREATE OR REPLACE PROCEDURE Salespeople_Load
AS
rowCnt NUMBER(10);
v_sql VARCHAR(255) := '';
BEGIN

    DELETE FROM   dimsalespeople where  SalespersonKey
    in (select spp.SalespersonKey from dimsalespeople sp join salespeople_preload spp on spp.salespersonkey = sp.salespersonkey);
    insert into dimsalespeople
    select * 
    from salespeople_preload;

rowCnt := SQL%ROWCOUNT;

dbms_output.put_line('Number of inserted records: ' || rowCnt);


END;


EXECUTE Salespeople_Load();

CREATE OR REPLACE PROCEDURE Locations_Load
AS
rowCnt NUMBER(10);
v_sql VARCHAR(255) := '';
BEGIN

    DELETE FROM  dimcities where citykey in
    (select loc.citykey from dimcities loc join locations_preload locpre on loc.citykey = locpre.locationkey);
    insert into dimcities
    select * 
    from locations_preload;

rowCnt := SQL%ROWCOUNT;

dbms_output.put_line('Number of inserted records: ' || rowCnt);

END;

EXECUTE Locations_Load();


CREATE OR REPLACE PROCEDURE Product_Load
AS
rowCnt NUMBER(10);
v_sql VARCHAR(255) := '';
BEGIN

    delete from dimproducts where productkey in (select pre.productkey from products_preload pre);
    insert into dimproducts
    select * 
    from products_preload;

rowCnt := SQL%ROWCOUNT;

dbms_output.put_line('Number of inserted records: ' || rowCnt);

END;

EXECUTE Product_Load();

