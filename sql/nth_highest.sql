/*
QUESTION:

Write a SQL query to get the nth highest salary from the Employee table.

    +----+--------+
    | Id | Salary |
    +----+--------+
    | 1  | 100    |
    | 2  | 200    |
    | 3  | 300    |
    +----+--------+

For example, given the above Employee table, the nth highest salary where n = 2 is 200.
If there is no nth highest salary, then the query should return null.

    +------------------------+
    | getNthHighestSalary(2) |
    +------------------------+
    | 200                    |
    +------------------------+

*/


/*
Use DECLARE to declare a new variablle M and set it to N - 1.
It is not OK to use "LIMIT N-1, 1"
*/
CREATE FUNCTION getNthHighestSalary(N INT) RETURNS INT
BEGIN
  DECLARE M INT DEFAULT N-1;
  RETURN (
      SELECT DISTINCT salary
          FROM employee
          ORDER BY salary DESC
          LIMIT 1 offset M
  );
END


/* Similar */
CREATE FUNCTION getNthHighestSalary(N INT) RETURNS INT
BEGIN
  DECLARE M INT;
  SET M = N - 1;
  RETURN (
      SELECT DISTINCT Salary
          FROM employee
          ORDER BY salary DESC
          LIMIT M, 1
  );
END


/* Generalizble to Tie */
SELECT DISTINCT Salary
FROM Employee AS e
WHERE (SELECT COUNT(DISTINCT Salary)
       FROM Employee
       WHERE e.Salary < Salary) = N - 1;


