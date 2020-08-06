/*
Data:

Students: ID | Name
Friends: ID | Friend_ID
Packages: ID | Salary --- $ thousands / Month

TASK:
  - Write a query to output the names of those students whose "best friends" got offered a higher salary than them.
  - Names must be ordered by the salary amount offered to the best friends. (ASC)
  - It is guaranteed that no two students got same salary offer.

REF:
  - https://www.hackerrank.com/challenges/placements/forum
*/

-- Structured approach
WITH A AS (
    SELECT S.ID, S.Name, P.Salary
        FROM Students S, Packages P
        WHERE S.ID = P.ID
),
B AS (
    SELECT S.ID, P.Salary AS Friend_Salary
        FROM Students S, Friends F, Packages P
        WHERE S.ID = F.ID AND F.Friend_ID = P.ID
),
C AS (
    SELECT A.ID, A.Name, A.Salary, Friend_Salary
    FROM A, B
    WHERE A.ID = B.ID AND A.Salary < B.Friend_Salary
    ORDER BY Friend_Salary
)
SELECT Name FROM C;


-- JOIN all of them togehter in one shot
Select S.Name
FROM Students S 
    JOIN Friends F USING(ID)
    JOIN Packages P1 ON S.ID=P1.ID
    JOIN Packages P2 ON F.Friend_ID=P2.ID
WHERE P2.Salary > P1.Salary
ORDER BY P2.Salary;


