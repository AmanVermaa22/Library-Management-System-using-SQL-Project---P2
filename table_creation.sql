
DROP TABLE IF EXISTS branch;
CREATE Table branch(
    branch_id	VARCHAR(10) NOT NULL PRIMARY KEY,
    manager_id	VARCHAR(10),
    branch_address	VARCHAR(50),
    contact_no VARCHAR(10)
);


DROP TABLE IF EXISTS employees;
CREATE Table employees(
    emp_id	VARCHAR(10) PRIMARY KEY,
    emp_name	VARCHAR(20),
    n_position	VARCHAR(20),
    salary	INT,
    branch_id VARCHAR(25) 

);

DROP TABLE IF EXISTS books;
CREATE Table books(
    isbn	VARCHAR(25) PRIMARY KEY,
    book_title	VARCHAR(75),
    category VARCHAR(25),	
    rental_price	FLOAT,
    n_status	VARCHAR(10),
    author	VARCHAR(20),
    publisher VARCHAR(20)

);
ALTER Table books
MODIFY COLUMN publisher  VARCHAR(30);

ALTER Table books
MODIFY COLUMN author  VARCHAR(30);

DROP TABLE IF EXISTS members;
CREATE Table members(
   member_id	VARCHAR(10) PRIMARY KEY,
   member_name	VARCHAR(20),
   member_address	VARCHAR(75),
   reg_date DATE

);

DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status(
    issued_id	VARCHAR(10) PRIMARY KEY,
    issued_member_id	VARCHAR(10),
    issued_book_name	VARCHAR(75),
    issued_date	DATE,
    issued_book_isbn VARCHAR(25),	
    issued_emp_id VARCHAR(25)
);

DROP TABLE IF EXISTS return_status ;
CREATE TABLE return_status(
    return_id	VARCHAR(10) PRIMARY KEY,
    issued_id	VARCHAR(10),
    return_book_name	VARCHAR(75),
    return_date	DATE,
    return_book_isbn VARCHAR(20)

);

ALTER Table return_status
MODIFY COLUMN issued_id  VARCHAR(30);

ALTER TABLE issued_status
ADD CONSTRAINT fk_members
Foreign Key (issued_member_id) 
REFERENCES members(member_id);

ALTER TABLE issued_status
ADD CONSTRAINT fk_books
Foreign Key (issued_book_isbn) 
REFERENCES books(isbn);

ALTER TABLE issued_status
ADD CONSTRAINT fk_employees
Foreign Key (issued_emp_id) 
REFERENCES employees(emp_id);

ALTER TABLE employees
ADD CONSTRAINT fk_branch
Foreign Key (branch_id) 
REFERENCES branch(branch_id);

ALTER TABLE return_status
ADD CONSTRAINT fk_issued_status
Foreign Key (issued_id) 
REFERENCES issued_status(issued_id);