-- analytical quaries
-- WHICH CITY HAS MOST CUSTOMERS
SELECT city,  COUNT(*) AS Customers_per_city
FROM customers
GROUP BY city
ORDER BY Customers_per_city DESC;
-- Kisumu has most customers leading with 25 customers

-- CUSTOMER HAVING MOST ACCOUNTS AND THE STATUS OF EACH
SELECT acc.customer_id, CONCAT(cus.first_name, ' ', cus.last_name) AS full_name, acc.account_name, acc.account_status,
 COUNT(*) OVER(PARTITION BY customer_id) AS total_accounts
FROM accounts AS acc
JOIN customers AS cus
ON acc.customer_id = cus.customer_id
ORDER BY total_accounts DESC;
-- FROM THE THE ANALYSIS i FOUND OUT George Njeru is the customer with most accounts(5) and the status of his accounts are active 

-- At what time do we have the largest transactions?
SELECT  SUM(amount) as Transaction_volume, HOUR(transaction_time) Hour
FROM transactions
GROUP BY  hour
order by Transaction_volume DESC;
-- We have largest transaction volumes between 11AM and 3PM

-- At What Time Of Day Do We Have The Most Transactions
SELECT  COUNT(amount) number_of_transaction, HOUR(transaction_time) hour
FROM transactions
GROUP BY  hour
ORDER BY number_of_transaction DESC;
-- 2PM is the busiest hour both by volume and by total amount. That is a consistent and reliable insight. 
-- A bank manager could use this to ensure maximum staff availability between 11AM and 3PM

-- At What Month Do We Have The Largest Transactions
SELECT  SUM(amount) Transaction_volume, MONTH(transaction_date) AS month
FROM transactions
GROUP BY  month
ORDER BY Transaction_volume DESC;
-- November sees the highest transaction volumes while January is the quietest month. 
-- A bank could use this to plan staffing, liquidity and marketing campaigns around these patterns.

-- Which Customer Segments Should Be Targeted For Loans
SELECT 
    CONCAT(cus.first_name, ' ', cus.last_name) AS full_name,
    acc.account_type,
    acc.account_status,
    acc.balance,
    CASE 
        WHEN acc.account_number NOT IN (
            SELECT account_number FROM Loans) 
        THEN 'No Loan History'
        WHEN acc.account_number IN (
            SELECT account_number FROM Loans 
            WHERE Status = 'paid') 
        THEN 'Paid Previous Loan'
        WHEN acc.account_number IN (
            SELECT account_number FROM Loans 
            WHERE Status = 'defaulted') 
        THEN 'Defaulted Previous Loan'
        ELSE 'Unknown'
    END AS loan_segment
FROM Customers cus
JOIN Accounts acc ON cus.customer_id = acc.customer_id
WHERE acc.account_status = 'active'
	AND acc.account_number NOT IN (
		SELECT account_number FROM Loans 
		WHERE Status = 'active'
)
	AND acc.account_number NOT IN (
		SELECT account_number FROM Loans
		WHERE Status = 'defaulted'
)
	AND acc.balance IS NOT NULL
ORDER BY acc.balance DESC;
-- The bank should prioritize the 12 customers with paid loan history for premium loan products since they have demonstrated they can repay.
-- The 84 customers with no loan history should be targeted with introductory loan products with smaller amounts to establish creditworthiness.

-- Which branches have the highest loan default rates?
WITH branch_loan_summary AS (
    SELECT 
        br.branch_name,
        br.city,
        COUNT(l.loan_id)                                    AS total_loans,
        SUM(CASE WHEN l.Status = 'defaulted' THEN 1 
            ELSE 0 END)                                     AS total_defaults,
        SUM(CASE WHEN l.Status = 'paid' THEN 1 
            ELSE 0 END)                                     AS total_paid,
        ROUND(AVG(l.offered_amount), 2)                     AS avg_loan_amount,
        ROUND(AVG(CASE WHEN l.Status = 'defaulted' 
            THEN l.offered_amount END), 2)                  AS avg_defaulted_loan,
        ROUND(AVG(acc.balance), 2)                          AS avg_customer_balance
    FROM branches br
    JOIN accounts acc ON br.branch_ID = acc.branch_ID
    JOIN loans l ON acc.account_number = l.account_number
    GROUP BY br.branch_name, br.city
),
branch_rates AS (
    SELECT *,
        ROUND((total_defaults * 100.0) / total_loans, 2)   AS default_rate,
        ROUND((total_paid * 100.0) / total_loans, 2)       AS repayment_rate,
        RANK() OVER (ORDER BY 
            (total_defaults * 100.0) / total_loans DESC)   AS risk_rank
    FROM branch_loan_summary
    WHERE total_loans > 0
)
SELECT 
    risk_rank,
    branch_name,
    city,
    total_loans,
    total_defaults,
    total_paid,
    default_rate,
    repayment_rate,
    avg_loan_amount,
    avg_defaulted_loan,
    avg_customer_balance,
    CASE 
        WHEN default_rate >= 40 THEN 'Critical Risk'
        WHEN default_rate >= 25 THEN 'High Risk'
        WHEN default_rate >= 10 THEN 'Moderate Risk'
        ELSE 'Low Risk'
    END AS risk_category
FROM branch_rates
ORDER BY risk_rank;
-- The loans are too large relative to customer balances. 
-- Thika Branch may be approving loans that customers cannot realistically repay based on their financial position.
-- Customers have decent balances but almost nobody repays. That points to a loan management problem not a customer financial problem. 
-- The branch may not be following up on repayments or may have weak loan recovery processes
-- Meru Similar to Eldoret — systemic follow up failure