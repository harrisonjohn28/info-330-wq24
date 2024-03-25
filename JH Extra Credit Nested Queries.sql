-- John Harrison
-- Lucy Lu Wang
-- INFO 330
-- 11 March 2024

-- Extra Credit: Nested Queries

-- Consider a table employee(id, name, hiredate, title, department)

-- 1. In English, describe what this query does:

SELECT *
FROM employees
WHERE hiredate IN (
 SELECT hiredate
 FROM employees
 WHERE title = 'Manager'
 AND department = 'Sales'
);

-- The table first selects all the sales managers from employees, and returns
-- a list of all of their specific hire dates. After that, it returns all the
-- full rows from employees for all employees that were hired on the same date
-- as the sales managers.

-- 2. Write the query above without nesting.

SELECT *
FROM employees e1, employees e2
WHERE e2.title = 'Manager'
AND e2.department = 'Sales'
AND e1.hiredate = e2.hiredate;
