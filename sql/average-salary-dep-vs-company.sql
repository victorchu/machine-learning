/*
Given two tables as below, write a query to display the comparison result
(higher/lower/same) of the average salary of employees in a department to the
company's average salary.

Table: salary

| id | employee_id | amount | pay_date   |
|----|-------------|--------|------------|
| 1  | 1           | 9000   | 2017-03-31 |
| 2  | 2           | 6000   | 2017-03-31 |
| 3  | 3           | 10000  | 2017-03-31 |
| 4  | 1           | 7000   | 2017-02-28 |
| 5  | 2           | 6000   | 2017-02-28 |
| 6  | 3           | 8000   | 2017-02-28 |
 
The employee_id column refers to the employee_id in the following table employee.

| employee_id | department_id |
|-------------|---------------|
| 1           | 1             |
| 2           | 2             |
| 3           | 2             |

 
So for the sample data above, the result is: 

| pay_month | department_id | comparison  |
|-----------|---------------|-------------|
| 2017-03   | 1             | higher      |
| 2017-03   | 2             | lower       |
| 2017-02   | 1             | same        |
| 2017-02   | 2             | same        |

Ref:
  - https://leetcode.com/problems/average-salary-departments-vs-company/ (Medium)

*/

-- DATA
DROP TABLE IF EXISTS salary;
CREATE TABLE IF NOT EXISTS salary (
    id INT,
    employee_id INT,
    amount INT,
    pay_date DATE
);
INSERT INTO salary VALUES 
    (1, 1,  9000, '2017-03-31'),
    (2, 2,  6000, '2017-03-31'),
    (3, 3, 10000, '2017-03-31'),
    (4, 1,  7000, '2017-02-28'),
    (5, 2,  6000, '2017-02-28'),
    (6, 3,  8000, '2017-02-28');


DROP TABLE IF EXISTS employee;
CREATE TABLE IF NOT EXISTS employee (
    employee_id INT,
    department_id INT
);

INSERT INTO employee VALUES 
    (1, 1),
    (2, 2),
    (3, 2);


-- Result:
--   +-----------+---------------+------------+
--   | pay_month | department_id | comparison |
--   +-----------+---------------+------------+
--   | 2017-03   |             1 | higher     |
--   | 2017-03   |             2 | lower      |
--   | 2017-02   |             1 | same       |
--   | 2017-02   |             2 | same       |
--   +-----------+---------------+------------+
--
-- Note:
--   * We may also use LEFT(pay_date, 7) to extract date month; this more risky
--     though since the string representation may be guaranteed.
--
WITH D AS (
    SELECT 
        DATE_FORMAT(pay_date, '%Y-%m') AS pay_month,
        department_id,
        AVG(amount) AS amount
    FROM salary s
    JOIN employee e ON s.employee_id = e.employee_id
    GROUP BY DATE_FORMAT(pay_date, '%Y-%m'), department_id
),
C AS (
    SELECT 
        DATE_FORMAT(pay_date, '%Y-%m') AS pay_month,
        AVG(amount) AS amount
    FROM salary s
    JOIN employee e ON s.employee_id = e.employee_id
    GROUP BY DATE_FORMAT(pay_date, '%Y-%m')
)
SELECT
    D.pay_month,
    D.department_id,
    CASE WHEN D.amount > C.amount THEN 'higher'
        WHEN D.amount < C.amount THEN 'lower'
        ELSE 'same' END AS comparison
    FROM D
    LEFT JOIN C ON D.pay_month = C.pay_month
    ORDER BY D.pay_month DESC, D.department_id ASC;


