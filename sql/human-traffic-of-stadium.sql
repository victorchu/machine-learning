/*
X city built a new stadium, each day many people visit it and the stats are
saved as these columns: id, visit_date, people

Please write a query to display the records which have 3 or more consecutive
rows and the amount of people more than 100 (inclusive).  For example, the table
stadium:

+------+------------+--------+
| id   | visit_date | people |
+------+------------+--------+
|    1 | 2017-01-01 |     10 |
|    2 | 2017-01-02 |    109 |
|    3 | 2017-01-03 |    150 |
|    4 | 2017-01-04 |    100 |
|    5 | 2017-01-05 |     99 |
|    6 | 2017-01-06 |    145 |
|    7 | 2017-01-07 |   1455 |
|    8 | 2017-01-08 |    199 |
|    9 | 2017-01-09 |    188 |
+------+------------+--------+

For the sample data above, the output is:

+------+------------+--------+
| id   | visit_date | people |
+------+------------+--------+
|    2 | 2017-01-02 |    109 |
|    3 | 2017-01-03 |    150 |
|    4 | 2017-01-04 |    100 |
|    6 | 2017-01-06 |    145 |
|    7 | 2017-01-07 |   1455 |
|    8 | 2017-01-08 |    199 |
|    9 | 2017-01-09 |    188 |
+------+------------+--------+

Note:
  - Each day only have one row record, and the dates are increasing with id increasing.

Ref:
  - https://leetcode.com/problems/human-traffic-of-stadium/ (Hard)

*/

-- DATA
DROP TABLE IF EXISTS stadium;
CREATE TABLE IF NOT EXISTS stadium (
    id INT,
    visit_date DATE,
    people INT
);

TRUNCATE TABLE stadium;
INSERT INTO stadium VALUES 
    (1, '2017-01-01', 10),
    (2, '2017-01-02', 109),
    (3, '2017-01-03', 150),
    (4, '2017-01-04', 100),
    (5, '2017-01-05', 99),
    (6, '2017-01-06', 145),
    (7, '2017-01-07', 1455),
    (8, '2017-01-08', 199),
    (9, '2017-01-09', 188);


-- Two passes: LEAD and variable
WITH A AS (
    SELECT id, visit_date, people,
        CASE WHEN
            people >= 100 AND
            COALESCE(LEAD(people, 1) OVER (ORDER BY id ASC), 0) >= 100 AND
            COALESCE(LEAD(people, 2) OVER (ORDER BY id ASC), 0) >= 100
            THEN True ELSE FALSE END AS selected
    FROM stadium
),
B AS (
    SELECT id, visit_date, people,
        CASE WHEN people >= 100 AND @s=True 
            THEN @s:=True 
            ELSE @s:=selected END AS selected
    FROM A, (SELECT @s:=False) X
    ORDER BY id ASC
)
SELECT id, visit_date, people
FROM B WHERE selected=True;


-- Two passes: Self-join and variable
WITH A AS (
    SELECT s1.*,
        CASE WHEN (s1.people >= 100 AND s2.people >= 100 AND s3.people >= 100) THEN True
            ELSE FALSE END AS selected
    FROM stadium s1
    LEFT JOIN stadium s2 ON s2.id = s1.id + 1
    LEFT JOIN stadium s3 ON s3.id = s1.id + 2
),
B AS (
    SELECT id, visit_date, people,
        CASE WHEN people >= 100 AND @s=True THEN @s:=True 
            ELSE @s:=selected END AS selected
    FROM A, (SELECT @s:=False) X
    ORDER BY id ASC
)
SELECT id, visit_date, people
FROM B WHERE selected=True;


-- LEFT self-join on 5 tables
SELECT s.*
    FROM stadium s
    LEFT JOIN stadium prev2 ON prev2.id = s.id - 2
    LEFT JOIN stadium prev1 ON prev1.id = s.id - 1
    LEFT JOIN stadium next1 ON next1.id = s.id + 1
    LEFT JOIN stadium next2 ON next2.id = s.id + 2
    WHERE s.people >= 100 AND (
        (prev2.people >= 100 AND prev1.people >= 100) OR
        (prev1.people >= 100 AND next1.people >= 100) OR
        (next1.people >= 100 AND next2.people >= 100))
    ORDER BY s.id;


-- Online: cross self-join on 3 tables
SELECT DISTINCT s1.*
    FROM stadium s1, stadium s2, stadium s3
    WHERE ((s1.id = s2.id - 1 AND s1.id = s3.id - 2)
        OR (s3.id = s1.id - 1 AND s3.id = s2.id - 2)
        OR (s3.id = s2.id - 1 AND s3.id = s1.id - 2))
        AND s1.people >= 100
        AND s2.people >= 100
        AND s3.people >= 100
    ORDER BY s1.id;


