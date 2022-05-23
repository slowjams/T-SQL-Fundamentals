Use TSQL2012;

SELECT
 GETDATE() AS [GETDATE],
 CURRENT_TIMESTAMP AS [CURRENT_TIMESTAMP],
 GETUTCDATE() AS [GETUTCDATE],
 SYSDATETIME() AS [SYSDATETIME],
 SYSUTCDATETIME() AS [SYSUTCDATETIME],
 SYSDATETIMEOFFSET() AS [SYSDATETIMEOFFSET];

 SELECT DATENAME(month, '20090212');
 Select FORMAT(getdate(),'MMM');

SELECT DATEADD(day, n - 1, '20060101') AS orderdate,
 O.orderid, O.custid, O.empid
FROM dbo.Nums
 LEFT JOIN Sales.Orders AS O
 ON DATEADD(day, n - 1, '20060101') = O.orderdate      -- apply predicate on 'ON'clause first, n matches 1, 2, 3
WHERE n <= DATEDIFF(day, '20060101', '20060103') + 1   -- n <=3 here
ORDER BY orderdate;


SELECT DATEADD(DAY, n-1, '20060101') AS orderdate
FROM dbo.Nums 
WHERE n <= DATEDIFF(day, '20060101', '20081231') + 1
ORDER BY orderdate;

SELECT * FROM dbo.Nums

SELECT DATEDIFF(year, '20060101', '20080105'); 

SELECT C.custid, C.companyname, O.orderid
FROM Sales.Customers AS C
 LEFT OUTER JOIN Sales.Orders AS O
 ON C.custid = O.custid

WHERE O.orderid IS NULL;

-------------Outer Joins------------------------V
SELECT C.custid, C.companyname, O.orderid
FROM Sales.Customers AS C 
  LEFT OUTER JOIN Sales.Orders AS O
    ON C.custid = O.custid;

SELECT C.custid, C.companyname, O.orderid
FROM Sales.Customers AS C 
  LEFT JOIN Sales.Orders AS O   -- OUTER keyword is optional
    ON C.custid = O.custid;
-----------------------------------------------Ʌ

-------------Multi-Join------------------------V
SELECT
  C.custid, C.companyname, O.orderid,
  OD.productid, OD.qty
FROM Sales.Customers AS C
  JOIN Sales.Orders AS O
  ON C.custid = O.custid          --- resultOne
  JOIN Sales.OrderDetails AS OD   --- OrderDetails joins resultOne
    ON O.orderid = OD.orderid;

-----------------------------------------------Ʌ

-------------Composite Joins------------------------V
select *  FROM Sales.OrderDetails;

SELECT OD.orderid, OD.productid, OD.qty,
 ODA.dt, ODA.loginname, ODA.oldval, ODA.newval
FROM Sales.OrderDetails AS OD
 JOIN Sales.OrderDetailsAudit AS ODA
 ON OD.orderid = ODA.orderid
 AND OD.productid = ODA.productid  -- JOIN AND, ...AND
WHERE  ODA.columnname = N'qty';
-----------------------------------------------Ʌ


SELECT * FROM Sales.OrderDetails;


SELECT C.COLUMN_NAME FROM  
INFORMATION_SCHEMA.TABLE_CONSTRAINTS T  
JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE C  
ON C.CONSTRAINT_NAME=T.CONSTRAINT_NAME  
WHERE  
C.TABLE_NAME='OrderDetailsAudit'  
and T.CONSTRAINT_TYPE='PRIMARY KEY'   




-------------INNER JOIN------------------------V
-- ANSI SQL-92 Syntax
SELECT E.empid, E.firstname, E.lastname, O.orderid
FROM HR.Employees AS E
  INNER JOIN Sales.Orders AS O
  ON E.empid = O.empid;

-- ANSI SQL-92 Syntax
SELECT E.empid, E.firstname, E.lastname, O.orderid
FROM HR.Employees AS E
  JOIN Sales.Orders AS O    -- INNER is optional, because an inner join is the default
    ON E.empid = O.empid;   -- this predicate 'E.empid = O.empid' filter rows that match the predicate 

 -- ANSI SQL-89 Syntax
SELECT E.empid, E.firstname, E.lastname, O.orderid
FROM HR.Employees AS E, Sales.Orders AS O
WHERE E.empid = O.empid;    -- Note that the ANSI SQL-89 syntax has no ON clause, it uses WHERE clause
-----------------------------------------------Ʌ



-------------CROSS JOIN------------------------V
-- ANSI SQL-92 Syntax
SELECT C.custid, E.empid
FROM Sales.Customers AS C 
  CROSS JOIN HR.Employees AS E;

 -- ANSI SQL-89 Syntax
SELECT C.custid, E.empid
FROM Sales.Customers AS C, HR.Employees AS E;  -- CROSS JOIN keyword is optional
-----------------------------------------------Ʌ













USE TSQL2012;
IF OBJECT_ID('dbo.Digits', 'U') IS NOT NULL DROP TABLE dbo.Digits;
CREATE TABLE dbo.Digits(digit INT NOT NULL PRIMARY KEY);
INSERT INTO dbo.Digits(digit)
 VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9);
SELECT digit FROM dbo.Digits;

--Exercise

SELECT * FROM dbo.Nums
SELECT * FROM Sales.Orders
SELECT * FROM Sales.OrderDetails

--1
SELECT empid, firstname, lastname, n 
FROM HR.Employees
  CROSS JOIN dbo.Nums
WHERE n < 6
ORDER BY n

--2
SELECT empid, DATEADD(day, n-1, '20090612') AS dt
FROM HR.Employees
  CROSS JOIN dbo.Nums
WHERE n <= DATEDIFF(day, '20090612', '20090616') + 1
ORDER BY empid, dt 

--3
SELECT C.custid, count(DISTINCT O.orderid) AS numorders , SUM(qty) AS totalqty
FROM Sales.Customers AS C
  JOIN Sales.Orders O
    ON C.custid = O.custid
  JOIN Sales.OrderDetails AS OD
    ON O.orderid = OD.orderid
WHERE C.country = N'USA'
GROUP BY C.custid

--4
SELECT C.custid, C.companyname
FROM Sales.Customers C
  LEFT JOIN Sales.Orders O
    ON C.custid = O.custid
WHERE O.orderid IS NULL

--5
SELECT O.custid, companyname, orderid, orderdate
FROM Sales.Orders O
  JOIN Sales.Customers C
    ON O.custid = C.custid
WHERE O.orderdate = '20070212'

--6
SELECT C.custid, C.companyname, O.orderid, O.orderdate
FROM Sales.Customers AS C
  LEFT JOIN Sales.Orders AS O
  ON O.custid = C.custid
  AND O.orderdate = '20070212' 

--7
SELECT DISTINCT C.custid, C.companyname, CASE WHEN O.orderdate = '20070212' THEN 'YES' ELSE 'NO' END AS HasOrderOn20070212 
FROM Sales.Customers C
  LEFT JOIN Sales.Orders O
    ON C.custid = O.custid
ORDER BY C.custid
--WHERE O.orderdate = '20070212'


SELECT * FROM Sales.Customers

SELECT * FROM Sales.Orders

SELECT C.custid, C.companyname, O.orderid, O.orderdate
FROM Sales.Customers AS C
  LEFT JOIN Sales.Orders AS O
  ON O.custid = C.custid

