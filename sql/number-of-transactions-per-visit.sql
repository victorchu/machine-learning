/*
Table: Visits

+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| user_id       | int     |
| visit_date    | date    |
+---------------+---------+
(user_id, visit_date) is the primary key for this table.
Each row of this table indicates that user_id has visited the bank in visit_date.


Table: Transactions

+------------------+---------+
| Column Name      | Type    |
+------------------+---------+
| user_id          | int     |
| transaction_date | date    |
| amount           | int     |
+------------------+---------+
There is no primary key for this table, it may contain duplicates.
Each row of this table indicates that user_id has done a transaction of amount
in transaction_date.  It is guaranteed that the user has visited the bank in the
transaction_date.(i.e The Visits table contains (user_id, transaction_date) in
one row)

A bank wants to draw a chart of the number of transactions bank visitors did in
one visit to the bank and the corresponding number of visitors who have done
this number of transaction in one visit.

Write an SQL query to find how many users visited the bank and didn't do any
transactions, how many visited the bank and did one transaction and so on.

The result table will contain two columns:

    transactions_count which is the number of transactions done in one visit.
    visits_count which is the corresponding number of users who did transactions_count in one visit to the bank.

transactions_count should take all values from 0 to max(transactions_count) done
by one or more users.

Order the result table by transactions_count.

The query result format is in the following example:

Visits table:
    +---------+------------+
    | user_id | visit_date |
    +---------+------------+
    | 1       | 2020-01-01 |
    | 2       | 2020-01-02 |
    | 12      | 2020-01-01 |
    | 19      | 2020-01-03 |
    | 1       | 2020-01-02 |
    | 2       | 2020-01-03 |
    | 1       | 2020-01-04 |
    | 7       | 2020-01-11 |
    | 9       | 2020-01-25 |
    | 8       | 2020-01-28 |
    +---------+------------+

Transactions table:
    +---------+------------------+--------+
    | user_id | transaction_date | amount |
    +---------+------------------+--------+
    | 1       | 2020-01-02       | 120    |
    | 2       | 2020-01-03       | 22     |
    | 7       | 2020-01-11       | 232    |
    | 1       | 2020-01-04       | 7      |
    | 9       | 2020-01-25       | 33     |
    | 9       | 2020-01-25       | 66     |
    | 8       | 2020-01-28       | 1      |
    | 9       | 2020-01-25       | 99     |
    +---------+------------------+--------+

Result table:
    +--------------------+--------------+
    | transactions_count | visits_count |
    +--------------------+--------------+
    | 0                  | 4            |
    | 1                  | 5            |
    | 2                  | 0            |
    | 3                  | 1            |
    +--------------------+--------------+

Ref:
  - https://leetcode.com/problems/number-of-transactions-per-visit/ (Hard)

*/

-- DATA
DROP TABLE IF EXISTS Visits;
CREATE TABLE IF NOT EXISTS Visits (
    user_id INT,
    visit_date DATE
);

DROP TABLE IF EXISTS Transactions;
CREATE TABLE IF NOT EXISTS Transactions (
    user_id INT,
    transaction_date DATE,
    amount INT
);

TRUNCATE TABLE Visits;
INSERT INTO Visits VALUES 
    (1,"2020-01-01"),
    (2,"2020-01-02"),
    (12,"2020-01-01"),
    (19,"2020-01-03"),
    (1,"2020-01-02"),
    (2,"2020-01-03"),
    (1,"2020-01-04"),
    (7,"2020-01-11"),
    (9,"2020-01-25"),
    (8,"2020-01-28");

TRUNCATE TABLE Transactions;
INSERT INTO Transactions VALUES 
    (1,"2020-01-02",120),
    (2,"2020-01-03",22),
    (7,"2020-01-11",232),
    (1,"2020-01-04",7),
    (9,"2020-01-25",33),
    (9,"2020-01-25",66),
    (8,"2020-01-28",1),
    (9,"2020-01-25",99);


-- Use Recursive CTE.
-- It doesn't mean that every CTE needs to be recursive.
WITH RECURSIVE 
T AS (
    SELECT user_id, transaction_date, COUNT(*) AS transactions_count
    FROM Transactions
    GROUP BY user_id, transaction_date
),
C AS (
    -- Visit counts, possibly with some missing transactions_counts values
    SELECT transactions_count, COUNT(*) AS visits_count
    FROM (
        SELECT v.*, COALESCE(T.transactions_count, 0) AS transactions_count
        FROM Visits v
        LEFT JOIN T ON v.user_id = T.user_id AND v.visit_date = T.transaction_date
    ) V
    GROUP BY transactions_count
),
N AS (
    -- Generate a series of numbers, with recursive CTE
    SELECT 0 AS transactions_count
    UNION ALL
    SELECT transactions_count + 1 FROM N
    WHERE transactions_count <  (
        SELECT MAX(transactions_count) FROM C
    )
)
SELECT transactions_count,
    COALESCE(C.visits_count, 0) AS visits_count
FROM N
LEFT JOIN C USING (transactions_count)
ORDER BY transactions_count;


