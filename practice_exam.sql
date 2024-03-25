-- John Harrison
-- Lucy Lu Wang
-- INFO 330
-- 30 January 2024

-- Practice Exam

Part 1: 
-- User(*uid*, name, company)
-- Follows(*uid*, followsid, weight)

-- Write a SQL query that computes, for each company, the total number of
-- users associated with that company. Your query should return a a set of
-- (company, totalusers) pairs, sorted in decreasing order of the count. The
-- count attribute should be named totalusers.

SELECT company, count(uid) as totalusers
FROM User
GROUP BY company
ORDER BY totalusers DESC;

-- Write a SQL query that returns, for each user name, the total number of
-- followers with a weight greater than 10.
SELECT u.name, f3.topfollowers
FROM Users u, (
    SELECT f1.uid, count(f2.followsid) as topfollowers  -- OG solution,
    FROM Follows f1, Follows f2                         -- slow because of self joins but
    WHERE f1.uid = f2.followsid                         -- gets the job done
        AND f2.weight > 10
    GROUP BY f1.uid
) f3
WHERE f3.uid = u.uid;

SELECT u.name, count(f.topfollowers) as topfollowers
FROM Users u
LEFT OUTER JOIN Follows f on u.uid = f.followsid -- Having the right table match everything on the left table, even if no entries
WHERE f.weight > 10
GROUP BY u.name
ORDER BY count(*);

-- Part 2

-- Consider the following query:
SELECT distinct x.company
FROM user x, follows y
WHERE x.uid = y.uid
    AND y.score >= 50;

-- For each query below, indicate whether return the same answer or not. 
-- You only need to answer Y or N.

--  Q1: Y
      select distinct x.company
      from user x inner join follows y on (x.uid = y.uid)
      where y.score >= 50;

--  Q2:
      select distinct x.company
      from user x left outer join follows y on (x.uid = y.uid)
      where y.score >= 50;

