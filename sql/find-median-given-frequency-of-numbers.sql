/*
The Numbers table keeps the value of number and its frequency.

    +----------+-------------+
    |  Number  |  Frequency  |
    +----------+-------------|
    |  0       |  7          |
    |  1       |  1          |
    |  2       |  3          |
    |  3       |  1          |
    +----------+-------------+

In this table, the numbers are 0, 0, 0, 0, 0, 0, 0, 1, 2, 2, 2, 3,
so the median is (0 + 0) / 2 = 0.

    +--------+
    | median |
    +--------|
    | 0.0000 |
    +--------+

Write a query to find the median of all numbers and name the result as median.

Ref:
  - https://leetcode.com/problems/find-median-given-frequency-of-numbers/ (Hard)

*/

-- DATA
DROP TABLE IF EXISTS Numbers;
CREATE TABLE IF NOT EXISTS Numbers (
    Number INT,
    Frequency INT
);

TRUNCATE TABLE Numbers;
INSERT INTO Numbers VALUES 
    (0, 7),
    (1, 1),
    (2, 3),
    (3, 1);


-- ANSWER
--
-- B (bounds):
--   +--------+-----------+------+------+
--   | Number | Frequency | lb   | ub   |
--   +--------+-----------+------+------+
--   |      0 |         7 |    1 |    7 |
--   |      1 |         1 |    8 |    8 |
--   |      2 |         3 |    9 |   11 |
--   |      3 |         1 |   12 |   12 |
--   +--------+-----------+------+------+
--
-- N (indices for median):
--   +------+------+
--   | i1   | i2   |
--   +------+------+
--   |    6 |    7 |
--   +------+------+
--
-- SELECT * FROM B, N;
--   +--------+-----------+------+------+------+------+
--   | Number | Frequency | lb   | ub   | i1   | i2   |
--   +--------+-----------+------+------+------+------+
--   |      0 |         7 |    1 |    7 |    6 |    7 |
--   |      1 |         1 |    8 |    8 |    6 |    7 |
--   |      2 |         3 |    9 |   11 |    6 |    7 |
--   |      3 |         1 |   12 |   12 |    6 |    7 |
--   +--------+-----------+------+------+------+------+
--
-- Final result:
--   +--------+
--   | median |
--   +--------+
--   | 0.0000 |
--   +--------+
--
WITH B AS (
    -- Get lb & ub of cumulative frequencies
    SELECT n.*,
        (@s + 1) AS lb,
        (@s := @s + Frequency) AS ub
    FROM Numbers n, (SELECT @s:= 0) v
    ORDER BY Number
),
N AS (
    SELECT
        CEIL(SUM(Frequency)/2) AS i1,
        CEIL((SUM(Frequency)+1)/2) AS i2
        FROM Numbers
)
SELECT AVG(Number) AS median
FROM B, N
WHERE (i1 BETWEEN lb AND ub) OR (i2 BETWEEN lb AND ub);


