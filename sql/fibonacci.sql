/*
QUESTION:

Use a query to generate the Fibonacci sequence like the following:

    n  | fib_n
    ---+------
     1 |     0
     2 |     1
     3 |     1
     4 |     2
     5 |     3
     6 |     5
     7 |     8
     8 |    13
     9 |    21
    10 |    34

TECHNIQUES:
  - WITH RECURSIVE: Recursive CTE (Common Table Expression)

REFERENCE:
  - https://dev.mysql.com/doc/refman/8.0/en/with.html

*/

WITH RECURSIVE fibonacci AS (
  SELECT 
    1 AS n,
    0 AS fib_n, 
    1 AS next_fib_n
  UNION ALL
  SELECT n + 1, next_fib_n, fib_n + next_fib_n  
    FROM fibonacci WHERE n < 10
)
SELECT n, fib_n from fibonacci;


