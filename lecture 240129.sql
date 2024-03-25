-- John Harrison
-- Lucy Lu Wang
-- INFO 330
-- 29 January 2024

-- Subqueries (con't)
-- Find all manufacturers that make *at least one* product that has been sold
-- at a price greater than $500.
-- 'At least one' is an existential quantifier; if any of the associated rows
-- fulfill the condition.

-- WHERE EXISTS syntax
SELECT r.manufacturer
FROM Product r
WHERE EXISTS (
	SELECT *
	FROM Purchase p
	WHERE r.product_id = p.product_id
		AND p.price > 500
);

-- Unnested syntax
SELECT DISTINCT r.manufacturer
FROM Product r, Purchase p
WHERE r.product_id = p.product_id
	AND p.price > 500;

-- IN syntax
SELECT r.manufacturer
FROM Product r
WHERE r.product_id IN (
	SELECT p.product_id
	FROM Purchase p
	WHERE p.price > 500
);

-- Find all manufacturers that make *ONLY* products with price < 500.
-- Universal quantifier: Everything satisfies the condition, not just one row.

-- 1. Find other manufacturers that make at least one product with price >= 500,
-- 2. and then use NOT IN to find the difference.

SELECT DISTINCT manufacturer          -- Returning all manufacturer names that do
FROM Product                          -- not appear in the nested set below.
WHERE manufacturer NOT IN (
	SELECT r.manufacturer             -- Building a set where all manufactures
	FROM Product r, Purchase p        -- have one product over $500 and
	WHERE r.product_id = p.product_id -- returning just the manufacturer names.
		AND p.price >= 500
);

--Monotonic queries:

-- Find all products by ACME that have been sold at < $10.    YES
----- Any product can be added with an entry
SELECT p.product_id, p.pname
FROM Product p, Purchase r
WHERE p.product_id = r.product_id
	AND p.manufacturer = 'Acme'
	AND r.price < 10;

-- Find manufacturers that have only sold hammers and screwdrivers  NO
----- If you have a manufacturer that ends up selling anything
----- OTHER than those two, then they'd get dropped from the table

SELECT p1.manufacturer
FROM Product p1, Product p2, Purchase r1, Purchase r2
WHERE p1.product_id = r1.product_id	   -- Self joins with Purchase tables
AND p2.product_id = r2.product_id	   -- to ensure whatever we pull away
AND p1.pname = 'hammer'				   -- from subquery has actually made
AND p2.pname = 'screwdriver'		   -- a sale.
AND p1.manufacturer NOT IN (
	SELECT DISTINCT p.manufacturer     -- Finding all the entries where
	FROM Product p, Purchase r		   -- a sale was made other than what
	WHERE p.product_id = r.product_id  -- we want, selecting those
		AND p.pname != 'hammer' 	   -- manufacturers, and then selecting
		AND p.pname != 'screwdriver'   -- all those that *aren't* here
);

-- Find month-years that have more than $10000 of total sales       NO
----- Semantically; cannot be expressed exclusively by a query with
----- SELECT-FROM-JOIN-WHERE clause; requires an aggregator.

SELECT month, year, sum(price*quantity) as total_sale
FROM purchase
GROUP BY month, year
HAVING sum(price*quantity) > 10000;

-- Find all products that have been sold at <$10 *AND* >$50         YES
----- Just because an item has been sold *BETWEEN* $10 and $50,
----- that does not preclude it from having been sold under $10
----- and over $50 in the past.

SELECT DISTINCT r1.product_id, p.pname
FROM Purchase r1, Purchase r2, Product p
WHERE r1.product_id = r2.product_id
AND r1.product_id = p.product_id
AND r1.price < 10
AND r2.price > 50;

-- Finding witnesses

-- For each country, find the most expensive product made in that country

-- Find max price first...
SELECT x.country, max(y.price) AS maxprice
FROM Company x, Purchase y, Product z
WHERE y.product_id = z.product_id
	AND z.manufacturer = x.cname
	AND x.country IS NOT NULL
GROUP BY x.country

-- ... then use as a subquery to find the products.
SELECT c.country, p.product_id, p.pname, r.price, m.maxprice
FROM Company c, Product p, Purchase r, 
(
	SELECT x.country, max(y.price) AS maxprice
	FROM Company x, Purchase y, Product z
	WHERE y.product_id = z.product_id
	AND z.manufacturer = x.cname
	AND x.country IS NOT NULL
	GROUP BY x.country
) m
WHERE p.product_id = r.product_id
AND p.manufacturer = c.cname
AND c.country = m.country
AND r.price = m.maxprice;

-- SELECT c1.country, p1.pname, r1.price, max(r2.price)
-- FROM Company c1, Company c2,
-- 	 Product p1, Product p2,			-- Only done with self joins!
-- 	 Purchase r1, Purchase r2
-- WHERE c1.cname = p1.manufacturer		-- this one is TRAAAASH
-- AND p1.product_id = r1.product_id	-- since it's a very expensive operation
-- AND c2.cname = p2.manufacturer		-- in terms of both time AND space as a
-- AND p2.product_id = r2.product_id	-- massive self join of SIX relations.
-- AND c1.country = c2.country
-- GROUP BY c1.country, p1.pname, r1.price
-- HAVING r1.price = max(r2.price);
