

---Assignment 4&5---
--Basavraj Jaliminche 8800149--
/* REQUIREMENT 1 */

CREATE TABLE PEOPLE (

    PERSONID int(10), 
	FULLNAME nvarchar(50) NOT NULL, 
	PREFERREDNAME nvarchar(50) NOT NULL, 
	ISPERMITTEDTOLOGON numeric(1,0) NOT NULL, 
	LOGONNAME nvarchar(50), 
	ISEXTERNALLOGONPROVIDER numeric(1,0) NOT NULL , 
	ISSYSTEMUSER numeric(1,0) NOT NULL , 
	ISEMPLOYEE numeric(1,0) NOT NULL , 
	ISSALESPERSON numeric(1,0) NOT NULL , 
	USERPREFERENCES nvarchar(400), 
	PHONEint nvarchar(20), 
	FAXint nvarchar(20), 
	EMAILADDRESS nvarchar(256), 
	CONSTRAINT PK_PEOPLE_ID PRIMARY KEY (PERSONID)

);

CREATE TABLE Countries(

	CountryID int (10) NOT NULL,
	CountryName nvarchar(60) NOT NULL,
	FormalName nvarchar(60) NOT NULL,
	IsoAlpha3Code nvarchar(3) NULL,
	IsoNumericCode int (10) NULL,
	CountryType nvarchar(20) NULL,
	LatestRecordedPopulation int(12) NULL,
	Continent nvarchar(30) NOT NULL,
	Region nvarchar(30) NOT NULL,
	Subregion nvarchar(30) NOT NULL,
    CONSTRAINT PK_Countries_ID PRIMARY KEY (CountryID), 
    CONSTRAINT UQ_Countries_CountryName UNIQUE(CountryName)
);

SELECT * FROM Countries;


CREATE TABLE StateProvinces(
	StateProvinceID int(10),
	StateProvinceCode nvarchar(5) NOT NULL,
	StateProvinceName nvarchar(50) NOT NULL,
	CountryID int(10) NOT NULL,
	SalesTerritory nvarchar(50) NOT NULL,
	LatestRecordedPopulation int(12) NULL,
 	CONSTRAINT PK_StateProvinces_ID PRIMARY KEY (StateProvinceID),
	CONSTRAINT FK_StateProvinces_CountryID_Countries FOREIGN KEY(CountryID) REFERENCES Countries (CountryID)
);


CREATE TABLE Cities(
	CityID int(10),
	CityName nvarchar(50) NOT NULL,
	StateProvinceID int(10) NOT NULL,
	LatestRecordedPopulation int(12) NULL,
 CONSTRAINT PK_Cities_ID PRIMARY KEY (CityID), 
 CONSTRAINT FK_Cities_StateProvinceID_StateProvinces FOREIGN KEY(StateProvinceID) REFERENCES StateProvinces (StateProvinceID)
);
SELECT * FROM Cities;

CREATE TABLE CustomerCategories(
	CustomerCategoryID int(10),
	CustomerCategoryName nvarchar(50) NOT NULL,
    CONSTRAINT PK_CustomerCategories_ID PRIMARY KEY (CustomerCategoryID),
    CONSTRAINT UQ_CustomerCategories_CustomerCategoryName UNIQUE (CustomerCategoryName)
);
SELECT * FROM CustomerCategories;


CREATE TABLE DeliveryMethods(
	DeliveryMethodID INT(10),
	DeliveryMethodName nvarchar(50) NOT NULL,
    CONSTRAINT PK_DeliveryMethods PRIMARY KEY (DeliveryMethodID),
    CONSTRAINT UQ_DeliveryMethods_DeliveryMethodName UNIQUE (DeliveryMethodName)
);
SELECT * FROM DeliveryMethods;

CREATE TABLE Customers(
	CustomerID int(10) NOT NULL,
	CustomerName nvarchar(100) NOT NULL,
	BillToCustomerID int(10) NOT NULL,
	CustomerCategoryID int(10) NOT NULL,
	PrimaryContactPersonID int(10) NOT NULL,
	DeliveryMethodID int(10) NOT NULL,
	DeliveryCityID int(10) NOT NULL,
	PostalCityID int(10) NOT NULL,
	CreditLimit numeric(18, 2) NOT NULL,
	AccountOpenedDate date NOT NULL,
	StandardDiscountPercentage numeric(18, 3) NOT NULL,
	IsStatementSent int(1) NOT NULL,
	IsOnCreditHold int(1) NOT NULL,
	PaymentDays int(10) NOT NULL,
	Phoneint nvarchar(20) NOT NULL,
	Faxint nvarchar(20) NOT NULL,
	WebsiteURL nvarchar(256) NOT NULL,
	DeliveryAddressLine1 nvarchar(60) NOT NULL,
	DeliveryAddressLine2 nvarchar(60) NULL,
	DeliveryPostalCode nvarchar(10) NOT NULL,
	PostalAddressLine1 nvarchar(60) NOT NULL,
	PostalAddressLine2 nvarchar(60) NULL,
	PostalPostalCode nvarchar(10) NOT NULL,
 	CONSTRAINT PK_Sales_Customers_ID PRIMARY KEY (CustomerID),
	CONSTRAINT FK_Customers_PrimaryContactPersonID_People FOREIGN KEY(PrimaryContactPersonID) REFERENCES People (PersonID)
);
SELECT * FROM customers;

CREATE TABLE Colors(
	ColorID int(10),
	ColorName nvarchar(20) NOT NULL,
    CONSTRAINT PK_Colors_ID PRIMARY KEY (ColorID),
    CONSTRAINT UQ_Colors_ColorName UNIQUE (ColorName)
);
TRUNCATE TABLE Colors;
SELECT * FROM Colors;

CREATE TABLE SupplierCategories(
	SupplierCategoryID int(10),
	SupplierCategoryName nvarchar(50) NOT NULL,
    CONSTRAINT PK_SupplierCategories_ID PRIMARY KEY (SupplierCategoryID),
    CONSTRAINT UQ_SupplierCategories_SupplierCategoryName UNIQUE (SupplierCategoryName)
);
SELECT * FROM SupplierCategories;
DROP TABLE Suppliers;
CREATE TABLE Suppliers(
	SupplierID int(10) NOT NULL,
	SupplierName nvarchar(100) NOT NULL,
	SupplierCategoryID int(10) NOT NULL,
	PrimaryContactPersonID int(10) NOT NULL,
	DeliveryCityID int(10) NOT NULL,
	PostalCityID int(10) NOT NULL,
	SupplierReference nvarchar(20) NULL,
	BankAccountName nvarchar(50) NULL,
	BankAccountBranch nvarchar(50) NULL,
	BankAccountCode nvarchar(20) NULL,
	BankAccountint nvarchar(20) NULL,
	BankInternationalCode nvarchar(20) NULL,
	PaymentDays int(10) NOT NULL,
	InternalComments nvarchar(300) NULL,
	Phoneint nvarchar(20) NOT NULL,
	Faxint nvarchar(20) NOT NULL,
	WebsiteURL nvarchar(256) NOT NULL,
	DeliveryAddressLine1 nvarchar(60) NOT NULL,
	DeliveryAddressLine2 nvarchar(60) NULL,
	DeliveryPostalCode nvarchar(10) NOT NULL,
	PostalAddressLine1 nvarchar(60) NOT NULL,
	PostalAddressLine2 nvarchar(60) NULL,
	PostalPostalCode nvarchar(10) NOT NULL,
	CONSTRAINT PK_Suppliers_ID PRIMARY KEY (SupplierID),
	CONSTRAINT UQ_Suppliers_SupplierName UNIQUE (SupplierName),
	CONSTRAINT FK_Suppliers_PrimaryContactPersonID_People FOREIGN KEY(PrimaryContactPersonID) REFERENCES People (PersonID),
	CONSTRAINT FK_Suppliers_DeliveryCityID_Cities FOREIGN KEY(DeliveryCityID) REFERENCES Cities (CityID),
	CONSTRAINT FK_Suppliers_PostalCityID_Cities FOREIGN KEY(PostalCityID) REFERENCES Cities (CityID),
	CONSTRAINT FK_Suppliers_SupplierCategoryID_SupplierCategories FOREIGN KEY(SupplierCategoryID) REFERENCES SupplierCategories (SupplierCategoryID)
);


SELECT * FROM suppliers;


CREATE TABLE StockItems(
	StockItemID int(10),
	StockItemName nvarchar(100) NOT NULL,
	SupplierID int(10) NOT NULL,
	ColorID int(10) NULL,
	Brand nvarchar(50) NULL,
	ItemSize nvarchar(20) NULL,
	LeadTimeDays int(10) NOT NULL,
	QuantityPerOuter int(10) NOT NULL,
	IsChillerStock int(1) NOT NULL,
	Barcode nvarchar(50) NULL,
	TaxRate numeric(18, 3) NOT NULL,
	UnitPrice numeric(18, 2) NOT NULL,
	RecommendedRetailPrice numeric(18, 2) NULL,
	TypicalWeightPerUnit numeric(18, 3) NOT NULL,
	MarketingComments nvarchar(300) NULL,
	InternalComments nvarchar(300) NULL,
	CustomFields nvarchar(300) NULL,
	Tags nvarchar(200) NULL,
	SearchDetails nvarchar(200) NULL,
	CONSTRAINT PK_StockItems PRIMARY KEY (StockItemID),
	CONSTRAINT UQ_StockItems_StockItemName UNIQUE (StockItemName),
	CONSTRAINT FK_StockItems_ColorID_Colors FOREIGN KEY(ColorID) REFERENCES Colors (ColorID),
	CONSTRAINT FK_StockItems_SupplierID_Suppliers FOREIGN KEY(SupplierID) REFERENCES Suppliers (SupplierID)
);

CREATE TABLE Orders(
	OrderID int(10),
	CustomerID int(10) NOT NULL,
	SalespersonPersonID int(10) NOT NULL,
	ContactPersonID int(10) NOT NULL,
	OrderDate date NOT NULL,
	ExpectedDeliveryDate date NOT NULL,
	CustomerPurchaseOrderint nvarchar(20) NULL,
	IsUndersupplyBackordered int(1) NOT NULL,
	PickingCompletedWhen Date NULL,
	LastEditedBy int(10) NOT NULL,
	LastEditedWhen Date NOT NULL,
	CONSTRAINT PK_Orders_ID PRIMARY KEY (OrderID),
	CONSTRAINT FK_Orders_CustomerID_Customers FOREIGN KEY(CustomerID) REFERENCES Customers (CustomerID),
	CONSTRAINT FK_Orders_SalespersonPersonID_People FOREIGN KEY(SalespersonPersonID) REFERENCES People (PersonID),
	CONSTRAINT FK_Orders_ContactPersonID_People FOREIGN KEY(ContactPersonID) REFERENCES People (PersonID),
	CONSTRAINT FK_Orders_People FOREIGN KEY(LastEditedBy) REFERENCES People (PersonID)
);


SELECT * FROM orders WHERE orderdate = '2013-01-01';


DROP TABLE OrderLines;
CREATE TABLE OrderLines(
	OrderLineID int(10) NOT NULL,
	OrderID int(10) NOT NULL,
	StockItemID int(10) NOT NULL,
	Description nvarchar(100) NOT NULL,
	Quantity int(4) NOT NULL,
	UnitPrice numeric(18, 2) NULL,
	TaxRate numeric(18, 3) NOT NULL,
	PickedQuantity int(4) NOT NULL,
	PickingCompletedWhen Date NULL,
	CONSTRAINT PK_OrderLines_ID PRIMARY KEY (OrderLineID),
	CONSTRAINT FK_OrderLines_Orders FOREIGN KEY(OrderID) REFERENCES Orders (OrderID),
	CONSTRAINT FK_OrderLines_StockItemID_StockItems FOREIGN KEY(StockItemID) REFERENCES StockItems (StockItemID)
);


TRUNCATE TABLE OrderLines;

SELECT * FROM OrderLines;



/* REQUIREMENT 2 */


CREATE PROCEDURE dimDate_Load
DECLARE @DateValue DATE;
BEGIN; 
INSERT INTO dbo . DimDate SELECT CAST( YEAR(@DateValue) * 10000 + MONTH(@DateValue) * 100 + DAY(@DateValue) AS INT), 
@DateValue, 
YEAR (@DateValue) , 
MONTH (@DateValue) , 
DAY (@DateValue) , 
DATEPART (qq, @DateValue) , 
DATEADD (DAY , 1, EOMONTH (@DateValue, -1) ) , 
EOMONTH(@DateValue) , DATENAME ( mm, @DateValue) , 
DATENAME ( dw, @DateValue) ; 
END


/* REQUIREMENT 3 */

select `wwi-db`.` customers`.`CustomerName`,`wwi-db`.`orders`.`orderID`,`wwi-db`.`people`.`FULLNAME`,`wwi-db`.`suppliers`.`SupplierName`,`wwi-db`.`orderlines`.`OrderID`
from `wwi-db`.` customers`,`wwi-db`.`orders`,`wwi-db`.`people`,`wwi-db`.`suppliers`,`wwi-db`.`orderlines`
where `wwi-db`.` customers`.`CustomerID`=`wwi-db`.`orders`.`orderID`=`wwi-db`.`people`.`PERSONID`=`wwi-db`.`suppliers`.`SupplierID`=`wwi-db`.`orderlines`.`OrderID`



---Assignment 5---

/* REQUIREMENT 4 */

select `wwi-db`.` customers`.`CustomerName`,`wwi-db`.`orderlines`.`Description`, `wwi-db`.`colors`.`ColorName`
from `wwi-db`.` customers`,`wwi-db`.`orderlines`, `wwi-db`.`colors`
where `wwi-db`.` customers`.`CustomerID`=`wwi-db`.`orderlines`.`OrderID`= `wwi-db`.`colors`.`ColorID`


/* REQUIREMENT 5 */

/* 
1.	No changes required as type-0 fixed dimension
2.	No update records 
3.	Utilise techniques from SCD  */




/* REQUIREMENT 6 */


CREATE PROCEDURE dimDatess
DECLARE @DateValue DATE;
BEGIN; 
INSERT INTO dbo . DimDate SELECT CAST( YEAR(@DateValue) * 10000 + MONTH(@DateValue) * 100 + DAY(@DateValue) AS INT), 
@DateValue, 
YEAR (@DateValue) , 
MONTH (@DateValue) , 
DAY (@DateValue) , 
DATEPART (qq, @DateValue) , 
DATEADD (DAY , 1, EOMONTH (@DateValue, -1) ) , 
EOMONTH(@DateValue) , DATENAME ( mm, @DateValue) , 
DATENAME ( dw, @DateValue) ; 
END

