
CREATE TABLE Ass2_Departments (
    DepartmentID    NUMBER(10) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    DepartmentName  NVARCHAR2(50),
    DepartmentDesc  NVARCHAR2(100) DEFAULT 'Dept. Description to be determined' NOT NULL 
);

CREATE TABLE Ass2_Employees (
    EmployeeID          NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    DepartmentID        NUMBER(10),
    ManagerEmployeeID   NUMBER(10),
    FirstName           NVARCHAR2(50),
    LastName            NVARCHAR2(50),
    Salary              NUMBER(18,2),
    CommissionBonus     NUMBER(18,2),
    FileFolder          NVARCHAR2(256) DEFAULT 'ToBeBuilt',
    CONSTRAINT PK_Ass2Employees_ID PRIMARY KEY (EmployeeID),
    CONSTRAINT FK_Ass2Employee_Department FOREIGN KEY (DepartmentID) REFERENCES Ass2_Departments ( DepartmentID ),
    CONSTRAINT FK_Ass2Employee_Manager FOREIGN KEY (ManagerEmployeeID) REFERENCES Ass2_Employees ( EmployeeID ),
    CONSTRAINT CK_Ass2EmployeeSalary CHECK ( Salary >= 0 ),
    CONSTRAINT CK_Ass2EmployeeCommission CHECK ( CommissionBonus >= 0 )
);



INSERT INTO Ass2_Departments ( DepartmentName, DepartmentDesc )
VALUES ( 'Management', 'Executive Management' );
INSERT INTO Ass2_Departments ( DepartmentName, DepartmentDesc )
VALUES ( 'HR', 'Human Resources' );
INSERT INTO Ass2_Departments ( DepartmentName, DepartmentDesc )
VALUES ( 'DatabaseMgmt', 'Database Management');
INSERT INTO Ass2_Departments ( DepartmentName, DepartmentDesc )
VALUES ( 'Support', 'Product Support' );
INSERT INTO Ass2_Departments ( DepartmentName, DepartmentDesc )
VALUES ( 'Software', 'Software Sales' );
INSERT INTO Ass2_Departments ( DepartmentName, DepartmentDesc )
VALUES ( 'Peripheral', 'Peripheral Sales' );


INSERT INTO Ass2_Employees ( DepartmentID, ManagerEmployeeID, FirstName, LastName, Salary, CommissionBonus, FileFolder )
VALUES ( 1, NULL, 'Sarah', 'Campbell', 76000, NULL, 'SarahCampbell' );
INSERT INTO Ass2_Employees ( DepartmentID, ManagerEmployeeID, FirstName, LastName, Salary, CommissionBonus, FileFolder )
VALUES ( 3, 1, 'James', 'Donoghue',     66000 , NULL, 'JamesDonoghue');
INSERT INTO Ass2_Employees ( DepartmentID, ManagerEmployeeID, FirstName, LastName, Salary, CommissionBonus, FileFolder )
VALUES ( 1, 1, 'Hank', 'Brady',        74000 , NULL, 'HankBrady');
INSERT INTO Ass2_Employees ( DepartmentID, ManagerEmployeeID, FirstName, LastName, Salary, CommissionBonus, FileFolder )
VALUES ( 2, 1, 'Samantha', 'Jones',    71000, NULL , 'SamanthaJones');
INSERT INTO Ass2_Employees ( DepartmentID, ManagerEmployeeID, FirstName, LastName, Salary, CommissionBonus, FileFolder )
VALUES ( 3, 4, 'Fred', 'Judd',         42000, 4000, 'FredJudd');
INSERT INTO Ass2_Employees ( DepartmentID, ManagerEmployeeID, FirstName, LastName, Salary, CommissionBonus, FileFolder )
VALUES ( 3, NULL, 'Hannah', 'Grant',   65000, 3000 ,  'HannahGrant');
INSERT INTO Ass2_Employees ( DepartmentID, ManagerEmployeeID, FirstName, LastName, Salary, CommissionBonus, FileFolder )
VALUES ( 3, 4, 'Dhruv', 'Patel',       64000, 2000 ,  'DhruvPatel');
INSERT INTO Ass2_Employees ( DepartmentID, ManagerEmployeeID, FirstName, LastName, Salary, CommissionBonus, FileFolder )
VALUES ( 4, 3, 'Ash', 'Mansfield',     52000, 5000 ,  'AshMansfield');


CREATE OR REPLACE FUNCTION Ass2_GetEmployeeID (FName IN NVARCHAR2, LName IN NVARCHAR2 )
RETURN NUMBER
IS
   EmpID NUMBER(10);
BEGIN
    SELECT EmployeeID INTO EmpID 
    FROM Ass2_Employees
    WHERE FirstName = FName AND LastName = LName;

    RETURN EmpID;
END;


/* REQUIREMENT 1*/
create or replace  PROCEDURE Insert_Dept (a IN VARCHAR2, b IN VARCHAR2) as
BEGIN
INSERT INTO Ass2_Departments(DepartmentName,DepartmentDesc) VALUES(a,b);
DBMS_OUTPUT.PUT_LINE('Insertion OK');
EXCEPTION WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('error : '|| SQLERRM);
END ;
BEGIN
Insert_Dept('SQA','Software Quality Assurance');
Insert_Dept('Engineering','Systems Design and Development');
Insert_Dept('TechSupport','Technical Support');
END;


/* REQUIREMENT 2*/
CREATE OR REPLACE FUNCTION Get_DeptID_name(a IN VARCHAR2)
RETURN NUMBER
IS 
var_result NUMBER;
BEGIN
select DepartmentID into var_result from Ass2_Departments where DepartmentName=a;
RETURN var_result;
EXCEPTION
WHEN NO_DATA_FOUND THEN
DBMS_OUTPUT.put_line('No department with that name');
RETURN var_result;
END;

DECLARE
my_result NUMBER;
BEGIN
my_result:=Get_DeptID_name('Management');
DBMS_OUTPUT.put_line('The ID for  department is: '||my_result);
END;

/* REQUIREMENT 3*/

/* REQUIREMENT 4*/

/* REQUIREMENT 5*/

SELECT Departmentid, 
   (Firstname|| ' ' || Lastname) AS EmployeeName
   ,CommissionBonus, Salary,
   RANK() OVER(PARTITION BY Departmentid ORDER BY CommissionBonus DESC) AS "RANK",
   LAG(Firstname, 1) OVER(PARTITION BY Departmentid ORDER BY CommissionBonus DESC) AS "prev Employee Name",
   LAG(CommissionBonus,1) OVER(PARTITION BY Departmentid ORDER BY CommissionBonus DESC) AS "prev Employee Commission",
   AVG(CommissionBonus) OVER(PARTITION BY Departmentid) AS "Commission avgerage",
   NVL(CommissionBonus,0) + Salary AS "Total Compensation"
FROM ASS2_EMPLOYEES
ORDER BY Departmentid, CommissionBonus DESC

/* REQUIREMENT 6*/


