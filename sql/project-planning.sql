/*
You are given a table, Projects, containing three columns: Task_ID, Start_Date
and End_Date. It is guaranteed that the difference between the End_Date and the
Start_Date is equal to 1 day for each row in the table.

If the End_Date of the tasks are consecutive, then they are part of the same
project.  Samantha is interested in finding the total number of different
projects completed.

Write a query to output the start and end dates of projects listed by the number
of days it took to complete the project in ascending order. If there is more
than one project that have the same number of completion days, then order by the
start date of the project.

REF: 
  - https://www.hackerrank.com/challenges/sql-projects/problem (Medium)

*/

--  Data
DROP TABLE IF EXISTS Projects;
CREATE TABLE Projects
(
    Task_ID  INT,
    Start_Date DATE,
    End_Date DATE
);

TRUNCATE TABLE Projects;
INSERT INTO Projects VALUES
   (1, '2015-10-01', '2015-10-02'),
   (2, '2015-10-02', '2015-10-03'),
   (3, '2015-10-03', '2015-10-04'),
   (4, '2015-10-13', '2015-10-14'),
   (5, '2015-10-14', '2015-10-15'),
   (6, '2015-10-28', '2015-10-29'),
   (7, '2015-10-30', '2015-10-31');


-- Output:
--  +------------+------------+
--  | Start_Date | End_Date   |
--  +------------+------------+
--  | 2015-10-28 | 2015-10-29 |
--  | 2015-10-30 | 2015-10-31 |
--  | 2015-10-13 | 2015-10-15 |
--  | 2015-10-01 | 2015-10-04 |
--  +------------+------------+
--
-- S:
--  +------------+---+
--  | Start_Date | R |
--  +------------+---+
--  | 2015-10-01 | 1 |
--  | 2015-10-13 | 2 |
--  | 2015-10-28 | 3 |
--  | 2015-10-30 | 4 |
--  +------------+---+
--
-- E:
--  +------------+---+
--  | End_Date   | R |
--  +------------+---+
--  | 2015-10-04 | 1 |
--  | 2015-10-15 | 2 |
--  | 2015-10-29 | 3 |
--  | 2015-10-31 | 4 |
--  +------------+---+
--
WITH S AS (
    SELECT Start_Date, ROW_NUMBER() OVER(ORDER BY Start_Date ASC) AS R
    FROM (
        SELECT Start_Date 
        FROM Projects
        WHERE Start_Date NOT IN (SELECT End_Date FROM Projects)
    ) T1
),
E AS (
    SELECT End_Date, ROW_NUMBER() OVER(ORDER BY End_Date ASC) AS R
    FROM (
        SELECT End_Date 
        FROM Projects
        WHERE End_Date NOT IN (SELECT Start_Date FROM Projects)
    ) T2
)
SELECT Start_Date, End_Date 
    FROM S, E 
    WHERE S.R = E.R
    ORDER BY DATEDIFF(End_Date, Start_Date) ASC, Start_Date ASC;


