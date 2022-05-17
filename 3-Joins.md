Chapter 3-Joins
==============================

## Cross Joins

A cross join implements only one logical query processing phase—a Cartesian Product. This phase operates on the two tables provided as inputs to the join and produces a Cartesian product of the two:

```SQL
-- ANSI SQL-92 Syntax
SELECT C.custid, E.empid
FROM Sales.Customers AS C 
  CROSS JOIN HR.Employees AS E;

 -- ANSI SQL-89 Syntax
SELECT C.custid, E.empid
FROM Sales.Customers AS C, HR.Employees AS E;  -- [CROSS JOIN] keyword is optional
```

One useful practice of cross joins is you can use it to produce numbers assuming you already have a Digits number table as:

```SQL
digit
-----------
0
1
2
3
4
5
6
7
8
9
```

```SQL
SELECT D3.digit * 100 + D2.digit * 10 + D1.digit + 1 AS n
FROM         dbo.Digits AS D1
  CROSS JOIN dbo.Digits AS D2
  CROSS JOIN dbo.Digits AS D3
ORDER BY n;


n
-----------
1
2
3
4
5
6
7
8
9
10
...
998
999
1000 

(1000 row(s) affected)
```


## Inner Joins

An inner join applies two logical query processing:

*it applies a Cartesian product between the two input tables as in a cross join*

and

*filters rows based on a predicate that you specify on `ON` clause*

```SQL
-- ANSI SQL-92 Syntax
SELECT E.empid, E.firstname, E.lastname, O.orderid
FROM HR.Employees AS E
  INNER JOIN Sales.Orders AS O
  ON E.empid = O.empid;

-- ANSI SQL-92 Syntax
SELECT E.empid, E.firstname, E.lastname, O.orderid
FROM HR.Employees AS E
  JOIN Sales.Orders AS O    -- [INNER] keyword is optional, because inner join is the default join
    ON E.empid = O.empid;   -- this predicate 'E.empid = O.empid' filter rows that match the predicate 

 -- ANSI SQL-89 Syntax
SELECT E.empid, E.firstname, E.lastname, O.orderid
FROM HR.Employees AS E, Sales.Orders AS O
WHERE E.empid = O.empid;    -- Note that the ANSI SQL-89 syntax has no ON clause, it uses WHERE clause
``` 

Recall the discussion from previous chapters about the three-valued predicate logic used by SQL. As with the WHERE and HAVING clauses, the **`ON` clause also returns only rows for which the predicate returns `TRUE`**, and does not return rows for which the predicate evaluates to `FALSE` or `UNKNOWN`.


## Composite Joins

A composite join is simply a join based on a predicate that involves more than one attribute from each side. For example, `[Sales].[OrderDetails]` has a comination key of orderid and productid

```SQL
SELECT OD.orderid, OD.productid, OD.qty,
  ODA.dt, ODA.loginname, ODA.oldval, ODA.newval
FROM Sales.OrderDetails AS OD
  JOIN Sales.OrderDetailsAudit AS ODA
  ON OD.orderid = ODA.orderid
  AND OD.productid = ODA.productid  -- JOIN AND, ...AND
WHERE  ODA.columnname = N'qty';
```

## Multi-Join Queries

the result table of the first table operator is treated as the left input to the second table operator; the result of the second table operator is treated as the left input
 o the third table operator; and so on

```SQL
SELECT
  C.custid, C.companyname, O.orderid,
  OD.productid, OD.qty
FROM Sales.Customers AS C
  JOIN Sales.Orders AS O
  ON C.custid = O.custid          --- resultOne
  ----------------------------------------------
  JOIN Sales.OrderDetails AS OD   --- OrderDetails joins resultOne
    ON O.orderid = OD.orderid;
```

## Outer Joins

Outer joins were introduced in ANSI SQL-92, so it only have one standard syntax. Outer joins apply the two logical processing phases that inner joins apply (Cartesian product and the ON filter), plus a third phase that identifies the rows from the preserved table that did not find matches in the other table based on the ON predicate. This phase adds those rows to the result table produced by the first two phases of the join, and uses NULL marks as placeholders for the attributes from the nonpreserved side of the join in those outer rows:

```SQL
SELECT C.custid, C.companyname, O.orderid
FROM Sales.Customers AS C 
  LEFT OUTER JOIN Sales.Orders AS O  -- OUTER keyword means the table on its left (Customers) is the perserved table
    ON C.custid = O.custid;

SELECT C.custid, C.companyname, O.orderid
FROM Sales.Customers AS C 
  LEFT JOIN Sales.Orders AS O   -- OUTER keyword is optional
    ON C.custid = O.custid;
```

Let's look at a complicated case that use outer joins, suppose you want to get order details for each date in the range January 1, 2006 through December 31, 2008:

```s
orderdate                  orderid     custid      empid
-------------------------- ----------- ----------- ----------- 
2006-01-01 00:00:00.000    NULL        NULL        NULL
2006-01-02 00:00:00.000    NULL        NULL        NULL
...
2006-07-03 00:00:00.000    NULL        NULL        NULL
2006-07-04 00:00:00.000    10248       85          5
2006-07-05 00:00:00.000    10249       79          6 
...
2008-12-31 00:00:00.000    NULL        NULL        NULL 
```

As the first step in the solution, you need to produce a sequence of all dates in the requested range:

```SQL
SELECT DATEADD(day, n-1, '20060101') AS orderdate
FROM dbo.Nums                                          -- Nums table contains integer from 1 100,000
WHERE n <= DATEDIFF(day, '20060101', '20081231') + 1
ORDER BY orderdate;

--orderdate
-----------------------
2006-01-01 00:00:00.000
2006-01-02 00:00:00.000
2006-01-03 00:00:00.000
2006-01-04 00:00:00.000
2006-01-05 00:00:00.000
...
2008-12-27 00:00:00.000
2008-12-28 00:00:00.000
2008-12-29 00:00:00.000
2008-12-30 00:00:00.000
2008-12-31 00:00:00.000
```

The next step is to extend the previous query, adding a left outer join between Nums and the Orders tables:

```SQL
SELECT DATEADD(day, n - 1, '20060101') AS orderdate,
  O.orderid, O.custid, O.empid
FROM dbo.Nums
  LEFT OUTER JOIN Sales.Orders AS O
    ON DATEADD(day, n - 1, '20060101') = O.orderdate   -- ON clause contains a precicate which is not quite like the most common one like `table1.Coulumn = table2.Column`
WHERE n <= DATEDIFF(day, '20060101', '20081231') + 1
ORDER BY orderdate;
```


## Exercise and Comments

1. Return customers with orders placed on February 12, 2007, along with their orders. Also return customers who didn't place orders on February 12, 2007
```s
custid      companyname       orderid     orderdate
----------- ----------------- ----------- -----------------------
72          Customer AHPOP    NULL        NULL
58          Customer AHXHT    NULL        NULL
...
5 Customer  HGVLZ             10444       2007-02-12 00:00:00.000   --note that customer could have multiple order on a date
...

(91 row(s) affected)
```
```SQL
SELECT C.custid, C.companyname, O.orderid, O.orderdate  -- no need to use Distinct as we need to show orderid 
FROM Sales.Customers AS C
  LEFT OUTER JOIN Sales.Orders AS O
    ON O.custid = C.custid
    AND O.orderdate = '20070212';  -- have to use composite join instead of WHERE clause like WHERE O.orderdate = '20070212'
```

2. Return all customers, and for each return a Yes/No value depending on whether the customer placed an order on February 12, 2007
```s
custid      companyname       HasOrderOn20070212    
----------- ----------------- ----------- 
1           Customer NRZBB    No       
2           Customer AHXHT    No
...
5           Customer  HGVLZ   Yes
6           Customer XHXJV    No
...

(91 row(s) affected)
```
```SQL
SELECT DISTINCT C.custid, C.companyname,
  CASE WHEN O.orderid IS NOT NULL THEN 'Yes' ELSE 'No' END AS [HasOrderOn20070212]
FROM Sales.Customers AS C
  LEFT OUTER JOIN Sales.Orders AS O
    ON O.custid = C.custid
    AND O.orderdate = '20070212';
```

this exercise is an extension of the previous exercise, the reason DISTINCT is used in here but not in above is that we don't need to show orderid here.

There are two things to note here:

1. You can't use `WHERE` clause to filer the orderdate because if you do that you lose infomation of customers don't place order on that date

2. You might be wondering can we not using composite join and use `SELECT` clause "innovatively" as:

```SQL
SELECT DISTINCT C.custid, C.companyname, CASE WHEN O.orderdate = '20070212' THEN 'YES' ELSE 'NO' END AS HasOrderOn20070212 
FROM Sales.Customers C
  LEFT JOIN Sales.Orders O
    ON C.custid = O.custid
ORDER BY C.custid
```
let's look at the ouput and see why we can't do this:
```s
custid      companyname       HasOrderOn20070212    
----------- ----------------- ----------- 
1           Customer NRZBB    No       
2           Customer AHXHT    No
...
5           Customer  HGVLZ   Yes
5           Customer  HGVLZ   No 
6           Customer XHXJV    No
...

(93 row(s) affected)  // not 91 rows as previous exercise
```

You can see that custid 5 has two rows (it could have 3,4,5... rows), the second rows is the same customer that place order in a date other than 20070212. We can use this query only if there is a mutually exclusive logic like if a customer place an order on 20070212 then he can't place another order on other date OR if the customer doesn't place an order on 20070212 and he can't place more than one order in other date, of course this kind of logic doesn't make sense at all.
<!-- <div class="alert alert-info p-1" role="alert">
    
</div> -->

<!-- ![alt text](./zImages/17-6.png "Title") -->

<!-- <code>&lt;T&gt;</code> -->

<!-- <div class="alert alert-info pt-2 pb-0" role="alert">
    <ul class="pl-1">
      <li></li>
      <li></li>
    </ul>  
</div> -->

<!-- <ul>
  <li><b></b></li>
  <li><b></b></li>
  <li><b></b></li>
  <li><b></b></li>
</ul>  -->

<!-- <span style="color:red">hurt</span> -->

<style type="text/css">
.markdown-body {
  max-width: 1800px;
  margin-left: auto;
  margin-right: auto;
}
</style>

<link rel="stylesheet" href="./zCSS/bootstrap.min.css">
<script src="./zCSS/jquery-3.3.1.slim.min.js"></script>
<script src="./zCSS/popper.min.js"></script>
<script src="./zCSS/bootstrap.min.js"></script>