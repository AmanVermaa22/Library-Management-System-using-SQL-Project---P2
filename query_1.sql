
--Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books(isbn, book_title, category, rental_price,n_status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM books;

--Task 2: Update an Existing Member's Address

UPDATE members
SET member_address = '125 Oak St'
WHERE member_id = 'C103';

--Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

DELETE FROM issued_status
WHERE   issued_id =   'IS121';

--Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT * FROM issued_status
WHERE issued_emp_id = 'E101'

--Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT
    issued_emp_id,
    COUNT(*)
FROM issued_status
GROUP BY 1
HAVING COUNT(*) > 1

--Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

CREATE TABLE book_issued_cnt AS
SELECT b.isbn, b.book_title, COUNT(ist.issued_id) AS issue_count
FROM issued_status as ist
JOIN books as b
ON ist.issued_book_isbn = b.isbn
GROUP BY b.isbn, b.book_title;

--Task 7: List Members Who Registered in the Last 180 Days:

SELECT * FROM members
WHERE reg_date >= NOW() - INTERVAL 180 DAY;

--Task 8: Find Total Rental Income by Category:

SELECT * FROM books
WHERE category = 'Classic';

--Task 9: Find Total Rental Income by Category:

SELECT 
    B.category,
    SUM(B.rental_price),
    COUNT(*) 
FROM 
issued_status AS IST 
JOIN books AS B 
ON B.isbn = IST.ISSUED_BOOK_ISBN
GROUP BY 1 

--Task 10: List Employees with Their Branch Manager's Name and their branch details:

SELECT 
    e1.emp_id,
    e1.emp_name,
    e1.n_position,
    e1.salary,
    b.*,
    e2.emp_name as manager
FROM 
employees as e1
join 
branch as b 
on e1.branch_id=b.branch_id
JOIN
employees as e2
on e2.emp_id=b.manager_id 

--Task 11: Retrieve the list of books not yet returned:

SELECT * FROM issued_status AS IST 
LEFT JOIN
return_status AS rs 
on rs.issued_id=IST.issued_id
WHERE rs.return_id IS NULL ;

/*Task 12:Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period).
 Display the member's_id, member's name, book title, issue date, and days overdue.*/

SELECT 

    ist.issued_member_id,
    m.member_name,
    bk.book_title,
    ist.issued_date,
    CURRENT_DATE - ist.issued_date as over_due_days
from 
issued_status as ist
join 
members as m 
 on m.member_id= ist.issued_member_id
JOIN
 books as bk
 on bk.isbn=ist.issued_book_isbn
left join
return_status as rs 
on rs.issued_id=ist.issued_id
    WHERE
        rs.return_date is NULL
        AND
        (CURRENT_DATE -ist.issued_date) > 30
    ORDER BY 1 





/*Task 13: Branch Performance Report
Create a query that generates a performance report for each branch,
 showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.*/

CREATE TABLE branch_reports
AS
SELECT 
    b.branch_id,
    b.manager_id,
    COUNT(ist.issued_id) as number_book_issued,
    COUNT(rs.return_id) as number_of_book_return,
    SUM(bk.rental_price) as total_revenue
FROM issued_status as ist
JOIN 
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
JOIN 
books as bk
ON ist.issued_book_isbn = bk.isbn
GROUP BY 1, 2;

SELECT * FROM branch_reports;

/*Task 14: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members 
who have issued at least one book in the last 2 months.*/

CREATE TABLE active_members
AS
SELECT * FROM members
WHERE member_id IN (SELECT 
                        DISTINCT issued_member_id   
                    FROM issued_status
                    WHERE 
                        issued_date >= CURRENT_DATE() - INTERVAL 2 MONTH
                    );

SELECT * FROM active_members;

/*Task 15: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. 
Display the employee name, number of books processed, and their branch.*/

SELECT 
    e.emp_name,
    b.*,
    COUNT(ist.issued_id) as no_book_issued
FROM issued_status as ist
JOIN
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
GROUP BY 1, 2

/*Task 16: Identify Members Issuing High-Risk Books
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table.
 Display the member name, book title, and the number of times they've issued damaged books.*/

SELECT 
    M.member_name,
    IST.issued_book_name,
    RS.book_quality
    


FROM 
members AS M
JOIN
issued_status AS IST
ON M.member_id = IST.issued_member_id
JOIN return_status As RS
ON IST.issued_id=RS.issued_id

WHERE book_quality = 'damaged'

/*
Task 17: Stored Procedure Objective: 

Create a stored procedure to manage the status of books in a library system. 

Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 

The procedure should function as follows: 

The stored procedure should take the book_id as an input parameter. 

The procedure should first check if the book is available (status = 'yes'). 

If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 

If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.
*/


SELECT * FROM BOOKS;

SELECT * FROM issued_status;
DELIMITER//

CREATE PROCEDURE ISSUE_BOOK(p_issued_id VARCHAR(10), p_issued_member_id VARCHAR(30), p_issued_book_isbn VARCHAR(30), p_issued_emp_id VARCHAR(15))

BEGIN

DECLARE v_status VARCHAR(10);
Select
     n_status
     INTO
     v_status
    from
     books
     where isbn=p_issued_book_isbn;
    
    if v_status = 'yes' THEN
       INSERT INTO issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
        VALUES
        (p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);

        UPDATE books
            SET n_status = 'no'
        WHERE isbn = p_issued_book_isbn;

        SIGNAL SQLSTATE '01000'
        SET MESSAGE_TEXT = 'Book records added successfully for book isbn : %',
           MYSQL_ERRNO=1000;

         
    ELSE
        SIGNAL SQLSTATE '01000'
        SET MESSAGE_TEXT = 'Sorry to inform you the book you have requested is unavailable book_isbn: %',
           MYSQL_ERRNO=1000;

        
    END IF;

END //
DELIMITER;

DROP Procedure `ISSUE_BOOK`

SELECT * FROM books;
-- "978-0-553-29698-2" -- yes
-- "978-0-375-41398-8" -- no
SELECT * FROM issued_status;

CALL issue_book('IS158', 'C108', '978-0-553-29698-2', 'E104');

CALL issue_book('IS156', 'C108', '978-0-375-41398-8', 'E104');

SELECT * FROM books
WHERE isbn = '978-0-375-41398-8'




