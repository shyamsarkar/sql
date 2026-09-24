-- 626. Exchange Seats

/*
Table: Seat

+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| id          | int     |
| student     | varchar |
+-------------+---------+

id is the primary key column for this table.
Each row of this table indicates the name and the ID of a student.
The ID is always sequential.

Mary is a teacher at a school and she wants to exchange the seats of
students who are seated consecutively.

Write an SQL query to swap the seats of every two consecutive students.

If the number of students is odd, the last student's seat is not
exchanged.

Return the result table ordered by id in ascending order.

The query result format is in the following example.

Example 1:

Input:
Seat table:
+----+---------+
| id | student |
+----+---------+
| 1  | Abbot   |
| 2  | Doris   |
| 3  | Emerson |
| 4  | Green   |
| 5  | Jeames  |
+----+---------+

Output:
+----+---------+
| id | student |
+----+---------+
| 1  | Doris   |
| 2  | Abbot   |
| 3  | Green   |
| 4  | Emerson |
| 5  | Jeames  |
+----+---------+

Note:
If the number of students is odd, there is no need to change the last
one's seat.
*/

SELECT CASE
  WHEN id % 2 = 1 AND id = (SELECT MAX(id) FROM seat) THEN id
  WHEN id % 2 = 1 THEN id + 1
  ELSE id - 1
  END AS id,
  student
FROM seat
ORDER BY id;


-- window functions, no subquery:

SELECT id,
  COALESCE(
  CASE WHEN id % 2 = 1 THEN LEAD(student) OVER (ORDER BY id)
  ELSE LAG(student)  OVER (ORDER BY id)
  END,
  student
) AS student
FROM seat
ORDER BY id;

