/*

DATA SET:
  OCCUPATIONS TABLE:
    Name: String 
    Occupation: String - Doctor, Professor, Singer, Actor.


QUESTION 1 - PADS

Generate the following two result sets:

 1. Query an alphabetically ordered list of all names in OCCUPATIONS,
    immediately followed by the first letter of each profession as a parenthetical
    (i.e.: enclosed in parentheses).  For example: 

      AnActorName(A),
      ADoctorName(D),
      AProfessorName(P),
      and ASingerName(S).

 2. Query the number of ocurrences of each occupation in OCCUPATIONS. Sort the
    occurrences in ascending order, and output them in the following format:

      There are a total of [occupation_count] [occupation]s.

    where [occupation_count] is the number of occurrences of an occupation in
    OCCUPATIONS and [occupation] is the lowercase occupation name. If more than
    one Occupation has the same [occupation_count], they should be ordered
    alphabetically.  For example,

      There are a total of 2 doctors.

Note: 
  - There will be at least two entries in the table for each type of occupation.

Sample Output:
    Ashely(P)
    Christeen(P)
    Jane(A)
    Jenny(D)
    Julia(A)
    Ketty(P)
    Maria(A)
    Meera(S)
    Priya(S)
    Samantha(D)
    There are a total of 2 doctors.
    There are a total of 2 singers.
    There are a total of 3 actors.
    There are a total of 3 professors.

Explanation:
    The results of the first query are formatted to the problem description's
    specifications.  The results of the second query are ascendingly ordered first
    by number of names corresponding to each profession (2 <= 2 <= 3 <= 3),
    and then alphabetically by profession (doctor <= singer, and actor <= professor).


QUESTION 2 - PIVOT:

Pivot the Occupation column in OCCUPATIONS so that each Name is sorted
alphabetically and displayed underneath its corresponding Occupation. The output
column headers should be:

    Doctor, Professor, Singer, Actor

Note: 
  - Print NULL when there are no more names corresponding to an occupation.

Sample Output:
    
    Doctor      Professor   Singer     Actor
    Jenny       Ashley      Meera       Jane
    Samantha    Christeen   Priya       Julia
    NULL        Ketty       NULL        Maria


REFERENCE:
  - https://www.hackerrank.com/challenges/the-pads/problem (Medium)
  - https://www.hackerrank.com/challenges/occupations/problem (Medium)

*/

-- -------
--  Data
-- -------
DROP TABLE IF EXISTS OCCUPATIONS;
CREATE TABLE OCCUPATIONS
(
    Name VARCHAR(20),
    Occupation VARCHAR(15)
);

TRUNCATE TABLE OCCUPATIONS;
INSERT INTO OCCUPATIONS VALUES
    ('Samantha', 'Doctor'),
    ('Julia', 'Actor'),
    ('Maria', 'Actor'),
    ('Meera', 'Singer'),
    ('Ashely', 'Professor'),
    ('Ketty', 'Professor'),
    ('Christeen', 'Professor'),
    ('Jane', 'Actor'),
    ('Jenny', 'Doctor'),
    ('Priya', 'Singer')
    ;


--
-- Q. The PADS
--

-- Two Queries
SELECT CONCAT(Name, '(', LEFT(Occupation,1), ')') as name_p
    FROM OCCUPATIONS
    ORDER BY name_p ASC;

SELECT CONCAT('There are a total of ', COUNT(*), ' ', LOWER(Occupation), 's.') AS summary
    FROM OCCUPATIONS
    GROUP BY Occupation
    ORDER BY COUNT(*) ASC, Occupation ASC;

--
-- Q. PIVOT
--

-- The nested query auguments the table into four occupulation
-- columns plus a row number.
--   +-------+----------+-----------+--------+------------+
--   | Actor | Doctor   | Professor | Singer | row_number |
--   +-------+----------+-----------+--------+------------+
--   | Jane  | NULL     | NULL      | NULL   |          1 |
--   | Julia | NULL     | NULL      | NULL   |          2 |
--   | Maria | NULL     | NULL      | NULL   |          3 |
--   | NULL  | Jenny    | NULL      | NULL   |          1 |
--   | NULL  | Samantha | NULL      | NULL   |          2 |
--   | NULL  | NULL     | Ashely    | NULL   |          1 |
--   | NULL  | NULL     | Christeen | NULL   |          2 |
--   | NULL  | NULL     | Ketty     | NULL   |          3 |
--   | NULL  | NULL     | NULL      | Meera  |          1 |
--   | NULL  | NULL     | NULL      | Priya  |          2 |
--   +-------+----------+-----------+--------+------------+
-- 
-- Then, the outer look group by row_number and then select a
-- non-NULL value.  We can use either MIN or MAX here.
--   +----------+-----------+--------+-------+
--   | Doctor   | Professor | Singer | Actor |
--   +----------+-----------+--------+-------+
--   | Jenny    | Ashely    | Meera  | Jane  |
--   | Samantha | Christeen | Priya  | Julia |
--   | NULL     | Ketty     | NULL   | Maria |
--   +----------+-----------+--------+-------+
--

SET @d=0, @a=0, @p=0, @s=0;
SELECT 
    MAX(Doctor) AS 'Doctor',
    MAX(Professor) AS 'Professor',
    MAX(Singer) AS 'Singer',
    MAX(Actor) AS 'Actor'
FROM (
    SELECT 
        IF(OCCUPATION='Actor', NAME, NULL) AS Actor,
        IF(OCCUPATION='Doctor', NAME, NULL) AS Doctor,
        IF(OCCUPATION='Professor', NAME, NULL) AS Professor,
        IF(OCCUPATION='Singer', NAME, NULL) AS Singer,
        CASE OCCUPATION 
            WHEN 'ACTOR' THEN @a:=@a+1
            WHEN 'Doctor' THEN @d:=@d+1 
            WHEN 'Professor' THEN @p:=@p+1 
            WHEN 'Singer' THEN @s:=@s+1 
            END AS r
    FROM OCCUPATIONS
    ORDER BY OCCUPATION, NAME
) T
GROUP BY r;

-- Nested query (for deeper understanding of the above query).
SET @d=0, @a=0, @p=0, @s=0;
SELECT 
    IF(OCCUPATION='Actor', NAME, NULL) AS Actor,
    IF(OCCUPATION='Doctor', NAME, NULL) AS Doctor,
    IF(OCCUPATION='Professor', NAME, NULL) AS Professor,
    IF(OCCUPATION='Singer', NAME, NULL) AS Singer,
    CASE OCCUPATION 
        WHEN 'ACTOR' THEN @a:=@a+1
        WHEN 'Doctor' THEN @d:=@d+1 
        WHEN 'Professor' THEN @p:=@p+1 
        WHEN 'Singer' THEN @s:=@s+1 
        END AS row_number
FROM OCCUPATIONS
ORDER BY OCCUPATION, NAME;





