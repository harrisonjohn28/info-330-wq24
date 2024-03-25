-- John Harrison, Paul Garces, Mekias Kebede, Baron Cabudol
-- Lucy Lu Wang
-- INFO 330
-- 7 March 2024

-- Team Assignment 4

-- Q0: What is the name of the database on the class server in which our schema
-- can be found?

-- johnh360

-- Q1: Provide a list of CREATE TABLE statements implementing the schema.

DROP TABLE IF EXISTS Codes, Calls, EventLoc, Dispatch_Sites, Dispatches, Caller_Identity;

CREATE TABLE Codes (
	call_code varchar(5) PRIMARY KEY,
	severity text,
	descriptor text
); --JH

CREATE TABLE Calls (
	callid int PRIMARY KEY,
    date date,
	datetime timestamp,
	priority int,
	call_code varchar(5),
	origin_precinct varchar(2),
	issue text,
	calltype text,
	FOREIGN KEY (call_code) REFERENCES Codes(call_code)
); --JH

CREATE TABLE EventLoc(
	call_id int PRIMARY KEY,
	zipcode  VARCHAR(5),
	precinct VARCHAR(2),
	Address TEXT,
	city_sector VARCHAR(5),
	loc_details TEXT,
	longitude FLOAT,
	latitude FLOAT,
	FOREIGN KEY(call_id) REFERENCES Calls(callid)
); --PG

CREATE TABLE Dispatch_Sites (
	dispatch_site text PRIMARY KEY,
	site_name TEXT,
	zipcode VARCHAR(5),
	latitude FLOAT,
	longitude FLOAT,
	street_address TEXT,
	precinct TEXT,
	department TEXT,
	city_sector VARCHAR(5)
); --BC

CREATE TABLE Dispatches (
	respondent_id int,
	callid int,
	response text,
	dispatch_site text,
	department text,
	date_of_year date,
	dispatch_time timestamp,
	arrival_time timestamp,
	FOREIGN KEY (callid) REFERENCES Calls(callid),
	FOREIGN KEY (dispatch_site) REFERENCES Dispatch_Sites(dispatch_site),
	PRIMARY KEY(callid, respondent_id)
); -- all of us

CREATE TABLE Caller_Identity (
	callid int PRIMARY KEY,
	physical_state text,
	emotional_state text,
	is_armed boolean,
	caller_description varchar(200),
	ended_call bool,
	age int,
	race text,
	gender text,
	FOREIGN KEY (callid) REFERENCES Calls(callid)
); --MK

-- Q2: a list of 10 SQL statements using your schema, along with the English
-- question it implements.

-- John Harrison:
-- Q06: A city councilmember might ask what the average speed of dispatches are by
-- department on any given day.

SELECT date_of_year as date, department, 
       avg(arrival_time - dispatch_time) as average_time
FROM Dispatches
GROUP BY date_of_year, department;

-- Q10: A researcher might wonder, out of all calls in a day, who’s calling most
-- often (grouping by day/race, day/gender).

SELECT c.date, id.race, count(*)
FROM Calls c, Caller_Identity id
WHERE c.callid = id.callid
GROUP BY c.date, id.race;

-- Q02: A resident may ask what kind of crime (codes) are most prevalent 
-- around the city?
WITH callcounts AS (
	SELECT call_code, count(*) as incidents
	FROM Calls
	GROUP BY call_code
)
SELECT o.descriptor, o.severity, c.incidents
FROM Codes o
JOIN callcounts c on o.call_code = c.call_code
GROUP BY o.descriptor, o.severity
ORDER BY c.incidents;


-- Baron Cabudol:
-- Q20: A news reporter would like to know the description of the perpetrator
-- if the 911 call type was a crime, as well as what area it was made from

SELECT ci.callid, ci.caller_description AS perpetrator_description, el.zipcode AS call_area
FROM Calls c
INNER JOIN EventLoc el ON c.callid = el.call_id
INNER JOIN Caller_Identity ci ON c.callid = ci.callid
WHERE c.calltype = 'crime';

-- Q18: A news reporter reporting 911 calls relating to crime would like to
-- know where the crimes that had armed perpetrators were located 

SELECT el.zipcode AS call_area
FROM Calls c
INNER JOIN EventLoc el ON c.callid = el.call_id
INNER JOIN Caller_Identity ci ON c.callid = ci.callid
WHERE c.calltype = 'crime' AND ci.is_armed = true;

-- Q08: A crisis coordinator might wonder, out of all callers, how many are
-- armed when they call

SELECT COUNT(*) AS armed_callers_count
FROM Caller_Identity
WHERE is_armed = TRUE;


-- Mekias Kebede:
-- Q05: A think tank may ask what are the most common characteristics of a
-- caller (age,race,gender) for each crime type?
select count(ci.age), count(ci.race), count(ci.gender)
from caller_identity ci
join calls cs on ci.callid = cs.callid
group by call_code;

-- Q04: Where are the most common dispatch sites dispatchers are coming from?
select count(ds.department) as num_dispatches, ds.department
from dispatches ds
group by department;


-- Paul Garces: 
-- QXX: What precincts produce the most calls?
SELECT origin_precinct AS precinct, COUNT(call_id) AS call_count
FROM Calls
GROUP BY origin_precinct
ORDER BY call_count DESC;

-- QXX: What is the count of each call priority in each city sector?
SELECT priority, city_sector, COUNT(*) AS priority_count
FROM Calls
JOIN EventLoc ON Calls.callid = EventLoc.call_id
GROUP BY priority, city_sector
ORDER BY city_sector, priority;

-- Q3: a list of 3-5 demo queries that return (minimal) sensible results. Please
-- specify the team member responsible for each.

-- John Harrison:

DROP TABLE IF EXISTS Dispatches2;

CREATE TABLE Dispatches2 (
	respondent_id int,			-- Creating a new table for the exercise of
	callid int,					-- testing purposes; if it was in Dispatches
	response text,				-- originally, would've needed to generate
	dispatch_site text,			-- full dispatch_site entries in Dispatch_Sites
	department text,			-- and full callid entries in Calls, when we're
	date_of_year date,			-- really only looking to test with values
	dispatch_time timestamp,	-- exclusive to this table.
	arrival_time timestamp,
	PRIMARY KEY(callid, respondent_id)
);

INSERT INTO Dispatches2 (respondent_id, callid, response, dispatch_site,
						department, date_of_year, dispatch_time, arrival_time)
VALUES
(16,1,'put out fire','SFD 09','fire', '2020-07-04', '2020-07-04 04:05:06', '2020-07-04 05:00:00'),
(17,2,'took to hospital','UW Medical','medical','2020-07-04','2020-07-04 12:05:06','2020-07-04 13:00:00'),
(18,3,'emt visit','UW Medical','medical','2020-07-04','2020-07-04 13:05:06','2020-07-04 14:50:00'),
(19,4,'took to hospital','SFD 10','fire','2020-07-04','2020-07-04 18:05:06','2020-07-04 19:00:00'),
(20,5,'arrest','Capitol Hill Precinct','police','2020-07-04','2020-07-04 21:05:06','2020-07-04 23:00:00'),
(21,6,'arrest','Capitol Hill Precinct','police','2021-10-31','2021-10-31 21:05:06','2021-10-31 22:14:06'),
(22,7,'no suspect found','Ghostbusters','police','2021-10-31','2021-10-31 21:05:06','2021-10-31 21:55:37'),
(23,8,'hooligans dispelled','UWPD','police','2021-10-31','2021-10-31 21:05:06','2021-10-31 21:12:04'),
(24,9,'witch captured','Wizards of Waverly Place','police','2021-10-31','2021-10-31 21:05:06','2021-10-31 21:59:50'),
(25,10,'antidote administered','UW Medical','medical','2021-10-31','2021-10-31 21:05:06','2021-11-01 0:00:01'),
(26,11,'party revived','Harborview','medical','2022-12-31','2022-12-31 23:59:00','2022-12-31 23:59:59'),
(27,12,'rushed to hospital','UW Medical','medical','2022-12-31','2022-12-31 23:59:00','2023-01-01 0:15:35'),
(28,13,'rushed to hospital','Harborview','medical','2022-12-31','2022-12-31 23:59:00','2023-01-01 1:22:17'),
(29,14,'administered narcan','UW Medical','medical','2022-12-31','2022-12-31 23:59:00','2023-01-01 0:12:07'),
(30,15,'wellness check','Harborview','medical','2022-12-31','2022-12-31 23:59:00','2023-01-01 0:22:34');

-- Five visits across three unique dates with multiple testing scenarios,
-- including wraparound from one day to another past midnight, different
-- ratios of fire to medical to police, and lost departments alltogether
-- (eg. fire is only present on July 4, there are *only* medical responses
-- on December 31st.)

SELECT date_of_year as date, department, 
       avg(arrival_time - dispatch_time) as average_time
FROM Dispatches2
GROUP BY date_of_year, department
ORDER BY date_of_year;

-- Returns:

-- "date"		"department""average_time"
-- "2020-07-04"	"fire"		"00:54:54"
-- "2020-07-04"	"medical"	"01:19:54"
-- "2020-07-04"	"police"	"01:54:54"
-- "2021-10-31"	"police"	"00:45:18.25"
-- "2021-10-31"	"medical"	"02:54:55"
-- "2022-12-31"	"medical"	"00:27:30.4"

-- Mekias Kebede:

insert into codes
values('0265T', 'high', 'person not breathing');
insert into calls
values(24,'03-21-2023','02:23:00','5','0265T','P5','heart attack', 'ambulance');
insert into Dispatch_Sites
values('456', 'Valley Medical', '9805', 5.232, 178.3432,'456 Taylor Medical PL','HOSP65', 'medical', 'Rtn');
insert into dispatches
values(132, 24, 'Renton', '456', 'medic', '02:23:00', '02:30:00');

insert into codes
values('067T', 'high', 'fire');
insert into calls
values(67, '07-13-2013',  '06:00:00', 3, '067T', 'FD', 'fire', 'fire');
insert into dispatch_sites
values('457', 'Renton Fire', 9805, 7.6, 3.4, 'Baker St 834 Dpt', 'Fire465', 'Fire', 'F465');
insert into dispatches
values(1822, 67, 'Renton', '457', 'fire', '06:00:00', '06:15:00');

insert into codes
values('068T', 'high', 'fire');
insert into calls
values(74, '07-13-2013',  '06:00:00', 3, '068T', 'FD', 'fire', 'fire');
insert into dispatch_sites
values('458', 'Renton Fire', 9805, 7.6, 3.4, 'Baker St 834 Dpt', 'Fire465', 'Fire', 'F465');
insert into dispatches
values(9450, 74, 'Renton', '458', 'police', '10:45:00', '10:48:00');

insert into codes
values('069T', 'high', 'fire');
insert into calls
values(90, '07-13-2013',  '06:00:00', 3, '069T', 'FD', 'fire', 'fire');
insert into dispatch_sites
values('893', 'Renton Fire', 9805, 7.6, 3.4, 'Baker St 834 Dpt', 'Fire465', 'Fire', 'F465');
insert into dispatches
values(6156, 90, 'Bellvue', '893', 'medic', '06:36:00', '07:32:00');

insert into codes
values('079T', 'high', 'fire');
insert into calls
values(56, '07-13-2013',  '06:00:00', 3, '079T', 'FD', 'fire', 'fire');
insert into dispatch_sites
values('894', 'Renton Fire', 9805, 7.6, 3.4, 'Baker St 834 Dpt', 'Fire465', 'Fire', 'F465');
insert into dispatches
values(3007, 56, 'Bellvue', '894', 'medic', '09:56:00', '07:36:00');

select count(ds.department) as num_dispatches, ds.department
from dispatches ds
group by department;

-- Returns:

-- "num_dispatches"	"department"
-- 3				"medic"
-- 1				"fire"
-- 1				"police"


-- Baron Cabudol:

INSERT INTO Codes (call_code, severity, descriptor)
VALUES
('CODE1', 'Low', 'Non-emergency'),
('CODE2', 'Medium', 'Emergency'),
('CODE3', 'High', 'Urgent');

INSERT INTO Calls (callid, date, timestamp, priority, call_code, origin_precinct, issue, calltype)
VALUES
(24, '2024-03-08', '12:00:00', 1, 'CODE1', '01', 'Heart attack symptoms reported', 'medical'),
(67, '2024-03-08', '12:15:00', 2, 'CODE2', '03', 'Fire in the neighborhood reported', 'fire'),
(74, '2024-03-08', '12:30:00', 3, 'CODE2', '02', 'Fire in the neighborhood reported', 'fire'),
(90, '2024-03-08', '12:45:00', 1, 'CODE2', '05', 'Fire in the neighborhood reported', 'fire'),
(56, '2024-03-08', '13:00:00', 2, 'CODE2', '04', 'Fire in the neighborhood reported', 'fire');


INSERT INTO Caller_Identity (callid, physical_state, emotional_state, is_armed, caller_description, ended_call, age, race, gender)
VALUES
(24, 'stable', 'calm', FALSE, 'Caller reported heart attack symptoms', FALSE, 45, 'White', 'Male'),
(67, 'unknown', 'panicked', TRUE, 'Caller reported fire in the neighborhood', FALSE, 45, 'White', 'Female'),
(74, 'unknown', 'agitated', FALSE, 'Caller reported fire in the neighborhood', FALSE, 45, 'White', 'Male'),
(90, 'stable', 'anxious', TRUE, 'Reported Home Invasion', FALSE, 45, 'White', 'Female'),
(56, 'unknown', 'panicked', FALSE, 'Caller reported fire in the neighborhood', FALSE, 45, 'White', 'Male');

SELECT COUNT(*) AS armed_callers_count
FROM Caller_Identity
WHERE is_armed = TRUE;

-- Returns:

-- "armed_callers_count"
-- 2


-- Paul Garces: 

-- insert statements done through pSQL command line; data present in 'paulsg25_db'

SELECT origin_precinct AS precinct, COUNT(callid) AS call_count
FROM Calls
GROUP BY origin_precinct
ORDER BY call_count DESC

-- OUTPUT:
-- "precinct"	"call_count"
-- "NE"			3
-- "S"			2
-- "NW"			1
-- "W"			1
-- "SW"			1
-- "SE"			1

SELECT priority, city_sector, COUNT(*) AS priority_count
FROM Calls
JOIN EventLoc ON Calls.callid = EventLoc.call_id
GROUP BY priority, city_sector
ORDER BY city_sector, priority;

-- OUTPUT:
-- "priority"	"city_sector"	"priority_count"
-- 1			"BOY"			1
-- 1			"EDWARD"		1
-- 2			"FRANK"			1
-- 3			"FRANK"			1
-- 5			"MARY"			1
-- 2			"QUEEN"			1
-- 5			"QUEEN"			1
-- 4			"UNION"			1
-- 5			"WILLIAM"		1

-- Q4: reflection on what you learned and challenges

-- The design and implementation of our SQL database began with an important
-- first step in understanding our business case problem; 911 dispatcher data
-- (public safety industry). The step was crucial in the formation of everything
-- that stemmed afterwards because we laid a foundation for who our typical users
-- would be; Community Members, Residents, Investors, Law Enforcement,
-- Researchers, Journalists/Media Outlets, and or City council/government
-- officials. As well as which representative questions (queries) we would want
-- our typical users to be able to answer. From this strong base we were able to
-- pivot into creating an initial entity relationship diagram (ERD) which is a
-- task that one can make as hard or as easy as one would like depending on the
-- kinds of questions we need or want to be answered from our database. The
-- database schema design was ultimately difficult for us because of the wide
-- freedom we had to work from, this forced us to think very carefully and be
-- meticulous on how we wanted to structure the ERD to answer the representative
-- questions we proposed earlier in the project process. 

-- This required us to make careful considerations of entities, attributes,
-- relationships, and constraints. Through this process, we gained a deeper
-- understanding of entity-relationship modeling, which facilitated the
-- translation of conceptual models into the physical database structures we
-- implemented once we started to actually write the SQL code. Once we revised
-- our ERD and began coding, we faced another unique challenge in that to work
-- collaboratively on our code base; particularly creating the physical tables in
-- pgAdmin we had to all meet in person and work from one groups members laptop
-- because we couldn’t individually work on assignment parts necessary because of
-- the foreign key relationships among all of the tables so it was hard to
-- initially figure how we would exactly divide up the tasks without being
-- inefficient. Another potential difficulty we faced was SQL Query Optimization.
-- We spent most of our time just trying to finish and get our queries to work
-- rather than taking time to think at all about crafting efficient queries for
-- improving database performance. Learning about query optimization techniques
-- such as indexing, query rewriting, and analysis is assumed to be an
-- instrumental part in enhancing a database's responsiveness and scalability
-- especially in industry. We also had trouble with creating some of our demo
-- data to test if some of our queries actually work and potential edge cases.
-- The difficulty here came from interpreting and managing the complex
-- relationships between our entities and resolving inconsistencies in data
-- dependencies such as foreign keys between relations. The way we addressed
-- these challenges was by making sure to meet as a group in person to complete
-- nearly every project assignment, that way we resolved any confusion about our
-- data and were able to divide up our workload very effectively. We resolved
-- some data dependency problems by modifying some of our foreign key
-- relationships in order for some of our queries to be answered. In addition
-- to this we made use of SQL Documentation as we all had forgotten some of our
-- prior learned techniques. So we referred back to old powerpoint slides from
-- past lectures as well as reading SQL documentation online. Through this
-- reflective analysis, we have gained a deeper appreciation for the intricacies
-- involved in database management and the importance of adaptability,
-- collaboration, and continuous iterative improvement in overcoming expected
-- challenges. 
