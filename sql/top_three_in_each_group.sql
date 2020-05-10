/*
QUESTION:

Employee table:
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

Department table:
    +----+----------+
    | Id | Name     |
    +----+----------+
    | 1  | IT       |
    | 2  | Sales    |
    +----+----------+

Find employees who earn the top three salaries in each of the department.
    +------------+----------+--------+
    | Department | Employee | Salary |
    +------------+----------+--------+
    | IT         | Max      | 90000  |
    | IT         | Randy    | 85000  |
    | IT         | Joe      | 85000  |
    | IT         | Will     | 70000  |
    | Sales      | Henry    | 80000  |
    | Sales      | Sam      | 60000  |
    +------------+----------+--------+

*/


-- Part 1: an intermediate step.
-- Select top 3 salaries of the whole company.
SELECT e1.Name as 'Employee', e1.Salary
    FROM Employee e1
    WHERE 3 > (
        SELECT COUNT(DISTINCT e2.Salary)
        FROM Employee e2
        WHERE e2.Salary > e1.Salary
    )
    ;


-- Part 2: full answer.
-- Join with Department table to get the department name.
-- Also only compares with salaries in the same department.
SELECT d.Name as 'Department', e1.Name as 'Employee', e1.Salary as 'Salary'
    FROM Employee e1
    JOIN Department d
        ON e1.DepartmentId = d.Id
    WHERE
        (SELECT COUNT(DISTINCT e2.Salary) 
            FROM Employee e2
            WHERE e2.DepartmentId = e1.DepartmentId AND e2.Salary > e1.Salary) < 3;



