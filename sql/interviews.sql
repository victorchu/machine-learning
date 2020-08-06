/*
Interviews

Samantha interviews many candidates from different colleges using coding
challenges and contests. Write a query to print 

    contest_id, hacker_id, name,
    sum(total_submissions),
    sum(total_accepted_submissions),
    sum(total_views),
    sum(total_unique_views)

for each contest sorted by contest_id. Exclude the contest
from the result if all four sums are 0.

Note: 
  - A specific contest can be used to screen candidates at more than one
    college, but each college only holds 1 screening contest.

Data:
  Contets: contest_id | hacker_id | name
  Colleges: college_id | contest_id
  Challenges: challenge_id | college_id
  View_Stats: challenge_id | total_views | total_unique_views
  Submission_Stats: challenge_id | total_submissions | total_accepted_submissions

Relations:
  Contests -> Colleges -> Challenges -> View_Stats 
                                     -> Submission_Stats

Ref:
  - https://www.hackerrank.com/challenges/interviews/problem (Hard)

*/

-- DATA
DROP TABLE IF EXISTS Contests;
CREATE TABLE IF NOT EXISTS Contests (contest_id INT, hacker_id INT, name VARCHAR(20) );
INSERT INTO Contests VALUES (66406, 17973, "Rose"), (66556, 79153, "Angela"), (94828, 80275, "Frank");

DROP TABLE IF EXISTS Colleges;
CREATE TABLE IF NOT EXISTS Colleges( college_id INT, contest_id INT );
INSERT INTO Colleges VALUES (11219, 66406), (32473, 66556), (56685, 94828);

DROP TABLE IF EXISTS Challenges;
CREATE TABLE IF NOT EXISTS Challenges (challenge_id INT, college_id INT);
INSERT INTO Challenges VALUES (18765, 11219), (47127, 11219), (60292, 32473), (72974, 56685);

DROP TABLE IF EXISTS View_Stats;
CREATE TABLE View_Stats (challenge_id INT, total_views INT, total_unique_views INT);
INSERT INTO View_Stats VALUES (47127, 26, 19), (47127, 15, 14), (18765, 43, 10), (18765, 72, 13), (75516, 35, 17), (60292, 11, 10), (72974, 41, 15), (75516, 75, 11);

DROP TABLE IF EXISTS Submission_Stats;
CREATE TABLE Submission_Stats (challenge_id INT, total_submissions INT, total_accepted_submissions INT);
INSERT INTO Submission_Stats VALUES (75516, 34, 12), (47127, 27, 10), (47127, 56, 18), (75516, 74, 12), (75516, 83, 8), (72974, 68, 24), (72974, 82, 14), (47127, 28, 11);


-- ANSWER 1 - WITH
-- +------------+-----------+--------+-------------------+----------------------------+-------------+--------------------+
-- | contest_id | hacker_id | name   | total_submissions | total_accepted_submissions | total_views | total_unique_views |
-- +------------+-----------+--------+-------------------+----------------------------+-------------+--------------------+
-- |      66406 |     17973 | Rose   |               111 |                         39 |         156 |                 56 |
-- |      66556 |     79153 | Angela |                 0 |                          0 |          11 |                 10 |
-- |      94828 |     80275 | Frank  |               150 |                         38 |          41 |                 15 |
-- +------------+-----------+--------+-------------------+----------------------------+-------------+--------------------+
WITH T AS (
    SELECT 
        a.contest_id, a.hacker_id, a.name, c.challenge_id
    FROM Contests a, Colleges b, Challenges c
    WHERE a.contest_id = b.contest_id 
        AND b.college_id = c.college_id
),
U AS (
    SELECT contest_id, hacker_id, name,
        COALESCE(SUM(v.total_views), 0) AS total_views,
        COALESCE(SUM(v.total_unique_views), 0) AS total_unique_views
    FROM T
    LEFT JOIN View_Stats v ON T.challenge_id = v.challenge_id
    GROUP BY contest_id, hacker_id, name
),
V AS (
    SELECT contest_id, hacker_id, name,
        COALESCE(SUM(s.total_submissions), 0)  AS total_submissions,
        COALESCE(SUM(s.total_accepted_submissions), 0) AS total_accepted_submissions
    FROM T
    LEFT JOIN Submission_Stats s ON T.challenge_id = s.challenge_id
    GROUP BY contest_id, hacker_id, name
)
SELECT 
    U.contest_id, U.hacker_id, U.name,
        V.total_submissions,
        V.total_accepted_submissions,
        U.total_views,
        U.total_unique_views
    FROM U, V
    WHERE U.contest_id=V.contest_id 
        AND U.hacker_id=V.hacker_id 
        AND U.name=V.name 
        AND (V.total_submissions + V.total_accepted_submissions + U.total_views + U.total_unique_views ) > 0
    ORDER BY U.contest_id;


-- ANSWER 2. Reduced WITH
WITH T AS (
    SELECT a.contest_id, a.hacker_id, a.name, c.challenge_id
    FROM Contests a
    JOIN Colleges b ON a.contest_id = b.contest_id 
    JOIN Challenges c ON b.college_id = c.college_id
)
SELECT 
    U.contest_id, U.hacker_id, U.name,
        V.total_submissions,
        V.total_accepted_submissions,
        U.total_views,
        U.total_unique_views
    FROM (
        SELECT contest_id, hacker_id, name,
            COALESCE(SUM(v.total_views), 0) AS total_views,
            COALESCE(SUM(v.total_unique_views), 0) AS total_unique_views
        FROM T
        LEFT JOIN View_Stats v ON T.challenge_id = v.challenge_id
        GROUP BY contest_id, hacker_id, name
    ) U
    JOIN (
        SELECT contest_id, hacker_id, name,
            COALESCE(SUM(s.total_submissions), 0)  AS total_submissions,
            COALESCE(SUM(s.total_accepted_submissions), 0) AS total_accepted_submissions
        FROM T
        LEFT JOIN Submission_Stats s ON T.challenge_id = s.challenge_id
        GROUP BY contest_id, hacker_id, name
    ) V
    ON U.contest_id=V.contest_id  AND U.hacker_id=V.hacker_id AND U.name=V.name 
    WHERE V.total_submissions > 0 OR V.total_accepted_submissions > 0 OR
        U.total_views > 0 OR U.total_unique_views > 0
    ORDER BY U.contest_id;

-- ANSER 3. Accepted by hackerrank.
SELECT 
    U.contest_id, U.hacker_id, U.name,
        V.total_submissions,
        V.total_accepted_submissions,
        U.total_views,
        U.total_unique_views
    FROM (
        SELECT a.contest_id, a.hacker_id, a.name,
            COALESCE(SUM(v.total_views), 0) AS total_views,
            COALESCE(SUM(v.total_unique_views), 0) AS total_unique_views
        FROM Contests a
        JOIN Colleges b ON a.contest_id = b.contest_id 
        JOIN Challenges c ON b.college_id = c.college_id
        LEFT JOIN View_Stats v ON c.challenge_id = v.challenge_id
        GROUP BY contest_id, hacker_id, name
    ) U
    JOIN (
        SELECT a.contest_id, a.hacker_id, a.name,
            COALESCE(SUM(s.total_submissions), 0)  AS total_submissions,
            COALESCE(SUM(s.total_accepted_submissions), 0) AS total_accepted_submissions
        FROM Contests a
        JOIN Colleges b ON a.contest_id = b.contest_id 
        JOIN Challenges c ON b.college_id = c.college_id
        LEFT JOIN Submission_Stats s ON c.challenge_id = s.challenge_id
        GROUP BY contest_id, hacker_id, name
    ) V
    ON U.contest_id=V.contest_id  AND U.hacker_id=V.hacker_id AND U.name=V.name 
    WHERE V.total_submissions > 0 OR V.total_accepted_submissions > 0 OR
        U.total_views > 0 OR U.total_unique_views > 0
    ORDER BY U.contest_id;


-- X. Simple yet doesn't work, because each challenge_id may
--    have multile entries in View_Stats and Submission_Stats.
SELECT a.contest_id, a.hacker_id, a.name,
        COALESCE(SUM(s.total_submissions), 0) AS total_submissions,
        COALESCE(SUM(s.total_accepted_submissions), 0) AS total_accepted_submissions,
        COALESCE(SUM(v.total_views), 0) AS total_views,
        COALESCE(SUM(v.total_unique_views), 0) AS total_unique_views
    FROM Contests a
    JOIN Colleges b ON a.contest_id = b.contest_id 
    JOIN Challenges c ON b.college_id = c.college_id
    LEFT JOIN View_Stats v ON c.challenge_id = v.challenge_id
    LEFT JOIN Submission_Stats s ON c.challenge_id = s.challenge_id
    GROUP BY contest_id, hacker_id, name
    HAVING (total_submissions + total_accepted_submissions + total_views + total_unique_views ) > 0
    ORDER BY contest_id;


