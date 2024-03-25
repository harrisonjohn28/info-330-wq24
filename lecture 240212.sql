-- John Harrison
-- Lucy Lu Wang
-- INFO 330
-- 12 February 2024

-- Inserting multiple tuples:

-- Inserting the entire result of a query into a relation

INSERT INTO Books(title, author, isbn)
(SELECT title, author, isbn
FROM GoodReadsBooks);

-- Deleting tuples

DELETE FROM Books
WHERE author = 'Jared Diamond';

DELETE FROM Books; -- will wipe ALL values in relation

-- Delete where there is another book by the same author.

DELETE FROM Books b
WHERE EXISTS (
    SELECT title FROM books
    WHERE author = b.author
    AND title != b.title
);

-- Updates: changing attributes in certain tuples of a relation

-- Changing Solaris rating to 4.2
UPDATE GoodReadsBooks
SET rating = 4.2
WHERE title = 'Solaris'
AND author = 'Stanislaw Lem';

-- Setting every rating above a 4.0 to be 4.0 maximum
UPDATE GoodReadsBooks
SET rating = 4.0
WHERE rating > 4.0

-- Practice:

-- Write a query that adds the following two rows to the Books table:
INSERT INTO Books
VALUES ('We have always lived in the castle',
        'Shirley Jackson',
        '978-32-572',
        'Penguin Classics',
        12
),
(
        'Bliss Montage', 
        'Ling Ma', 
        '073-42-935', 
        'Macmillan',
        12
);

-- Write a query that updates any row in the Books table to increase printing
-- number by 1

UPDATE Books
SET printing = 1
WHERE printing IS NULL;

UPDATE Books
SET printing = printing + 1;

-- Write a query that deletes any row in the Books table whose publisher value
-- is NULL

DELETE FROM Books
WHERE publisher IS NULL;