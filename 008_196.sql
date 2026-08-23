-- 196. Delete Duplicate Emails

/*
SQL Schema
Pandas Schema
Table: Person

+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| id          | int     |
| email       | varchar |
+-------------+---------+
id is the primary key (column with unique values) for this table.
Each row of this table contains an email. The emails will not contain uppercase letters.

Write a solution to delete all duplicate emails, keeping only one unique email with the smallest id.

For SQL users, please note that you are supposed to write a DELETE statement and not a SELECT one.

For Pandas users, please note that you are supposed to modify Person in place.

After running your script, the answer shown is the Person table. The driver will first compile and run your piece of code and then show the Person table. The final order of the Person table does not matter.

The result format is in the following example.

Example 1:

Input: 
Person table:
+----+------------------+
| id | email            |
+----+------------------+
| 1  | john@example.com |
| 2  | bob@example.com  |
| 3  | john@example.com |
+----+------------------+
Output: 
+----+------------------+
| id | email            |
+----+------------------+
| 1  | john@example.com |
| 2  | bob@example.com  |
+----+------------------+
Explanation: john@example.com is repeated two times. We keep the row with the smallest Id = 1.
 
Seen this question in a real interview before?
1/6
*/

-- Write your PostgreSQL query statement below
DELETE FROM Person WHERE id NOT IN (
  SELECT MIN(id) FROM Person GROUP BY email
);

-- Write your PostgreSQL query statement below
DELETE FROM Person p1 USING Person p2
WHERE p1.email = p2.email AND p1.id > p2.id;

-- With Window function

DELETE FROM Person
WHERE id IN (
  SELECT id FROM (
    SELECT id, ROW_NUMBER() OVER (PARTITION BY email ORDER BY id) AS rn FROM Person
  ) t
  WHERE rn > 1
);
