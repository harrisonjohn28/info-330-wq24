-- John Harrison
-- Lucy Lu Wang
-- INFO 330
-- 5 February 2024

-- Creating and writing to tables

CREATE TABLE Company (
    cname VARCHAR(50) PRIMARY KEY,
    country VARCHAR(30),
    no_employees INT,
    for_profit BOOLEAN
);

-- To make changes to attributes, you will need to delete the table and
-- reinitialize it. This is IRREVERSIBLE, so be careful.

DROP TABLE IF EXISTS Company;

-- Primary Keys
-- Product(*product_id*, pname, manufacturer)
CREATE TABLE Product (
    product_id INT PRIMARY KEY,
    pname VARCHAR(200),
    manufacturer VARCHAR(100)
);

-- Keys with multiple attributes
CREATE TABLE Product (
    pname VARCHAR(200),
    manufacturer VARCHAR(100),
    PRIMARY KEY (pname, manufacturer)
);

-- Specifying *other* keys ooooooooh
CREATE TABLE Product (
    product_id INT,
    pname VARCHAR(100),
    manufacturer VARCHAR(50),
    PRIMARY KEY (product_id),       -- This is a unique ID; can't be null
    UNIQUE (pname, manufacturer)    -- You can't have two acme wrenches, but you can have null entries
);

-- Foreign Key Constraints

CREATE TABLE Purchase (
    purchase_id INT PRIMARY KEY,
    product_id INT REFERENCES Product(product_id),
    price DECIMAL,          --^-table ^-foreign key in other table
    quantity INT,                     --this MUST be a key in Product
    month CHAR(3),
    year INT
);

-- Practice
CREATE TABLE Books(
    title TEXT,
    author TEXT,
    isbn CHAR(10) PRIMARY KEY,
    publisher TEXT,
    printing SMALLINT
);

CREATE TABLE Customer (
    customer INT PRIMARY KEY,
    lname VARCHAR(100),
    fname VARCHAR(100)
);

CREATE TABLE Ordered ( -- because Ordered references Customer, it has to be
    isbn VARCHAR(10) REFERENCES Books(isbn),         -- created beforehand.
    customer INT REFERENCES Customer(customer),
    date DATE
    -- PRIMARY KEY (isbn, customer, date) if you wanted to always have all info
    -- UNIQUE (isbn, customer, date) if above is too strong
);

-- Database modifications

INSERT INTO Books(title, author, isbn, publisher, printing)
VALUES(
    'The New Jim Crow',
    'Michelle Alexander',
    '123-45-678',
    'The New Press',
    1
);

INSERT INTO Books(title, author, isbn) 
VALUES(
    'The Thief',            -- You can have missing attributes; they'll just
    'Fuminori Nakamura',    -- be filled as null when added to the database.
    '161-69-502'
);

-- NULL / NOT NULL Values

CREATE TABLE BooksNull(
    title TEXT,
    author TEXT,
    isbn CHAR(10) PRIMARY KEY,
    publisher TEXT NOT NULL,    -- if this condition is violated in an INSERT
    printing SMALLINT           -- INTO statement, an error is thrown
);

-- Default Values

CREATE TABLE BooksDefault(
    title TEXT,
    author TEXT,
    isbn CHAR(10) PRIMARY KEY,
    publisher TEXT,             -- if no value passed for 'printing', will be
    printing SMALLINT DEFAULT 1 -- inserted into table as 1
);

-- Check Constraints
CREATE TABLE BooksDefault(
    title TEXT,
    author TEXT,
    isbn CHAR(10) PRIMARY KEY CHECK (                   -- checking the ISBN to
        isbn SIMILAR TO '[0-9]{3}\-[0-9]{2}\-[0-9]{3}'  -- match format
    ),
    publisher TEXT CHECK(                               -- checking publishers
        publisher IN ('Norton', 'Penguin Classics')     -- against allowed list
    ),
    printing SMALLINT CHECK(                    -- checking if it's between the
        printing > 0 AND printing <= 100        -- 1st or 100th printing
    ),
    year_published SMALLINT NOT NULL,           -- Validating that whatever
    year_first_published SMALLINT NOT NULL,     -- book we're entering, the
    CONSTRAINT valid_year CHECK(                -- year of publication is not
        year_published >= year_first_published  -- before its first appearance
    )
);

-- Practice 2
DROP TABLE IF EXISTS Books;
CREATE TABLE Books(
    title TEXT,
    author TEXT,
    isbn CHAR(10) PRIMARY KEY,
    publisher TEXT CHECK(
        publisher IN ('Norton', 'Macmillan', 'The New Press', 'Penguin Classics')
    ),  -- checking if book is published by allowed publishers
    printing SMALLINT CHECK (
        printing >= 1 AND printing <= 20
    )   -- checking if printing is between 1 and 20 inclusive
);

CREATE TABLE Customer (
    customer INT PRIMARY KEY CHECK(
        customer >= 1000 AND customer <= 9999
    ),  -- validates that customer is between 1000 and 9999
    lname VARCHAR(100),
    fname VARCHAR(100)
);

CREATE TABLE Ordered ( 
    isbn VARCHAR(10) REFERENCES Books(isbn),
    customer INT REFERENCES Customer(customer),
    -- Foreign key constraint takes care of any requirements since no customer
    -- can be entered into the Customer table outside the given range.
    date DATE
);

-- Inserting multiple tuples using:
-- INSERT INTO <relation>
-- (tuple1),
-- (tuple2),
-- (tuple3),
-- ...;

INSERT INTO Books(title, author, isbn)
(SELECT title, author, isbn -- writing to queries and insertin the results
FROM GoodReadsBooks);       -- of those subqueries into the table