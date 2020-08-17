/*
Table: Users
    +----------------+---------+
    | Column Name    | Type    |
    +----------------+---------+
    | user_id        | int     |
    | join_date      | date    |
    | favorite_brand | varchar |
    +----------------+---------+
  - user_id is the primary key of this table.
  - This table has the info of the users of an online shopping website where
    users can sell and buy items.

Table: Orders
    +---------------+---------+
    | Column Name   | Type    |
    +---------------+---------+
    | order_id      | int     |
    | order_date    | date    |
    | item_id       | int     |
    | buyer_id      | int     |
    | seller_id     | int     |
    +---------------+---------+
  - order_id is the primary key of this table.
  - item_id is a foreign key to the Items table.
  - buyer_id and seller_id are foreign keys to the Users table.

Table: Items
    +---------------+---------+
    | Column Name   | Type    |
    +---------------+---------+
    | item_id       | int     |
    | item_brand    | varchar |
    +---------------+---------+
  - item_id is the primary key of this table.


Write an SQL query to find for each user, whether the brand of the second item
(by date) they sold is their favorite brand. If a user sold less than two items,
report the answer for that user as no.

It is guaranteed that no seller sold more than one item on a day.

The query result format is in the following example:

Users table:
    +---------+------------+----------------+
    | user_id | join_date  | favorite_brand |
    +---------+------------+----------------+
    | 1       | 2019-01-01 | Lenovo         |
    | 2       | 2019-02-09 | Samsung        |
    | 3       | 2019-01-19 | LG             |
    | 4       | 2019-05-21 | HP             |
    +---------+------------+----------------+

Orders table:
    +----------+------------+---------+----------+-----------+
    | order_id | order_date | item_id | buyer_id | seller_id |
    +----------+------------+---------+----------+-----------+
    | 1        | 2019-08-01 | 4       | 1        | 2         |
    | 2        | 2019-08-02 | 2       | 1        | 3         |
    | 3        | 2019-08-03 | 3       | 2        | 3         |
    | 4        | 2019-08-04 | 1       | 4        | 2         |
    | 5        | 2019-08-04 | 1       | 3        | 4         |
    | 6        | 2019-08-05 | 2       | 2        | 4         |
    +----------+------------+---------+----------+-----------+

Items table:
    +---------+------------+
    | item_id | item_brand |
    +---------+------------+
    | 1       | Samsung    |
    | 2       | Lenovo     |
    | 3       | LG         |
    | 4       | HP         |
    +---------+------------+

Result table:
    +-----------+--------------------+
    | seller_id | 2nd_item_fav_brand |
    +-----------+--------------------+
    | 1         | no                 |
    | 2         | yes                |
    | 3         | yes                |
    | 4         | no                 |
    +-----------+--------------------+

  - The answer for the user with id 1 is no because they sold nothing.
  - The answer for the users with id 2 and 3 is yes because the brands of their
    second sold items are their favorite brands.
  - The answer for the user with id 4 is no because the brand of their second sold
    item is not their favorite brand.

Ref:
  - https://leetcode.com/problems/market-analysis-ii/ (Hard)

*/

-- DATA
DROP TABLE IF EXISTS Users;
CREATE TABLE IF NOT EXISTS Users (
    user_id INT,
    join_date DATE,
    favorite_brand VARCHAR(15)
);

DROP TABLE IF EXISTS Orders;
CREATE TABLE IF NOT EXISTS Orders (
    order_id INT,
    order_date DATE,
    item_id INT,
    buyer_id INT,
    seller_id INT
);

DROP TABLE IF EXISTS Items;
CREATE TABLE IF NOT EXISTS Items (
    item_id INT,
    item_brand VARCHAR(15)
);

TRUNCATE TABLE Users;
INSERT INTO Users VALUES 
    (1, '2019-01-01', 'Lenovo'),
    (2, '2019-02-09', 'Samsung'),
    (3, '2019-01-19', 'LG'),
    (4, '2019-05-21', 'HP');

TRUNCATE TABLE Orders;
INSERT INTO Orders VALUES 
    (1 ,'2019-08-01', 4, 1, 2),
    (2 ,'2019-08-02', 2, 1, 3),
    (3 ,'2019-08-03', 3, 2, 3),
    (4 ,'2019-08-04', 1, 4, 2),
    (5 ,'2019-08-04', 1, 3, 4),
    (6 ,'2019-08-05', 2, 2, 4);

TRUNCATE TABLE Items;
INSERT INTO Items VALUES 
    (1, 'Samsung'),
    (2, 'Lenovo'),
    (3, 'LG'),
    (4, 'HP');


-- ANSWER
WITH A AS (
    -- Get 2nd item from each seller
    SELECT seller_id, item_id, I.item_brand
    FROM (
        -- Get order ranks
        SELECT 
            seller_id,
            item_id,
            order_date,
            RANK() OVER (PARTITION BY seller_id ORDER BY order_date) AS rnk
        FROM Orders
    ) T
    -- Use LEFT JOIN to get the brand
    LEFT JOIN Items I Using(item_id)
    WHERE rnk=2
)
SELECT 
    user_id AS seller_id,
    IF(favorite_brand=item_brand, 'yes', 'no') AS 2nd_item_fav_brand
FROM Users U
LEFT JOIN A ON U.user_id=A.seller_id;


