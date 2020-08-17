/*
Table: Activity

+--------------+---------+
| Column Name  | Type    |
+--------------+---------+
| player_id    | int     |
| device_id    | int     |
| event_date   | date    |
| games_played | int     |
+--------------+---------+
(player_id, event_date) is the primary key of this table.
This table shows the activity of players of some game.
Each row is a record of a player who logged in and played a number of games (possibly 0) before logging out on some day using some device.



We define the install date of a player to be the first login day of that player.

We also define day 1 retention of some date X to be the number of players whose install date is X and they logged back in on the day right after X, divided by the number of players whose install date is X, rounded to 2 decimal places.

Write an SQL query that reports for each install date, the number of players that installed the game on that day and the day 1 retention.

The query result format is in the following example:

Activity table:
+-----------+-----------+------------+--------------+
| player_id | device_id | event_date | games_played |
+-----------+-----------+------------+--------------+
| 1         | 2         | 2016-03-01 | 5            |
| 1         | 2         | 2016-03-02 | 6            |
| 2         | 3         | 2017-06-25 | 1            |
| 3         | 1         | 2016-03-01 | 0            |
| 3         | 4         | 2016-07-03 | 5            |
+-----------+-----------+------------+--------------+

Result table:
+------------+----------+----------------+
| install_dt | installs | Day1_retention |
+------------+----------+----------------+
| 2016-03-01 | 2        | 0.50           |
| 2017-06-25 | 1        | 0.00           |
+------------+----------+----------------+
Player 1 and 3 installed the game on 2016-03-01 but only player 1 logged back in on 2016-03-02 so the day 1 retention of 2016-03-01 is 1 / 2 = 0.50
Player 2 installed the game on 2017-06-25 but didn't log back in on 2017-06-26 so the day 1 retention of 2017-06-25 is 0 / 1 = 0.00



Ref:
  - 

*/

-- DATA
DROP TABLE IF EXISTS Activity;
CREATE TABLE IF NOT EXISTS Activity (
    player_id INT,
    device_id INT,
    event_date DATE,
    games_played INT
);

TRUNCATE TABLE Activity;
INSERT INTO Activity VALUES 
    (1, 2, '2016-03-01', 5),
    (1, 2, '2016-03-02', 6),
    (2, 3, '2017-06-25', 1),
    (3, 1, '2016-03-01', 0),
    (3, 4, '2016-07-03', 5);


-- ANSWER 1: cmpare event_date with the MIN date.
-- Has some redundancy; thus, Time Lmit Exceeded!
WITH T AS (
    SELECT 
        player_id,
        a1.event_date AS install_dt
    FROM Activity a1
    WHERE a1.event_date = (
        SELECT MIN(a2.event_date)
        FROM Activity a2
        WHERE a1.player_id = a2.player_id)
),
X AS (
    SELECT t.*, 
        IF(a.event_date IS NULL, 0, 1) AS day1_retention,
        a.event_date
    FROM T t
    LEFT JOIN Activity a
    ON t.player_id=a.player_id AND
        DATEDIFF(a.event_date, t.install_dt) = 1
)
SELECT install_dt,
    COUNT(*) AS installs,
    ROUND(SUM(day1_retention)/COUNT(*), 2) AS Day1_retention
FROM X
GROUP BY install_dt
ORDER BY install_dt;


-- ANSWER 2: directly select MIN(event_date) as the install date.
WITH T AS (
    -- Identify install date
    SELECT 
        player_id,
        MIN(event_date) AS install_dt
    FROM Activity a
    GROUP BY player_id
),
X AS (
    -- Check day 1 retention
    SELECT t.*, 
        IF(a.event_date IS NULL, 0, 1) AS day1_retention
    FROM T t
    LEFT JOIN Activity a
    ON t.player_id=a.player_id AND
        DATEDIFF(a.event_date, t.install_dt) = 1
)
-- Calculate the day 1 retention ratio.
SELECT install_dt,
    COUNT(*) AS installs,
    ROUND(SUM(day1_retention)/COUNT(*), 2) AS Day1_retention
FROM X
GROUP BY install_dt
ORDER BY install_dt;


