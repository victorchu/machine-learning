/*
The Employee table holds the salary information in a year.

Write a SQL to get the cumulative sum of an employee's salary over
a period of "3 months" but exclude the most recent month.

The result should be displayed by 'Id' ascending, and then by 'Month'
descending.

Ref:
  - https://leetcode.com/problems/find-cumulative-salary-of-an-employee/ (Hard)

*/

-- DATA
DROP TABLE IF EXISTS Employee;
CREATE TABLE IF NOT EXISTS Employee (
    Id INT,
    Month INT,
    Salary INT
);

-- CASE 1
-- Expected:
-- +------+-------+--------+
-- | Id   | Month | Salary |
-- +------+-------+--------+
-- |    1 |     3 |     90 |
-- |    1 |     2 |     50 |
-- |    1 |     1 |     20 |
-- |    2 |     1 |     20 |
-- |    3 |     3 |    100 |
-- |    3 |     2 |     40 |
-- +------+-------+--------+
TRUNCATE TABLE Employee;
INSERT INTO Employee VALUES 
    (1, 1, 20),
    (2, 1, 20),
    (1, 2, 30),
    (2, 2, 30),
    (3, 2, 40),
    (1, 3, 40),
    (3, 3, 60),
    (1, 4, 60),
    (3, 4, 70);

-- CASE 2
-- Expected: 
-- +------+-------+--------+
-- | id   | month | salary |
-- +------+-------+--------+
-- |    1 |     4 |    130 |
-- |    1 |     3 |     90 |
-- |    1 |     2 |     50 |
-- |    1 |     1 |     20 |
-- |    2 |     1 |     20 |
-- |    3 |     3 |    100 |
-- |    3 |     2 |     40 |
-- +------+-------+--------+
TRUNCATE TABLE Employee;
INSERT INTO Employee VALUES 
    (1, 1, 20),
    (2, 1, 20),
    (1, 2, 30),
    (2, 2, 30),
    (3, 2, 40),
    (1, 3, 40),
    (3, 3, 60),
    (1, 4, 60),
    (3, 4, 70),
    (1, 5, 70);


-- Use self-join
WITH M AS (
    -- Get max month for each Id
    SELECT Id, MAX(Month) AS max_month 
    FROM Employee GROUP BY Id
),
T AS (
    -- Self Join twice 
    SELECT 
        e1.Id, e1.Month, 
        COALESCE(e1.Salary, 0) AS s1,
        COALESCE(e2.Salary, 0) AS s2,
        COALESCE(e3.Salary, 0) AS s3
    FROM Employee e1
    JOIN M ON e1.Id = M.Id AND e1.Month < M.max_month
    LEFT JOIN Employee e2 ON e1.Id = e2.Id AND e2.Month = e1.Month - 1
    LEFT JOIN Employee e3 ON e1.Id = e3.Id AND e3.Month = e1.Month - 2
)
SELECT Id as id, Month as month, (s1 + s2 + s3) AS salary
FROM T
ORDER BY Id, Month DESC;


-- Use Variables
WITH T AS (
    SELECT 
        CASE WHEN @i=Id THEN @s3:=@s2 + Salary ELSE @s3:= Salary END AS s3,
        CASE WHEN @i=Id THEN @s2:=@s1 + Salary ELSE @s2:= Salary END AS s2,
        @s1:=Salary AS s1,
        @i:=Id AS Id,
        Month
    FROM Employee e, (SELECT @s1:=0, @s2:=0, @s3:=0, @i:=-1) V
    ORDER BY Id ASC, Month ASC
)
SELECT Id AS id, Month AS month, s3 AS salary
FROM T
WHERE T.Month < (SELECT MAX(e.Month) FROM Employee e WHERE T.Id = e.Id)
ORDER BY Id, Month DESC;


-- Use Window Function: SUM + ROWS BETWEEN
SELECT 
    Id, Month,
    SUM(Salary) OVER(PARTITION BY Id ORDER BY Month ASC
                     ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS Salary
FROM Employee e1
WHERE e1.Month < (SELECT MAX(e2.Month) FROM Employee e2 WHERE e1.Id = e2.Id) 
ORDER BY Id, Month DESC;


-- Use Window Function: LAG.
-- Apparently, SUM with ROWS BETWEEN is easier.
--
-- Some limitations on MariaDB (as of 10.3):
--  1) no defulat LAG values.
--  2) no named window
--
SELECT 
    Id, Month,
    Salary 
        + COALESCE(LAG(Salary, 1) OVER (PARTITION BY Id ORDER BY Month ASC), 0)
        + COALESCE(LAG(Salary, 2) OVER (PARTITION BY Id ORDER BY Month ASC), 0) AS Salary
FROM Employee e1
WHERE e1.Month < (SELECT MAX(e2.Month) FROM Employee e2 WHERE e1.Id = e2.Id) 
ORDER BY Id, Month DESC;


