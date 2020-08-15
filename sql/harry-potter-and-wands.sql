/*
Harry Potter and his friends are at Ollivander's with Ron, finally replacing
Charlie Weasley's old broken wand.

Hermione decides the best way to choose is by determining the minimum number of
gold galleons needed to buy each non-evil wand of high power and age. Write a
query to print the id, age, coins_needed, and power of the wands that Ron's
interested in, sorted in order of descending power. If more than one wand has
same power, sort the result in order of descending age.

Input Format:

The following tables contain data on the wands in Ollivander's inventory:

  - Wands: The id is the id of the wand, code is the code of the wand,
    coins_needed is the total number of gold galleons needed to buy the wand, and
    power denotes the quality of the wand (the higher the power, the better the
    wand is).

    TABLE Wands (
        id INT,
        code INT,
        coins_needed INT,
        power INT
    )

  - Wands_Property: The code is the code of the wand, age is the age of the
    wand, and is_evil denotes whether the wand is good for the dark arts. If the
    value of is_evil is 0, it means that the wand is not evil. The mapping between
    code and age is one-one, meaning that if there are two pairs, (code1, age1)
    and (code2, age2), then and code1 != code2 and age1 != age2.

    TABLE Wands_Property (
        code INT,
        age INT,
        is_evil INT
    )


Sample Wands Table:
    +------+------+--------------+-------+
    | id   | code | coins_needed | power |
    +------+------+--------------+-------+
    |    1 |    4 |         3688 |     8 |
    |    2 |    3 |         9365 |     3 |
    |    3 |    3 |         7187 |    10 |
    |    4 |    3 |          734 |     8 |
    |    5 |    1 |         6020 |     2 |
    |    6 |    2 |         6733 |     7 |
    |    7 |    3 |         9873 |     9 |
    |    8 |    3 |         7721 |     7 |
    |    9 |    1 |         1647 |    10 |
    |   10 |    4 |          504 |     5 |
    |   11 |    2 |         7587 |     5 |
    |   12 |    5 |         9897 |    10 |
    |   13 |    3 |         4651 |     8 |
    |   14 |    2 |         5408 |     1 |
    |   15 |    2 |         6018 |     7 |
    |   16 |    4 |         7710 |     5 |
    |   17 |    2 |         8798 |     7 |
    |   18 |    2 |         3312 |     3 |
    |   19 |    4 |         7651 |     6 |
    |   20 |    5 |         5689 |     3 |
    +------+------+--------------+-------+

Sample Wands_Property Table:
    +------+------+---------+
    | code | age  | is_evil |
    +------+------+---------+
    |    1 |   45 |       0 |
    |    2 |   40 |       0 |
    |    3 |    4 |       1 |
    |    4 |   20 |       0 |
    |    5 |   17 |       0 |
    +------+------+---------+

Sample Output:
    +------+------+--------------+-------+
    | id   | age  | coins_needed | power |
    +------+------+--------------+-------+
    |    9 |   45 |         1647 |    10 |
    |   12 |   17 |         9897 |    10 |
    |    1 |   20 |         3688 |     8 |
    |   15 |   40 |         6018 |     7 |
    |   19 |   20 |         7651 |     6 |
    |   11 |   40 |         7587 |     5 |
    |   10 |   20 |          504 |     5 |
    |   18 |   40 |         3312 |     3 |
    |   20 |   17 |         5689 |     3 |
    |    5 |   45 |         6020 |     2 |
    |   14 |   40 |         5408 |     1 |
    +------+------+--------------+-------+

REF:
  - https://www.hackerrank.com/challenges/harry-potter-and-wands/problem (Medium)

*/

DROP TABLE IF EXISTS Wands;
CREATE TABLE IF NOT EXISTS Wands (
    id INT,
    code INT,
    coins_needed INT,
    power INT
);

DROP TABLE IF EXISTS Wands_Property;
CREATE TABLE IF NOT EXISTS Wands_Property (
    code INT,
    age INT,
    is_evil INT
);


TRUNCATE TABLE Wands;
INSERT INTO Wands VALUES 
    ( 1, 4, 3688, 8),
    ( 2, 3, 9365, 3),
    ( 3, 3, 7187, 10),
    ( 4, 3,  734, 8),
    ( 5, 1, 6020, 2),
    ( 6, 2, 6733, 7),
    ( 7, 3, 9873, 9),
    ( 8, 3, 7721, 7),
    ( 9, 1, 1647, 10),
    (10, 4,  504, 5),
    (11, 2, 7587, 5),
    (12, 5, 9897, 10),
    (13, 3, 4651, 8),
    (14, 2, 5408, 1),
    (15, 2, 6018, 7),
    (16, 4, 7710, 5),
    (17, 2, 8798, 7),
    (18, 2, 3312, 3),
    (19, 4, 7651, 6),
    (20, 5, 5689, 3);

TRUNCATE TABLE Wands_Property;
INSERT INTO Wands_Property VALUES
    (1, 45, 0),
    (2, 40, 0),
    (3,  4, 1),
    (4, 20, 0),
    (5, 17, 0);

--
-- The key is the compare coins_needed with the MIN coins_needed,
-- which is obtained by a sub-query.
--
SELECT w.id, p.age, w.coins_needed, w.power 
FROM Wands as w, Wands_Property p
WHERE 
    w.code = p.code AND
    p.is_evil = 0 AND
    w.coins_needed = (
      SELECT MIN(coins_needed) 
      FROM Wands w1, Wands_Property p1 
      WHERE w1.code = p1.code AND w1.power = w.power AND p1.age = p.age
    ) 
ORDER BY w.power DESC, p.age DESC;


