-- John Harrison
-- Lucy Lu Wang
-- INFO 330
-- 22 January 2024

-- Lab 2

-- Question 1:
-- Write a SQL query that returns the titles 
-- and authors of books that were published in 2010,
-- sorted alphabetically by author, then by title. 
-- The resulting table should have two columns: 
-- title and author.

SELECT title, author
FROM books
WHERE year_published = 2010
ORDER BY author, title;

-- "title"	"author"
-- "Música para corazones incendiados"	"A.M. Homes"
-- "Paris to the Moon"	"Adam Gopnik"
-- "Banquet For the Damned"	"Adam Nevill"
-- "Allô, Hercule Poirot"	"Agatha Christie"
-- "At Bertram's Hotel (Megamind)"	"Agatha Christie"
-- "Cartes sur table"	"Agatha Christie"
-- "Christmas Pudding"	"Agatha Christie"
-- "Cinq Petits Cochons"	"Agatha Christie"
-- "Destination inconnue"	"Agatha Christie"
-- "Drame en trois actes"	"Agatha Christie"
-- ...


-- Question 2:
-- Write a SQL query that returns the number of 
-- books that are over 300 pages long and highly
-- rated on goodreads (rating greater than or equal
-- to 4). The resulting table should have one column
-- called num.

SELECT count(*) as num
FROM books
WHERE pages > 300 and goodreads_rating >= 4;

-- "num"
-- 13467


-- Question 3.a:
-- Write a SQL query that returns the number of
-- books published per year ordered by publication
-- year. The resulting table should have two columns:
-- year_published and count.

SELECT year_published, count(*)
FROM books
GROUP BY year_published
ORDER BY year_published;

-- "year_published"	"count"
-- 1879	1
-- 1897	1
-- 1899	1
-- 1900	3
-- 1908	2
-- 1911	1
-- 1913	1
-- 1920	6
-- ...
-- 2005	2942
-- 2006	2679
-- 2007	6546
-- 2008	13577
-- 2009	1803
-- ...
-- 2022	1
-- 2030	1


-- Question 3.b:
-- Based on the results of your query, describe the
-- distribution of books by year and whether there’s
-- anything unusual about the distribution.

-- There's a crazy amount of books published in 2008; 
-- most years barely break a thousand and '07 saw 6.5k,
-- but during the *housing market crash of 2008*, nearly
-- 14,000 books were published. There's also a pretty 
-- small amount of books being published pre-1969, and a
-- book in here that will be published in 2030!

-- The long and short of it is that there's a crazy spike 
-- in 2008, with significantly fewer books published in the 
-- early 1900s than you would expect.


-- Question 4:
-- Write a SQL query that returns for *each* book in
-- the books table its Goodreads rating and the number
-- of ratings computed from the books table, and its
-- average rating and total number of ratings computed
-- from the ratings table. Note that the number and
-- average ratings computed from the two tables may be
-- different!

SELECT b.title, max(b.goodreads_rating) as goodreads_rating, 
	   sum(b.num_ratings) as num_ratings_books,
	   avg(r.rating) as average_rating, 
	   count(r.book_id) as num_ratings_ratings
FROM books b
LEFT JOIN ratings r ON b.id = r.book_id
GROUP BY b.title;

-- "title"	"goodreads_rating"	"num_ratings_books"	"average_rating"	"num_ratings_ratings"
-- "Trick or Treat (Corinna Chapman, #4)"	3.9	3810	3.5000000000000000	2
-- "The Left Hand of Darkness"	4.07	955160	4.0000000000000000	8
-- "Reef"	3.7	1343	4.0000000000000000	1
-- "Confessions of a Prep School Mommy Handler"	3.36	705	3.0000000000000000	1
-- ...

-- NOTE: In order to pass goodreads_ratings as a column,
-- it had to be wrapped in the aggregate function max.
-- There's no difference from using min, but count, sum
-- and avg would return inaccurate results.


-- Question 5:

-- Write a SQL query that returns for each user in users their "crankiness"
-- score. Your results should include only the 10 most "cranky" reviewers,
-- ordered by their "crankiness" from most cranky to least cranky. The
-- resulting table should have the following columns: user_id, username,
-- mean_rating, crankiness.

-- Crankiness is defined as an average across all books a user has rated,
-- calculated from the difference between a user's average rating and the
-- given book's GoodReads rating.

SELECT r.user_id, u.username,
	   avg(r.rating) as mean_rating,
	   avg(r.rating - b.goodreads_rating) as crankiness
FROM ratings r
JOIN books b ON r.book_id = b.id
JOIN users u ON r.user_id = u.id
GROUP BY r.user_id, u.username
ORDER BY crankiness
LIMIT 10;

-- "user_id"	"username"	"mean_rating"	"crankiness"
-- 4378	"schaeferbenjamin"	1.00000000000000000000	-3.559999942779541
-- 3577	"copelandjonathon"	1.00000000000000000000	-3.3850000699361167
-- 203	"ihodges"	1.00000000000000000000	-3.3000001907348633
-- 2662	"brownallison"	1.00000000000000000000	-3.260000228881836
-- 96	"richardyates"	1.00000000000000000000	-3.1599998474121094
-- 2683	"kgarcia"	1.00000000000000000000	-3.0199999809265137
-- 7895	"moorefrank"	1.00000000000000000000	-2.950000047683716
-- 5104	"vhendricks"	1.00000000000000000000	-2.950000047683716
-- 9264	"jordansteven"	1.00000000000000000000	-2.940000057220459
-- 10957	"darryl64"	1.3333333333333333	-2.8666667143503823

-- Question 6: 

-- One of the users is called 'austenfan'. We want to investigate, based on
-- the books they've rated, whether they are actually a Jane Austen fan.

-- (a) Write a query to output a list of the most commonly rated authors by 
-- this user, the number of books per author the user has rated, and the list
-- of book titles from books for each author that has been rated by this user
-- (using array aggregation). The resulting table should have the following
-- columns: author, num_rated (number of books rated for this author), rated_books.

SELECT b.author, count(b.author) as num_rated,
	   array_agg(b.title) as rated_books
FROM books b
JOIN ratings r ON b.id = r.book_id
JOIN users u ON r.user_id = u.id
GROUP BY b.author, u.username
HAVING u.username = 'austenfan';

-- "author"	"num_rated"	"rated_books"
-- "Betty  Smith"	1	"{""Joy in the Morning""}"
-- "Harper Lee"	1	"{""To Kill a Mockingbird""}"
-- "Jane Austen"	1	"{""Pride and Prejudice""}"
-- "Khaled Hosseini"	1	"{""The Kite Runner""}"
-- "P.G. Wodehouse"	3	"{""Carry On, Jeeves (Jeeves, #3)"",""Thank You, Jeeves (Jeeves, #5)"",""Jeeves in the Offing (Jeeves, #12)""}"

-- (b) Based on the results of your query, is 'austenfan' a Jane Austen fan? Why
-- or why not?

-- Not really, according to their Goodreads records! austenfan has only reviewed
-- 'Pride and Prejudice', with one book each for Harper Lee, Betty Smith, and
-- Khaled Hosseini also in their ratings. A better username would be 'jeevesfan',
-- as P.G. Wodehouse takes up three ratings with entries from their 'Jeeves' series.

-- BONUS:
-- Who is/are the biggest Jane Austen fan(s) and how many of her books did they
-- read? Alter the above query to output a list of users and the number of Jane
-- Austen books they've read (using rated as a proxy for read), ordered from
-- most to least number of Austen books rated.

SELECT u.username, count(r.book_id) as books_read
FROM books b
JOIN ratings r ON b.id = r.book_id
JOIN users u ON r.user_id = u.id
GROUP BY u.username, b.author
HAVING b.author = 'Jane Austen'
ORDER BY books_read DESC;

-- "username"	"books_read"
-- "xtorres"	8
-- "stephanie29"	7
-- "simpsonchristopher"	7
-- "yritter"	7
-- "brittany31"	6
-- "gallen"	6
-- "gary40"	6
-- "alicia63"	6
-- "debrareynolds"	6
-- "barnettrachel"	6
-- ...
