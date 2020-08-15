/*
Symmetric Pairs

https://www.hackerrank.com/challenges/symmetric-pairs/problem (Medium)
*/

-- DATA
DROP TABLE IF EXISTS Functions;
CREATE TABLE IF NOT EXISTS Functions
(
    X INT,
    Y INT
);

TRUNCATE TABLE Functions;
INSERT INTO Functions VALUES
    (20, 20),
    (20, 20),
    (20, 21),
    (23, 22),
    (22, 23),
    (21, 20),
    (24, 25);


-- ANSWER
--  +------+------+
--  | X    | Y    |
--  +------+------+
--  |   20 |   20 |
--  |   20 |   21 |
--  |   22 |   23 |
--  +------+------+
--
-- The key is 'A.R < B.R', which will avoid redundancy.
--
WITH A AS (
    SELECT X, Y,
        ROW_NUMBER() OVER(ORDER BY X, Y) AS R
      FROM Functions
)
SELECT A.X, A.Y
    FROM A, A AS B
    WHERE A.R < B.R AND A.X = B.Y AND A.Y = B.X
    ORDER BY A.X, A.Y;

