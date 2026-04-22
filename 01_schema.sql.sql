CREATE DATABASE Bank_analytics;
-- Creating 5 tables that will be used in the bank analytics
-- list of the tables customers, Branchs, Accounts, Transaction, Loans

CREATE TABLE Customers(
customer_id INT PRIMARY KEY,
first_name VARCHAR(20),
last_name VARCHAR(20),
gender ENUM('Male', 'Female', 'Other'),
DOB DATE,
email VARCHAR(50),
city VARCHAR(20)
);
CREATE TABLE Branches(
branch_ID INT PRIMARY KEY,
branch_name VARCHAR(20),
city VARCHAR(20),
location VARCHAR(20)
);

CREATE TABLE Accounts(
account_number VARCHAR(20) PRIMARY KEY,
account_name VARCHAR(20),
customer_id int,
branch_ID int,
account_type ENUM('savings accounts', 'current accounts', 'fixed deposit accounts', 'Salary Account'),
account_status ENUM('active', 'inactive','suspended'),
balance DECIMAL(10,2),
open_date DATE,

FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) ,
FOREIGN KEY (branch_ID) REFERENCES Branches(branch_ID)
);

CREATE TABLE Transactions(
transaction_code VARCHAR(10) PRIMARY KEY,
account_number VARCHAR(20),
transaction_type ENUM('Deposit','Withdraw', 'Fund Transfers', 'Payments'),
amount DECIMAL(10,2),
transaction_date DATE,
transaction_time TIME,
transaction_cost DECIMAL(10,2),

FOREIGN KEY (account_number) REFERENCES Accounts(account_number)
);

CREATE TABLE Loans(
loan_id int PRIMARY KEY,
customer_id INT,
account_number VARCHAR(20),
date_taken DATETIME,
offered_amount DECIMAL(10,2),
return_period INT,
rate DECIMAL(9,6),
payment_date DATETIME,
returned_amount DECIMAL(10,2),

FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
FOREIGN KEY (account_number) REFERENCES Accounts(account_number)
);
