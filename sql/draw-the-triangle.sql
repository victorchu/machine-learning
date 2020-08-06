/*
P(R) represents a pattern drawn by Julia in R rows. The following pattern represents P(5):

    * * * * *
    * * * *
    * * *
    * *
    *

Write a query to print the pattern P(20).

Ref:
  - https://www.hackerrank.com/challenges/draw-the-triangle-1/problem (Easy)
*/

-- Descending order
WITH RECURSIVE T AS (
    SELECT 1 AS n, 
        CAST('*' AS CHAR(50))  AS s
    UNION ALL
    SELECT n + 1, CONCAT(s,' *') FROM T WHERE n < 20
)
SELECT s from T
ORDER BY n DESC;


-- Ascending order
WITH RECURSIVE T AS (
    SELECT 1 AS n, 
        CAST('*' AS CHAR(50))  AS s
    UNION ALL
    SELECT n + 1, CONCAT(s,' *') FROM T WHERE n < 20
)
SELECT s from T;

