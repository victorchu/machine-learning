/*
QUESTION:

Suppose that a website contains two tables, the Customers table and the Orders table.
Write a SQL query to find all customers who never order anything.

EXAMPLES:

Table: Customers
    +----+-------+
    | Id | Name  |
    +----+-------+
    | 1  | Joe   |
    | 2  | Henry |
    | 3  | Sam   |
    | 4  | Max   |
    +----+-------+

Table: Orders
    +----+------------+
    | Id | CustomerId |
    +----+------------+
    | 1  | 3          |
    | 2  | 1          |
    +----+------------+

Expected Output:
    +-----------+
    | Customers |
    +-----------+
    | Henry     |
    | Max       |
    +-----------+

TECHNIQUES:
  - SELECT DISTINCT
  - NOT IN (...)
  - LEFT JOIN ... ON ...
  - WITH cte AS (...)

REFERENCE:
  - https://leetcode.com/articles/customers-who-never-order/

*/


-- NOT IN.
SELECT Name as 'Customers'
    FROM Customers
    WHERE Id NOT IN (SELECT DISTINCT CustomerId from Orders);


-- JOIN and IS NULL.
SELECT c.Name as 'Customers'
    FROM Customers c
    LEFT JOIN (
        SELECT DISTINCT CustomerId as CustomerId FROM Orders
    ) t
    ON c.Id = t.CustomerId
    WHERE t.CustomerId IS NULL;


-- JOIN again, yet put the sub-query into WITH.
WITH T AS (
    SELECT DISTINCT CustomerId FROM Orders
)
SELECT C.Name AS 'Customers'
    FROM Customers C
    LEFT JOIN T
    ON C.ID = T.CustomerId
    WHERE T.CustomerId IS NULL;
    

