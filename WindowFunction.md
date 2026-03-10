# Window Functions — Practice Challenges

## Setup

```bash
rails new window_functions_lab --database=postgresql
cd window_functions_lab
rails generate model Department name:string
rails generate model Employee name:string department:references salary:integer hire_date:date
rails db:create db:migrate
rails db:seed
rails c
```

### Seed Data

| name  | department  | salary | hire_date  |
|-------|-------------|--------|------------|
| Alice | Engineering | 95,000 | 2019-01-15 |
| Bob   | Engineering | 80,000 | 2020-03-10 |
| Carol | Engineering | 80,000 | 2021-06-01 |
| Dave  | Engineering | 70,000 | 2022-09-20 |
| Eve   | Marketing   | 75,000 | 2018-11-05 |
| Frank | Marketing   | 72,000 | 2020-07-22 |
| Grace | Marketing   | 68,000 | 2021-12-01 |
| Hank  | Sales       | 60,000 | 2019-05-18 |
| Ivy   | Sales       | 65,000 | 2020-02-14 |
| Jack  | Sales       | 62,000 | 2023-01-10 |

---

## A1. SUM OVER () — Company total alongside each row

### Question
Write a query that shows `name`, `department`, `salary`, `company_total` (sum of ALL salaries),
and `pct_of_company` (this employee's salary as % of total, rounded to 2 decimals).

Expected output:

| name  | department  | salary | company_total | pct_of_company |
|-------|-------------|--------|---------------|----------------|
| Alice | Engineering | 95,000 | 727,000       | 13.07          |
| Bob   | Engineering | 80,000 | 727,000       | 11.00          |
| Carol | Engineering | 80,000 | 727,000       | 11.00          |
| Dave  | Engineering | 70,000 | 727,000       | 9.63           |
| Eve   | Marketing   | 75,000 | 727,000       | 10.32          |
| Frank | Marketing   | 72,000 | 727,000       | 9.90           |
| Grace | Marketing   | 68,000 | 727,000       | 9.35           |
| Hank  | Sales       | 60,000 | 727,000       | 8.25           |
| Ivy   | Sales       | 65,000 | 727,000       | 8.94           |
| Jack  | Sales       | 62,000 | 727,000       | 8.53           |

### Answer

```sql
SELECT
  e.name,
  d.name AS department,
  e.salary,
  SUM(salary) OVER () AS company_total,
  ROUND(100.0 * salary / SUM(salary) OVER (), 2) AS pct_of_company
FROM employees e
LEFT JOIN departments d ON e.department_id = d.id
ORDER BY salary DESC
```

**Rails:**
```ruby
Employee
  .joins(:department)
  .select(
    "employees.name",
    "departments.name AS department",
    "employees.salary",
    Arel.sql("SUM(salary) OVER () AS company_total"),
    Arel.sql("ROUND(100.0 * salary / SUM(salary) OVER (), 2) AS pct_of_company")
  )
  .order(salary: :desc)
  .each { |e| puts "#{e.name} | #{e.department} | #{e.salary} | #{e.company_total} | #{e.pct_of_company}%" }
```

**Key lessons:**
- `OVER ()` with nothing inside = entire table is the window
- Always alias `d.name AS department` — two `name` columns silently overwrites in Rails
- Use `100.0` not `100` — integer division returns `0` for everyone

---

## A2 — Mini Challenge 1: Department Headcount

### Question
Write a query that shows every employee's `name`, `department`, and how many people
are in their department (`dept_headcount`). Every row must stay — do not collapse.

Expected output:

| name  | department  | dept_headcount |
|-------|-------------|----------------|
| Alice | Engineering | 4              |
| Bob   | Engineering | 4              |
| Carol | Engineering | 4              |
| Dave  | Engineering | 4              |
| Eve   | Marketing   | 3              |
| Frank | Marketing   | 3              |
| Grace | Marketing   | 3              |
| Hank  | Sales       | 3              |
| Ivy   | Sales       | 3              |
| Jack  | Sales       | 3              |

### Answer

```sql
SELECT e.name, d.name department,
  COUNT(*) OVER (PARTITION BY department_id) dept_headcount
FROM employees e
LEFT JOIN departments d ON e.department_id = d.id
```

**Key lesson:** `PARTITION BY department_id` groups by department. The column in `PARTITION BY` has nothing to do with the column you're aggregating — they are two separate decisions.

---

## A2 — Mini Challenge 2: Department Average Salary

### Question
Write a query that shows every employee's `name`, `department`, `salary`,
and the average salary of their department (`dept_avg`), rounded to 0 decimals.

Expected output:

| name  | department  | salary | dept_avg |
|-------|-------------|--------|----------|
| Alice | Engineering | 95,000 | 81,250   |
| Bob   | Engineering | 80,000 | 81,250   |
| Carol | Engineering | 80,000 | 81,250   |
| Dave  | Engineering | 70,000 | 81,250   |
| Eve   | Marketing   | 75,000 | 71,667   |
| Frank | Marketing   | 72,000 | 71,667   |
| Grace | Marketing   | 68,000 | 71,667   |
| Hank  | Sales       | 60,000 | 62,333   |
| Ivy   | Sales       | 65,000 | 62,333   |
| Jack  | Sales       | 62,000 | 62,333   |

### Answer

```sql
SELECT e.name, d.name department, salary,
  ROUND(AVG(salary) OVER (PARTITION BY department_id), 0) dept_avg
FROM employees e
LEFT JOIN departments d ON e.department_id = d.id
```

**Key lesson:** Every aggregate — `SUM`, `AVG`, `COUNT`, `MIN`, `MAX` — works as a window function.

---

## A2 — Mini Challenge 3: Difference from Department Average

### Question
Write a query that shows `name`, `department`, `salary`, `dept_avg`,
and how much each employee earns above or below their dept average (`diff_from_avg`).

Expected output:

| name  | department  | salary | dept_avg | diff_from_avg |
|-------|-------------|--------|----------|---------------|
| Alice | Engineering | 95,000 | 81,250   | 13,750        |
| Bob   | Engineering | 80,000 | 81,250   | -1,250        |
| Carol | Engineering | 80,000 | 81,250   | -1,250        |
| Dave  | Engineering | 70,000 | 81,250   | -11,250       |
| Eve   | Marketing   | 75,000 | 71,667   | 3,333         |
| Frank | Marketing   | 72,000 | 71,667   | 333           |
| Grace | Marketing   | 68,000 | 71,667   | -3,667        |
| Hank  | Sales       | 60,000 | 62,333   | -2,333        |
| Ivy   | Sales       | 65,000 | 62,333   | 2,667         |
| Jack  | Sales       | 62,000 | 62,333   | -333          |

### Answer

```sql
SELECT e.name, d.name department, salary,
  ROUND(AVG(salary) OVER (PARTITION BY department_id), 0) dept_avg,
  salary - ROUND(AVG(salary) OVER (PARTITION BY department_id), 0) diff_from_avg
FROM employees e
LEFT JOIN departments d ON e.department_id = d.id
```

**Key lesson:** You can reuse a window function directly inside arithmetic — no need to store it anywhere.

---

## A2 — Full Challenge: All Department Columns Together

### Question
Write a single query with all columns: `name`, `department`, `salary`,
`dept_total`, `dept_avg`, `dept_headcount`, `diff_from_avg`.

### Answer

```sql
SELECT e.name, d.name department, salary,
  SUM(salary)                                        OVER w AS dept_total,
  ROUND(AVG(salary) OVER w, 0)                              AS dept_avg,
  COUNT(*)                                           OVER w AS dept_headcount,
  salary - ROUND(AVG(salary) OVER w, 0)                     AS diff_from_avg
FROM employees e
LEFT JOIN departments d ON e.department_id = d.id
WINDOW w AS (PARTITION BY department_id)
ORDER BY d.name, salary DESC
```

**Rails:**
```ruby
Employee
  .joins(:department)
  .select(
    "employees.name",
    "departments.name AS department",
    "employees.salary",
    Arel.sql("SUM(salary) OVER (PARTITION BY employees.department_id) AS dept_total"),
    Arel.sql("ROUND(AVG(salary) OVER (PARTITION BY employees.department_id), 2) AS dept_avg"),
    Arel.sql("COUNT(*) OVER (PARTITION BY employees.department_id) AS dept_headcount"),
    Arel.sql("salary - AVG(salary) OVER (PARTITION BY employees.department_id) AS diff_from_avg")
  )
  .order("departments.name, employees.salary DESC")
  .each { |e| puts "#{e.name} | #{e.department} | #{e.salary} | #{e.dept_total} | #{e.dept_avg} | #{e.diff_from_avg}" }
```

**Key lesson:** Use `WINDOW w AS (...)` to define the partition once and reuse with `OVER w` — avoids repetition.

---

## A3 — Challenge 1: Company-wide Running Total

### Question
Write a query that shows `name`, `hire_date`, `salary`, and a `running_total` —
cumulative sum of salaries ordered by `hire_date` across the entire company.

Expected output:

| name  | hire_date  | salary | running_total |
|-------|------------|--------|---------------|
| Eve   | 2018-11-05 | 75,000 | 75,000        |
| Alice | 2019-01-15 | 95,000 | 170,000       |
| Hank  | 2019-05-18 | 60,000 | 230,000       |
| Ivy   | 2020-02-14 | 65,000 | 295,000       |
| Bob   | 2020-03-10 | 80,000 | 375,000       |
| Frank | 2020-07-22 | 72,000 | 447,000       |
| Carol | 2021-06-01 | 80,000 | 527,000       |
| Grace | 2021-12-01 | 68,000 | 595,000       |
| Dave  | 2022-09-20 | 70,000 | 665,000       |
| Jack  | 2023-01-10 | 62,000 | 727,000       |

### Answer

```sql
SELECT name, hire_date, salary,
  SUM(salary) OVER w AS running_total
FROM employees
WINDOW w AS (ORDER BY hire_date)
```

**Key lesson:** `ORDER BY` inside `OVER` is not about display sorting — it defines which rows the function can see. It silently applies `ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`.

---

## A3 — Challenge 2: Running Total Per Department

### Question
Same as above but the running total **resets per department**.

Expected output:

| name  | department  | hire_date  | salary | running_total |
|-------|-------------|------------|--------|---------------|
| Alice | Engineering | 2019-01-15 | 95,000 | 95,000        |
| Bob   | Engineering | 2020-03-10 | 80,000 | 175,000       |
| Carol | Engineering | 2021-06-01 | 80,000 | 255,000       |
| Dave  | Engineering | 2022-09-20 | 70,000 | 325,000       |
| Eve   | Marketing   | 2018-11-05 | 75,000 | 75,000        |
| Frank | Marketing   | 2020-07-22 | 72,000 | 147,000       |
| Grace | Marketing   | 2021-12-01 | 68,000 | 215,000       |
| Hank  | Sales       | 2019-05-18 | 60,000 | 60,000        |
| Ivy   | Sales       | 2020-02-14 | 65,000 | 125,000       |
| Jack  | Sales       | 2023-01-10 | 62,000 | 187,000       |

### Answer

```sql
SELECT e.name, d.name AS department, hire_date, salary,
  SUM(salary) OVER w AS running_total
FROM employees e
LEFT JOIN departments d ON e.department_id = d.id
WINDOW w AS (PARTITION BY department_id ORDER BY hire_date)
ORDER BY d.name, hire_date
```

**Key lesson:** Combining `PARTITION BY` + `ORDER BY` in the same window gives running totals that reset per group.

---

## B1 — Challenge 1: ROW_NUMBER Within Department

### Question
Write a query that ranks employees within their department by salary (highest first)
using `ROW_NUMBER`.

Expected output:

| name  | department  | salary | row_num |
|-------|-------------|--------|---------|
| Alice | Engineering | 95,000 | 1       |
| Bob   | Engineering | 80,000 | 2       |
| Carol | Engineering | 80,000 | 3       |
| Dave  | Engineering | 70,000 | 4       |
| Eve   | Marketing   | 75,000 | 1       |
| Frank | Marketing   | 72,000 | 2       |
| Grace | Marketing   | 68,000 | 3       |
| Ivy   | Sales       | 65,000 | 1       |
| Jack  | Sales       | 62,000 | 2       |
| Hank  | Sales       | 60,000 | 3       |

### Answer

```sql
SELECT e.name, d.name department, salary,
  ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY salary DESC) row_num
FROM employees e
LEFT JOIN departments d ON e.department_id = d.id
ORDER BY d.name, salary DESC
```

**Key lesson:** `PARTITION BY` defines the group. `ORDER BY` inside `OVER` defines what determines the rank — always ask "what is the natural order within this group?"

---

## B1 — Challenge 2: ROW_NUMBER + RANK + DENSE_RANK Together

### Question
Write a single query showing all three ranking functions side by side,
partitioned by department, ordered by salary descending.

Expected output:

| name  | department  | salary | row_num | rank | dense_rank |
|-------|-------------|--------|---------|------|------------|
| Alice | Engineering | 95,000 | 1       | 1    | 1          |
| Bob   | Engineering | 80,000 | 2       | 2    | 2          |
| Carol | Engineering | 80,000 | 3       | 2    | 2          |
| Dave  | Engineering | 70,000 | 4       | 4    | 3          |
| Eve   | Marketing   | 75,000 | 1       | 1    | 1          |
| Frank | Marketing   | 72,000 | 2       | 2    | 2          |
| Grace | Marketing   | 68,000 | 3       | 3    | 3          |
| Ivy   | Sales       | 65,000 | 1       | 1    | 1          |
| Jack  | Sales       | 62,000 | 2       | 2    | 2          |
| Hank  | Sales       | 60,000 | 3       | 3    | 3          |

### Answer

```sql
SELECT e.name, d.name department, salary,
  ROW_NUMBER() OVER w row_num,
  RANK()       OVER w rank,
  DENSE_RANK() OVER w dense_rank
FROM employees e
LEFT JOIN departments d ON e.department_id = d.id
WINDOW w AS (PARTITION BY department_id ORDER BY salary DESC)
ORDER BY d.name, salary DESC
```

**Key lesson:**
- `ROW_NUMBER` — always unique, breaks ties arbitrarily (1,2,3,4)
- `RANK` — ties get same number, next number skips (1,2,2,4)
- `DENSE_RANK` — ties get same number, next number doesn't skip (1,2,2,3)

---

## B1 — Challenge 3: Top 2 Earners Per Department (Subquery Pattern)

### Question
Write a query that returns only the top 2 earners per department.

Expected output:

| name  | department  | salary | row_num |
|-------|-------------|--------|---------|
| Alice | Engineering | 95,000 | 1       |
| Bob   | Engineering | 80,000 | 2       |
| Eve   | Marketing   | 75,000 | 1       |
| Frank | Marketing   | 72,000 | 2       |
| Ivy   | Sales       | 65,000 | 1       |
| Jack  | Sales       | 62,000 | 2       |

### Answer

```sql
SELECT * FROM (
  SELECT e.name, d.name department, salary,
    ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY salary DESC) row_num
  FROM employees e
  LEFT JOIN departments d ON e.department_id = d.id
) top_earners
WHERE row_num <= 2
ORDER BY department, salary DESC
```

**Rails:**
```ruby
ranked = Employee
  .joins(:department)
  .select(
    "employees.name",
    "departments.name AS department",
    "employees.salary",
    Arel.sql("ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY salary DESC) AS row_num")
  )

Employee
  .from("(#{ranked.to_sql}) AS top_earners")
  .where("row_num <= 2")
  .order("department, salary DESC")
  .each { |e| puts "#{e.name} | #{e.department} | #{e.salary}" }
```

**Key lessons:**
- You cannot use a window function in `WHERE` — SQL runs `WHERE` before `SELECT`
- Wrap the query in a subquery, then filter on the outside
- Subquery alias (`top_earners`) is **mandatory** — SQL throws an error without it
- `AS` keyword is optional — `d.name department` and `d.name AS department` are identical

---

## B2 — NTILE: Salary Quartiles

### Question
Write a query that shows every employee's `name`, `salary`, and which salary
`quartile` (1–4) they fall into company-wide. Bucket 1 = lowest salaries, Bucket 4 = highest.

### Answer

```sql
SELECT name, salary,
  NTILE(4) OVER (ORDER BY salary) AS quartile
FROM employees
ORDER BY salary
```

**Key lessons:**
- `NTILE(n)` divides rows into n equal buckets — no ties, just fills buckets by row count
- When rows don't divide evenly, extra rows go to the **earlier** buckets
- Use `ORDER BY` inside `OVER` to define what determines bucket assignment

---

## C1 — Challenge 1: LAG and LEAD Company-wide

### Question
Write a query showing `name`, `hire_date`, `salary`, `prev_salary` (salary of person hired before),
`next_salary` (salary of person hired after), and `diff_from_prev` (difference from previous hire's salary).
Order by `hire_date`.

Expected output:

| name  | hire_date  | salary | prev_salary | next_salary | diff_from_prev |
|-------|------------|--------|-------------|-------------|----------------|
| Eve   | 2018-11-05 | 75,000 | null        | 95,000      | null           |
| Alice | 2019-01-15 | 95,000 | 75,000      | 60,000      | 20,000         |
| Hank  | 2019-05-18 | 60,000 | 95,000      | 65,000      | -35,000        |
| Ivy   | 2020-02-14 | 65,000 | 60,000      | 80,000      | 5,000          |
| Bob   | 2020-03-10 | 80,000 | 65,000      | 72,000      | 15,000         |
| Frank | 2020-07-22 | 72,000 | 80,000      | 80,000      | -8,000         |
| Carol | 2021-06-01 | 80,000 | 72,000      | 68,000      | 8,000          |
| Grace | 2021-12-01 | 68,000 | 80,000      | 70,000      | -12,000        |
| Dave  | 2022-09-20 | 70,000 | 68,000      | 62,000      | 2,000          |
| Jack  | 2023-01-10 | 62,000 | 70,000      | null        | -8,000         |

### Answer

```sql
SELECT name, hire_date, salary,
  LAG(salary)  OVER w AS prev_salary,
  LEAD(salary) OVER w AS next_salary,
  salary - LAG(salary) OVER w AS diff_from_prev
FROM employees
WINDOW w AS (ORDER BY hire_date)
```

**Key lessons:**
- `LAG(col, n)` looks n rows back, `LEAD(col, n)` looks n rows forward — default n is 1
- `LAG` and `LEAD` **always need `ORDER BY`** — without it "previous" has no meaning
- First row's `LAG` = null, last row's `LEAD` = null (use 3rd arg for default: `LAG(salary, 1, 0)`)

---

## C1 — Challenge 2: LAG Within Department

### Question
Write a query comparing each employee's salary to the previously hired person
**within the same department**. Show `name`, `department`, `hire_date`, `salary`,
`prev_in_dept`, and `growth`.

Expected output:

| name  | department  | hire_date  | salary | prev_in_dept | growth  |
|-------|-------------|------------|--------|--------------|---------|
| Alice | Engineering | 2019-01-15 | 95,000 | null         | null    |
| Bob   | Engineering | 2020-03-10 | 80,000 | 95,000       | -15,000 |
| Carol | Engineering | 2021-06-01 | 80,000 | 80,000       | 0       |
| Dave  | Engineering | 2022-09-20 | 70,000 | 80,000       | -10,000 |
| Eve   | Marketing   | 2018-11-05 | 75,000 | null         | null    |
| Frank | Marketing   | 2020-07-22 | 72,000 | 75,000       | -3,000  |
| Grace | Marketing   | 2021-12-01 | 68,000 | 72,000       | -4,000  |
| Hank  | Sales       | 2019-05-18 | 60,000 | null         | null    |
| Ivy   | Sales       | 2020-02-14 | 65,000 | 60,000       | 5,000   |
| Jack  | Sales       | 2023-01-10 | 62,000 | 65,000       | -3,000  |

### Answer

```sql
SELECT e.name, d.name AS department, hire_date, salary,
  LAG(salary)          OVER w AS prev_in_dept,
  salary - LAG(salary) OVER w AS growth
FROM employees e
LEFT JOIN departments d ON e.department_id = d.id
WINDOW w AS (PARTITION BY department_id ORDER BY hire_date)
ORDER BY d.name, hire_date
```

**Key lesson:** Combine `PARTITION BY` + `ORDER BY` in the same window — LAG resets at the start of each partition.

---

## C2 — FIRST_VALUE & LAST_VALUE: Highest and Lowest Earner Per Department

### Question
Write a query showing `name`, `department`, `salary`, `highest_earner`
(name of top earner in dept) and `lowest_earner` (name of lowest earner in dept).

Expected output:

| name  | department  | salary | highest_earner | lowest_earner |
|-------|-------------|--------|----------------|---------------|
| Alice | Engineering | 95,000 | Alice          | Dave          |
| Bob   | Engineering | 80,000 | Alice          | Dave          |
| Carol | Engineering | 80,000 | Alice          | Dave          |
| Dave  | Engineering | 70,000 | Alice          | Dave          |
| Eve   | Marketing   | 75,000 | Eve            | Grace         |
| Frank | Marketing   | 72,000 | Eve            | Grace         |
| Grace | Marketing   | 68,000 | Eve            | Grace         |
| Ivy   | Sales       | 65,000 | Ivy            | Hank          |
| Jack  | Sales       | 62,000 | Ivy            | Hank          |
| Hank  | Sales       | 60,000 | Ivy            | Hank          |

### Answer

```sql
SELECT e.name, d.name AS department, salary,
  FIRST_VALUE(e.name) OVER w AS highest_earner,
  LAST_VALUE(e.name)  OVER (
    PARTITION BY department_id
    ORDER BY salary DESC
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
  ) AS lowest_earner
FROM employees e
LEFT JOIN departments d ON e.department_id = d.id
WINDOW w AS (PARTITION BY department_id ORDER BY salary DESC)
ORDER BY d.name, salary DESC
```

**Key lessons:**
- `FIRST_VALUE` works fine with default frame — the first row is always in every row's frame
- `LAST_VALUE` needs explicit frame `ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING`
- Without the explicit frame, `LAST_VALUE` returns the **current row itself** (default frame only goes to current row)
- You cannot reuse the named window `w` for `LAST_VALUE` when it needs a different frame

---

## Window Frames — ROWS BETWEEN

### Frame Cheat Sheet

| Frame | Meaning | Use case |
|---|---|---|
| `ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW` | Start to current row | Running totals (default with ORDER BY) |
| `ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING` | Entire partition | LAST_VALUE, full totals |
| `ROWS BETWEEN 2 PRECEDING AND CURRENT ROW` | Last 3 rows | 3-row moving average |
| `ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING` | Centered window | Smoothing with neighbors |

---

### Challenge 1: Feel the Difference — Default vs Full Frame

Run both queries and compare output:

```sql
-- Query 1: Running total (default frame — grows row by row)
SELECT name, salary,
  SUM(salary) OVER (ORDER BY salary DESC
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS running_total
FROM employees ORDER BY salary DESC;

-- Query 2: Full total every row (full frame — same number everywhere)
SELECT name, salary,
  SUM(salary) OVER (ORDER BY salary DESC
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
  ) AS full_total
FROM employees ORDER BY salary DESC;
```

**Observation:** Query 1 grows row by row. Query 2 shows `727,000` on every single row.

---

### Challenge 2: 3-Row Moving Average

### Question
Write a query showing each employee's `name`, `hire_date`, `salary`, and `moving_avg` —
the average salary of the current row plus the 2 rows before it, ordered by `hire_date`.

Expected output:

| name  | hire_date  | salary | moving_avg |
|-------|------------|--------|------------|
| Eve   | 2018-11-05 | 75,000 | 75,000     |
| Alice | 2019-01-15 | 95,000 | 85,000     |
| Hank  | 2019-05-18 | 60,000 | 76,667     |
| Ivy   | 2020-02-14 | 65,000 | 73,333     |
| Bob   | 2020-03-10 | 80,000 | 68,333     |
| Frank | 2020-07-22 | 72,000 | 72,333     |
| Carol | 2021-06-01 | 80,000 | 77,333     |
| Grace | 2021-12-01 | 68,000 | 73,333     |
| Dave  | 2022-09-20 | 70,000 | 72,667     |
| Jack  | 2023-01-10 | 62,000 | 66,667     |

Notice:
- Eve has only herself → `moving_avg = 75,000` (only 1 row available)
- Alice has Eve + herself → `moving_avg = 85,000` (only 2 rows available)
- From Hank onwards — always 3 rows included

### Answer

```sql
SELECT name, hire_date, salary,
  ROUND(AVG(salary) OVER w, 0) AS moving_avg
FROM employees
WINDOW w AS (ORDER BY hire_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
```

**Rails:**
```ruby
Employee
  .select(
    "name",
    "hire_date",
    "salary",
    Arel.sql("ROUND(AVG(salary) OVER (ORDER BY hire_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 0) AS moving_avg")
  )
  .order("hire_date")
  .each { |e| puts "#{e.name} | #{e.hire_date} | #{e.salary} | #{e.moving_avg}" }
```

**Key lessons:**
- The frame clause goes **inside** the window definition, after `ORDER BY`
- When fewer than N rows exist before current row, SQL uses however many are available — no errors
- `AVG()` and `SUM()/COUNT()` produce identical results — `AVG()` is cleaner
- Named window `w` can include the frame: `WINDOW w AS (ORDER BY ... ROWS BETWEEN ...)`

---

## Complete Progress Tracker

| Concept | Status |
|---|---|
| Basic `OVER ()` — entire table as window | ✅ |
| `PARTITION BY` — correct column to group on | ✅ |
| All aggregates work as window functions | ✅ |
| Named windows `WINDOW w AS (...)` | ✅ |
| `ORDER BY` inside OVER changes frame, not just sort | ✅ |
| Running totals with `ORDER BY` inside OVER | ✅ |
| `ROW_NUMBER`, `RANK`, `DENSE_RANK` differences | ✅ |
| Subquery pattern to filter window function results | ✅ |
| `NTILE(n)` — bucketing into equal groups | ✅ |
| `LAG` / `LEAD` — always need `ORDER BY` | ✅ |
| `FIRST_VALUE` works with default frame | ✅ |
| `LAST_VALUE` needs explicit full frame | ✅ |
| `ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW` | ✅ |
| `ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING` | ✅ |
| Custom sliding frame `N PRECEDING AND CURRENT ROW` | ✅ |
| `AS` keyword is optional for aliases | ✅ |
| Choosing ORDER BY column based on business logic | ⚠️ (improving) |