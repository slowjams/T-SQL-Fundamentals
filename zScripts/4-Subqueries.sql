USE TSQL2012;

DECLARE @maxid AS INT = (SELECT MAX(orderid) FROM Sales.Orders);

SELECT orderid, orderdate, empid, custid
FROM Sales.Orders
WHERE orderid = @maxid;

SELECT orderid, orderdate, empid, custid
FROM Sales.Orders
WHERE orderid = (SELECT MAX(O.orderid) FROM Sales.Orders AS O);

SELECT orderid
FROM Sales.Orders
WHERE empid IN
 (SELECT E.empid
 FROM HR.Employees AS E
 WHERE E.lastname LIKE N'D%');

 SELECT orderid
FROM Sales.Orders
WHERE empid =
 (SELECT E.empid
 FROM HR.Employees AS E
 WHERE E.lastname LIKE N'A%');



SELECT custid, companyname
FROM Sales.Customers
WHERE custid NOT IN
 (SELECT DISTINCT O.custid
 FROM Sales.Orders AS O);

INSERT INTO dbo.Orders(orderid)
 SELECT orderid
 FROM Sales.Orders
 WHERE orderid % 2 = 0;SELECT n
FROM dbo.Nums




SELECT custid, orderid, orderdate, empid
FROM Sales.Orders AS O1
WHERE orderid =
  (SELECT MAX(O2.orderid)
   FROM Sales.Orders AS O2
   WHERE O2.custid = O1.custid)


SELECT custid, orderid, orderdate, empid
FROM Sales.Orders AS O1
ORDER BY custid DESC


-- what's the most efficient way to do it if correlated subqueries need to analysis every row and therefore execute subquery once for each out row OR database engine optimized it?
SELECT custid, MAX(orderid)
FROM Sales.Orders
GROUP BY custid
ORDER BY custid DESC