
/*
Sampling & selecting random records.

REFERENCE:
  - 
*/


-- --------------------
--  Select Random Rows
-- --------------------

-- Use RAND + SORT
--   +------+---------+
--   | n    | s       |
--   +------+---------+
--   |   42 | X-00042 |
--   |  100 | X-00100 |
--   |    9 | X-00009 |
--   |   50 | X-00050 |
--   |   40 | X-00040 |
--   +------+---------+
WITH RECURSIVE T AS (
    SELECT 1 AS n, CONCAT('X-', LPAD(1, 5, '0')) AS s
    UNION ALL
    SELECT n + 1, CONCAT('X-', LPAD(n + 1, 5, '0'))
        FROM T WHERE n < 100
)
SELECT * from T
    ORDER BY RAND() LIMIT 5;


-- Use RAND + INNER JOIN
WITH RECURSIVE T AS (
    SELECT 1 AS n, CONCAT('X-', LPAD(1, 5, '0')) AS s
    UNION ALL
    SELECT n + 1, CONCAT('X-', LPAD(n + 1, 5, '0'))
        FROM T WHERE n < 100
),
S AS (
    SELECT ROUND(RAND() * (SELECT MAX(t2.n) FROM T t2)) AS n
    FROM T LIMIT 5
)
SELECT T.* from T, S
    WHERE T.n = S.n;


-- Use RAND + IN
WITH RECURSIVE T AS (
    SELECT 1 AS n, CONCAT('X-', LPAD(1, 5, '0')) AS s
    UNION ALL
    SELECT n + 1, CONCAT('X-', LPAD(n + 1, 5, '0'))
        FROM T WHERE n < 100
),
S AS (
    SELECT CEIL(RAND() * (SELECT MAX(t2.n) FROM T t2)) AS n
    FROM T LIMIT 5
)
SELECT * from T
    WHERE T.n IN (SELECT S.n FROM S);



-- -----------
--  SAMPLING
-- -----------

-- RAND() < threshold
--   +------+---------+
--   | n    | s       |
--   +------+---------+
--   |   17 | X-00017 |
--   |   20 | X-00020 |
--   |   31 | X-00031 |
--   |   67 | X-00067 |
--   |   77 | X-00077 |
--   +------+---------+
WITH RECURSIVE T AS (
    SELECT 1 AS n, CONCAT('X-', LPAD(1, 5, '0')) AS s
    UNION ALL
    SELECT n + 1, CONCAT('X-', LPAD(n + 1, 5, '0'))
        FROM T WHERE n < 100
)
SELECT * from T
    WHERE RAND() < 0.05;


