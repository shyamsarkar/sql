-- 574 — Winning Candidate

/*
Table: Candidate

+-------------+----------+
| Column Name | Type     |
+-------------+----------+
| id          | int      |
| name        | varchar  |
+-------------+----------+
id is the column with unique values for this table.
Each row of this table contains information about the id and the name of a candidate.

Table: Vote

+-------------+------+
| Column Name | Type |
+-------------+------+
| id          | int  |
| candidateId | int  |
+-------------+------+
id is an auto-increment primary key (column with unique values).
candidateId is a foreign key (reference column) to id from the Candidate table.
Each row of this table determines the candidate who got the ith vote in the elections.

Write a solution to report the name of the winning candidate (i.e., the candidate
who got the largest number of votes).

The test cases are generated so that exactly one candidate wins the elections.

The result format is in the following example.

Example 1:

Input:
Candidate table:
+----+------+
| id | name |
+----+------+
| 1  | A    |
| 2  | B    |
| 3  | C    |
| 4  | D    |
| 5  | E    |
+----+------+

Vote table:
+----+-------------+
| id | candidateId |
+----+-------------+
| 1  | 2           |
| 2  | 4           |
| 3  | 3           |
| 4  | 2           |
| 5  | 5           |
+----+-------------+

Output:
+------+
| name |
+------+
| B    |
+------+

Explanation:
Candidate B has 2 votes. Candidates C, D, and E have 1 vote each.
The winner is candidate B.
*/

-- 1. Join + aggregate — best overall
SELECT c.name FROM Candidate AS c
JOIN Vote AS v ON v.CandidateId = c.id
GROUP BY c.id, c.name ORDER BY COUNT(*) DESC LIMIT 1;

-- 2. Argmax subquery — best for returning only the name
SELECT name FROM Candidate
WHERE id = (
    SELECT CandidateId FROM Vote
    GROUP BY CandidateId ORDER BY COUNT(*) DESC LIMIT 1
);

-- 3. RANK() — best for learning tie handling
SELECT name
FROM (
    SELECT c.name, RANK() OVER (ORDER BY COUNT(*) DESC) AS rnk
    FROM Candidate AS c
    JOIN Vote AS v ON v.CandidateId = c.id
    GROUP BY c.id, c.name
) AS t
WHERE rnk = 1;
