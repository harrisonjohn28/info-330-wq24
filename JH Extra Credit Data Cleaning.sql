-- John Harrison
-- Lucy Lu Wang
-- INFO 330
-- 11 March 2024

-- Extra Credit: Data Cleaning (INSERT, UPDATE, DELETE, and more)
-- (all actions performed on johnh360_db)

-- 1. Load Raw Data

-- Load this CSV file (data is from Seattle City Government) into your database into a staging table:

CREATE TABLE Public_Art_Data (
	sac_id text,
    project text,
    artist_first_name text,
    artist_last_name text,
    title text,
    description text,
    classification text,
    media text,
    measurements text,
    date text,
    location text,
    address text,
    latitude float,
    longitude float,
    Geolocation text
);

CREATE temporary TABLE temp (
	sac_id text,
    project text,
    artist_first_name text,
    artist_last_name text,
    title text,
    description text,
    classification text,
    media text,
    measurements text,
    date text,
    location text,
    address text,
    latitude float,
    longitude float,
    Geolocation text
);

-- as one line for pSQL:
-- CREATE temporary TABLE temp (sac_id text, project text, artist_first_name text, artist_last_name text, title text, description text, classification text, media text, measurements text, date text, location text, address text, latitude float, longitude float, Geolocation text);

\copy temp(
    sac_id, project, artist_first_name, artist_last_name, title, description,
    classification, media, measurements, date, location, address, latitude,
    longitude, Geolocation
) FROM 'C:\Users\harri\Documents\INFO 330\Public_Art_Data.csv'
CSV HEADER;

-- Unsure why I had to do this now and not beforehand, but had to reset SQLs
-- client encoding to accept UTF-8 formatted CSVs from WIN1252 encoding.
-- SET CLIENT_ENCODING TO 'utf8';

-- as one line for pSQL:
-- \copy temp(sac_id, project, artist_first_name, artist_last_name, title, description, classification, media, measurements, date, location, address, latitude, longitude, Geolocation) FROM 'C:\Users\harri\Documents\INFO 330\Public_Art_Data.csv' CSV HEADER;

INSERT INTO Public_Art_Data(sac_id, project, artist_first_name,
                            artist_last_name, title, description,
                            classification, media, measurements, 
                            date, location, address, latitude,
                            longitude, Geolocation)
SELECT sac_id, project, artist_first_name, artist_last_name, title, description,
       classification, media, measurements, date, location, address, latitude,
       longitude, Geolocation
FROM temp;

-- as one line for pSQL:
INSERT INTO Public_Art_Data(sac_id, project, artist_first_name, artist_last_name, title, description, classification, media, measurements, date, location, address, latitude, longitude, Geolocation) SELECT sac_id, project, artist_first_name, artist_last_name, title, description, classification, media, measurements, date, location, address, latitude, longitude, Geolocation FROM temp;

DROP TABLE IF EXISTS temp;

-- Once loaded, run a simple query to make sure everything works:

select * From Public_Art_Data;

-- 2. Figure out the keys

-- Write some GROUP BY statements to check keys.  Is sac_id a key?  Title?

SELECT DISTINCT *
FROM Public_Art_Data
ORDER BY sac_id;

Returns 313 rows.

-- SELECT sac_id            SELECT title            SELECT sac_id, title
-- FROM Public_Art_Data     FROM Public_Art_Data    FROM Public_Art_Data
-- GROUP BY sac_id;         GROUP BY title;         GROUP BY sac_id, title;

-- Returns 304 rows.        Returns 291 rows.       Returns 313 rows!

-- 3. Fix empty descriptions

-- Write an UPDATE statement to replace all values of the description column that
-- are the empty string ‘’ with NULL.  

SELECT *
FROM Public_Art_Data        -- Returns 34 rows; checkin what we're working
WHERE description = '''';   -- with here.

SELECT *
FROM Public_Art_Data        -- Returns 1 row.
WHERE description IS NULL;

UPDATE Public_Art_Data
SET description = NULL      -- UPDATE 34
WHERE description = '''';

SELECT *
FROM Public_Art_Data        -- Now returns 35 rows; appears to have worked!
WHERE description = ''''; 

-- 4. Create clean public art table

-- Create a new table called clean_seattle_public_art, making sac_id and title
-- the primary key and excluding entries where sac_id is NULL.

DROP TABLE IF EXISTS clean_seattle_public_art;

CREATE TABLE clean_seattle_public_art (
    sac_id VARCHAR(200),
    project VARCHAR(200),
    title VARCHAR(200),
    description text,
    media VARCHAR(300), -- set to 300 as a result of entry 228, 
    date varchar(200),  -- 'An Equal And Opposite Reaction'
    location varchar(200),
    PRIMARY KEY(sac_id, title)
);

INSERT INTO clean_seattle_public_art(sac_id, project, title, description,
                                    media, date, location)
SELECT DISTINCT sac_id, project, title, description, media, date, location
FROM Public_Art_Data
WHERE sac_id IS NOT NULL;

SELECT * from clean_seattle_public_art;

-- 5. Create an artist table

-- Create a table seattle_public_art_artist, making the primary key the
-- combination of artist_first_name and artist_last_name.

DROP TABLE IF EXISTS seattle_public_art_artist;

CREATE TABLE seattle_public_art_artist(
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    suffix VARCHAR(10),
    PRIMARY KEY(first_name, last_name)
);

SELECT * FROM seattle_public_art_artist;

-- 6. Populate your artist table with all the artist data.

INSERT INTO seattle_public_art_artist(first_name, last_name)
SELECT DISTINCT artist_first_name, artist_last_name
FROM Public_Art_Data
WHERE artist_first_name IS NOT NULL;

-- 7. Fix the dirty artist data.

-- sac_id ESD00.074.06

SELECT *
FROM Public_Art_Data
WHERE sac_id = 'ESD00.074.06';

DELETE FROM seattle_public_art_artist a
WHERE a.first_name = 'James Jr.';

INSERT INTO seattle_public_art_artist VALUES ('James', 'Washington', 'Jr.');

-- sac_id PR99.044/PR99.043/PR99.046/PR99.045

SELECT *
FROM Public_Art_Data
WHERE sac_id = 'PR99.044';

DELETE FROM seattle_public_art_artist a
WHERE a.last_name = 'Fels, Donald; Feddersen, Joe; Quick to see Smith, Jaune';

INSERT INTO seattle_public_art_artist VALUES ('Donald', 'Fels', NULL);
INSERT INTO seattle_public_art_artist VALUES ('Joe', 'Feddersen', NULL);
INSERT INTO seattle_public_art_artist VALUES ('Jaune', 'Quick to see Smith', NULL);

-- sac_id NEA97.024/PR97.022

SELECT *
FROM Public_Art_Data
WHERE sac_id = 'NEA97.024';

DELETE FROM seattle_public_art_artist a
WHERE a.last_name = 'Brother and Mark Calderon';

INSERT INTO seattle_public_art_artist VALUES ('Beliz', 'Brother', NULL);
INSERT INTO seattle_public_art_artist VALUES ('Mark', 'Calderon', NULL);

-- sac_id = 'LIB05.006'

SELECT *
FROM Public_Art_Data
WHERE sac_id = 'LIB05.006';

DELETE FROM seattle_public_art_artist a
WHERE a.last_name = 'D'' Agostino, Fernanda'; -- had to double up on '' to escape apostrophe in Fernanda's last name

INSERT INTO seattle_public_art_artist VALUES ('Fernanda', 'D'' Agostino', NULL);


-- 8. Create the many-to-many relationship between art and artist

CREATE TABLE seattle_public_art_artist_work (
    sac_id varchar(200),
    title varchar(200),
    artist_first_name varchar(100),
    artist_last_name varchar(100),
    PRIMARY KEY(sac_id, title, artist_first_name, artist_last_name)
);

-- 9. Populate your new artist table

INSERT INTO seattle_public_art_artist_work
SELECT DISTINCT p.sac_id, p.title,  a.first_name, a.last_name
FROM seattle_public_art_artist a, Public_Art_Data p
WHERE a.first_name = p.artist_first_name
AND a.last_name = p.artist_last_name
AND sac_id IS NOT NULL;

-- INSERT 0 262

-- Jaune Quick to see Smith
INSERT INTO seattle_public_art_artist_work VALUES ('PR99.044', 'Bronze Imbeds', 'Jaune', 'Quick to see Smith');
INSERT INTO seattle_public_art_artist_work  VALUES ('PR99.043', 'Pavers', 'Jaune', 'Quick to see Smith');
INSERT INTO seattle_public_art_artist_work  VALUES ('PR99.046', 'Viewers', 'Jaune', 'Quick to see Smith');
INSERT INTO seattle_public_art_artist_work  VALUES ('PR99.045', 'Bronze Plaques and Medallion', 'Jaune', 'Quick to see Smith');

-- INSERT 0 1

-- James Washington
INSERT INTO seattle_public_art_artist_work VALUES ('ESD00.074.06', 'Coelacanths', 'James', 'Washington');

-- INSERT 0 1

-- Donald Fels
INSERT INTO seattle_public_art_artist_work VALUES ('PR99.044', 'Bronze Imbeds', 'Donald', 'Fels');
INSERT INTO seattle_public_art_artist_work  VALUES ('PR99.043', 'Pavers', 'Donald', 'Fels');
INSERT INTO seattle_public_art_artist_work  VALUES ('PR99.046', 'Viewers', 'Donald', 'Fels');
INSERT INTO seattle_public_art_artist_work  VALUES ('PR99.045', 'Bronze Plaques and Medallion', 'Donald', 'Fels');

-- INSERT 0 1

-- Joe Feddersen
INSERT INTO seattle_public_art_artist_work VALUES ('PR99.044', 'Bronze Imbeds', 'Joe', 'Feddersen');
INSERT INTO seattle_public_art_artist_work  VALUES ('PR99.043', 'Pavers', 'Joe', 'Feddersen');
INSERT INTO seattle_public_art_artist_work  VALUES ('PR99.046', 'Viewers', 'Joe', 'Feddersen');
INSERT INTO seattle_public_art_artist_work  VALUES ('PR99.045', 'Bronze Plaques and Medallion', 'Joe', 'Feddersen');

-- INSERT 0 1

-- Beliz Brother
INSERT INTO seattle_public_art_artist_work VALUES ('NEA97.024', 'Water Borne', 'Beliz', 'Brother'); 
INSERT INTO seattle_public_art_artist_work VALUES ('PR97.022', 'Aureole', 'Beliz', 'Brother');

-- INSERT 0 1

-- Mark Calderon
INSERT INTO seattle_public_art_artist_work VALUES ('NEA97.024', 'Water Borne', 'Mark', 'Calderon');
INSERT INTO seattle_public_art_artist_work VALUES ('PR97.022', 'Aureole', 'Mark', 'Calderon'); 

-- INSERT 0 1

-- Fernanda D'Agostino
INSERT INTO seattle_public_art_artist_work VALUES ('LIB05.006', 'Into the Green Wood', 'Fernanda', 'D''Agostino');

-- INSERT 0 1

-- 10. Now query your clean schema!

SELECT artist_first_name, artist_last_name, count(*)
FROM seattle_public_art_artist_work w, clean_seattle_public_art art
WHERE art.sac_id = w.sac_id
AND art.title = w.title
GROUP BY artist_first_name, artist_last_name
ORDER BY count(*) DESC;

-- Shoutout to Beliz Brother with the most works in our database at 14!
