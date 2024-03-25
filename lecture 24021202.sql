-- John Harrison
-- Lucy Lu Wang
-- INFO 330
-- 12 February 2024

-- Importing/exporting data

-- 1. Create temporary table with the same schema as the CSV (same attributes)

CREATE temporary TABLE temp (
 book_id INTEGER,
 title TEXT,
 author TEXT,
 authorlf TEXT,
 additional_authors TEXT,
 isbn VARCHAR(20),
 isbn13 VARCHAR(20),
 ...
);
-- 2. Copy data from CSV into temp table using PSQL query cmd line
COPY temp (
    book_id, title, author, authorlf, additional_authors, isbn,
    isbn13, my_rating, goodreads_rating, publisher, binding,
    pages, year_published, original_year, date_read, date_added,
    bookshelves, bookshelves_w_position, exclusive_shelf, my_review,
    spoiler, private_notes, read_count, owned_copied
) FROM '/Users/lucylw/Teaching/info330_datasets/data/
goodreads_tiny.csv'
CSV HEADER;
-- 3. Insert data from temp table into final table
INSERT INTO books (title, author, isbn, publisher)
SELECT title, author,
    LEFT(TRIM(both '="' FROM isbn), 10), publisher
FROM temp;
-- 4. Drop temp table
DROP TABLE temp;

-- Exporting to CSV via PSQL (will create a file, doesn't need to be preestablished)
\copy Books
TO '/Users/lucylw/Desktop/books_dbdump.csv'
CSV HEADER;
