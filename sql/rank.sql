/*
QUESTION:

Employee Table:
    +----+--------+--------------+
    | Id | Salary | DepartmentId |
    +----+--------+--------------+
    | 1  | 100    | 1            |
    | 2  | 200    | 1            |
    | 3  | 300    | 2            |
    | 4  | 300    | 2            |
    | 5  | 250    | 2            |
    +----+--------+--------------+ 

Generate salary rank with no gaps in the ranking values.
    +--------+------+
    | Salary | Rank |
    +--------+------+
    | 300    | 1    |
    | 250    | 3    |
    | 200    | 4    |
    | 100    | 5    |
    +--------+------+

VARIATIONS:
  - Remove gaps
  - Get number of employess for each salary.
  - Get the rank within each department
  - Get the percentage of each salary over total salary.
  - Get the percentage of each salary in each Department.

TECHNOLOGIES:
  - Window Functions:
    . RANK() OVER(...)
    . DENSE_RANK() OVER(...)
    . SUM() OVER(...)
    . OVER (
		  PARTITION BY <expression>[{,<expression>...}]
		  ORDER BY <expression> [ASC|DESC], [{,<expression>...}]
      )
  - WITH table_name AS (..) : a Common Table Expression (CTE), a named temp table.

REFERENCE:
  - https://dev.mysql.com/doc/refman/8.0/en/window-functions-usage.html
  - https://dev.mysql.com/doc/refman/8.0/en/with.html
  - https://www.mysqltutorial.org/mysql-window-functions/mysql-dense_rank-function/
  - http://www.silota.com/docs/recipes/sql-percentage-total.html

*/


--------------
-- ANSWERS
--------------

-- RANK, with gaps in the ranking values.
SELECT Salary,
    RANK() OVER (
      ORDER BY Salary DESC
    ) AS 'Rank'
  FROM Employee;

-- DISTINCT RANK, with gaps, sort explicitly.
SELECT DISTINCT 
    Salary,
    RANK() OVER (
      ORDER BY Salary DESC
    ) AS 'Rank'
  FROM Employee
  ORDER BY 'Rank' ASC;

-- DISTINCT DENSE_RANK, no gaps in the ranking values.
SELECT DISTINCT Salary,
    DENSE_RANK() OVER (
      ORDER BY Salary DESC
    ) AS 'Rank'
  FROM Employee;

-- Count the number of employess for each salary.
SELECT 
    Salary,
    DENSE_RANK() OVER (
      ORDER BY Salary DESC
    ) AS 'Rank',
    COUNT(*) AS Num
  FROM Employee
  GROUP BY Salary
  ORDER BY 'Rank' ASC;

/*
Get rank within each department.

    DepartmentId	Salary	Rank	Num
    1	200	1	1
    1	100	2	1
    2	300	1	2
    2	250	2	1
*/
SELECT 
    DepartmentId,
    Salary,
    DENSE_RANK() OVER (
      PARTITION BY DepartmentId
      ORDER BY Salary DESC
    ) AS 'Rank',
    COUNT(*) AS Num
  FROM Employee
  GROUP BY Salary, DepartmentId
  ORDER BY DepartmentId ASC, 'Rank' ASC;


/* 
Percentage

    Salary	Percentage
    300	0.52
    250	0.22
    200	0.17
    100	0.09
*/
WITH T AS
    (SELECT SUM(Salary) AS total FROM Employee)
SELECT Salary,
        ROUND(SUM(Salary/T.total), 3) AS 'Percentage'
    FROM Employee, T
    GROUP BY Salary
    ORDER BY Percentage DESC;

/* 
Percentage over each Department

    DepartmentId	Salary	Perc
    1	100	0.33
    1	200	0.67
    2	300	0.71
    2	250	0.29
*/
SELECT DepartmentId, Salary,
        SUM(Salary)/SUM(Salary) OVER (PARTITION BY DepartmentId) AS 'Perc'
    FROM Employee
    GROUP BY DepartmentId, Salary
    ORDER BY 'Perc' DESC;

/*
Percentage over nothing. It, it will be applied on the whole table.
This is an interesting variation.
*/
SELECT Salary, SUM(Perc) AS Perc FROM (
        SELECT Salary,
                Salary/SUM(Salary) Over() AS 'Perc'
            FROM Employee
    ) A
    GROUP BY Salary
    ORDER BY Perc DESC;


------------------
-- TEST DATA
------------------
-- Table names are case sensitive
DROP TABLE IF EXISTS Employee;
CREATE TABLE IF NOT EXISTS Employee
(
    Id INT,
    Salary Float,
    DepartmentId INT
);

INSERT INTO TABLE Employee (Id, Salary, DepartmentId)
VALUES (1, 100, 1), (2, 200, 1), (3, 300, 2), (4, 300, 2), (5, 250, 2);


