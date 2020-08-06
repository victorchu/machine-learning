/*

STATION (
  ID     NUMBER,
  CITY   VARCHAR2(21),
  STATE  VARCHAR2(2),
  LAT_N  NUMBER,  -- the norther latitude
  LONG_W NUMBER   -- the western longitude
)

*/

-- -------
--  Data
-- -------
DROP TABLE IF EXISTS STATION;
CREATE TABLE STATION
(
    ID     REAL NOT NULL,
    CITY   VARCHAR(21),
    STATE  VARCHAR(2),
    LAT_N  REAL,
    LONG_W REAL 
);

TRUNCATE TABLE STATION;
INSERT INTO STATION VALUES
    (1001, 'San Jose', 'CA', 37.3382, 121.8863),
    (1002, 'San Francisco', 'CA', 37.7749, 122.4194),
    (1003, 'Milpitas', 'CA', 37.4323, 121.8896),
    (1101, 'Seattle', 'WA', 47.6062, 122.3321),
    (1201, 'Salt Lake City', 'UH', 40.7608, 111.8910),
    (9001, 'Anchorage', 'AL', 62.2181, 149.9003)
    ;


-- ------
--  EASY
-- ------

--
-- Q5. Query the two cities in STATION with the shortest and longest CITY names, 
-- as well as their respective length. If there is more than one smallest or largest city,
-- choose the one that comes first when ordered alphabetically. 
-- 
-- Note: you can write two separate queries.  It need not to be a single query.
--

-- Two queries
SELECT CITY, LENGTH(CITY) AS LEN
  FROM STATION
  ORDER BY LENGTH(CITY) DESC, CITY ASC
  LIMIT 1;

SELECT CITY, LENGTH(CITY) AS LEN
  FROM STATION
  ORDER BY LENGTH(CITY) ASC, CITY ASC
  LIMIT 1;


-- UNION
(SELECT CITY, LENGTH(CITY) AS LEN
  FROM STATION
  ORDER BY LENGTH(CITY) DESC, CITY ASC
  LIMIT 1)

UNION

(SELECT CITY, LENGTH(CITY) AS LEN
  FROM STATION
  ORDER BY LENGTH(CITY) ASC, CITY ASC
  LIMIT 1);


--
-- Q6. Query the list of CITY names 'starting' with vowels (a, e, i, o, u) 
-- from STATION. Your result cannot contain duplicates.
-- 

-- REGEXP
SELECT DISTINCT CITY 
  FROM STATION 
  WHERE CITY REGEXP '^[aeiou]';

-- UPPER LEFT
SELECT DISTINCT CITY 
  FROM STATION 
  WHERE UPPER(LEFT(CITY,1)) IN ('A', 'E', 'I', 'O', 'U');


--
-- Q7. Query the list of CITY names 'ending' with vowels ( a, e, i, o, u)
-- from STATION. Your result cannot contain duplicates.
-- 

-- REGEXP
SELECT DISTINCT CITY 
  FROM STATION 
  WHERE CITY REGEXP '[aeiou]$';

-- LOWER RIGHT
SELECT DISTINCT CITY 
  FROM STATION 
  WHERE LOWER(RIGHT(CITY,1)) IN ('a', 'e', 'i', 'o', 'u');


--
-- Q8. Query the list of CITY names from STATION which have vowels (a, e, i, o, u)
-- as both their first and last characters. Your result cannot contain duplicates. 
--
SELECT DISTINCT CITY 
  FROM STATION 
  WHERE CITY REGEXP '^[aeiou].*[aeiou]$';


--
-- Q9. Query the list of CITY names from STATION that do not start with vowels.
-- Your result cannot contain duplicates.
-- 
SELECT DISTINCT CITY 
  FROM STATION 
  WHERE CITY NOT REGEXP '^[aeiou]';


--
-- Q. Get the sum of LAT_N and sum of LONG_W.  Round them to 2 decimal places.
--
SELECT ROUND(SUM(LAT_N), 2), ROUND(SUM(LONG_W), 2) FROM STATION;


--
-- Q. Query the sum of Northern Latitudes (LAT_N) from STATION having values
-- greater than 38.7880 and less than 137.2345.
-- Truncate your answer to 4 decimal places.
--
SELECT ROUND(SUM(LAT_N), 4)
    FROM STATION
    WHERE LAT_N > 38.7880 AND LAT_N < 137.2345;

-- Use BETWEEN, which is inclusive
SELECT ROUND(SUM(LAT_N), 4)
    FROM STATION
    WHERE LAT_N BETWEEN 38.7880 AND 137.2345;


--
-- Q. Query the Western Longitude (LONG_W) for the largest Northern Latitude
-- (LAT_N) in STATION that is less than 137.2345.
-- Round your answer to decimal places.
--
SELECT ROUND(LONG_W, 4)
    FROM STATION
    WHERE LAT_N < 137.2345
    ORDER BY LAT_N DESC
    LIMIT 1;


-- --------
--  MEDIUM
-- --------

--
-- Q. Consider P1(a,b) and P2(c,d) are two points of the rounding rectangle, s.t.
--     a = MIN(LAT_N)
--     b = MIN(LONG_W)
--     c = MAX(LAT_N)
--     d = MAX(LONG_W)

--   1. Query the Manhattan Distance between P1 and P2, and round it to 4 decimal places.
SELECT ROUND(MAX(LAT_N) - MIN(LAT_N) + MAX(LONG_W) - MIN(LONG_W), 4) AS DIST
    FROM STATION;

--   2. Query the Euclidean Distance between P1 and P2, and round it to 4 decimal places.
SELECT ROUND(SQRT(POWER(MAX(LAT_N)-MIN(LAT_N),2) + POWER(MAX(LONG_W)-MIN(LONG_W),2)), 4) AS DIST
    FROM STATION;


--
-- Q. Query the median of the Northern Latitudes (LAT_N) from STATION and
--    round your answer to 4 decimal places. 
--    https://www.hackerrank.com/challenges/weather-observation-station-20/problem

-- row_number(), MySQL 8.0 or later
WITH 
  R AS (
      SELECT 
        LAT_N,
        ROW_NUMBER() OVER(ORDER BY LAT_N ASC) AS r
      FROM STATION
  ),
  N AS (SELECT CEIL(MAX(r)/2) AS n1, CEIL(MAX(r+1)/2) AS n2 FROM R)
SELECT 
    ROUND(AVG(R.LAT_N), 4) AS median
  FROM R, N
  WHERE R.r IN (N.n1, N.n2);

-- Create my own row number; use COUNT to get the number of rows.
WITH 
  R AS (
    SELECT
        LAT_N, 
        (@row_number := @row_number + 1) AS r
    FROM STATION,  (SELECT @row_number := 0) as t
    ORDER BY LAT_N ASC
  ),
  N AS (SELECT CEIL(COUNT(*)/2) AS n1, CEIL((COUNT(*)+1)/2) AS n2 FROM STATION)
SELECT 
    ROUND(AVG(R.LAT_N), 4) AS median
  FROM R, N
  WHERE R.r IN (N.n1, N.n2);

-- Withotu WITH
SELECT 
    ROUND(AVG(LAT_N), 4) AS median
  FROM (
    SELECT 
        LAT_N,
        ROW_NUMBER() OVER(ORDER BY LAT_N ASC) AS r
      FROM STATION
  ) R,
  (
      SELECT 
          CEIL(COUNT(*)/2) AS n1, 
          CEIL((COUNT(*)+1)/2) AS n2
      FROM STATION
  ) N
  WHERE r in (n1, n2);


