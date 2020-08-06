/*
Samantha was tasked with calculating the average monthly salaries for all
employees in the EMPLOYEES table, but did not realize her keyboard's 0
key was broken until after completing the calculation. She wants your help
finding the difference between her miscalculation (using salaries with any
zeroes removed), and the actual average salary.

Write a query calculating the amount of error (i.e.: average monthly salaries),
and round it up to the next integer.

REFERENCE:
  - https://www.hackerrank.com/challenges/the-company/problem (Medium)

*/

------------------
-- TEST DATA
------------------
DROP TABLE IF EXISTS EMPLOYEES;
CREATE TABLE IF NOT EXISTS EMPLOYEES
(
    ID INT,
    Name VARCHAR(20),
    Salary INT
);

TRUNCATE TABLE EMPLOYEES;
INSERT INTO EMPLOYEES VALUES
    (1, 'Kristeen', 1420),
    (2, 'Ashley', 2006),
    (3, 'Julia', 2210),
    (4, 'Maria', 3000);


------------
-- ANSWERS
------------

-- REPLACE can work directly on integers.
SELECT 
    CEIL( AVG(Salary) - AVG(REPLACE(Salary,'0','')) )
    FROM EMPLOYEES;
    


