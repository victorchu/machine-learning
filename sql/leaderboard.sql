/*
Multiple questions related to leaderboard.

Shared Table Schemas:
    Hackers, Difficulty, Challenges, Submissions

The data contents may vary from question to question.

REF: 
  Q1. https://www.hackerrank.com/challenges/full-score/problem (Medium)
  Q2. https://www.hackerrank.com/challenges/challenges/problem (Medium)
  Q3. https://www.hackerrank.com/challenges/contest-leaderboard/problem (Medium)

*/

-- -------------
--  Common Data
-- --------------
DROP TABLE IF EXISTS Hackers;
CREATE TABLE Hackers
(
    hacker_id  INT,
    name   VARCHAR(17)
);

DROP TABLE IF EXISTS Difficulty;
CREATE TABLE Difficulty
(
    difficulty_level INT,
    score INT
);

DROP TABLE IF EXISTS Challenges;
CREATE TABLE Challenges
(
    challenge_id INT,
    hacker_id  INT,
    difficulty_level INT DEFAULT 1
);

DROP TABLE IF EXISTS Submissions;
CREATE TABLE Submissions
(
    submission_id INT,
    hacker_id  INT,
    challenge_id INT,
    score INT
);


/* 
Q1.

Find top competitors based on number of full scores.
*/

-- Q1 Data
TRUNCATE TABLE Hackers;
INSERT INTO Hackers VALUES
   (5580, 'Rose'),
   (8439, 'Angela'),
   (27205, 'Frank'),
   (55243, 'Patrick'),
   (52348, 'Lisa'),
   (77726, 'Bonnie'),
   (83082, 'Michael'),
   (86870, 'Todd'),
   (90411, 'Joe');

TRUNCATE TABLE Difficulty;
INSERT INTO Difficulty VALUES
    ( 1,  20),
    ( 2,  30),
    ( 3,  40),
    ( 4,  60),
    ( 5,  80),
    ( 6, 100),
    ( 7, 120);

TRUNCATE TABLE Challenges;
INSERT INTO Challenges VALUES
    ( 4810, 77726, 4),
    (21089, 27205, 1),
    (36566,  5580, 7),
    (66730, 52243, 6),
    (71055, 52243, 2);

TRUNCATE TABLE Submissions;
INSERT INTO Submissions VALUES
    ( 68628, 77726, 71055, 30),
    ( 94613, 86870, 71055, 30),
    ( 93058, 86870, 36566, 30),
    ( 97397, 90411, 66730, 100),
    ( 97431, 90411, 71055, 30);

-- ANSWER
SELECT 
    S.hacker_id, H.name
FROM Submissions S, Challenges C, Difficulty D, Hackers H
WHERE
    S.challenge_id = C.challenge_id AND
    C.difficulty_level = D.difficulty_level AND
    S.hacker_id = H.hacker_id AND
    S.score = D.score
GROUP BY S.hacker_id, H.name
HAVING COUNT(S.hacker_id) > 1
ORDER BY COUNT(S.hacker_id) DESC, S.hacker_id ASC;


/*
Q2.

Julia asked her students to create some coding challenges. Write a query to
print the hacker_id, name, and the total number of challenges created by each
student. Sort your results by the total number of challenges in descending
order. If more than one student created the same number of challenges, then sort
the result by hacker_id. If more than one student created the same number of
challenges and the count is less than the maximum number of challenges created,
then exclude those students from the result.

Tables: Hackers, Challenges

Output:
  - hacker_id, name, num_challenges
  - ORDER BY: num_challenges DESC, hacker_id ASC
  - Exclude on duplicated num_challanges, unless the best.

Sample Output:
    +-----------+---------+----+
    | hacker_id | name    | nc |
    +-----------+---------+----+
    |     21283 | Angela  |  6 |
    |     88255 | Patrick |  5 |
    |     96196 | Lisa    |  1 |
    +-----------+---------+----+
*/

-- DATA
TRUNCATE TABLE Hackers;
INSERT INTO Hackers VALUES
    (5077, 'Rose'),
    (21283, 'Angela'),
    (62743, 'Frank'),
    (88255, 'Patrick'),
    (96196, 'Lisa');

TRUNCATE TABLE Challenges;
INSERT INTO Challenges (challenge_id, hacker_id) VALUES
    (1, 5077),
    (2, 21283),
    (3, 88255),
    (4, 5077),
    (5, 21283),
    (6, 21283),
    (7, 62743),
    (8, 62743),
    (9, 88255),
    (10, 21283),
    (11, 5077),
    (12, 21283),
    (13, 96196),
    (14, 88255),
    (15, 62743),
    (16, 62743),
    (17, 21283),
    (18, 88255),
    (19, 88255),
    (20, 5077),
    (21, 88255);

-- Use WITH to create temp tables
-- Note: hackerrank doesn't work with WITH.
WITH T AS (
    SELECT h.hacker_id, h.name, COUNT(*) AS nc
    FROM Hackers h, Challenges c
    WHERE h.hacker_id = c.hacker_id
    GROUP BY h.hacker_id, h.name
), M AS (
    SELECT nc, COUNT(*) AS num_hackers
    FROM T
    GROUP BY nc
)
SELECT hacker_id, name, T.nc
FROM T
LEFT JOIN M ON T.nc = M.nc 
WHERE 
    T.nc = (SELECT MAX(nc) FROM T) OR
    M.num_hackers = 1
ORDER BY T.nc DESC, hacker_id ASC;


-- Without WITH
SELECT c.hacker_id, h.name, COUNT(c.hacker_id) as nc
    FROM Hackers h
    JOIN Challenges c ON c.hacker_id = h.hacker_id
    GROUP by c.hacker_id, h.name
    HAVING
        nc = (
            SELECT MAX(t.cnt)
            FROM (
                SELECT COUNT(hacker_id) as cnt
                FROM Challenges
                GROUP BY hacker_id) t
            )
        OR nc IN (
            SELECT t.cnt
            FROM (
                SELECT COUNT(*) as cnt
                FROM Challenges
                GROUP by hacker_id) t
             GROUP BY t.cnt
             HAVING count(t.cnt) = 1)
    ORDER BY nc DESC, c.hacker_id;


/*
Q3.
You did such a great job helping Julia with her last coding contest challenge
that she wants you to work on this one, too!

The total score of a hacker is the sum of their "maximum" scores for all of the
challenges. Write a query to print the hacker_id, name, and total score of the
hackers ordered by the descending score. If more than one hacker achieved the
same total score, then sort the result by ascending hacker_id. Exclude all
hackers with a total score of 0 from your result.


TABLES: Hackers, Submissions (same schema as in Q1)

Note:
  - A hacker may submit a challenge for more than once.
    Only consider the maximum score.  


*/

-- Data - reuse Q1

-- Note that Having needs to be before ORDER BY.
SELECT hacker_id, name, SUM(max_score) AS total
    FROM (
        SELECT h.hacker_id, h.name, s.challenge_id, MAX(s.score) AS max_score
            FROM Hackers h, Submissions s
            WHERE h.hacker_id = s.hacker_id
            GROUP BY h.hacker_id, h.name, s.challenge_id
    ) A
    GROUP BY hacker_id, name
    HAVING total > 0
    ORDER BY total DESC, hacker_id ASC;


