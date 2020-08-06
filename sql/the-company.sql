/*
Amber's conglomerate corporation just acquired some new companies. Each of the
companies follows this hierarchy:

  Founder
  Lead Manager
  Senior Manager
  Manager
  Employee

Given the table schemas below, write a query to print the company_code, founder
name, total number of lead managers, total number of senior managers, total
number of managers, and total number of employees.
Order your output by ascending company_code.

Sample Output:

  C1 Monika 1 2 1 2
  C2 Samantha 1 1 2 2

Note:
  - The tables may contain duplicate records.
  - The company_code is string, so the sorting should not be numeric.
    For example, if the company_codes are C_1, C_2, and C_10, then the ascending
    company_codes will be C_1, C_10, and C_2.

REFERENCE:
  - https://www.hackerrank.com/challenges/the-company/problem (Medium)

*/

------------------
-- TEST DATA
------------------
DROP TABLE IF EXISTS Company;
CREATE TABLE IF NOT EXISTS Company
(
    company_code VARCHAR(5),
    founder VARCHAR(20)
);

DROP TABLE IF EXISTS Lead_Manager;
CREATE TABLE IF NOT EXISTS Lead_Manager
(
    lead_manager_code VARCHAR(5),
    company_code VARCHAR(5)
);

DROP TABLE IF EXISTS Senior_Manager;
CREATE TABLE IF NOT EXISTS Senior_Manager
(
    senior_manager_code VARCHAR(5),
    lead_manager_code VARCHAR(5),
    company_code VARCHAR(5)
);

DROP TABLE IF EXISTS Manager;
CREATE TABLE IF NOT EXISTS Manager
(
    manager_code VARCHAR(5),
    senior_manager_code VARCHAR(5),
    lead_manager_code VARCHAR(5),
    company_code VARCHAR(5)
);

DROP TABLE IF EXISTS Employee;
CREATE TABLE IF NOT EXISTS Employee
(
    employee_code VARCHAR(5),
    manager_code VARCHAR(5),
    senior_manager_code VARCHAR(5),
    lead_manager_code VARCHAR(5),
    company_code VARCHAR(5)
);


TRUNCATE TABLE Company;
INSERT INTO Company VALUES
    ('C1', 'Monika'),
    ('C2', 'Samantha');

TRUNCATE TABLE Lead_Manager;
INSERT INTO Lead_Manager VALUES
    ('LM1', 'C1'),
    ('LM2', 'C2');

TRUNCATE TABLE Senior_Manager;
INSERT INTO Senior_Manager VALUES
    ('SM1', 'LM1', 'C1'),
    ('SM2', 'LM1', 'C1'),
    ('SM3', 'LM2', 'C2');

TRUNCATE TABLE Manager;
INSERT INTO Manager VALUES
    ('M1', 'SM1', 'LM1', 'C1'),
    ('M2', 'SM3', 'LM2', 'C2'),
    ('M3', 'SM3', 'LM2', 'C2');

TRUNCATE TABLE Employee;
INSERT INTO Employee VALUES
    ('E1', 'M1', 'SM1', 'LM1', 'C1'),
    ('E2', 'M1', 'SM1', 'LM1', 'C1'),
    ('E3', 'M2', 'SM3', 'LM2', 'C2'),
    ('E4', 'M3', 'SM3', 'LM2', 'C2');


------------
-- ANSWERS
------------

-- 1. WITH + Multiple JOINs
WITH 
  LM AS (SELECT company_code, COUNT(DISTINCT lead_manager_code) AS num_lmgr FROM Lead_Manager GROUP BY company_code),
  SM AS (SELECT company_code, COUNT(DISTINCT senior_manager_code) AS num_smgr FROM Senior_Manager GROUP BY company_code),
  M  AS (SELECT company_code, COUNT(DISTINCT manager_code) AS num_mgr FROM Manager GROUP BY company_code),
  E  AS (SELECT company_code, COUNT(DISTINCT employee_code) AS num_emp FROM Employee GROUP BY company_code)
SELECT
    C.company_code, 
    C.founder, 
    COALESCE(LM.num_lmgr, 0) AS num_lmgr,
    COALESCE(SM.num_smgr, 0) AS num_smgr,
    COALESCE(M.num_mgr, 0) AS num_mgr,
    COALESCE(E.num_emp, 0) AS num_emp
  FROM Company C
  LEFT JOIN LM ON C.company_code = LM.company_code
  LEFT JOIN SM ON C.company_code = SM.company_code
  LEFT JOIN M ON C.company_code = M.company_code
  LEFT JOIN E ON C.company_code = E.company_code
  ORDER BY C.company_code ASC;


-- 2. Multie JOIN + SELECT
SELECT
    C.company_code, 
    C.founder, 
    COALESCE(LM.num_lmgr, 0) AS num_lmgr,
    COALESCE(SM.num_smgr, 0) AS num_smgr,
    COALESCE(M.num_mgr, 0) AS num_mgr,
    COALESCE(E.num_emp, 0) AS num_emp
  FROM Company C
  LEFT JOIN (
      SELECT company_code, COUNT(DISTINCT lead_manager_code) AS num_lmgr 
      FROM Lead_Manager
      GROUP BY company_code
  ) LM ON C.company_code = LM.company_code
  LEFT JOIN (
      SELECT company_code, COUNT(DISTINCT senior_manager_code) AS num_smgr 
      FROM Senior_Manager
      GROUP BY company_code
  ) SM ON C.company_code = SM.company_code
  LEFT JOIN (
      SELECT company_code, COUNT(DISTINCT manager_code) AS num_mgr 
      FROM Manager
      GROUP BY company_code
  ) M ON C.company_code = M.company_code
  LEFT JOIN (
      SELECT company_code, COUNT(DISTINCT employee_code) AS num_emp 
      FROM Employee
      GROUP BY company_code
  ) E ON C.company_code = E.company_code
  ORDER BY C.company_code ASC;



