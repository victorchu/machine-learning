/*
QUESTION:

Write a SQL query to get the second highest salary from the Employee table.

EXAMPLE:

Employee Table:
    +----+--------+
    | Id | Salary |
    +----+--------+
    | 1  | 100    |
    | 2  | 200    |
    | 3  | 300    |
    +----+--------+

Sample result:
    +---------------------+
    | SecondHighestSalary |
    +---------------------+
    | 200                 |
    +---------------------+

TECHNIQUES:
  - MAX: which returns NULL on empty set.
  - LIMIT [offset], num_rows
  - IFNULL( , )
  - COUNT DISTINCT

VARIATIONS:
  - Return 0 instead of NULL on empty set.  
    . Use COALESCE (expr1, expr2).
    . Or, NVL(expr1, expr2) -- replacing NULL value.

  - Generate salary rank.
  - Generate salary percentile.

REFERENCE:
  - https://www.w3schools.com/sql/func_mysql_max.asp
  - https://www.geeksforgeeks.org/sql-query-to-find-second-largest-salary/
*/


--------------
-- ANSWERS
--------------

-- Use MAX Twice
SELECT MAX(Salary) AS SecondHighestSalary 
    FROM Employee
    WHERE Salary < (SELECT MAX(Salary) FROM Employee)
;


-- Use MAX Twice, elaborate on two different Employee tables
-- Why that we don't need IFNULL here?  I guess it is taken care of by MAX.
SELECT MAX(e1.Salary) AS 'SecondHighestSalary'
    FROM Employee e1
    WHERE e1.Salary < (SELECT MAX(e2.Salary) FROM Employee e2)
;


-- Use MAX & LIMIT 1.  Need to deal with empty table
SELECT IFNULL ( (
    SELECT e1.Salary
        FROM Employee e1 
        WHERE e1.Salary < (SELECT MAX(e2.Salary) FROM Employee e2)
        ORDER BY e1.Salary DESC
        LIMIT 1
    ), NULL)  AS 'SecondHighestSalary'
;


-- Use COUNT DISTINCT.  Can be generalized to handle n-th highest.
--
SELECT IFNULL ((
    SELECT e1.Salary
        FROM Employee e1
        WHERE (SELECT COUNT(DISTINCT e2.Salary)
                   FROM Employee e2
                   WHERE e2.Salary > e1.Salary) = 1
        LIMIT 1
    ), NULL)
    AS SecondHighestSalary;


--
-- [PARTIAL ANSWER] Use LIMIT with OFFSET.  
-- 1. Need to deal with empty table.
-- 2. It fails when there are multiple employees with the highest salary.
--    E.g. (1, 300), (2, 300), (3, 100)
SELECT 
    IFNULL(
        (SELECT Salary FROM Employee ORDER BY Salary DESC LIMIT 1, 1),
        NULL
    ) AS 'SecondHighestSalary'
;




------------------
-- TEST DATA
------------------
-- Table names are case sensitive
DROP TABLE IF EXISTS Employee;
CREATE TABLE IF NOT EXISTS Employee
(
    Id INT,
    Salary Float
);

INSERT INTO TABLE Employee (Id, Salary)
	VALUES (1, 100), (2, 200), (3, 300), (4, 300);



