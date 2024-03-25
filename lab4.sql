-- John Harrison
-- Lucy Lu Wang
-- INFO 330
-- 16 February 2024

-- Lab 4

-- 1.a. Write a series of CREATE and INSERT INTO statements that map the data
-- from the ‘alzheimers’ table into tables with the following schema (each
-- table will have the same number of rows since we are not doing any data
-- depulication or cleaning):

-- results(*id*, loc_abbrev, source, class, topic, *question_id*)
-- questions(*id, question_id*, question)
-- responses(id, question_id, data_value, data_value_unit)

-- Please observe the following in your CREATE and INSERT statements:
-- • The attribute names should be the same as the attributes from the 
-- ‘alzheimers’ table.
-- • (id, question_id) should be multikey in the ‘results’ table.
-- • (id, question_id) should be multikey in the ‘questions’ table.
-- • Each row in the ‘questions’ table should correspond to an entry in the
-- ‘results’ table.
-- • Each row in the ‘responses’ table should correspond to an entry in the
-- ‘questions’ table.

CREATE TABLE results (
	id BIGINT PRIMARY KEY,
	loc_abbrev VARCHAR(20),
	source VARCHAR(20),
	class TEXT,
	topic TEXT,
	question_id VARCHAR(20),
	UNIQUE(id, question_id)
);

INSERT INTO results(id, loc_abbrev, source, class, topic, question_id) (
	SELECT id, loc_abbrev, source, class, topic, question_id
	FROM alzheimers
);

CREATE TABLE questions (
	id BIGINT PRIMARY KEY,
	question_id VARCHAR(20),
	question TEXT,
	UNIQUE(id, question_id),
	FOREIGN KEY (id, question_id)
		REFERENCES results(id, question_id)
);

INSERT INTO questions(id, question_id, question) (
	SELECT id, question_id, question
	FROM alzheimers
);

CREATE TABLE responses (
	id BIGINT PRIMARY KEY,
	question_id VARCHAR(20),
	data_value VARCHAR(100),
	data_value_unit VARCHAR(20),
	UNIQUE(id, question_id),
	FOREIGN KEY (id, question_id)
		REFERENCES questions(id, question_id)
);

INSERT INTO responses(id, question_id, data_value, data_value_unit) (
	SELECT id, question_id, data_value, data_value_unit
	FROM alzheimers
);

-- 1.b.  I have not specified any keys for the ‘responses’ table. Please
-- propose a (primary) key/set of keys, implement them in the CREATE statement
-- for your ‘responses’ table, and add a comment to describe why you picked
-- those attribute(s) as keys.

-- I chose to implement the same multikey setup from the relation 'questions',
-- being id as the primary key and id/question_id as the unique multikey. The
-- reason I chose to do this was to maintain consistency across relations, such
-- that every row in the responses table not only had to match the questions
-- table, but could be referenced in the exact same way using SELECT statements
-- and could be paired using join statements without hassle.

-- 1.c. What foreign key relations would be appropriate between these tables?
-- Please propose and implement in your CREATE statements, and add a comment
-- to describe why you picked those foreign key relations.

-- For similar reasons, I used the same (*id*, question_id) foreign key schema
-- across all three relations. There was consistency established in the results
-- table, and since both of these eventually link back to results, it would make
-- sense to be able to trace the route back by similar means. The only funky
-- thing I changed was the fact that responses references questions and not
-- results with its foreign keys, but it made sense in my head to work
-- backwards, with each response having an associated question, and each
-- question being referenced from a preexisting result.


-- 2. Write a series of CREATE and INSERT INTO statements to map the data from
-- this CSV file into a table with the following schema:

-- EV(*id*, vin, county, city, state, postal_code, model_year, make, model,
-- ev_type, electric_range, base_msrp, census_tract)

-- Recall that the steps for loading data from a file:

-- (1) create a table schema
CREATE TABLE EV (
	id INT PRIMARY KEY,
	vin TEXT,
	county TEXT,
	city TEXT,
	state CHAR(2),
	postal_code INT,
	model_year INT,
	make TEXT,
	model TEXT,
	ev_type TEXT,
	electric_range INT,
	base_msrp INT,
	census_tract BIGINT
);

-- (2) create a temporary table that matches the schema of the CSV file
CREATE temporary TABLE temp (
	VIN VARCHAR(10), 		-- only up to first 10 digits are present in table
	County TEXT,
	City TEXT,
	State VARCHAR(2),		-- forcing two letter state abbreviations
	Postal_Code INT,
	Model_Year INT,
	Make TEXT,
	Model TEXT,	
	Electric_Vehicle_Type TEXT,
	Clean_Alternative_Fuel_Vehicle_CAFV_Eligibility TEXT,
	Electric_Range INT,
	Base_MSRP INT,
	Legislative_District INT,
	DOL_Vehicle_ID INT,
	Vehicle_Location TEXT,
	Electric_Utility TEXT,
	Census_Tract BIGINT
);

-- one line:
-- CREATE temporary TABLE temp (VIN VARCHAR(10), County TEXT, City TEXT, State VARCHAR(2), Postal_Code INT, Model_Year INT, Make TEXT, Model TEXT,	Electric_Vehicle_Type TEXT, Clean_Alternative_Fuel_Vehicle_CAFV_Eligibility TEXT, Electric_Range INT, Base_MSRP INT, Legislative_District INT, DOL_Vehicle_ID INT, Vehicle_Location TEXT, Electric_Utility TEXT, Census_Tract BIGINT);

-- (3) copy the data from the file to the temporary table

\copy temp(
	VIN, County, City, State, Postal_Code, Model_Year, Make, Model,
	Electric_Vehicle_Type, Clean_Alternative_Fuel_Vehicle_CAFV_Eligibility,
	Electric_Range, Base_MSRP, Legislative_District, DOL_Vehicle_ID, 
	Vehicle_Location, Electric_Utility,	Census_Tract
) FROM 'C:\Users\harri\Documents\INFO 330\Electric_Vehicle_Population_Data-1.csv'
CSV HEADER;

-- one line:
-- \copy temp(VIN, County, City, State, Postal_Code, Model_Year, Make, Model, Electric_Vehicle_Type, Clean_Alternative_Fuel_Vehicle_CAFV_Eligibility, Electric_Range, Base_MSRP, Legislative_District, DOL_Vehicle_ID, Vehicle_Location, Electric_Utility,	Census_Tract) FROM 'C:\Users\harri\Documents\INFO 330\Electric_Vehicle_Population_Data-1.csv' CSV HEADER;

-- (4) insert data from the temporary table to the final table 

INSERT INTO EV(id, vin, county, city, state, postal_code, model_year,
			  make, model, ev_type, electric_range, base_msrp, census_tract)
SELECT dol_vehicle_id, vin, county, city, state, postal_code, model_year, make,
	   model, electric_vehicle_type, electric_range, base_msrp, census_tract
FROM temp;

-- one line:
-- INSERT INTO EV(id, vin, county, city, state, postal_code, model_year, make, model, ev_type, electric_range, base_msrp, census_tract) SELECT dol_vehicle_id, vin, county, city, state, postal_code, model_year, make, model, electric_vehicle_type, electric_range, base_msrp, census_tract FROM temp;

-- (5) drop the temporary table.

DROP TABLE IF EXISTS temp;


-- BONUS: Write the command to export data from the ‘alzheimers’ table in your
-- database to a CSV file with headers.

\copy alzheimers 
TO 'C:\Users\harri\Documents\INFO 330\alzheimers.csv'
CSV HEADER;

-- one line:
-- \copy alzheimers TO 'C:\Users\harri\Documents\INFO 330\alzheimers.csv' CSV HEADER;
