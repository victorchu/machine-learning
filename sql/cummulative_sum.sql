/*
QUESTION:

Get the cumulative salaries and cumulative salary ratios of employees.
Order by the salary.

EXAMPLE:

Employee Table:
    Id | Salary
    ---+-------
     1 |    100
     2 |    200
     3 |    300
     4 |    300
     5 |    250

Expected output:
    Id | Salary | CumSalary | CumSalaryRatio
    ---+--------+-----------+---------------
     1 |    100 |       100 |           0.09
     2 |    200 |       300 |           0.26
     5 |    250 |       550 |           0.48
     3 |    300 |       850 |           0.74
     4 |    300 |      1150 |              1

TECHNOLOGIES:
  - MySQL Variable, initialized with SET @VAR := 0, OR JOIN.
  - WITH: used to calculate the total.


REFERENCE:
  - https://popsql.com/learn-sql/mysql/how-to-calculate-cumulative-sum-running-total-in-mysql/
*/


-- -----------
--   ANSWERS
-- -----------

-- Use SET to initialize the variable
SET @sum := 0;
WITH T AS (SELECT SUM(Salary) Total FROM Employee)
SELECT Id, Salary, CumSalary, CumSalary/T.Total AS CumSalaryRatio
FROM (
  SELECT Id, Salary, 
      (@sum := @sum + Salary) AS CumSalary
    FROM Employee 
    ORDER BY Salary ASC
) C, T;


-- Initialize the variable with a JOIN.
WITH T AS (SELECT SUM(Salary) Total FROM Employee)
SELECT Id, Salary, CumSalary, CumSalary/T.Total AS CumSalaryRatio
FROM (
  SELECT Id, Salary, 
      (@sum := @sum + Salary) AS CumSalary
    FROM Employee 
    JOIN (SELECT @sum :=  0) AS V
    ORDER BY Salary ASC
) C, T;


-- -------------
--   TEST DATA
-- -------------
DROP TABLE IF EXISTS Employee;
CREATE TABLE IF NOT EXISTS Employee
(
    Id INT,
    Salary Float
);

INSERT INTO TABLE Employee (Id, Salary)
	VALUES (1, 100), (2, 200), (3, 300), (4, 300), (5, 250);


