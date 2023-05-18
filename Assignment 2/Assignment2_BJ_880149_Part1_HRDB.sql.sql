---- Assignment 2 Part 1 Initial Database -------------------
CREATE TABLE A2P2_Departments(
	DepartmentID 	NUMBER(10) GENERATED ALWAYS AS IDENTITY,
	DepartmentName 	NVARCHAR2(150) NOT NULL,
	StreetAddress 	NVARCHAR2(100) NOT NULL,
	City 			NVARCHAR2(60) NOT NULL,
	Province 		NVARCHAR2(50) NOT NULL,
	PostalCode 		CHAR(6) NOT NULL,
	MaxWorkstations NUMBER(10) NOT NULL,
	CONSTRAINT PK_Department PRIMARY KEY (DepartmentID)
);

CREATE TABLE A2P2_PhoneTypes(
	PhoneTypeID NUMBER(10) GENERATED ALWAYS AS IDENTITY,
	PhoneType NVARCHAR2(50) NOT NULL,
	CONSTRAINT PK_PhoneTypes PRIMARY KEY (PhoneTypeID)
);
  
CREATE TABLE A2P2_Employees(
	EmployeeID NUMBER(10) GENERATED ALWAYS AS IDENTITY,
	FirstName NVARCHAR2(50) NOT NULL,
	MiddleName NVARCHAR2(50) NULL,
	LastName NVARCHAR2(50) NOT NULL,
	DateofBirth DATE NOT NULL,
	SIN char(9) NOT NULL,
	DefaultDepartmentID  NUMBER(10) NOT NULL,
    CurrentDepartmentID  NUMBER(10) NOT NULL,
	ReportsToEmployeeID NUMBER(10) NULL, 
	StreetAddress NVARCHAR2(100) NULL,
	City NVARCHAR2(60) NULL,
	Province NVARCHAR2(50) NULL,
	PostalCode CHAR(6) NULL,
	StartDate  DATE NOT NULL,
	BaseSalary NUMBER(18, 2) NOT NULL,
-- 	BonusPercent NUMBER(3, 2) NOT NULL -- Best not to Store, as this Can be calculated from Employee data
	CONSTRAINT PK_Employee PRIMARY KEY (EmployeeID),
	CONSTRAINT FK_Employee_Department_Default FOREIGN KEY (DefaultDepartmentID) REFERENCES A2P2_Departments ( DepartmentID ),
	CONSTRAINT FK_Employee_Department_Current FOREIGN KEY (CurrentDepartmentID) REFERENCES A2P2_Departments ( DepartmentID ),
	CONSTRAINT FK_Employee_ReportsTo FOREIGN KEY (ReportsToEmployeeID) REFERENCES A2P2_Employees ( EmployeeID )

);

CREATE TABLE A2P2_EmployeePhoneNumbers(
	EmployeePhoneNumberID NUMBER(10) GENERATED ALWAYS AS IDENTITY,
	EmployeeID NUMBER(10) NOT NULL, 
	PhoneTypeID NUMBER(10) NOT NULL, 
	PhoneNumber NVARCHAR2(14) NULL,
	CONSTRAINT PK_EmployeePhoneNumbers PRIMARY KEY (EmployeePhoneNumberID),
	CONSTRAINT FK_EmployeePhoneNumbers_Employee FOREIGN KEY(EmployeeID) REFERENCES A2P2_Employees ( EmployeeID ),
	CONSTRAINT FK_EmployeePhoneNumbers_PhoneTypes FOREIGN KEY(PhoneTypeID) REFERENCES A2P2_PhoneTypes (PhoneTypeID )
); 

CREATE TABLE A2P2_BenefitTypes(
	BenefitTypeID NUMBER(10) GENERATED ALWAYS AS IDENTITY, 
	BenefitType NVARCHAR2(100) NOT NULL,
	BenefitCompanyName NVARCHAR2(100) NOT NULL,
    PolicyNumber INT NULL,
	CONSTRAINT PK_BenefitTypes PRIMARY KEY (BenefitTypeID)
);

CREATE TABLE A2P2_EmployeeBenefits(
	EmployeeBenefitID NUMBER(10) GENERATED ALWAYS AS IDENTITY, 
	EmployeeId NUMBER(10) NOT NULL, 
	BenefitTypeID NUMBER(10) NOT NULL, 
    StartDate DATE NULL,
	CONSTRAINT PK_EmployeeBenefits PRIMARY KEY(EmployeeBenefitID), 
	CONSTRAINT FK_Employee FOREIGN KEY (EmployeeId) REFERENCES A2P2_Employees ( EmployeeID ),
	CONSTRAINT FK_Employee_BenefitTypes FOREIGN KEY (BenefitTypeID) REFERENCES A2P2_BenefitTypes ( BenefitTypeID )
);

CREATE TABLE A2P2_Providers (
	ProviderID NUMBER(10) GENERATED ALWAYS AS IDENTITY, 
	ProviderName  NVARCHAR2(50) NOT NULL,
	ProviderAddress NVARCHAR2(60) NOT NULL,
	ProviderCity NVARCHAR2(50) NOT NULL,
	CONSTRAINT PK_Providers PRIMARY KEY (ProviderID) 
);

CREATE TABLE A2P2_Claims(
	ClaimID NUMBER(10) GENERATED ALWAYS AS IDENTITY, 
	ProviderID NUMBER(10) NOT NULL, 
	ClaimAmount NUMBER(18, 2) NOT NULL,
	ServiceDate DATE NOT NULL,
	EmployeeBenefitID INT NULL, 
	ClaimDate DATE NOT NULL,
	CONSTRAINT PK_Claims PRIMARY KEY (ClaimID), 
	CONSTRAINT FK_Provider FOREIGN KEY (ProviderID) REFERENCES A2P2_Providers ( ProviderID ),
	CONSTRAINT FK_Claims_EmployeeBenefits FOREIGN KEY (EmployeeBenefitID) REFERENCES A2P2_EmployeeBenefits ( EmployeeBenefitID )
);

---**Solutions**---


--1.The customer has told you that whenever an employee is added, their SIN number is used to uniquely identify that
--employee in the database. Lookups on SIN Number will need to be properly optimized and constrained.---

CREATE unique INDEX employee_socialinsurancenumber
ON A2P2_Employees(SIN);

--2.In testing, the customer found that a department’s maximum number of physical workstations would sometimes
--incorrectly be set to a negative number. Since this is invalid, they would like to prevent negative numbers from
--being added to the maximum workstations’ column. Testing also found that department records were frequently
--looked up by DepartmentName, which can be used to uniquely identify records. They would like these lookups
--optimized.--

ALTER TABLE A2P2_Departments
ADD CONSTRAINT max_workstations_greater_than_zero check (MaxWorkstations > 0);

--3.The customer has identified that dates in the system (Employees.DateOfBirth, Employee.StartDate,
--EmployeeBenefits.StartDate, Claims.ServiceDate, and Claims.ClaimDate) should never be a future date, so they
--must be equal to or less than the current datetime. When testing these tables the customer discovered that
--Benefits will often be uniquely identified by PolicyNumber. This lookup will need to be optimized.--

CREATE unique INDEX department_name_unique
ON A2P2_Departments(departmentname);


ALTER TABLE A2P2_Employees
add redundant date default sysdate;

ALTER TABLE A2P2_Employees
ADD CONSTRAINT dob_past_present check (DateofBirth <= redundant);
ALTER TABLE A2P2_Employees
ADD CONSTRAINT start_date_past_present check (StartDate <= redundant);
ALTER TABLE A2P2_EmployeeBenefits
add redundant date default sysdate;
ALTER TABLE A2P2_EmployeeBenefits
ADD CONSTRAINT start_date_past_present_emp_benf check (StartDate <= redundant);
ALTER TABLE A2P2_claims
add redundant  date default sysdate;
ALTER TABLE A2P2_claims
ADD CONSTRAINT serv_date_past_present_claims check (servicedate <= redundant);
ALTER TABLE A2P2_claims
ADD CONSTRAINT claimdate_past_present_claims check (claimdate <= redundant);
CREATE unique INDEX policy_number_unique
ON A2P2_BenefitTypes(PolicyNumber);

--4.To improve consistency, the customer has asked you to provide some suitable defaults when complete details are
--not available. When not provided, Employee.BaseSalary and ClaimAmount should be set to $0, and
--Department.MaxWorkStations should be set to 1, and Claims.ServiceDate and Claims.ClaimDate should be set to
--the current date.--

ALTER TABLE A2P2_Employees MODIFY BaseSalary DEFAULT 0;
ALTER TABLE A2P2_Claims MODIFY ClaimAmount DEFAULT 0;
ALTER TABLE A2P2_Departments MODIFY MaxWorkStations DEFAULT 1;

ALTER TABLE A2P2_Claims MODIFY ServiceDate DEFAULT SYSDATE;
ALTER TABLE A2P2_Claims MODIFY ClaimDate DEFAULT SYSDATE;

--5.A review of queries on the Employees table identified three queries that need to be optimized. The first query
--creates a sorted list of cities and postal codes. This list is sorted by city first, then by postal code. The second query
--looks up records by city only. The last query looks up records by postal code only.--

CREATE  INDEX city_post
ON A2P2_Employees(city,postalcode);
CREATE  INDEX ind_city
ON A2P2_Employees(city);
CREATE  INDEX ind_post
ON A2P2_Employees(postalcode);

--6,7.The customer has found that lookups will frequently be done in both directions across all foreign keys. They would
--like lookups by the parent and child columns optimized for all foreign keys. They would also like you to optimize
--lookups in both directions across the three junction tables.
--Covering indexes should be provided to quickly look up Employees by PhoneTypes, PhoneTypes by Employees,
--Employees by BenefitTypes, BenefitTypes by Employees, Providers by EmployeeBenefits, or EmployeeBenefits by
--Providers--

CREATE INDEX fk_DefaultDepartmentID
ON A2P2_Employees (DefaultDepartmentID);
CREATE INDEX fk_CurrentDepartmentID 
ON A2P2_Employees (CurrentDepartmentID);
CREATE INDEX fk_ReportsToEmployeeID
ON A2P2_Employees (ReportsToEmployeeID);
CREATE INDEX fk_empid_benfid
ON A2P2_EmployeeBenefits(EmployeeId,BenefitTypeID);
CREATE INDEX fk_benfid_empid
ON A2P2_EmployeeBenefits(BenefitTypeID,EmployeeId);

CREATE INDEX fk_empid_phnid
ON A2P2_EmployeePhoneNumbers(EmployeeID,PhoneTypeID);

CREATE INDEX fk_phnid_empid
ON A2P2_EmployeePhoneNumbers(PhoneTypeID,EmployeeID);
CREATE INDEX fk_provid_empbenfid
ON A2P2_Claims(ProviderID,EmployeeBenefitID);
CREATE INDEX fk_empbenfid_provid
ON A2P2_Claims(EmployeeBenefitID,ProviderID);






