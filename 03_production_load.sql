-- moving clean data to production
INSERT INTO customers(customer_id, first_name, last_name, gender, DOB, email, city)
select customer_id, first_name, last_name, NULLIF(gender, 'Unknown'), DOB, email, city
from stg_customers;

INSERT INTO branches(branch_ID, branch_name, city, location)
SELECT branch_ID, branch_name, city, location
FROM stg_branches;

-- I NEEDED TO DROP THE CUSTOMER ID FOREIGN KEY SO AS TO IMPORT THE STG ACCOUNTS TO ACCOUNTS TABLE
SELECT CONSTRAINT_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_NAME = 'accounts'
AND COLUMN_NAME = 'customer_id'
AND REFERENCED_TABLE_NAME = 'customers';

ALTER TABLE accounts DROP FOREIGN KEY accounts_ibfk_1;

INSERT INTO accounts(account_number, account_name, customer_id, branch_ID, account_type, account_status, balance, open_date)
SELECT account_number, account_name, customer_id, branch_ID, account_type, account_status, balance, open_date
FROM stg_accounts;
-- THEN ADDED THE FOREIGN KEY
ALTER TABLE accounts ADD FOREIGN KEY (customer_id) REFERENCES customers (customer_id);

-- INSERTING STG_TRANSACTIONS TO TRANSACTIONS TABLE
INSERT INTO transactions(transaction_code, account_number, transaction_type, amount, transaction_date, transaction_time, transaction_cost)
SELECT transaction_code, account_number, NULLIF(transaction_type, 'Unknown'), amount, transaction_date, transaction_time, transaction_cost
FROM stg_transactions;

-- INSERTING STG_LOANS TO LOANS TABLE

INSERT INTO loans(loan_id, customer_id, account_number, date_taken, offered_amount, return_period, rate, payment_date, returned_amount)
SELECT loan_id, customer_id, account_number,STR_TO_DATE(date_taken,  '%d/%m/%Y %H:%i'), offered_amount, return_period, rate, STR_TO_DATE(payment_date, '%d/%m/%Y %H:%i'), returned_amount
FROM stg_loans2;