/*
We define an employee's total earnings to be their monthly worked, and the
maximum total earnings to be the maximum total earnings for any employee in the
Employee table. Write a query to find the maximum total earnings for all
employees as well as the total number of employees who have maximum total
earnings. Then print these values as space-separated integers.

Sample Output:

  69952 2

REFERENCE:
  - https://www.hackerrank.com/challenges/earnings-of-employees/problem (Easy)

*/

---------
-- DATA
---------
DROP TABLE IF EXISTS Employee;
CREATE TABLE IF NOT EXISTS Employee
(
    employee_id INT,
    name VARCHAR(20),
    months INT,
    salary INT
);

TRUNCATE TABLE Employee;
INSERT INTO Employee VALUES
    (1, 'Rose', 15, 1968),
    (2, 'Angela', 1, 3443),
    (3, 'Frank', 17, 1608),
    (4, 'Patrick', 7, 1345),
    (5, 'Lisa', 11, 2330),
    (6, 'Kimberly', 16, 4372),
    (7, 'Bonnie', 8, 1771),
    (8, 'Michael', 6, 2017),
    (9, 'Todd', 5, 3396),
    (10, 'Joe', 9, 3573),
    (11, 'Ruby', 16, 4372)
    ;


------------
-- ANSWERS
------------

-- JOIN
SELECT 
    M.max_earning, COUNT(*)
  FROM (SELECT months * salary AS earning FROM Employee) E
  JOIN (SELECT MAX(months * salary) as max_earning FROM Employee) M
  ON E.earning = M.max_earning;


-- JOIN WITH v1
WITH 
  E AS (SELECT months * salary AS earning FROM Employee),
  M AS (SELECT MAX(months * salary) as max_earning FROM Employee)
SELECT 
    M.max_earning, COUNT(*)
  FROM E, M
  where E.earning = M.max_earning;


-- JOIN WITH v2 -- reuse E in M query
WITH 
  E AS (SELECT months * salary AS earning FROM Employee),
  M AS (SELECT MAX(earning) as max_earning FROM E)
SELECT 
    M.max_earning, COUNT(*)
  FROM E, M
  where E.earning = M.max_earning;


