-- 180. Consecutive Numbers

/*
Table: Logs

+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| id          | int     |
| num         | varchar |
+-------------+---------+
In SQL, id is the primary key for this table.
id is an autoincrement column starting from 1.

Find all numbers that appear at least three times consecutively.

Return the result table in any order.

The result format is in the following example.

Example 1:

Input: 
Logs table:
+----+-----+
| id | num |
+----+-----+
| 1  | 1   |
| 2  | 1   |
| 3  | 1   |
| 4  | 2   |
| 5  | 1   |
| 6  | 2   |
| 7  | 2   |
+----+-----+
Output: 
+-----------------+
| ConsecutiveNums |
+-----------------+
| 1               |
+-----------------+
Explanation: 1 is the only number that appears consecutively for at least three times.
 
Seen this question in a real interview before?
1/6
*/


-- Write your PostgreSQL query statement below
WITH lagged AS (
  SELECT num,
    LAG(num, 1) OVER (ORDER BY id) AS prev1,
    LAG(num, 2) OVER (ORDER BY id) AS prev2
  FROM Logs
)
SELECT DISTINCT num AS ConsecutiveNums
FROM lagged
WHERE num = prev1 AND num = prev2;


-- Write your PostgreSQL query statement below
SELECT DISTINCT l1.num AS ConsecutiveNums
FROM Logs l1
JOIN Logs l2 ON l1.id = l2.id - 1 AND l1.num = l2.num
JOIN Logs l3 ON l2.id = l3.id - 1 AND l2.num = l3.num;

-- Write your PostgreSQL query statement below
WITH grouped AS (
  SELECT num, id - ROW_NUMBER() OVER (PARTITION BY num ORDER BY id) AS grp
  FROM Logs
)
SELECT DISTINCT num AS ConsecutiveNums
FROM grouped
GROUP BY num, grp
HAVING COUNT(*) >= 3;


-- Write your PostgreSQL query statement below
SELECT DISTINCT l1.num AS ConsecutiveNums
FROM logs l1, logs l2, logs l3
WHERE l1.id=l2.id - 1 AND l2.id=l3.id - 1
  AND l1.num=l2.num AND l2.num=l3.num;


-- Write your PostgreSQL query statement below
SELECT DISTINCT l1.num AS ConsecutiveNums
FROM logs l1 JOIN logs l2
ON l1.id = l2.id-1
JOIN logs l3 ON l2.id = l3.id-1
WHERE l1.num=l2.num AND l2.num=l3.num;
