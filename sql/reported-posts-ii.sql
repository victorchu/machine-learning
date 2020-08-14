/*
Write an SQL query to find the average for daily percentage of posts that got
removed after being reported as spam, rounded to 2 decimal places.

Ref:
  - https://leetcode.com/problems/reported-posts-ii/ (Medium)

*/

-- DATA
DROP TABLE IF EXISTS Actions;
CREATE TABLE IF NOT EXISTS Actions (
    user_id INT,
    post_id INT,
    action_date DATE,
    ACTION VARCHAR(20),
    extra VARCHAR(20)
);
INSERT INTO Actions VALUES 
    (1,1,'2019-07-01','view',null),
    (1,1,'2019-07-01','like',null),
    (1,1,'2019-07-01','share',null),
    (2,2,'2019-07-04','view',null),
    (2,2,'2019-07-04','report','spam'),
    (3,4,'2019-07-04','view',null),
    (3,4,'2019-07-04','report','spam'),
    (4,3,'2019-07-02','view',null),
    (4,3,'2019-07-02','report','spam'),
    (5,2,'2019-07-03','view',null),
    (5,2,'2019-07-03','report','racism'),
    (5,5,'2019-07-03','view',null),
    (5,5,'2019-07-03','report','racism');

DROP TABLE IF EXISTS Removals;
CREATE TABLE IF NOT EXISTS Removals (
    post_id INT,
    remove_date DATE
);
INSERT INTO Removals VALUES 
    (2,'2019-07-20'),
    (3,'2019-07-18');


-- Answer
WITH A AS (
    SELECT DISTINCT action_date, post_id, remove_date
    FROM Actions a
    LEFT JOIN Removals r USING(post_id)
    WHERE a.extra = 'spam'
),
DAILY AS (
    SELECT action_date,
        100 * COUNT(remove_date) / COUNT(post_id) AS percent
    FROM A
    GROUP BY action_date
)
SELECT ROUND(AVG(d.percent), 2) AS average_daily_percent
FROM DAILY d;


