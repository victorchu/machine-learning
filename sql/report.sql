/*
Students & Grades

REF: 
  - https://www.hackerrank.com/challenges/the-report/problem (Medium)
*/

-- -------
--  Data
-- -------
DROP TABLE IF EXISTS Students;
CREATE TABLE Students
(
    ID     INT,
    Name   VARCHAR(17),
    Marks  INT
);

DROP TABLE IF EXISTS Grades;
CREATE TABLE Grades
(
    Grade INT,
    Min_Mark INT,
    Max_Mark INT
);

TRUNCATE TABLE Students;
INSERT INTO Students VALUES
   (1, 'Julia', 88),
   (2, 'Samantha', 68),
   (3, 'Maria', 99),
   (4, 'Scarlet', 78),
   (5, 'Ashley', 63),
   (6, 'Jane', 81);

TRUNCATE TABLE Grades;
INSERT INTO Grades VALUES
    ( 1,  0,  9),
    ( 2, 10, 19),
    ( 3, 20, 29),
    ( 4, 30, 39),
    ( 5, 40, 49),
    ( 6, 50, 59),
    ( 7, 60, 69),
    ( 8, 70, 79),
    ( 9, 80, 89),
    (10, 90, 100);



/*
Ketty gives Eve a task to generate a report containing three columns: 

    Name, Grade,  Mark.

  - Ketty doesn't want the NAMES of those students who received a grade lower than 8.
  - The report must be in descending order by grade -- i.e.  higher grades are entered first.
  - If there is more than one student with the same grade (8-10) assigned to them, order those
    particular students by their name alphabetically.
  - Finally, if the grade is lower than 8, use "NULL" as their name
    and list them by their grades in descending order.
  - If there is more than one student with the same grade (1-7) assigned to them,
    order those particular students by their marks in ascending order.

Write a query to help Eve.

Sample Output:

    Maria 10 99
    Jane 9 81
    Julia 9 88
    Scarlet 8 78
    NULL 7 63
    NULL 7 68

*/

SELECT
        CASE WHEN a.Grade >= 8 THEN a.Name ELSE NULL END AS Name,
        a.Grade,
        a.Marks
    FROM (
        SELECT S.*, G.*,
            CASE WHEN (S.Marks >= G.Min_Mark) AND (S.Marks <= G.Max_Mark) THEN 1 ELSE 0 END AS M
        FROM Students S, Grades G
        HAVING M = 1
    ) a
    ORDER BY GRADE DESC, Name ASC, Marks ASC
    ;


