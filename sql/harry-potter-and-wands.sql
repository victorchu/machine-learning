/*
Harry Potter and his friends are at Ollivander's with Ron, finally replacing
Charlie's old broken wand.

Hermione decides the best way to choose is by determining the minimum number of
gold galleons needed to buy each non-evil wand of high power and age. Write a
query to print the id, age, coins_needed, and power of the wands that Ron's
interested in, sorted in order of descending power. If more than one wand has
same power, sort the result in order of descending age.

Wantds: 
    id | code | coins_needed | power

Wantds_Properties: 
    code | age | is_evail
    

REF:
  - https://www.hackerrank.com/challenges/harry-potter-and-wands/problem (Medium)

*/

--
-- The key is the compare coins_needed with the MIN coins_needed,
-- which is obtained by a sub-query.
--
SELECT w.id, p.age, w.coins_needed, w.power 
FROM Wands as w, Wands_Property p
WHERE 
    w.code = p.code AND p.is_evil = 0 AND
    w.coins_needed = (
      SELECT MIN(coins_needed) 
      FROM Wands w1, Wands_Property p1 
      WHERE w1.code = p1.code AND w1.power = w.power AND p1.age = p.age
    ) 
ORDER BY w.power DESC, p.age DESC;


