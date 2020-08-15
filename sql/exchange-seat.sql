/*
Mary is a teacher in a middle school and she has a table seat storing students'
names and their corresponding seat ids.  The column id is continuous increment.

Mary wants to change seats for the adjacent students.

Can you write a SQL query to output the result for Mary? 

Input (seat table):
    +----+---------+
    | id | student |
    +----+---------+
    |  1 | Abbot   |
    |  2 | Doris   |
    |  3 | Emersno |
    |  4 | Green   |
    |  5 | Jeames  |
    +----+---------+

Output:
    +------+---------+
    | id   | student |
    +------+---------+
    |    1 | Doris   |
    |    2 | Abbot   |
    |    3 | Green   |
    |    4 | Emersno |
    |    5 | Jeames  |
    +------+---------+

Ref:
  - https://leetcode.com/problems/exchange-seats/ (Medium)

*/

-- DATA
DROP TABLE IF EXISTS seat;
CREATE TABLE IF NOT EXISTS seat (
    id INT NOT NULL AUTO_INCREMENT,
    student VARCHAR(16),
    PRIMARY KEY (id)
);
INSERT INTO seat (student) VALUES ('Abbot'), ('Doris'), ('Emersno'), ('Green'), ('Jeames');


-- ----------
--  ANSWERS
-- ----------

-- WITH + CASE + LEAST
WITH T AS (
    SELECT MAX(id) AS idmax FROM seat
)
SELECT 
    CASE WHEN id % 2 = 0 THEN id - 1 ELSE LEAST(id + 1, idmax) END AS id,
    student
FROM seat, T
ORDER BY id;


-- CASE + subquery
SELECT 
    CASE WHEN id % 2 = 1 AND id = (SELECT MAX(id) FROM seat) THEN id
        WHEN id % 2 = 0 THEN id - 1
        ELSE id + 1 END AS id,
    student
FROM seat
ORDER BY id;


-- IF + subquery
SELECT
    IF(id % 2 = 0, id - 1,
       IF(id = (SELECT MAX(id) FROM seat), id, id + 1)) AS id,
    student
FROM seat 
ORDER BY id;


