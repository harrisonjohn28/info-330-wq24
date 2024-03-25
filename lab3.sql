-- John Harrison
-- Lucy Lu Wang
-- INFO 330
-- 30 January 2024

-- Lab 3

-- Question 1:
-- Write a nested SQL query (subqueries or CTEs okay) that returns the top 10
-- electric vehicles (make, model, year) with the highest average electric
-- range. The average electric range should be computed from the electric
-- range numbers reported in the ‘ev_wa’ table. The reason this is a nested
-- query is because each VIN (vehicle identification number–unique to each
-- specific car) may be included multiple times in the table, so you will
-- first need to compute the average range per VIN before aggregating over all
-- the VINs of each makemodel-year. In your final output table, please include
-- the model_year, make, model, number of cars of that make-model-year, and the
-- average electric range.

SELECT DISTINCT e1.vin, e1.model_year, e1.make, e1.model, e2.num_cars, e2.range
FROM ev_wa e1, (
	SELECT vin, avg(electric_range) as range, count(*) as num_cars
	FROM ev_wa
	GROUP BY vin
	ORDER BY range DESC
	LIMIT 10
) e2
WHERE e1.vin = e2.vin;

-- "vin"	"model_year"	"make"	"model"	"num_cars"	"range"
-- "5YJSA1E40L"	2020	"TESLA"	"MODEL S"	5	337.0000000000000000
-- "5YJSA1E41L"	2020	"TESLA"	"MODEL S"	5	337.0000000000000000
-- "5YJSA1E42L"	2020	"TESLA"	"MODEL S"	5	337.0000000000000000
-- "5YJSA1E43L"	2020	"TESLA"	"MODEL S"	8	337.0000000000000000
-- "5YJSA1E44L"	2020	"TESLA"	"MODEL S"	4	337.0000000000000000
-- "5YJSA1E45L"	2020	"TESLA"	"MODEL S"	9	337.0000000000000000
-- "5YJSA1E47L"	2020	"TESLA"	"MODEL S"	4	337.0000000000000000
-- "5YJSA1E48L"	2020	"TESLA"	"MODEL S"	5	337.0000000000000000
-- "5YJSA1E49L"	2020	"TESLA"	"MODEL S"	7	337.0000000000000000
-- "5YJSA1E4XL"	2020	"TESLA"	"MODEL S"	9	337.0000000000000000

-- Question 2:
-- We want to know which electric vehicles have made the most year-on year
-- improvement in electric range. Write a query using common table expressions
-- to return the vehicles (make, model) that made the most single year 
-- improvement to their electric range. Output just the top 10 largest year-on
-- year improvements. The output table should have at least seven columns (extra
-- columns are okay): make, model, year1, year2, range1 (range in year1), range2
-- (range in year2), and diff (difference in the range between the two years).

-- A single year improvement is made between adjacent years, e.g., the
-- improvement between 2022 and 2023. Hypothetically, if Toyota Rav4s had an
-- electric range of 50 in 2022 and 60 in 2023, the year-on-year improvement would
-- be 10. If the range were 60 in 2022 and 50 in 2023, the year-on-year improvement
-- would be -10 (not an improvement at all).

WITH YoY as (
	SELECT DISTINCT make, model, model_year, avg(electric_range) as range
	FROM ev_wa
	GROUP BY make, model, model_year
),
diffs as (
	SELECT v1.make, v1.model, 
	v1.model_year as year1, v2.model_year as year2,
	v1.range as range1, v2.range as range2,
	(v2.range - v1.range) as diff
	FROM YoY v1, YoY v2
	WHERE v1.model_year = (v2.model_year - 1)
)
SELECT *
FROM diffs
ORDER BY diff DESC
LIMIT 10;

-- "make"	"model"	"year1"	"year2"	"range1"	"range2"	"diff"
-- "KIA"	"SOUL EV"	2019	2020	0.00000000000000000000	331.2342105263157895	331.23421052631578950000
-- "MERCEDES-BENZ"	"GLC-CLASS"	2019	2020	10.0000000000000000	331.2342105263157895	321.2342105263157895
-- "MINI"	"COUNTRYMAN"	2019	2020	12.0000000000000000	331.2342105263157895	319.2342105263157895
-- "PORSCHE"	"CAYENNE"	2019	2020	13.0000000000000000	331.2342105263157895	318.2342105263157895
-- "BMW"	"740E"	2019	2020	14.0000000000000000	331.2342105263157895	317.2342105263157895
-- "PORSCHE"	"PANAMERA"	2019	2020	14.0000000000000000	331.2342105263157895	317.2342105263157895
-- "BMW"	"530E"	2019	2020	15.3561643835616438	331.2342105263157895	315.8780461427541457
-- "SUBARU"	"CROSSTREK"	2019	2020	17.0000000000000000	331.2342105263157895	314.2342105263157895
-- "VOLVO"	"XC90"	2019	2020	17.0000000000000000	331.2342105263157895	314.2342105263157895
-- "VOLVO"	"XC60"	2019	2020	17.0000000000000000	331.2342105263157895	314.2342105263157895

-- Question 3:
-- Write a query to return the number of unique electric vehicles (identified
-- by unique VIN) per census tract in Washington state along with the median
-- household income of that census tract in 2020, for only tracts where the 
-- 2020 median household income is available. The query should return only the
-- top 10 tracts ordered by highest median income. The output table should have
-- three columns: census_tract, num_cars (number of unique cars in that tract), 
-- and median_hh_income_2020.

WITH wa_tracts as (
 	SELECT DISTINCT e.census_tract, 
	i.census_geo_id, i.median_hh_income_2020
	FROM ev_wa e
	JOIN income i ON SUBSTRING(i.census_geo_id, 8) = e.census_tract
	WHERE i.median_hh_income_2020 IS NOT NULL
),
wa_counts as (
	SELECT e.census_tract, count(e.vin) as num_cars
	FROM ev_wa e, wa_tracts t
	WHERE e.census_tract = t.census_tract
	GROUP BY e.census_tract
	ORDER BY num_cars DESC
)
SELECT t.census_tract, c.num_cars, t.median_hh_income_2020
FROM wa_tracts t
JOIN wa_counts c on t.census_tract = c.census_tract
ORDER BY t.median_hh_income_2020 DESC
LIMIT 10;

-- "census_tract"	"num_cars"	"median_hh_income_2020"
-- "53033024602"	292	250001
-- "53033024100"	390	250001
-- "51107611029"	2	250001
-- "53033004101"	246	250001
-- "53033024601"	352	245278
-- "53033032217"	234	245099
-- "51059415600"	1	244028
-- "53033023902"	208	240833
-- "06013351200"	1	236923
-- "53033032215"	310	235821

-- Question 4:
-- Modify your previous query to return the top 10 and bottom 10 tracts
-- by median 2020 household income, and also identify the cities associated with
-- these tracts (can be two separate queries for top 10 and bottom 10).

WITH wa_tracts as (
 	SELECT DISTINCT e.census_tract, e.city,
	i.census_geo_id, i.median_hh_income_2020
	FROM ev_wa e
	JOIN income i ON SUBSTRING(i.census_geo_id, 8) = e.census_tract
	WHERE i.median_hh_income_2020 IS NOT NULL
),
wa_counts as (
	SELECT e.census_tract, count(e.vin) as num_cars
	FROM ev_wa e, wa_tracts t
	WHERE e.census_tract = t.census_tract
	GROUP BY e.census_tract
	ORDER BY num_cars DESC
)
SELECT t.census_tract, c.num_cars, t.median_hh_income_2020, t.city
FROM wa_tracts t
JOIN wa_counts c on t.census_tract = c.census_tract
ORDER BY t.median_hh_income_2020 DESC -- removing DESC returns bottom 10
LIMIT 10;

-- Top 10:
-- "census_tract"	"num_cars"	"median_hh_income_2020"	"city"
-- "53033024100"	1560	250001	"Clyde Hill"
-- "53033024602"	292	250001	"Mercer Island"
-- "53033024100"	1560	250001	"Yarrow Point"
-- "53033004101"	246	250001	"Seattle"
-- "53033024100"	1560	250001	"Hunts Point"
-- "53033024100"	1560	250001	"Kirkland"
-- "51107611029"	2	250001	"Aldie"
-- "53033024601"	352	245278	"Mercer Island"
-- "53033032217"	234	245099	"Sammamish"
-- "51059415600"	1	244028	"Alexandria"

-- Bottom 10:
-- "census_tract"	"num_cars"	"median_hh_income_2020"	"city"
-- "53075000100"	1	12473	"Pullman"
-- "53063003500"	19	14280	"Spokane"
-- "53075000601"	7	17294	"Pullman"
-- "53075000602"	6	21024	"Pullman"
-- "53075000500"	5	21696	"Pullman"
-- "53033005305"	43	21781	"Seattle"
-- "53077002005"	7	21783	"Sunnyside"
-- "29510127000"	1	21875	"Saint Louis"
-- "53037975404"	12	22080	"Ellensburg"
-- "53077000100"	7	23590	"Yakima"

-- Is there a difference in the number of electric vehicles in the two sets of
-- tracts? In the cities associated with the two sets of tracts? Do these results
-- match your expectations?

-- There's a stark difference in that there are significantly fewer electric
-- vehicles in the tracts rated at the bottom 10 for household income. In
-- terms of the cities themselves, it appears there's some overlap with
-- neighborhoods in Seattle, but most of the bottom 10 are tracts on the
-- east side of the state, compared to the top ten being around Seattle
-- or the east side of Lake Washington.

