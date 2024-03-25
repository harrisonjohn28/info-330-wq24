-- John Harrison
-- Lucy Lu Wang
-- INFO 330
-- 7 February 2024

-- Midterm

-- I attest that I did not communicate with anyone other than the instructors
-- about the questions on this midterm, and that all work is my own.

-- Name: John Harrison
-- Signature: John Harrison
-- Date: 02/07/2024

-- 1. False
-- 2. True
-- 3. True
-- 4. False
-- 5. True
-- 6. False
-- 7. False
-- 8. True
-- 9. False
-- 10. True

-- 11. Write a SQL query that computes, for each demographic, the total number of
-- users associated with that demographic. Your query should return a set of
-- (demo, totalusers) pairs, sorted in decreasing order of the total user count. The
-- count attribute should be named totalusers.

SELECT demo, count(uid) as totalusers
FROM UserTable
GROUP BY demo
ORDER BY count(uid) DESC;

-- 12. Write a SQL query that returns, for each ip, the number of visits made to pages
-- where the revenue was greater than 10, along with the average revenue earned for that
-- IP address per visit.

-- Your answer should consist of a set of (ip, num_visits, average_rev) triples, sorted
-- in decreasing order of the average revenue.

-- Your answer should include all IP addresses, even those for which there are zero
-- corresponding visits with rev > 10. If there are no corresponding visits, the number of
-- visits should be 0, but it's ok if the average revenue is NULL. 

SELECT u.ip, count(v.uid) as num_visits, avg(v.rev) as average_rev
FROM UserTable u
LEFT JOIN Visit v ON u.uid = v.uid
WHERE v.rev > 10
GROUP BY u.ip
ORDER BY avg(v.rev);

-- 13. Write a SQL query to find all "high revenue" pages: those pages for
-- which all visits to that page made more than 10 revenue each. In other words, those
-- page for which no visit earned less than 10. Return the url and the title of these pages

WITH lowrev AS (
	SELECT *
	FROM Visit
	WHERE rev < 10
)
SELECT p.url, p.title
FROM Page p, Visit v, lowrev l
WHERE p.url = v.url
	AND p.url != l.url;

-- 14. Write a SQL query that for each url, finds the src url of the earliest visit. The
-- earliest visit is the visit with the minimum dt (datetime). Each record in the Visit table
-- (url, dt, uid, src, rev) represents a visit to page url, arriving from source src.
-- You want to find, for each url, not only the earliest dt but also the src associated
-- with the earliest dt (i.e., finding the associated witness).
-- a. In case of ties, your query should return all urls with the same earliest date
-- b. You should return tuples of the form (url, earliest_dt, earliest_src)

with early_visits AS (
	SELECT url, min(dt) as earliest_dt
	FROM Visit
	GROUP BY url
)
SELECT v.url, e.earliest_dt, v.src as earliest_src
FROM Visit v, early_visits e
WHERE v.url = e.url
	AND v.dt = e.earliest_dt;

-- 15.  Write a SQL query that returns the unique ip of all users that had a
-- highrevenue page visit (rev > 10) after arriving from a low-revenue page
-- visit (rev < 5)

with lowrev as (
	SELECT *
	FROM Visit
	WHERE rev < 5
),
highvisit as (
	SELECT v.url, v.dt, v.uid
	FROM Visit v, lowrev l
	WHERE v.src = l.url
		AND v.rev > 10
)
SELECT DISTINCT u.ip
FROM UserTable u, highvisit h
WHERE u.uid = h.uid;

-- 16. Write a SQL query that returns all pages that have been visited by at least one
-- child (demo = 'child') and ALSO has been visited by at least one person aged 40+ (demo
-- ='40+'). Your query should return a list of unique urls.

WITH childvisits AS (
	SELECT v.url
	FROM Visit v, UserTable u
	WHERE v.uid = u.uid
		AND u.demo = 'child'
)
SELECT DISTINCT v.url
FROM Visit v, UserTable u, childvisits c
WHERE v.uid = u.uid
	AND u.demo = '40+'
	AND v.url = c.url;

-- 17.a. No.
-- 17.b. Yes.
-- 17.c. Yes.
-- 17.d. No.
-- 17.e. Yes.
-- 17.f. Yes.
-- 17.g. Yes.

-- 18.a. The query will return the city name, the difference in population over 10 years for
-- that given city, and the annual rainfall for that city. The query's result will be sorted
-- by the change in population size in descending order, with the largest 10-year jumps
-- being at the front of the list.

--  *city*          popdiff     ann_rainfall
--  'Seattle'       127500      37.0
--  'San Francisco' 64500       25.0

-- 18.b. The query will create highest_population as a given year and the biggest population
-- for that year. It will then take the year, population size, city name and annual rainfall
-- for the biggest city in every year.

--  *year*  maxpop  city            ann_rainfall
--  2020    1601000 'Philadelphia'  41.5
--  2010    805500  'San Francisco' 25.0

-- 18.BONUS. The query will create diff as the city name and population difference between
-- 2010 and 2020 for all cities, regardless if they had an entry in 2010. It will then spit
-- out the annual rainfall and cloudy days for all cities in the wather set, regardless of
-- if they even had census data or not.

--  *city*          pop_diff    ann_rainfall    ann_cloudy_days
--  'Seattle'       127500      37.0            226
--  'San Francisco' 64500       25.0            105
--  'Dallas'        NULL        39.1            133
--  'Philadelphia'  NULL        41.5            160
--  'Denver'        NULL        17.0            120
--  'Los Angeles'   NULL        11.7            103
--  'Boston'        NULL        43.0            164