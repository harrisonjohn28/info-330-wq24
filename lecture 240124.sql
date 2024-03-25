-- Try to find the companies who produce both drills AND wrenches in the USA.

-- SELECT DISTINCT c.cname
-- FROM Product p1, Product p2, Company c
-- WHERE p1.manufacturer = c.cname
--   AND p2.manufacturer = c.cname
--   AND c.country = 'USA'
--   AND p1.pname = 'drill'
--   AND p2.pname = 'wrench';

-- Does not work, since no entries will be drill and wrench simultaneously.
-- You need to do a self join of at least two Product tables to find entries
-- where p1 is 'drill' and p2 is 'wrench', since it's a cross product (all
-- possible combinations will appear).

-- SELECT DISTINCT c.cname
-- FROM Company c
-- JOIN Product p1 on p1.manufacturer = c.cname
-- JOIN Product p2 ON p2.manufacturer = c.cname
-- WHERE c.country = 'USA'
--   AND p1.name = 'drill'
--   AND p2.name = 'wrench';

-- Find the products listings where said product has been sold for both
-- over $500 *and* under $300.

-- SELECT DISTINCT p.product_id, p.pname
-- FROM Product p
-- JOIN Purchase q1 on p.product_id = q1.product_id
-- JOIN Purchase q2 on p.product_id = q2.product_id
-- WHERE q1.price > 500
--   AND q2.price < 300;

-- Do the same thing, but find the highest and lowest price that
-- the product has ever been sold for.

-- SELECT p.product_id, p.pname, max(q1.price) as max, min(q2.price) as min
-- FROM Product p
-- JOIN Purchase q1 on p.product_id = q1.product_id
-- JOIN Purchase q2 on p.product_id = q2.product_id
-- WHERE q1.price > 500 -- finding max from q1 since all results are > 500
--   AND q2.price < 300 -- finding min from q2 since all results are < 300
-- GROUP BY p.product_id;

-- SUBQUERIES practice: find the average monthly earnings from the Products
-- table, a table which only has individual purchases.
-- THE VIBE: You've got to find the monthly earnings first, then find the
-- average from that afterwards.

-- SELECT avg(earnings)
-- FROM (
-- 	  SELECT year, month, sum(price*quantity) as earnings
-- 	  FROM Purchase
-- 	  GROUP BY year, month
-- ) as X;