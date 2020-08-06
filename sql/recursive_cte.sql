/*
Recursive WITH (Common Table Expressions).

REFERENCE:
  - https://dev.mysql.com/doc/refman/8.0/en/with.html

*/


/*
Generate series 1 to 5.

    +------+
    | n    |
    +------+
    |    1 |
    |    2 |
    |    3 |
    |    4 |
    |    5 |
    +------+
*/
WITH RECURSIVE S(n) AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM S WHERE n < 5
)
SELECT * from S;


/*
Generate series (n, n^2, n^3) for n in [1,5].

    +------+------+------+
    | n    | n2   | n3   |
    +------+------+------+
    |    1 |    1 |    1 |
    |    2 |    4 |    8 |
    |    3 |    9 |   27 |
    |    4 |   16 |   64 |
    |    5 |   25 |  125 |
    +------+------+------+
*/
WITH RECURSIVE S AS (
    SELECT 1 AS n, 1 AS n2, 1 AS n3
    UNION ALL
    SELECT n + 1, POW(n+1,2), POW(n+1, 3) FROM S WHERE n < 5
)
SELECT * from S;


/*
Use a query to generate the Fibonacci sequence like the following:

    +------+-------+
    | n    | fib_n |
    +------+-------+
    |    1 |     0 |
    |    2 |     1 |
    |    3 |     1 |
    |    4 |     2 |
    |    5 |     3 |
    |    6 |     5 |
    |    7 |     8 |
    +------+-------+
*/
WITH RECURSIVE fibonacci AS (
  SELECT 
    1 AS n,
    0 AS fib_n, 
    1 AS next_fib_n
  UNION ALL
  SELECT n + 1, next_fib_n, fib_n + next_fib_n  
    FROM fibonacci WHERE n < 7
)
SELECT n, fib_n from fibonacci;


/*
Generate series (n, ['X']*n, ['X']*2^n) for n in [1,5].

    +------+-------+------------------+
    | n    | sn    | sn2              |
    +------+-------+------------------+
    |    1 | X     | X                |
    |    2 | XX    | XX               |
    |    3 | XXX   | XXXX             |
    |    4 | XXXX  | XXXXXXXX         |
    |    5 | XXXXX | XXXXXXXXXXXXXXXX |
    +------+-------+------------------+

NOTE: it is necessary to CAST 'X' to a larger size; otherwise,
      they will be truncated to the original size.
*/
WITH RECURSIVE S AS (
    SELECT 1 AS n, 
        CAST('X' AS CHAR(20))  AS sn,
        CAST('X' AS CHAR(20))  AS sn2
    UNION ALL
    SELECT n + 1, CONCAT(sn,'X'), CONCAT(sn2,sn2) FROM S WHERE n < 5
)
SELECT * from S;



/*
Prime Numbers

+------------+
| PRIMES     |
+------------+
| 2&3&5&7&11 |
+------------+

*/
WITH RECURSIVE S AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM S WHERE n < 1000
)
SELECT GROUP_CONCAT(n SEPARATOR '&') AS PRIMES
FROM (
    SELECT S1.n AS n,
            SUM(CASE WHEN S1.n % S2.n = 0 THEN 1 ELSE 0 END) AS divisors
        FROM S AS S1, S AS S2
        WHERE S2.n < S1.n
        GROUP BY S1.n
        ORDER BY S1.n
) A
WHERE divisors = 1;

