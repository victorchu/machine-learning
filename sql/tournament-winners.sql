/*
Table: Players
    +-------------+-------+
    | Column Name | Type  |
    +-------------+-------+
    | player_id   | int   |
    | group_id    | int   |
    +-------------+-------+
player_id is the primary key of this table.
Each row of this table indicates the group of each player.

Table: Matches
    +---------------+---------+
    | Column Name   | Type    |
    +---------------+---------+
    | match_id      | int     |
    | first_player  | int     |
    | second_player | int     | 
    | first_score   | int     |
    | second_score  | int     |
    +---------------+---------+
match_id is the primary key of this table.
Each row is a record of a match, first_player and second_player contain the
player_id of each match.  first_score and second_score contain the number of
points of the first_player and second_player respectively.  You may assume that,
in each match, players belongs to the same group.

The winner in each group is the player who scored the maximum total points
within the group. In the case of a tie, the lowest player_id wins.

Write an SQL query to find the winner in each group.

The query result format is in the following example:

Players table:
    +-----------+------------+
    | player_id | group_id   |
    +-----------+------------+
    | 15        | 1          |
    | 25        | 1          |
    | 30        | 1          |
    | 45        | 1          |
    | 10        | 2          |
    | 35        | 2          |
    | 50        | 2          |
    | 20        | 3          |
    | 40        | 3          |
    +-----------+------------+

Matches table:
    +------------+--------------+---------------+-------------+--------------+
    | match_id   | first_player | second_player | first_score | second_score |
    +------------+--------------+---------------+-------------+--------------+
    | 1          | 15           | 45            | 3           | 0            |
    | 2          | 30           | 25            | 1           | 2            |
    | 3          | 30           | 15            | 2           | 0            |
    | 4          | 40           | 20            | 5           | 2            |
    | 5          | 35           | 50            | 1           | 1            |
    +------------+--------------+---------------+-------------+--------------+

Result table:
    +-----------+------------+
    | group_id  | player_id  |
    +-----------+------------+ 
    | 1         | 15         |
    | 2         | 35         |
    | 3         | 40         |
    +-----------+------------+

Ref:
  - https://leetcode.com/problems/tournament-winners/ (Hard)

*/

-- DATA
DROP TABLE IF EXISTS Players;
CREATE TABLE IF NOT EXISTS Players (
    player_id INT,
    group_id INT
);

DROP TABLE IF EXISTS Matches;
CREATE TABLE IF NOT EXISTS Matches (
    match_id INT,
    first_player INT,
    second_player INT,
    first_score INT,
    second_score INT
);

TRUNCATE TABLE Players;
INSERT INTO Players VALUES 
    (15, 1),
    (25, 1),
    (30, 1),
    (45, 1),
    (10, 2),
    (35, 2),
    (50, 2),
    (20, 3),
    (40, 3);

TRUNCATE TABLE Matches;
INSERT INTO Matches VALUES 
    (1, 15, 45, 3, 0),
    (2, 30, 25, 1, 2),
    (3, 30, 15, 2, 0),
    (4, 40, 20, 5, 2),
    (5, 35, 50, 1, 1);


--
-- Use UNION ALL to flatten the Matches table.
-- Then use RANK OVER to find the winner.
--
-- R table (intermediate results):
--   +----------+-----------+-------+-----+
--   | group_id | player_id | score | rnk |
--   +----------+-----------+-------+-----+
--   |        1 |        15 |     3 |   1 |
--   |        1 |        30 |     3 |   2 |
--   |        1 |        25 |     2 |   3 |
--   |        1 |        45 |     0 |   4 |
--   |        2 |        35 |     1 |   1 |
--   |        2 |        50 |     1 |   2 |
--   |        3 |        40 |     5 |   1 |
--   |        3 |        20 |     2 |   2 |
--   +----------+-----------+-------+-----+
--
-- Note that players (15, 30) and (35, 50) have the same scores.
-- The use of player_id in ranking assures that no two players can have the same rank.
--
WITH T AS (
    -- Get group_id and total score for each player
    SELECT 
        group_id,
        player_id, 
        SUM(score) AS score
    FROM (
        -- "Flatten" the Matches table
        SELECT 
            first_player AS player_id,
            first_score AS score
            FROM Matches
        UNION ALL
        SELECT 
            second_player AS player_id,
            second_score AS score
            FROM Matches
    ) M
    -- Use LEFT JOIN to get the group_id
    LEFT JOIN Players p USING (player_id)
    GROUP BY player_id
    ORDER BY group_id, score DESC, player_id 
),
R AS (
    -- Get the ranks in each group
    SELECT *,
        RANK() OVER(
            PARTITION BY group_id 
            ORDER BY score DESC, player_id ASC) AS rnk
    FROM T
)
SELECT group_id, player_id
FROM R
WHERE rnk = 1;


