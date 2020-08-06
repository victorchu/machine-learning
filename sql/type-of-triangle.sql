/*
Write a query identifying the type of each record in the TRIANGLES table using
its three side lengths. Output one of the following statements for each record
in the table:

  - Equilateral: It's a triangle with sides of equal length.
  - Isosceles: It's a triangle with sides of equal length.
  - Scalene: It's a triangle with sides of differing lengths.
  - Not A Triangle: The given values of A, B, and C don't form a triangle.

The TRIANGLES table is described as follows:

  A: Integer
  B: Integer
  C: Integer

REFERENCE:
  - https://www.hackerrank.com/challenges/what-type-of-triangle/problem

*/

-- -------
--  Data
-- -------
DROP TABLE IF EXISTS TRIANGLES;
CREATE TABLE TRIANGLES
(
    A INT,
    B INT,
    C INT
);

TRUNCATE TABLE TRIANGLES;
INSERT INTO TRIANGLES VALUES
    (20, 20, 23),
    (20, 20, 20),
    (20, 21, 22),
    (13, 14, 27);


--------------
-- ANSWER
--------------
SELECT 
    CASE
    WHEN ((A+B<=C) OR (B+C<=A) OR (C+A<=B)) THEN 'Not A Triangle'
    WHEN (A=B) AND (B=C) THEN 'Equilateral'
    WHEN (A=B) OR (B=C) OR (C=A) THEN 'Isosceles'
    ELSE 'Scalene' END AS triangle_type
  FROM TRIANGLES;


