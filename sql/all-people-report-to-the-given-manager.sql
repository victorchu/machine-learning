/*
Write an SQL query to find employee_id of all employees that directly or indirectly report their work to the head of the company.

Note:
  - The head of the company has employee_id 1
  - The indirect relation between managers will not exceed 3 managers
    as the company is small.
  - Return result tble in any order without duplicates.

Ref:
  - https://leetcode.com/problems/all-people-report-to-the-given-manager/ (Medium)
*/

DROP TABLE IF EXISTS Employees;
CREATE TABLE IF NOT EXISTS Employees (
    employee_id INT,
    employee_name VARCHAR(16),
    manager_id INT
);

INSERT INTO Employees VALUES
    (1, 'Boss', 1),
    (2, 'Bob', 1),
    (3, 'Alice', 3),
    (4, 'Daniel', 2),
    (7, 'Luis', 4),
    (8, 'John', 3),
    (9, 'Angela', 8),
    (77, 'Robert', 1);


-- WITH + Subquerry + UNION 
-- UNION will automatically dedupe.  Besides, there shouldn't be
-- any duplication.
--
-- Result:
--   +-------------+
--   | employee_id |
--   +-------------+
--   |           2 |
--   |          77 |
--   |           4 |
--   |           7 |
--   +-------------+

-- WITH
WITH L1 AS (
    SELECT employee_id
    FROM Employees
    WHERE manager_id = 1
    AND employee_id != 1
),
L2 AS (
    SELECT employee_id
    FROM Employees
    WHERE manager_id IN (SELECT * FROM L1)
),
L3 AS (
    SELECT employee_id
    FROM Employees
    WHERE manager_id IN (SELECT * FROM L2)
)
SELECT * FROM L1
UNION 
SELECT * FROM L2
UNION
SELECT * FROM L3;


-- Replace subquery with JOIN
WITH L1 AS (
    SELECT employee_id
    FROM Employees
    WHERE manager_id = 1
    AND employee_id != 1
),
L2 AS (
    SELECT e2.employee_id
    FROM Employees e2, L1
    WHERE e2.manager_id = L1.employee_id
),
L3 AS (
    SELECT e3.employee_id
    FROM Employees e3, L2
    WHERE e3.manager_id = L2.employee_id
)
SELECT * FROM L1
UNION 
SELECT * FROM L2
UNION
SELECT * FROM L3;


-- RECURSSIVE v1
WITH RECURSIVE L AS (
    SELECT employee_id FROM Employees WHERE manager_id=1 AND employee_id != 1
    UNION 
    SELECT e.employee_id FROM Employees e
    JOIN L ON e.manager_id = L.employee_id
)
SELECT * FROM L;


-- RECURSSIVE v2: also show the distance to the boss
--    +------+-------------+
--    | n    | employee_id |
--    +------+-------------+
--    |    1 |           2 |
--    |    1 |          77 |
--    |    2 |           4 |
--    |    3 |           7 |
--    +------+-------------+
WITH RECURSIVE L AS (
    SELECT 1 as n, employee_id FROM Employees WHERE manager_id=1 AND employee_id != 1
    UNION 
    SELECT n + 1, e.employee_id 
    FROM Employees e
    JOIN L ON e.manager_id = L.employee_id
)
SELECT * FROM L
WHERE L.employee_id != 1;


