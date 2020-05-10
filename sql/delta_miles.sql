/*
QUESTION:

A company has a table tracking the total mileage of cars on different dates.
Want to find out the miles driven since the previous date on record for each car.
For the first record of each car, the delta miles will be NULL since
there is no previous record to compare with.

EXAMPLE:

Table: auto_mileage
	id | miles  | date       | car_id
	---+--------+------------+-------
	 1 | 100.00 | 2100-05-01 |      1
	 2 | 180.00 | 2100-05-02 |      1
	 3 | 190.00 | 2100-05-03 |      1
	 4 | 290.00 | 2100-05-04 |      1
	 5 | 100.00 | 2100-05-01 |      2
	 6 | 150.00 | 2100-05-02 |      2
	 7 | 170.00 | 2100-05-03 |      2

Desired output:
	id | car_id | date       | miles  | delta_miles
	---+--------+------------+--------+------------
	 1 |      1 | 2100-05-01 | 100.00 |            
	 5 |      2 | 2100-05-01 | 100.00 |            
	 2 |      1 | 2100-05-02 | 180.00 |       80.00
	 6 |      2 | 2100-05-02 | 150.00 |       50.00
	 3 |      1 | 2100-05-03 | 190.00 |       10.00
	 7 |      2 | 2100-05-03 | 170.00 |       20.00
	 4 |      1 | 2100-05-04 | 290.00 |      100.00

TECHNIQUES:
  - Self JOIN.

REFERENCE:
  - https://stackoverflow.com/questions/14857159/mysql-difference-between-two-rows-of-a-select-statement

*/

-- ---------
--  ANSWER
-- ---------

-- Multiple self JOINs.
SELECT a1.id, a1.car_id, a1.date, 
    a2.date AS prev_date, 
    a1.miles,
    a2.miles AS prev_miles,
    a1.miles - a2.miles AS delta_miles
  FROM auto_mileage a1
  LEFT JOIN auto_mileage a2 ON
    a1.car_id = a2.car_id AND
    a2.date = (
      SELECT MAX(date) FROM auto_mileage a3
        WHERE a3.date < a1.date)
  ORDER BY a1.date, a1.car_id;



-- -------
--  Data
-- -------
DROP TABLE IF EXISTS auto_mileage;
CREATE TABLE auto_mileage
(
	id INT NOT NULL AUTO_INCREMENT,
	miles DECIMAL(8,2),
	date DATE,
	car_id INT,
	PRIMARY KEY(id)
);

INSERT INTO auto_mileage (miles, date, car_id) VALUES
	(100,  '2100-05-01', 1),
	(180,  '2100-05-02', 1),
	(190,  '2100-05-03', 1),
	(290,  '2100-05-04', 1),
	(100,  '2100-05-01', 2),
	(150,  '2100-05-02', 2),
	(170,  '2100-05-03', 2);


