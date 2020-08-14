/*
Table: Spending
    +-------------+---------+
    | Column Name | Type    |
    +-------------+---------+
    | user_id     | int     |
    | spend_date  | date    |
    | platform    | enum    | 
    | amount      | int     |
    +-------------+---------+

The table logs the spendings history of users that make purchases from an online shopping website which has a desktop and a mobile application.
(user_id, spend_date, platform) is the primary key of this table.
The platform column is an ENUM type of ('desktop', 'mobile').

Write an SQL query to find the total number of users and the total amount spent using mobile only, desktop only and both mobile and desktop together for each date.

The query result format is in the following example:

Spending table:
    +---------+------------+----------+--------+
    | user_id | spend_date | platform | amount |
    +---------+------------+----------+--------+
    | 1       | 2019-07-01 | mobile   | 100    |
    | 1       | 2019-07-01 | desktop  | 100    |
    | 2       | 2019-07-01 | mobile   | 100    |
    | 2       | 2019-07-02 | mobile   | 100    |
    | 3       | 2019-07-01 | desktop  | 100    |
    | 3       | 2019-07-02 | desktop  | 100    |
    +---------+------------+----------+--------+

Result table:
    +------------+----------+--------------+-------------+
    | spend_date | platform | total_amount | total_users |
    +------------+----------+--------------+-------------+
    | 2019-07-01 | desktop  | 100          | 1           |
    | 2019-07-01 | mobile   | 100          | 1           |
    | 2019-07-01 | both     | 200          | 1           |
    | 2019-07-02 | desktop  | 100          | 1           |
    | 2019-07-02 | mobile   | 100          | 1           |
    | 2019-07-02 | both     | 0            | 0           |
    +------------+----------+--------------+-------------+ 

Note:
  - On 2019-07-01, user 1 purchased using both desktop and mobile, user 2 purchased using mobile only and user 3 purchased using desktop only.
  - On 2019-07-02, user 2 purchased using mobile only, user 3 purchased using desktop only and no one purchased using both platforms.

Ref:
  - https://leetcode.com/problems/user-purchase-platform/ (Hard)

*/

-- DATA
DROP TABLE IF EXISTS Spending;
CREATE TABLE IF NOT EXISTS Spending (
    user_id INT,
    spend_date DATE,
    platform ENUM ('mobile', 'desktop'),
    amount INT
);

TRUNCATE TABLE Spending;
INSERT INTO Spending VALUES 
    (1, '2019-07-01', 'mobile', 100),
    (1, '2019-07-01', 'desktop', 100),
    (2, '2019-07-01', 'mobile', 100),
    (2, '2019-07-02', 'mobile', 100),
    (3, '2019-07-01', 'desktop', 100),
    (3, '2019-07-02', 'desktop', 100);


-- Get mobile spending and desktop spending in one row.
WITH T AS (
    SELECT spend_date, user_id,
        SUM(CASE WHEN platform='desktop' THEN amount ELSE 0 END) AS desktop_amount,
        SUM(CASE WHEN platform='mobile' THEN amount ELSE 0 END) AS mobile_amount
    FROM Spending
    GROUP BY spend_date, user_id
)
SELECT spend_date, platform, total_amount, total_users
FROM (
    SELECT spend_date, 'desktop' AS platform, 1 as rnk,
        SUM(CASE WHEN desktop_amount > 0 and mobile_amount = 0 THEN desktop_amount ELSE 0 END) AS total_amount,
        SUM(CASE WHEN desktop_amount > 0 and mobile_amount = 0 THEN 1 ELSE 0 END) AS total_users
        FROM T GROUP BY spend_date
    UNION ALL
    SELECT spend_date, 'mobile' AS platform, 2 as rnk,
        SUM(CASE WHEN desktop_amount = 0 and mobile_amount > 0 THEN mobile_amount ELSE 0 END) AS total_amount,
        SUM(CASE WHEN desktop_amount = 0 and mobile_amount > 0 THEN 1 ELSE 0 END) AS total_users
        FROM T GROUP BY spend_date
    UNION ALL
    SELECT spend_date, 'both' AS platform, 3 as rnk,
        SUM(CASE WHEN desktop_amount > 0 and mobile_amount > 0 THEN desktop_amount + mobile_amount ELSE 0 END) AS total_amount,
        SUM(CASE WHEN desktop_amount > 0 and mobile_amount > 0 THEN 1 ELSE 0 END) AS total_users
        FROM T GROUP BY spend_date
) X
ORDER BY spend_date, rnk;


-- Alter the platform value
WITH A AS (
    SELECT spend_date, platform,
        SUM(amount) AS total_amount,
        COUNT(DISTINCT user_id) AS total_users 
    FROM (
        -- Change platform to 'both' if the user spend on both platforms
        SELECT spend_date, user_id, 
            CASE WHEN COUNT(distinct platform) > 1 THEN 'both' ELSE platform END AS platform,
            SUM(amount) AS amount
        FROM Spending
        GROUP BY spend_date, user_id
    ) T
    GROUP BY spend_date, platform
),
B AS (
    SELECT DISTINCT spend_date FROM Spending
),
C AS (
    -- Set the output format to cover missing lines in A
    SELECT spend_date, 'desktop' AS platform, 1 as rnk FROM B
    UNION
    SELECT spend_date, 'mobile' AS platform, 2 as rnk FROM B
    UNION
    SELECT spend_date, 'both' AS platform, 3 as rnk FROM B
)
SELECT spend_date, platform, total_amount, total_users
FROM (
    SELECT C.*, 
        COALESCE(A.total_amount, 0) AS total_amount,
        COALESCE(A.total_users, 0) AS total_users
    FROM C 
    LEFT JOIN A USING (spend_date, platform)
) J
ORDER BY spend_date, rnk;


-- Combine the above two ansers
WITH T AS (
    -- Change platform values
    SELECT spend_date, user_id, 
        CASE WHEN COUNT(distinct platform) > 1 THEN 'both' ELSE platform END AS platform,
        SUM(amount) AS amount
    FROM Spending
    GROUP BY spend_date, user_id
)
SELECT spend_date, platform, total_amount, total_users
FROM (
    -- Group by each platform
    SELECT spend_date, 'desktop' AS platform, 1 as rnk,
        SUM(CASE WHEN platform = 'desktop' THEN amount ELSE 0 END) AS total_amount,
        SUM(CASE WHEN platform = 'desktop' THEN 1 ELSE 0 END) AS total_users
        FROM T GROUP BY spend_date
    UNION
    SELECT spend_date, 'mobile' AS platform, 2 as rnk,
        SUM(CASE WHEN platform = 'mobile' THEN amount ELSE 0 END) AS total_amount,
        SUM(CASE WHEN platform = 'mobile' THEN 1 ELSE 0 END) AS total_users
        FROM T GROUP BY spend_date
    UNION
    SELECT spend_date, 'both' AS platform, 3 as rnk,
        SUM(CASE WHEN platform = 'both' THEN amount ELSE 0 END) AS total_amount,
        SUM(CASE WHEN platform = 'both' THEN 1 ELSE 0 END) AS total_users
        FROM T GROUP BY spend_date
) X
ORDER BY spend_date, rnk;



