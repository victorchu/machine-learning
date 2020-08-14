/*
Julia conducted a 15 days of learning SQL contest. The start date of the contest
was March 01, 2016 and the end date was March 15, 2016.

Write a query to print total number of unique hackers who made at least 1
submission each day (starting on the first day of the contest), and find the
hacker_id and name of the hacker who made maximum number of submissions each
day. If more than one such hacker has a maximum number of submissions, print the
lowest hacker_id. The query should print this information for each day of the
contest, sorted by the date.

    date, num_hackers, hacker_id, name

DATA:

Hackers: hacker_id | name
Submissions: submission_date | submission_id | hacker_id | score

Sample Output

    2016-03-01 4 20703 Angela
    2016-03-02 2 79722 Michael
    2016-03-03 2 20703 Angela
    2016-03-04 2 20703 Angela
    2016-03-05 1 36396 Frank
    2016-03-06 1 20703 Angela

Ref:
  - https://www.hackerrank.com/challenges/15-days-of-learning-sql/problem (Hard)

*/

-- DATA
DROP TABLE IF EXISTS Hackers;
CREATE TABLE IF NOT EXISTS Hackers (hacker_id INT, name VARCHAR(16));
INSERT INTO Hackers VALUES
    (15758, 'Rose'), (20703, 'Angela'), (36396, 'Frank'), (38289, 'Patrick'),
    (44065, 'Lisa'), (53473, 'Kimberly'), (62529, 'Bonnie'), (79722, 'Michael');

DROP TABLE IF EXISTS Submissions;
CREATE TABLE IF NOT EXISTS Submissions (
    submission_date DATE, submission_id INT, hacker_id INT, score INT);
INSERT INTO Submissions VALUES 
    ('2016-03-01',  8494, 20703, 0),
    ('2016-03-01', 23965, 53473, 60),
    ('2016-03-01', 23965, 79722, 60),
    ('2016-03-01', 30173, 36396, 70),
    ('2016-03-02', 34928, 20703, 0),
    ('2016-03-02', 38740, 15758, 60),
    ('2016-03-02', 42769, 79722, 60),
    ('2016-03-02', 44364, 79722, 60),
    ('2016-03-03', 45440, 20703, 0),
    ('2016-03-03', 49050, 36396, 70),
    ('2016-03-03', 50273, 79722, 5),
    ('2016-03-04', 50344, 20703, 0),
    ('2016-03-04', 51360, 44065, 90),
    ('2016-03-04', 54404, 53473, 65),
    ('2016-03-04', 61533, 79722, 45),
    ('2016-03-05', 72852, 20703, 0),
    ('2016-03-05', 74546, 38289, 0),
    ('2016-03-05', 76487, 62529, 0),
    ('2016-03-05', 82439, 36396, 10),
    ('2016-03-05',  9006, 36396, 40),
    ('2016-03-06', 90404, 20703, 0); 

-- First, get the hackers without gaps using sub-query.
--   +-----------------+-------------+
--   | submission_date | num_hackers |
--   +-----------------+-------------+
--   | 2016-03-01      |           4 |
--   | 2016-03-02      |           2 |
--   | 2016-03-03      |           2 |
--   | 2016-03-04      |           2 |
--   | 2016-03-05      |           1 |
--   | 2016-03-06      |           1 |
--   +-----------------+-------------+
--
SELECT submission_date, COUNT(DISTINCT hacker_id) AS num_hackers
    FROM Submissions s1
    WHERE DATEDIFF(s1.submission_date, '2016-03-01') = (
        SELECT COUNT(DISTINCT s2.submission_date)
            FROM Submissions s2 
            WHERE s2.hacker_id=s1.hacker_id AND s2.submission_date<s1.submission_date
    )
    GROUP BY submission_date;
    
-- Second, get number of submissions per day and ranks
--   +-----------------+-----------+-----+-----+
--   | submission_date | hacker_id | num | rnk |
--   +-----------------+-----------+-----+-----+
--   | 2016-03-01      |     20703 |   1 |   1 |
--   | 2016-03-01      |     36396 |   1 |   2 |
--   | 2016-03-01      |     53473 |   1 |   3 |
--   | 2016-03-01      |     79722 |   1 |   4 |
--   | 2016-03-02      |     79722 |   2 |   1 |
--   | 2016-03-02      |     15758 |   1 |   2 |
--   | 2016-03-02      |     20703 |   1 |   3 |
--   | 2016-03-03      |     20703 |   1 |   1 |
--   | 2016-03-03      |     36396 |   1 |   2 |
--   | 2016-03-03      |     79722 |   1 |   3 |
--   | 2016-03-04      |     20703 |   1 |   1 |
--   | 2016-03-04      |     44065 |   1 |   2 |
--   | 2016-03-04      |     53473 |   1 |   3 |
--   | 2016-03-04      |     79722 |   1 |   4 |
--   | 2016-03-05      |     36396 |   2 |   1 |
--   | 2016-03-05      |     20703 |   1 |   2 |
--   | 2016-03-05      |     38289 |   1 |   3 |
--   | 2016-03-05      |     62529 |   1 |   4 |
--   | 2016-03-06      |     20703 |   1 |   1 |
--   +-----------------+-----------+-----+-----+
--
-- Daily Winners
--   +-----------------+-----------+
--   | submission_date | hacker_id |
--   +-----------------+-----------+
--   | 2016-03-01      |     20703 |
--   | 2016-03-02      |     79722 |
--   | 2016-03-03      |     20703 |
--   | 2016-03-04      |     20703 |
--   | 2016-03-05      |     36396 |
--   | 2016-03-06      |     20703 |
--   +-----------------+-----------+
--
WITH B AS (
    SELECT submission_date, hacker_id, COUNT(*) AS num
    FROM Submissions
    GROUP BY submission_date, hacker_id
    ORDER BY submission_date, num DESC, hacker_id ASC
)
SELECT submission_date, hacker_id 
FROM (
    SELECT submission_date, hacker_id,
        num,
        RANK() OVER(PARTITION BY submission_date ORDER BY num DESC, hacker_id ASC) AS rnk
    FROM B
) X
WHERE rnk=1;


-- Third, put all together
--   +-----------------+-------------+-----------+---------+
--   | submission_date | num_hackers | hacker_id | name    |
--   +-----------------+-------------+-----------+---------+
--   | 2016-03-01      |           4 |     20703 | Angela  |
--   | 2016-03-02      |           2 |     79722 | Michael |
--   | 2016-03-03      |           2 |     20703 | Angela  |
--   | 2016-03-04      |           2 |     20703 | Angela  |
--   | 2016-03-05      |           1 |     36396 | Frank   |
--   | 2016-03-06      |           1 |     20703 | Angela  |
--   +-----------------+-------------+-----------+---------+

-- Use WITH ... doesn't work with hackerrank. Yet, work locally.
WITH A AS (
    SELECT submission_date, COUNT(DISTINCT hacker_id) AS num_hackers
        FROM Submissions s1
        WHERE DATEDIFF(s1.submission_date, '2016-03-01') = (
            SELECT COUNT(DISTINCT s2.submission_date)
                FROM Submissions s2 
                WHERE s2.hacker_id=s1.hacker_id AND s2.submission_date<s1.submission_date
        )
        GROUP BY submission_date
),
B AS (
    SELECT submission_date, hacker_id, COUNT(*) AS n
        FROM Submissions
        GROUP BY submission_date, hacker_id
), 
C AS (
    SELECT submission_date, hacker_id 
    FROM (
        SELECT submission_date, hacker_id,
            RANK() OVER(
                PARTITION BY submission_date
                ORDER BY n DESC, hacker_id ASC) AS rnk
        FROM B
    ) T
    WHERE rnk=1
)
SELECT 
        C.submission_date, A.num_hackers, H.hacker_id, H.name
    FROM C
    LEFT JOIN A ON C.submission_date = A.submission_date
    JOIN Hackers H ON C.hacker_id = H.hacker_id
    ORDER BY C.submission_date ASC;


-- Without WITH ... doesn't work with hackerrank.
SELECT 
        C.submission_date, A.num_hackers, H.hacker_id, H.name
    FROM (
        SELECT submission_date, hacker_id 
        FROM (
            SELECT submission_date, hacker_id,
                RANK() OVER(
                    PARTITION BY submission_date
                    ORDER BY n DESC, hacker_id ASC) AS rnk
            FROM (
                SELECT submission_date, hacker_id, COUNT(*) AS n
                    FROM Submissions
                    GROUP BY submission_date, hacker_id
            ) B
        ) T
        WHERE rnk=1
    ) C
    LEFT JOIN (
        SELECT submission_date, COUNT(DISTINCT hacker_id) AS num_hackers
            FROM Submissions s1
            WHERE DATEDIFF(s1.submission_date, '2016-03-01') = (
                SELECT COUNT(DISTINCT s2.submission_date)
                    FROM Submissions s2 
                    WHERE s2.hacker_id=s1.hacker_id AND s2.submission_date<s1.submission_date
            )
            GROUP BY submission_date
        
    ) A ON C.submission_date = A.submission_date
    JOIN Hackers H ON C.hacker_id = H.hacker_id
    ORDER BY C.submission_date ASC;


-- Try to avoid PARTIONTION BY ... doesn't work with hackerrank.
SELECT C.submission_date, A.num_hackers, H.hacker_id, H.name
    FROM (
        WITH B AS (
            SELECT submission_date, hacker_id, COUNT(*) AS n
                FROM Submissions
                GROUP BY submission_date, hacker_id
        )
        SELECT submission_date, hacker_id
        FROM B b1
        WHERE 
            n = (SELECT MAX(n) FROM B b2 WHERE b2.submission_date = b1.submission_date) AND
            hacker_id = (SELECT MIN(hacker_id) FROM B b3 
                WHERE b3.submission_date = b1.submission_date AND b3.n = b1.n)
    ) C
    LEFT JOIN (
        SELECT submission_date, COUNT(DISTINCT hacker_id) AS num_hackers
            FROM Submissions s1
            WHERE DATEDIFF(s1.submission_date, '2016-03-01') = (
                SELECT COUNT(DISTINCT s2.submission_date)
                    FROM Submissions s2 
                    WHERE s2.hacker_id=s1.hacker_id AND s2.submission_date<s1.submission_date
            )
            GROUP BY submission_date
    ) A ON C.submission_date = A.submission_date
    JOIN Hackers H ON C.hacker_id = H.hacker_id
    ORDER BY C.submission_date ASC;


-- ------------------
--  ONLINE SOLUTIONS
-- ------------------

-- This one works with hackerrank!
SELECT submission_date,
    ( 
        SELECT COUNT(distinct hacker_id)  
            FROM Submissions s2  
            WHERE s2.submission_date = s1.submission_date AND (
                SELECT COUNT(DISTINCT s3.submission_date) 
                     FROM Submissions s3 
                     WHERE s3.hacker_id = s2.hacker_id AND  
                         s3.submission_date < s1.submission_date
             ) = DATEDIFF(s1.submission_date , '2016-03-01')
    ) AS num_hackers_without_gaps,
    (
         SELECT hacker_id  
             FROM Submissions s2 
             WHERE s2.submission_date = s1.submission_date 
             GROUP BY hacker_id 
             ORDER BY COUNT(submission_id) DESC, hacker_id ASC
             LIMIT 1
    ) AS winner_hacker_id,
    (
        SELECT h.name 
            FROM Hackers h
            WHERE h.hacker_id = winner_hacker_id
    ) AS winner_name
    FROM (
        SELECT DISTINCT submission_date FROM Submissions
    ) s1;


