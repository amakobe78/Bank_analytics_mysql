# Bank Customer Analytics System — MySQL

## Project Overview

This project builds a complete bank analytics system using MySQL. It looks at customer data, branch performance, transactions, and loans to help a bank understand how its business is running. The data covers 5 areas of a bank — customers, branches, accounts, transactions, and loans — and the project goes from building the database all the way to generating business insights.

---

## Database Schema

This project uses 5 tables:

- **Customers** — Stores personal details about each bank customer, such as their name, gender, date of birth, email, and city.
- **Branches** — Stores information about each bank branch, including the branch name, city, and location.
- **Accounts** — Stores each bank account linked to a customer and a branch, along with the account type, status, balance, and opening date.
- **Transactions** — Records every transaction made on an account, including the type of transaction (deposit, withdrawal, transfer, or payment), the amount, date, time, and transaction cost.
- **Loans** — Stores loan records for customers, including the amount offered, repayment period, interest rate, payment date, and amount returned.

---

## Project Phases

- **Phase 1 — Database Design:** Designed the structure of all 5 tables and defined the relationships between them using foreign keys.
- **Phase 2 — Building The Database:** Created the database and all tables in MySQL using the schema design from Phase 1.
- **Phase 3 — Data Cleaning:** Imported raw CSV data into staging tables, then checked for and fixed missing values, duplicate rows, and outliers in all 5 datasets before moving the data forward.
- **Phase 4 — Production Load:** Moved the cleaned staging data into the main production tables, handling data type conversions and foreign key constraints along the way.
- **Phase 5 — Analytical Queries:** Wrote SQL queries to answer key business questions about customers, transactions, loan targeting, and branch loan default rates.
- **Phase 6 — Advanced Analytics:** Built reusable views, stored procedures, and a full branch performance dashboard query to make the analysis easy to repeat and share.

---

## Key Business Insights

1. **Kisumu has the most customers (25).** The bank should consider investing more resources and marketing in Kisumu since it already has a large customer base there.

2. **Transaction volumes are highest between 11AM and 3PM, with 2PM being the busiest hour.** The bank should make sure it has enough staff available during these hours to handle the peak load.

3. **November is the busiest month for transactions while January is the quietest.** The bank can use this pattern to plan staffing, cash flow, and marketing campaigns in advance.

4. ** 96 eligible customers where 84 customers have no loan history and 12 customers have already paid back a previous loan.** The bank should offer premium loan products to the 12 customers with a good repayment record, and use smaller introductory loans to test the 84 with no history.

5. **Some branches like Thika have very high loan default rates.** The loans being offered are too large compared to what customers can realistically repay, and the branch may not be following up properly on repayments.

6. **Nakuru leads all branches with the highest total account balance (KSh 7,786,127.42)** but still carries a 30% loan default rate, showing that even strong branches need better loan recovery processes.

---

## Skills Demonstrated

- Database design and schema creation with foreign key relationships
- Data import and staging using MySQL's Data Import Wizard
- Data cleaning: handling NULL values, empty cells, duplicates, and outliers
- Data type conversions (DECIMAL, DATE, TIME, DATETIME)
- SQL window functions: `ROW_NUMBER()`, `RANK()`, `PARTITION BY`
- Common Table Expressions (CTEs) for multi-step queries
- Subqueries and correlated subqueries
- Aggregate functions: `SUM()`, `COUNT()`, `AVG()`, `ROUND()`
- `CASE WHEN` logic for data classification and risk categorization
- Creating and using SQL Views
- Writing and calling Stored Procedures with input parameters
- Building a multi-CTE dashboard query joining all tables

---

## Tools Used

- **MySQL** — Database management and all SQL queries
- **MySQL Workbench** — Writing queries and managing the database
- **MySQL Data Import Wizard** — Importing raw CSV files into staging tables
- **CSV files** — Source data for all 5 tables

---

## How To Run This Project

Run the SQL files in this exact order:

| Step | File | What It Does |
|------|------|--------------|
> **Data:** Import the CSV files from the `/data` folder 
> into their corresponding staging tables using 
> MySQL Workbench Table Import Wizard before running Step 2.
| 1 | `01_schema.sql` | Creates the database and all 5 tables |
| 2 | `02_data_cleaning.sql` | Imports raw data into staging tables and cleans it |
| 3 | `03_production_load.sql` | Moves clean data from staging into the main tables |
| 4 | `04_analysis_queries.sql` | Runs business analysis queries |
| 5 | `05_views.sql` | Creates the 3 reusable views |
| 6 | `06_stored_procedures.sql` | Creates the 3 stored procedures |
| 7 | `07_dashboard.sql` | Runs the full branch performance dashboard query |

> **Note:** You must run the files in order. Each step depends on the one before it. Do not skip steps.