/*
Two data sets:

user_network_requests
  - userid
  - timestamp
  - data_center: label of the data center
  - success:  1 for success and 0 for failure.

user_country
  - userid
  - country

*/

-- -------
--  Data
-- -------
DROP TABLE IF EXISTS user_network_requests;
CREATE TABLE user_network_requests
(
    userid INT NOT NULL,
    timestamp TIMESTAMP NOT NULL,
    data_center VARCHAR(10),
    success INT
);

TRUNCATE TABLE user_network_requests;
INSERT INTO user_network_requests VALUES
    (10023411, '2020-07-01 00:00:01', 'A', 1),
    (10023411, '2020-07-01 00:00:02', 'B', 0),
    (10023422, '2020-07-01 00:00:03', 'A', 0),
    (10023422, '2020-07-01 00:00:04', 'B', 0),
    (10023422, '2020-07-01 00:00:05', 'B', 1),
    (10023433, '2020-07-01 00:00:06', 'A', 1);

DROP TABLE IF EXISTS user_country;
CREATE TABLE user_country
(
    userid INT NOT NULL,
    country VARCHAR(10)
);

TRUNCATE TABLE user_country;
INSERT INTO user_country VALUES
    (10023411, 'US'),
    (10023422, 'JP'),
    (10023433, 'US');


-- 
-- Q1. For each data center, compute the fraction of requests that fail.
-- 

-- Simple answer
SELECT
    data_center,
    SUM(CASE WHEN success=0 THEN 1 ELSE 0 END) / COUNT(*) AS fail_ratio
  FROM user_network_requests
  GROUP BY data_center;

-- An unnecesarry overkill
WITH T AS (
  SELECT data_center, count(*) as total_requests
  FROM user_network_requests
  GROUP BY data_center
)
SELECT 
  A.data_center,
  A.num_fails / T.total_requests AS fail_ratio
FROM
(
  SELECT data_center, 
    SUM(CASE WHEN success=0 THEN 1 ELSE 0 END) AS num_fails
  FROM user_network_requests
  GROUP BY data_center
) A, T
WHERE A.data_center = T.data_center;


-- 
-- Q2. For each country, compute the fraction of requests that fail.
-- 
SELECT
    country,
    SUM(CASE WHEN success=0 THEN 1 ELSE 0 END) / COUNT(*) AS fail_ratio
  FROM user_network_requests a, user_country b
  WHERE a.userid = b.userid
  GROUP BY b.country;


-- 
-- Q3. Count the number of users who has never had a failure in each country.
-- 
SELECT 
    country,
    SUM(CASE WHEN num_failures = 0 THEN 1 ELSE 0 END) as num_users_no_failures
  FROM (
    -- Get the numver of failures for each country/user
    SELECT
        country,
        a.userid,
        SUM(CASE WHEN success=0 THEN 1 ELSE 0 END) AS num_failures
      FROM user_network_requests a, user_country b
      WHERE a.userid = b.userid
      GROUP BY country, a.userid
  ) c
  GROUP BY country;


