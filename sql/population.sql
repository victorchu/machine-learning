/*
CITY & COUNTRY

REF: 
  - https://www.hackerrank.com/challenges/average-population-of-each-continent/problem (Easy)
*/

-- -------
--  Data
-- -------
DROP TABLE IF EXISTS CITY;
CREATE TABLE CITY
(
    ID     NUMBER,
    NAME   VARCHAR(17),
    COUNTRYCODE  VARCHAR(3),
    DISTRICT VARCHAR(20),
    POPULATION INT
);

DROP TABLE IF EXISTS COUNTRY;
CREATE TABLE COUNTRY
(
    CODE   VARCHAR(3),
    NAME   VARCHAR(17),
    CONTINENT   VARCHAR(13),
    REGION   VARCHAR(25),
    SURFACEAREA INT,
    POPULATION INT,
    -- ...
);

TRUNCATE TABLE CITY
INSERT INTO CITY VALUES
    ;



-- ------
--  EASY
-- ------

--
-- Q. Get total population in listed Asia cities.

SELECT SUM(A.POPULATION)
    FROM CITY A, COUNTRY B
    WHERE A.COUNTRYCODE = B.CODE
        AND B.CONTINENT = 'Asia';


--
-- Q. Query the names of all cities where the CONTINENT is 'Africa'. 

SELECT A.NAME
    FROM CITY A, COUNTRY B
    WHERE A.COUNTRYCODE = B.CODE
        AND B.CONTINENT = 'Africa';

--
-- Q. Query the names of all the continents (COUNTRY.Continent) and their
-- respective average city populations (CITY.Population) rounded 'down' to the
-- nearest integer.

-- Rounded 'down' => CEIL; rounded 'up' => CEIL.
SELECT 
        B.CONTINENT,
        FLOOR(AVG(A.POPULATION)) AS AVG_CITY_POP
    FROM CITY A, COUNTRY B
    WHERE A.COUNTRYCODE = B.CODE
    GROUP BY B.CONTINENT;


