/*
The Employee table holds all employees. The employee table has three columns: Employee Id, Company Name, and Salary.

+-----+------------+--------+
|Id   | Company    | Salary |
+-----+------------+--------+
|1    | A          | 2341   |
|2    | A          | 341    |
|3    | A          | 15     |
|4    | A          | 15314  |
|5    | A          | 451    |
|6    | A          | 513    |
|7    | B          | 15     |
|8    | B          | 13     |
|9    | B          | 1154   |
|10   | B          | 1345   |
|11   | B          | 1221   |
|12   | B          | 234    |
|13   | C          | 2345   |
|14   | C          | 2645   |
|15   | C          | 2645   |
|16   | C          | 2652   |
|17   | C          | 65     |
+-----+------------+--------+

Write a SQL query to find the median salary of each company. Bonus points if you can solve it without using any built-in SQL functions.

+-----+------------+--------+
|Id   | Company    | Salary |
+-----+------------+--------+
|5    | A          | 451    |
|6    | A          | 513    |
|12   | B          | 234    |
|9    | B          | 1154   |
|14   | C          | 2645   |
+-----+------------+--------+

Ref:
  - https://leetcode.com/problems/median-employee-salary/ (Hard)

*/

-- DATA
DROP TABLE IF EXISTS Employee;
CREATE TABLE IF NOT EXISTS Employee (
    Id INT,
    Company VARCHAR(15),
    Salary INT
);

TRUNCATE TABLE Employee;
INSERT INTO Employee VALUES 
    ( 1, 'A', 2341),
    ( 2, 'A', 341),
    ( 3, 'A', 15),
    ( 4, 'A', 15314),
    ( 5, 'A', 451),
    ( 6, 'A', 513),
    ( 7, 'B', 15),
    ( 8, 'B', 13),
    ( 9, 'B', 1154),
    (10, 'B', 1345),
    (11, 'B', 1221),
    (12, 'B', 234),
    (13, 'C', 2345),
    (14, 'C', 2645),
    (15, 'C', 2645),
    (16, 'C', 2652),
    (17, 'C', 65);


-- ANSWER
--
-- CTE A (add per-company row numbers rn)
--   +------+---------+--------+----+
--   | Id   | Company | Salary | rn |
--   +------+---------+--------+----+
--   |    3 | A       |     15 |  1 |
--   |    2 | A       |    341 |  2 |
--   |    5 | A       |    451 |  3 |
--   |    6 | A       |    513 |  4 |
--   |    1 | A       |   2341 |  5 |
--   |    4 | A       |  15314 |  6 |
--   |    8 | B       |     13 |  1 |
--   |    7 | B       |     15 |  2 |
--   |   12 | B       |    234 |  3 |
--   |    9 | B       |   1154 |  4 |
--   |   11 | B       |   1221 |  5 |
--   |   10 | B       |   1345 |  6 |
--   |   17 | C       |     65 |  1 |
--   |   13 | C       |   2345 |  2 |
--   |   14 | C       |   2645 |  3 |
--   |   15 | C       |   2645 |  4 |
--   |   16 | C       |   2652 |  5 |
--   +------+---------+--------+----+
--
-- CTE B (row numbers for median salaries)
--   +---------+------+------+
--   | Company | n1   | n2   |
--   +---------+------+------+
--   | A       |    3 |    4 |
--   | B       |    3 |    4 |
--   | C       |    3 |    3 |
--   +---------+------+------+
--
-- Result:
--   +------+---------+--------+
--   | Id   | Company | Salary |
--   +------+---------+--------+
--   |    5 | A       |    451 |
--   |    6 | A       |    513 |
--   |    9 | B       |   1154 |
--   |   12 | B       |    234 |
--   |   15 | C       |   2645 |
--   +------+---------+--------+
--
WITH A AS (
SELECT *,
    ROW_NUMBER() OVER(PARTITION BY Company ORDER BY Salary) AS rn
    FROM Employee
),
B AS (
    SELECT Company,
        CEIL(MAX(rn)/2) AS n1,
        CEIL(MAX(rn)/2 + 0.5) AS n2
    FROM A
    GROUP BY Company
)
SELECT A.Id, A.Company, A.Salary
FROM A
JOIN B ON A.Company = B.Company 
    AND A.rn in (B.n1, B.n2)
ORDER BY A.Company, A.Id;




