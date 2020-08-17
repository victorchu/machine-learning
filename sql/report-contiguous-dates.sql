/*
Table: Failed
+--------------+---------+
| Column Name  | Type    |
+--------------+---------+
| fail_date    | date    |
+--------------+---------+

  - Primary key for this table is fail_date.
  - Failed table contains the days of failed tasks.


Table: Succeeded
+--------------+---------+
| Column Name  | Type    |
+--------------+---------+
| success_date | date    |
+--------------+---------+

  - Primary key for this table is success_date.
  - Succeeded table contains the days of succeeded tasks.
 

A system is running one task every day. Every task is independent of the
previous tasks. The tasks can fail or succeed.

Write an SQL query to generate a report of period_state for each continuous
interval of days in the period from 2019-01-01 to 2019-12-31.

period_state is 'failed' if tasks in this interval failed or 'succeeded' if
tasks in this interval succeeded. Interval of days are retrieved as start_date
and end_date.

Order result by start_date.

The query result format is in the following example:

Failed table:
+-------------------+
| fail_date         |
+-------------------+
| 2018-12-28        |
| 2018-12-29        |
| 2019-01-04        |
| 2019-01-05        |
+-------------------+

Succeeded table:
+-------------------+
| success_date      |
+-------------------+
| 2018-12-30        |
| 2018-12-31        |
| 2019-01-01        |
| 2019-01-02        |
| 2019-01-03        |
| 2019-01-06        |
+-------------------+


Result table:
+--------------+--------------+--------------+
| period_state | start_date   | end_date     |
+--------------+--------------+--------------+
| succeeded    | 2019-01-01   | 2019-01-03   |
| failed       | 2019-01-04   | 2019-01-05   |
| succeeded    | 2019-01-06   | 2019-01-06   |
+--------------+--------------+--------------+

The report ignored the system state in 2018 as we care about the system in the period 2019-01-01 to 2019-12-31.
From 2019-01-01 to 2019-01-03 all tasks succeeded and the system state was "succeeded".
From 2019-01-04 to 2019-01-05 all tasks failed and system state was "failed".
From 2019-01-06 to 2019-01-06 all tasks succeeded and system state was "succeeded".

Ref:
  - https://leetcode.com/problems/report-contiguous-dates/ (Hard)

*/

-- DATA
DROP TABLE IF EXISTS Failed;
CREATE TABLE IF NOT EXISTS Failed (
    fail_date DATE
);

DROP TABLE IF EXISTS Succeeded;
CREATE TABLE IF NOT EXISTS Succeeded (
    success_date DATE
);

TRUNCATE TABLE Failed;
INSERT INTO Failed VALUES 
    ('2018-12-28'),
    ('2018-12-29'),
    ('2019-01-04'),
    ('2019-01-05');

TRUNCATE TABLE Succeeded;
INSERT INTO Succeeded VALUES 
    ('2018-12-30'),
    ('2018-12-31'),
    ('2019-01-01'),
    ('2019-01-02'),
    ('2019-01-03'),
    ('2019-01-06');

-- ANSWER
--
-- CTE A:
--   +--------------+------------+
--   | period_state | dt         |
--   +--------------+------------+
--   | succeeded    | 2018-12-30 |
--   | succeeded    | 2018-12-31 |
--   | succeeded    | 2019-01-01 |
--   | succeeded    | 2019-01-02 |
--   | succeeded    | 2019-01-03 |
--   | succeeded    | 2019-01-06 |
--   | failed       | 2018-12-28 |
--   | failed       | 2018-12-29 |
--   | failed       | 2019-01-04 |
--   | failed       | 2019-01-05 |
--   +--------------+------------+
--
-- CTE B:
--   +--------------+------------+--------+-----------+------------+
--   | period_state | dt         | period | v1        | v2         |
--   +--------------+------------+--------+-----------+------------+
--   | failed       | 2019-01-04 |      1 | failed    | 2019-01-04 |
--   | failed       | 2019-01-05 |      1 | failed    | 2019-01-05 |
--   | succeeded    | 2019-01-01 |      2 | succeeded | 2019-01-01 |
--   | succeeded    | 2019-01-02 |      2 | succeeded | 2019-01-02 |
--   | succeeded    | 2019-01-03 |      2 | succeeded | 2019-01-03 |
--   | succeeded    | 2019-01-06 |      3 | succeeded | 2019-01-06 |
--   +--------------+------------+--------+-----------+------------+
--
-- Result:
--   +--------------+------------+------------+
--   | period_state | start_date | end_date   |
--   +--------------+------------+------------+
--   | succeeded    | 2019-01-01 | 2019-01-03 |
--   | failed       | 2019-01-04 | 2019-01-05 |
--   | succeeded    | 2019-01-06 | 2019-01-06 |
--   +--------------+------------+------------+
--
WITH A AS (
    -- Union these two tables; so that we can deal with them together.
    (SELECT 'succeeded' AS period_state, success_date AS dt FROM Succeeded)
    UNION ALL
    (SELECT 'failed' AS period_state, fail_date AS dt FROM Failed)
),
B AS (
    -- Assign the period group ID.
    -- @s : the previous period_state
    -- @d : the previous date
    -- @g : the period group (1, 2, 3, ...)
    SELECT
        period_state,
        dt,
        CASE WHEN @s=period_state AND DATEDIFF(dt, @d)=1 THEN @g ELSE @g:=@g+1 END AS period,
        @s := period_state AS v1,
        @d := dt AS v2
    FROM A, (SELECT @s:='', @d:='', @g:=0) X
    WHERE dt BETWEEN '2019-01-01' AND '2019-12-31'
    ORDER BY period_state, dt
)
SELECT period_state,
    MIN(dt) AS start_date,
    MAX(dt) AS end_date
FROM B
GROUP BY period_state, period
ORDER BY start_date;


