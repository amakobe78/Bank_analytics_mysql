-- After importing the csv files with data import wizard as stage data
-- we start by cleaning each stage table
-- we start by checking number of rows in each table to ensure we did not loose any data while importing
SELECT 'stg_branches' AS table_name , COUNT(*) AS row_count From stg_branches
UNION ALL
SELECT 'stg_customers' AS table_name , COUNT(*) AS row_count FROM stg_customers
UNION ALL
SELECT 'stg_accounts' AS table_name, COUNT(*) AS row_count FROM stg_accounts
UNION ALL 
SELECT 'stg_transactions' AS table_name, COUNT(*) AS row_count FROM stg_transactions
UNION ALL
SELECT 'stg_loans' AS table_name, COUNT(*) AS row_count FROM stg_loans;

-- REMOVING EMPTY CELLS OR NULL VALUES
SELECT *
FROM stg_customers
WHERE customer_id = '' OR customer_id IS NULL
OR first_name = ''    OR first_name IS NULL
OR last_name = ''     OR last_name IS NULL
OR gender = ''        OR gender IS NULL
OR DOB = ''           OR DOB IS NULL
OR email = ''         OR email IS NULL
OR city = ''          OR city IS NULL;

-- from the customers table we have a missing value
SELECT * 
FROM stg_customers
WHERE customer_id = 15;

-- UPDATED THE TABLE BE FILLING THE MISSING GENDER by Unknown
UPDATE stg_customers
SET gender = 'Unknown'
WHERE customer_id = 15;
-- deleted the row with missing DOB since the customer had no relation with other table
SELECT * FROM stg_accounts 
WHERE customer_id = 33;

SELECT * FROM stg_transactions t
JOIN stg_accounts a ON t.account_number = a.account_number
WHERE a.customer_id = 33;

DELETE
FROM stg_customers
WHERE DOB = '';

-- DELETING DUPLICATES
WITH dup_values AS(
SELECT first_name, last_name, DOB, email,
ROW_NUMBER () OVER(PARTITION BY first_name, last_name, DOB, email) AS ROW_NUM
FROM stg_customers
)
SELECT *
FROM dup_values
WHERE ROW_NUM > 1
ORDER BY 1 ;

SELECT *
FROM stg_customers
WHERE first_name = 'Halima' AND last_name = 'Omondi';

CREATE TABLE `stg_customers2` (
  `customer_id` text,
  `first_name` text,
  `last_name` text,
  `gender` text,
  `DOB` text,
  `email` text,
  `city` text,
  `ROW_NUM` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO stg_customers2
SELECT *,
ROW_NUMBER () OVER(PARTITION BY first_name, last_name, DOB, email) AS ROW_NUM
FROM stg_customers;

DELETE
FROM stg_customers2
WHERE ROW_NUM > 1;

ALTER TABLE stg_customers2
DROP COLUMN ROW_NUM;

SELECT*
FROM stg_customers2;

-- checking for inconsistence 
-- looking for uniformity in the city column
SELECT CAST(city AS CHAR) AS exact_city, COUNT(*) AS total
FROM stg_customers2
GROUP BY CAST(city AS CHAR)
ORDER BY CAST(city AS CHAR);

-- looking for uniformity in the gender column
SELECT DISTINCT gender, COUNT(*) AS total
FROM stg_customers2
GROUP BY gender
ORDER BY gender;
 
-- checking for outliers
SELECT * 
FROM stg_customers2
WHERE DOB > CURDATE();

SELECT customer_id, email
FROM stg_customers2
WHERE email NOT LIKE '%@%'; 
-- CHECKING IF THE OUTLIER LINK TO OTHER TABLES
SELECT *
FROM stg_accounts AS sta
LEFT JOIN stg_loans AS stl
ON sta.customer_id = stl.customer_id
WHERE sta.customer_id = 180;

SELECT *
FROM stg_loans
WHERE  customer_id = 67;

-- updating the date and the email by replacing both by null
UPDATE stg_customers2
SET DOB = null
WHERE customer_id = 180;

UPDATE stg_customers2
SET email = null
WHERE customer_id = 67;

SELECT customer_id, first_name, DOB, email
FROM stg_customers2
WHERE customer_id IN (67, 180);

-- Moving the cleaned data from stg_customers2 tostg_customers
select *
from stg_customers2 STGC2
join stg_customers STGC
on STGC2.customer_id = STGC.customer_id;
-- moving all the columns 
truncate table stg_customers;
insert into stg_customers
select *
from stg_customers2;
-- finshed cleaning stg_customer dataset

-- cleaning stg_branches
-- checking for null or empty values in the data
SELECT *
FROM stg_branches;

SELECT
SUM(branch_ID = '' OR branch_ID IS NULL ) AS missing_branch_ID,
SUM(branch_name = '' OR branch_name IS NULL ) AS missing_branch_name,
SUM(city = '' OR city IS NULL ) AS missing_city,
SUM(location = '' OR location IS NULL ) AS missing_location
FROM stg_branches;
-- NO MISSING OR NULL VALUE IN STG_branches
-- CHECKING FOR DUPLICATE 
WITH dup_branch AS(
SELECT branch_ID, branch_name, city, location,
ROW_NUMBER() OVER(PARTITION BY   branch_name, city, location) AS Row_num
FROM stg_branches )
SELECT *
FROM dup_branch
WHERE Row_num > 1
ORDER BY 1; 
-- I found two duplicates from the data

CREATE TABLE `stg_branches2` (
  `branch_ID` text,
  `branch_name` text,
  `city` text,
  `location` text,
  Row_num int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO stg_branches2
SELECT branch_ID, branch_name, city, location,
ROW_NUMBER() OVER(PARTITION BY  branch_name, city, location) AS Row_num
FROM stg_branches;

DELETE
FROM stg_branches2
WHERE Row_num > 2;
-- dropping the row_num column 
ALTER TABLE stg_branches2 DROP COLUMN Row_num;
-- DELETED DUPLICATES FROM THE TABLE

-- CHECKING FOR DISTINCT STRING IN THE TABLE
SELECT branch_name, TRIM(branch_name),
	COUNT(*) AS occurence ,
	SUM(COUNT(*)) OVER (ORDER BY branch_name) AS cumulative_occurrence
FROM stg_branches2
GROUP BY branch_name
ORDER BY branch_name;

SELECT city, TRIM(city), 
	COUNT(*) AS OCCURENCE ,
	SUM(COUNT(*)) OVER(ORDER BY city) AS cumulative_occurrence
FROM stg_branches2
GROUP BY city
ORDER BY city;

SELECT location, TRIM(location), 
	COUNT(*) AS OCCURENCE ,
	SUM(COUNT(*)) OVER(ORDER BY location) AS cumulative_occurrence
FROM stg_branches2
GROUP BY location
ORDER BY location;
-- PREVIEWING IF THE TWO TABLES ARE THE SAME AFTER CLEANING 
SELECT *
FROM stg_branches AS stb
JOIN stg_branches2 AS stb2
ON stb.branch_ID = stb2.branch_ID;
-- REPLACING THE CLEANNED DATA WITH THE ORIGINAL
TRUNCATE TABLE stg_branches;

INSERT INTO stg_branches
SELECT*
FROM stg_branches2;

-- CLEANING FOR stg_accounts
SELECT *
FROM stg_accounts;
-- CHECKING FOR MISSING VALUES
SELECT 
SUM(account_number = '' OR account_number IS NULL) AS missing_acc_no,
SUM(account_name = '' OR account_name IS NULL) missing_acc_name,
SUM(customer_id = '' OR customer_id IS NULL ) missing_cus_id,
SUM(branch_ID = '' OR branch_ID IS NULL) mising_bra_id,
SUM(account_type = '' OR account_type IS NULL ) missing_acc_type,
SUM(account_status = '' OR account_status IS NULL ) missing_acc_status,
SUM(balance= '' OR balance IS NULL) missing_bal,
SUM(open_date = '' OR open_date IS NULL) missing_date
FROM stg_accounts;
-- THERE IS NO MISSSING VAUES

-- CHECKING FOR DUPLICATES
WITH dup_acc AS(
SELECT *,
	ROW_NUMBER() 
	OVER(PARTITION BY  account_name, account_type, account_status, balance, open_date) AS row_num
FROM stg_accounts
)
SELECT * 
FROM dup_acc
WHERE row_num > 1
ORDER BY 1;
-- counter checking each duplicate
SELECT *
FROM stg_accounts
WHERE customer_id = 103;

-- deleting the duplicates
CREATE TABLE `stg_accounts2` (
  `account_number` text,
  `account_name` text,
  `customer_id` text,
  `branch_ID` text,
  `account_type` text,
  `account_status` text,
  `balance` decimal(16, 2),
  `open_date` text,
  row_num int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT stg_accounts2
SELECT *,
	ROW_NUMBER() 
	OVER(PARTITION BY  account_name, account_type, account_status, balance, open_date) AS row_num
FROM stg_accounts ;

DELETE
FROM stg_accounts2
WHERE account_number IN ('ACC0251', 'ACC0252', 'ACC0253', 'ACC0254','ACC0255');

ALTER TABLE stg_accounts2 DROP COLUMN row_num;

SELECT TRIM(account_name), COUNT(*), SUM(COUNT(*)) OVER(ORDER BY account_name)
FROM stg_accounts2
GROUP BY account_name
ORDER BY account_name;

SELECT TRIM(account_type), COUNT(*), SUM(COUNT(*)) OVER(ORDER BY account_type)
FROM stg_accounts2
GROUP BY account_type
ORDER BY account_type;

SELECT account_status, COUNT(*), SUM(COUNT(*)) OVER(ORDER BY account_status)
FROM stg_accounts2
GROUP BY account_status
ORDER BY account_status;
-- THE FORMATING IN STG_ACCOUNTS2 IS IN THE CORRECT FORMAT

-- CHECKING FOR OUTLIERS
-- FIRST CHNGING BALANCE DATA TYPE TO DECIMAL

ALTER TABLE stg_accounts2 MODIFY COLUMN balance DECIMAL(16,2);
SELECT  MIN(balance), MAX(balance)
FROM stg_accounts2
;
SELECT *
FROM stg_accounts2
WHERE balance LIKE '-%';

UPDATE stg_accounts2
SET balance = NULL
WHERE account_number = 'ACC0045';

UPDATE stg_accounts2
SET balance = NULL
WHERE balance = 999999999.99;
-- checking for outliers on open date column
SELECT * FROM stg_accounts2
WHERE open_date > CURDATE();

-- Fix it the outlier with null
UPDATE stg_accounts2
SET open_date = NULL
WHERE open_date > CURDATE();

SELECT *
FROM stg_accounts2 STA2
JOIN stg_accounts STA
ON STA2.account_number = STA.account_number;

-- moving THE CLEANED DATA TABE STG ACCOUNT2 to ORRIGINAL TABLE
TRUNCATE TABLE stg_accounts;

INSERT INTO stg_accounts
SELECT*
FROM stg_accounts2;
-- FINIHED CLEANING STG ACCOUNTS

-- STARTING TO CLEAN STG TRANSACTIONS TABLE
SELECT *
FROM stg_transactions;

-- I WOULD LIKE FIRST BY CHANGING THE DATA TYPES OF AMOUNT AND TRANSACTION COST 

ALTER TABLE stg_transactions MODIFY COLUMN amount DECIMAL(12, 2); 
ALTER TABLE stg_transactions MODIFY COLUMN transaction_cost DECIMAL(12, 2);
ALTER TABLE stg_transactions MODIFY COLUMN transaction_time TIME;
-- checking for empty and null 
SELECT 
SUM(transaction_code = '' OR transaction_code IS NULL) missing_code, 
SUM(account_number = '' OR account_number IS NULL) missing_num, 
SUM(transaction_type = '' OR transaction_type IS NULL) missing_type, 
SUM(amount = '' OR amount IS NULL) missing_amount, 
SUM(transaction_date = '' OR transaction_date IS NULL) missing_date, 
SUM(transaction_time = '' OR transaction_time IS NULL) missing_time, 
SUM(transaction_cost = '' OR transaction_cost IS NULL) missing_cost
FROM stg_transactions;
-- found two rmpty cells one from transaction_type and the other from transaction_cost
SELECT  *
FROM stg_transactions
WHERE transaction_type = '';

SELECT  *
FROM stg_transactions
WHERE transaction_cost = '';
-- updating the missing values 
UPDATE stg_transactions
SET transaction_type = 'unkown'
WHERE  transaction_type = '';
-- IHAVE CHANGED THE TRANSACTION TYPE TWO UNKOWN AND FOR THE MISSING TRANSACTION COST I HAVE SEEN THERE VALUES ARE 0.00 SO I DONT NEED TO CHANGE

-- FINDING DUPLICATES AND REMOVING DUPLICATES
WITH DUP_TRAN AS (
	SELECT*,
	ROW_NUMBER() OVER(PARTITION BY  account_number, amount, transaction_date, transaction_time, transaction_cost) AS row_num
    FROM stg_transactions  )
SELECT *
FROM DUP_TRAN
WHERE row_num > 1
ORDER BY 1;

SELECT *
FROM stg_transactions
WHERE account_number = 'ACC0238' AND transaction_type = 'Payments';

CREATE TABLE `stg_transactions2` (
  `transaction_code` text,
  `account_number` text,
  `transaction_type` text,
  `amount` decimal(12,2) DEFAULT NULL,
  `transaction_date` text,
  `transaction_time` time DEFAULT NULL,
  `transaction_cost` decimal(12,2) DEFAULT NULL,
  row_num INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO stg_transactions2
SELECT*,
ROW_NUMBER() OVER(PARTITION BY  account_number, amount, transaction_date, transaction_time, transaction_cost) AS row_num
FROM stg_transactions;

DELETE
FROM stg_transactions2
WHERE row_num > 1;

ALTER TABLE stg_transactions2 DROP COLUMN row_num;
-- REMOVED 10 DUPLICATES ROW

-- CHECKING FOR UNIFORMITTY ON THE STRINGS

SELECT TRIM(transaction_type), COUNT(*), SUM(COUNT(*)) OVER(ORDER BY transaction_type)
FROM stg_transactions2
GROUP BY transaction_type
ORDER BY transaction_type;

-- CHECKING FOR OUTLIERS
SELECT MIN(amount), MAX(amount), MIN(transaction_cost), MAX(transaction_cost)
FROM stg_transactions2;

-- COUNTER CHECK IN STG ACCOUNTS TABLE IF THE ACCOUNT NUMBER REFERED TO STG TRANSACTIONS2 IF THEY EXIST
SELECT *
FROM stg_accounts
WHERE account_number IN ('ACC0017','ACC0048');

UPDATE stg_transactions2
SET AMOUNT = NULL
WHERE AMOUNT IN (-5000.00, 999999999.00);

UPDATE stg_transactions2
SET transaction_cost = null
WHERE transaction_cost = -100;
-- FINISHED SORTING THE OUTLIERS IN AMOUNT AND TRANSACTION COST
ALTER TABLE stg_transactions2 MODIFY COLUMN transaction_date DATE ;
SELECT *
FROM stg_transactions2
WHERE transaction_date = STR_TO_DATE(transaction_date, 'YYYY-MM-DD');

SELECT *
FROM stg_transactions2
WHERE transaction_date > current_date();

SELECT *
FROM stg_transactions2
WHERE transaction_time > current_TIME();
-- FINISHED CLEANING STG TRANSACTION2 DATASET
-- moving cleaned dataset to te original stage dataset
SELECT *
FROM stg_transactions2 stgt2
JOIN stg_transactions stgt
ON stgt2.transaction_code = stgt.transaction_code;

TRUNCATE TABLE stg_transactions;

INSERT INTO stg_transactions
SELECT *
FROM stg_transactions2;
-- fINISHED WITH STG TRANSACTIONS

-- START TO CLEAN STG LOANS
SELECT *
FROM stg_loans;

SELECT 
sum(customer_id = '' OR customer_id IS NULL) mising_cus_id,
SUM(account_number = '' OR account_number IS NULL) missing_num,
SUM(date_taken = '' OR date_taken IS NULL ) missing_date_t,
SUM(offered_amount = '' OR offered_amount IS NULL ) missing_off_amo,
SUM(return_period = '' OR return_period IS NULL) missing_per,
SUM(rate = '' OR rate IS NULL ) missing_rate,
SUM(payment_date = '' OR payment_date IS NULL) missing_date,
SUM(returned_amount = '' OR returned_amount IS NULL) missing_re_amount,
SUM(Status = '' OR Status IS NULL) missing_status
FROM stg_loans;

SELECT *
FROM stg_loans
WHERE payment_date = '' ;

UPDATE stg_loans
SET payment_date = null
WHERE loan_id = 60;
-- REPLACED THE MISSING DATE WITH NULL

-- REMOVING DUPLICATES
WITH dup_loan AS (
	SELECT *,
    ROW_NUMBER() OVER(PARTITION BY  customer_id, account_number, date_taken, offered_amount, return_period, rate, payment_date, returned_amount) AS row_num
    FROM stg_loans
)
SELECT *
FROM dup_loan
WHERE row_num > 1
ORDER BY 1;

CREATE TABLE `stg_loans2` (
  `loan_id` text,
  `customer_id` text,
  `account_number` text,
  `date_taken` text,
  `offered_amount` text,
  `return_period` text,
  `rate` text,
  `payment_date` text,
  `returned_amount` text,
  `Status` text,
  row_num INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT stg_loans2
SELECT *,
ROW_NUMBER() OVER(PARTITION BY  customer_id, account_number, date_taken, offered_amount, return_period, rate, payment_date, returned_amount) AS row_num
FROM stg_loans;

DELETE
FROM stg_loans2
WHERE row_num > 1;
-- DELETED DUPLICATES
ALTER TABLE stg_loans2 DROP COLUMN row_num;

-- CHECKING FOR INCONCISTENCE 
SELECT Status, TRIM(Status), COUNT(*) occurence,
	SUM(COUNT(*)) OVER(ORDER BY Status) cummilative_occurence
FROM stg_loans2
GROUP BY Status
ORDER BY Status;
-- THE DATA SET HAS CONSISTENCE
-- CHANGING DATA TYPE OF FEW COLUMS
ALTER TABLE stg_loans2 MODIFY COLUMN offered_amount DECIMAL(12,2);
ALTER TABLE stg_loans2 MODIFY COLUMN returned_amount DECIMAL(12,2);
ALTER TABLE stg_loans2 MODIFY COLUMN return_period INT;
ALTER TABLE stg_loans2 MODIFY COLUMN returned_amount DECIMAL(9,2);

-- CHECKING FOR OTLIERS
SELECT MIN(offered_amount), MAX(offered_amount), MIN(return_period), MAX(return_period), MIN(rate), MAX(rate),
MIN(returned_amount), MAX(returned_amount)
FROM stg_loans2
;
UPDATE stg_loans2
SET offered_amount = null
WHERE offered_amount = -50000.00;

UPDATE stg_loans2
SET rate = null
WHERE rate = 0.999999;
-- REMOVED OUTLIERS IN OFFERED AMOUNT AND RATE
SELECT loan_id, date_taken, left(date_taken, 10), str_to_date(left(date_taken, 10), '%d/%m/%Y') as Taken_date,
payment_date, left(payment_date, 10), str_to_date(left(payment_date, 10), '%d/%m/%Y') as Taken_date
FROM stg_loans2;



