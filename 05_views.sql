-- Creating 3 views for branch_default_rates,loan_target_customers and monthly_transaction_summary
CREATE VIEW branch_default_rates AS
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

CREATE VIEW loan_target_customers AS
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

CREATE VIEW monthly_transaction_summary AS
SELECT  SUM(amount) total_amount, MONTH(transaction_date) AS month
FROM transactions
GROUP BY  month
ORDER BY total_amount DESC;

-- SHOWING FULL TABLES
SHOW FULL TABLES 
WHERE Table_type = 'VIEW';

SELECT * 
FROM branch_default_rates