-- 580. Count Student Number in Departments

/*
Table: Student

+--------------+---------+
| Column Name  | Type    |
+--------------+---------+
| student_id   | int     |
| student_name | varchar |
| gender       | varchar |
| dept_id      | int     |
+--------------+---------+
student_id is the primary key (column with unique values) for this table.
dept_id is a foreign key (referencing column with unique values) to
Department.dept_id.
Each row of this table indicates a student's ID, name, gender, and the
ID of the department in which they are enrolled.

Table: Department

+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| dept_id     | int     |
| dept_name   | varchar |
+-------------+---------+
dept_id is the primary key (column with unique values) for this table.
Each row of this table contains the id and the name of a department.

Write a solution to count the number of students in each department.
A department with zero students should also be included in the result.

Return the result table in any order? No -- ordered by student_number
in descending order. If there is a tie, order them by dept_name
alphabetically in ascending order.

The result format is in the following example.

Example 1:

Input:
Student table:
+------------+--------------+--------+---------+
| student_id | student_name | gender | dept_id |
+------------+--------------+--------+---------+
| 1          | Jack         | M      | 1       |
| 2          | Jane         | F      | 1       |
| 3          | Mark         | M      | 2       |
+------------+--------------+--------+---------+
Department table:
+---------+-------------+
| dept_id | dept_name   |
+---------+-------------+
| 1       | Engineering |
| 2       | Science     |
| 3       | Law         |
+---------+-------------+
Output:
+-------------+----------------+
| dept_name   | student_number |
+-------------+----------------+
| Engineering | 2              |
| Science     | 1              |
| Law         | 0              |
+-------------+----------------+
Explanation:
All students are in the Engineering and Science departments,
so they each have 2 and 1 students respectively. The Law
department has no students, so it has 0 students.
*/

-- 1. LEFT JOIN + GROUP BY
SELECT d.dept_name, COUNT(s.student_id) AS student_number FROM Department d
LEFT JOIN Student s ON s.dept_id = d.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY student_number DESC, d.dept_name ASC;

-- 2. pre-aggregate subquery
SELECT d.dept_name, COALESCE(s.student_number, 0) AS student_number
FROM Department d
LEFT JOIN (
    SELECT dept_id, COUNT(*) AS student_number FROM Student GROUP BY dept_id
) s ON s.dept_id = d.dept_id
ORDER BY student_number DESC, d.dept_name ASC;


-- 3. scalar subquery
SELECT d.dept_name, (SELECT COUNT(*) FROM Student s WHERE s.dept_id = d.dept_id) AS student_number FROM Department d
ORDER BY student_number DESC, d.dept_name ASC;
