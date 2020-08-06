/*
The Employee table holds all employees. Every employee has an Id, a salary, and there is also a column for the department Id.

    +----+-------+--------+--------------+
    | Id | Name  | Salary | DepartmentId |
    +----+-------+--------+--------------+
    | 1  | Joe   | 85000  | 1            |
    | 2  | Henry | 80000  | 2            |
    | 3  | Sam   | 60000  | 2            |
    | 4  | Max   | 90000  | 1            |
    | 5  | Janet | 69000  | 1            |
    | 6  | Randy | 85000  | 1            |
    | 7  | Will  | 70000  | 1            |
    +----+-------+--------+--------------+

The Department table holds all departments of the company.

    +----+----------+
    | Id | Name     |
    +----+----------+
    | 1  | IT       |
    | 2  | Sales    |
    +----+----------+

Write a SQL queries to find N employees in each department that have the highest salaries.

    +------------+----------+--------+
    | Department | Employee | Salary |
    +------------+----------+--------+
    | IT         | Max      | 90000  |
    | IT         | Randy    | 90000  |
    | IT         | Joe      | 85000  |
    | IT         | Will     | 70000  |
    | Sales      | Henry    | 80000  |
    | Sales      | Sam      | 60000  |
    +------------+----------+--------+

REFERENCE:
  - https://leetcode.com/problems/department-highest-salary/ (Medium)
  - https://leetcode.com/problems/department-top-three-salaries/ (Hard)

*/

-- -------
--  Data
-- -------
DROP TABLE IF EXISTS Employee;
CREATE TABLE Employee
(
    Id     INT NOT NULL,
    Name   VARCHAR(20),
    Salary INT,
    DepartmentId INT
);

TRUNCATE TABLE Employee;
INSERT INTO Employee VALUES
    (1, 'Joe',   85000, 1),
    (2, 'Henry', 80000, 2),
    (3, 'Sam',   60000, 2),
    (4, 'Max',   90000, 1),
    (5, 'Janet', 65000, 1),
    (6, 'Randy', 90000, 1),
    (7, 'Cathy', 70000, 1);

DROP TABLE IF EXISTS Department;
CREATE TABLE Department
(
    Id     INT NOT NULL,
    Name   VARCHAR(20)
);

TRUNCATE TABLE Department;
INSERT INTO Department VALUES
    (1, 'IT'),
    (2, 'Sales');

-- ---------
--  ANSWERS
-- ---------

-- Å1. MAX and JOINE (top 1 only)
WITH T AS (
    SELECT 
        DepartmentId,
        MAX(Salary) as Salary
    FROM Employee
    GROUP BY DepartmentId
)
SELECT 
    d.Name AS Department,
    e.Name AS Employee,
    e.Salary
    FROM Employee e, Department d, T
    WHERE e.DepartmentId = d.Id
        AND e.DepartmentId = T.DepartmentId
        AND e.Salary = T.Salary;

-- Å2. MAX and IN (top 1 only)
WITH T AS (
    SELECT 
        DepartmentId,
        MAX(Salary) as Salary
    FROM Employee
    GROUP BY DepartmentId
)
SELECT 
    d.Name AS Department,
    e.Name AS Employee,
    e.Salary
    FROM Employee e, Department d
    WHERE e.DepartmentId = d.Id
        AND (e.DepartmentId, e.Salary) in (SELECT * FROM T);


-- A3. DENSE_RANK OVER (PARTITION BY ... ORDER BY ...)
WITH T AS (
    SELECT 
        d.Name as Department,
        e.Name as Employee,
        e.Salary,
        DENSE_RANK() OVER(
            PARTITION BY d.Name
            ORDER BY Salary DESC
        ) as rnk
    FROM Employee e, Department d
    WHERE e.DepartmentId = d.Id
)
SELECT Department, Employee, Salary 
FROM T
WHERE rnk = 1;


-- A4. Self-join
SELECT 
        d.Name as 'Department',
        e1.Name as 'Employee',
        e1.Salary as 'Salary'
    FROM Employee e1
    JOIN Department d ON e1.DepartmentId = d.Id
    WHERE
        (SELECT COUNT(DISTINCT e2.Salary) 
            FROM Employee e2
            WHERE e2.DepartmentId = e1.DepartmentId AND e2.Salary > e1.Salary) < 3;


