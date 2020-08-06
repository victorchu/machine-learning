/*
You are given a table, BST, containing two columns: N and P, where N represents
the value (Id) of a node in Binary Tree, and P is the parent (Id) of N.

BST:
   N: Integer
   P: Integer

Write a query to find the node type of Binary Tree ordered by the value of the
node. Output one of the following for each node:

  - Root:  If node is root node.
  - Leaf:  If node is leaf node.
  - Inner: If node is neither root nor leaf node.

Sample Input

  N  P
  1  2
  3  2
  6  8
  9  8
  2  5
  8  5
  5  NULL

Sample Output

  1  Leaf
  2  Inner
  3  Leaf
  5  Root
  6  Leaf
  8  Inner
  9  Leaf

REFERENCE:
  - https://www.hackerrank.com/challenges/binary-search-tree-1/problem (Medium)

*/

------------------
-- TEST DATA
------------------
DROP TABLE IF EXISTS BST;
CREATE TABLE IF NOT EXISTS BST
(
    N INT,
    P INT
);

TRUNCATE TABLE BST;
INSERT INTO BST
    VALUES (1, 2), (3, 2), (6, 8), (9, 8), (2, 5), (8, 5), (5, NULL);


-------------
-- ANSWER(S)
-------------
--
--  +------+-----------+
--  | N    | NODE_TYPE |
--  +------+-----------+
--  |    1 | Leaf      |
--  |    2 | Inner     |
--  |    3 | Leaf      |
--  |    5 | Root      |
--  |    6 | Leaf      |
--  |    8 | Inner     |
--  |    9 | Leaf      |
--  +------+-----------+
--
WITH T AS (
    SELECT P, COUNT(*) AS CHILDREN
    FROM BST
    WHERE P IS NOT NULL
    GROUP BY  P
)
SELECT 
    N,
    CASE 
        WHEN A.P IS NULL THEN 'Root'
        WHEN (A.P > 0 AND T.CHILDREN > 0) THEN 'Inner'
        ELSE 'Leaf'
        END AS NODE_TYPE
  FROM BST A
  LEFT JOIN T ON A.N = T.P
  ORDER BY A.N ASC;



-- Intermediate result (for debugging)
--
--  +------+------+----------+
--  | N    | P    | CHILDREN |
--  +------+------+----------+
--  |    1 |    2 |     NULL |
--  |    2 |    5 |        2 |
--  |    3 |    2 |     NULL |
--  |    5 | NULL |        2 |
--  |    6 |    8 |     NULL |
--  |    8 |    5 |        2 |
--  |    9 |    8 |     NULL |
--  +------+------+----------+
--
WITH T AS (
    SELECT P, COUNT(*) AS CHILDREN
    FROM BST
    WHERE P IS NOT NULL
    GROUP BY  P
)
SELECT 
    A.N, A.P, T.CHILDREN
  FROM BST A
  LEFT JOIN T ON A.N = T.P
  ORDER BY A.N ASC;

