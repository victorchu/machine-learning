/*
A U.S graduate school has students from Asia, Europe and America. The students'
location information are stored in table student as below.

Table: student
    +--------+-----------+
    | name   | continent |
    +--------+-----------+
    | Jack   | America   |
    | Pascal | Europe    |
    | Xi     | Asia      |
    | Jane   | America   |
    +--------+-----------+

Pivot the continent column in this table so that each name is sorted
alphabetically and displayed underneath its corresponding continent. The output
headers should be America, Asia and Europe respectively. It is guaranteed that
the student number from America is no less than either Asia or Europe.
 
For the sample input, the output is:
    +---------+------+--------+
    | America | Asia | Europe |
    +---------+------+--------+
    | Jack    | Xi   | Pascal |
    | Jane    |      |        |
    +---------+------+--------+

Follow-up: 
  - If it is unknown which continent has the most students, can you write a
    query to generate the student report?

Ref:
  - https://leetcode.com/problems/students-report-by-geography/ (Hard)

*/

-- DATA
DROP TABLE IF EXISTS student;
CREATE TABLE IF NOT EXISTS student (
    name VARCHAR(15),
    continent VARCHAR(15)
);

TRUNCATE TABLE student;
INSERT INTO student VALUES 
    ('Jack',   'America'),
    ('Pascal', 'Europe'),
    ('Xi',     'Asia'),
    ('Jane',   'America');


-- ANSWER
-- T:
--   +---------+------+--------+----+
--   | America | Asia | Europe | rn |
--   +---------+------+--------+----+
--   | Jack    | NULL | NULL   |  1 |
--   | Jane    | NULL | NULL   |  2 |
--   | NULL    | Xi   | NULL   |  1 |
--   | NULL    | NULL | Pascal |  1 |
--   +---------+------+--------+----+
-- Result:
--   +---------+------+--------+
--   | America | Asia | Europe |
--   +---------+------+--------+
--   | Jack    | Xi   | Pascal |
--   | Jane    | NULL | NULL   |
--   +---------+------+--------+
--
WITH T AS (
    SELECT 
        CASE WHEN continent='America' THEN name ELSE NULL END AS America,
        CASE WHEN continent='Asia' THEN name ELSE NULL END AS Asia,
        CASE WHEN continent='Europe' THEN name ELSE NULL END AS Europe,
        ROW_NUMBER() OVER(PARTITION BY continent ORDER BY name) rn
    FROM student
)
SELECT 
    MAX(America) AS America,
    MAX(Asia) AS Asia,
    MAX(Europe) AS Europe
FROM T
GROUP BY rn
ORDER BY rn;


-- ONLINE: Use two left joins,
-- assuming that America has the most number of students.
SELECT America, Asia, Europe
FROM (
    SELECT name AS America, 
        ROW_NUMBER() OVER(ORDER BY name) AS rn
    FROM student
    WHERE continent='America') a
LEFT JOIN (
    SELECT name AS Asia, row_number()over(order by name) AS rn
    FROM student
    WHERE continent='Asia') b ON a.rn=b.rn
LEFT JOIN (
    SELECT name AS Europe, row_number()over(order by name) AS rn
    FROM student
    WHERE continent='Europe') c ON a.rn=c.rn
ORDER BY a.rn;


-- Combined. No assumption on which continent has the most students.
WITH T AS (
    SELECT name, continent,
        ROW_NUMBER() OVER(PARTITION BY continent ORDER BY name) rn
    FROM student
),
N AS (SELECT DISTINCT rn FROM T),
A AS (SELECT rn, name AS America FROM T WHERE continent='America'),
B AS (SELECT rn, name AS Asia FROM T WHERE continent='Asia'),
C AS (SELECT rn, name AS Europe FROM T WHERE continent='Europe')
SELECT America, Asia, Europe 
    FROM N
    LEFT JOIN A ON N.rn=A.rn
    LEFT JOIN B ON N.rn=B.rn
    LEFT JOIN C ON N.rn=C.rn
    ORDER BY A.rn;


