/*
Write a SQL query to find all numbers that appear at least three times consecutively.

    +----+-----+
    | Id | Num |
    +----+-----+
    | 1  |  1  |
    | 2  |  1  |
    | 3  |  1  |
    | 4  |  2  |
    | 5  |  1  |
    | 6  |  2  |
    | 7  |  2  |
    +----+-----+

For example, given the above Logs table, 1 is the only number that appears consecutively for at least three times.

    +-----------------+
    | ConsecutiveNums |
    +-----------------+
    | 1               |
    +-----------------+

REFERENCE:
  - https://leetcode.com/problems/consecutive-numbers/ (Medium)

*/

-- -------
--  Data
-- -------
DROP TABLE IF EXISTS Logs;
CREATE TABLE Logs
(
    Id     INT NOT NULL,
    Num    INT
);

TRUNCATE TABLE Logs;
INSERT INTO Logs VALUES
    (1, 1),
    (2, 1),
    (3, 1),
    (4, 2),
    (5, 1),
    (6, 2),
    (7, 2);

TRUNCATE TABLE Logs;
INSERT INTO Logs VALUES
    (1, -1),
    (2, -1),
    (3, -1);


--------------
-- ANSWERS
--------------

-- Self-joins
SELECT DISTINCT a.Num AS ConsecutiveNums
    FROM Logs a
    JOIN Logs b ON a.Id + 1 = b.Id AND a.Num = b.Num
    JOIN Logs c ON b.Id + 1 = c.Id AND b.Num = c.Num;


-- Variables
SET @n=0, @prev=NULL;
SELECT DISTINCT a.Num AS ConsecutiveNums
    FROM (
        SELECT 
            Num,
            CASE WHEN @prev=Num THEN @n:=@n+1
                ELSE @n:=1 END AS n,
            (@prev:=Num) as p
            FROM Logs
    ) a
    WHERE a.n >= 3;


