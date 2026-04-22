-- Bank Dashboard
WITH loan_by_branch as(
	SELECT branch_name,city,
		COUNT(DISTINCT l.loan_id) AS total_loans,
        SUM(CASE WHEN l.Status = 'defaulted' THEN 1 ELSE 0 END) AS total_default
FROM branches br
JOIN accounts a ON br.branch_ID = a.branch_ID
JOIN loans l ON a.account_number = l.account_number
GROUP BY branch_name,city
),
Transaction_by_branch AS(
	SELECT branch_name,city,
		SUM(CASE WHEN transaction_type = 'Deposit' THEN 1 ELSE 0 END) AS total_deposit,
        COUNT(DISTINCT transaction_code) AS total_transactions,
        SUM(t.amount) AS total_transaction_value
FROM branches br
JOIN accounts a ON br.branch_ID = a.branch_ID
LEFT JOIN transactions t ON a.account_number = t.account_number
GROUP BY branch_name,city
),
cus_acc_by_branches AS (
	SELECT
		br.branch_name,br.city,
        COUNT(DISTINCT c.customer_id) AS total_customer,
		COUNT(DISTINCT a.account_number) AS total_accounts,
        SUM(a.balance) AS total_balance
FROM branches br
left JOIN accounts a ON br.branch_ID = a.branch_ID
left JOIN customers c ON a.customer_id = c.customer_id
GROUP BY br.branch_name,br.city
),
Rate_rank AS(
SELECT 
	RANK() OVER(ORDER BY cab.total_balance DESC) Branch_rank_by_total_deposit,
    cab.branch_name,cab.city,
	cab.total_customer,
    cab.total_accounts,
    cab.total_balance,
    tb.total_deposit,
    tb.total_transactions,
    tb.total_transaction_value,
	lb.total_loans,
    lb.total_default,
    ROUND((lb.total_default*100)/lb.total_loans,2) Default_rate
FROM cus_acc_by_branches AS cab
JOIN Transaction_by_branch tb  ON cab.branch_name = tb.branch_name AND cab.city = tb.city
JOIN loan_by_branch lb ON cab.branch_name = lb.branch_name AND cab.city = lb.city
)
	SELECT Branch_rank_by_total_deposit,
    branch_name,city,
	total_customer,
    total_accounts,
    total_balance,
    total_deposit,
    total_transactions,
    total_transaction_value,
	total_loans,
    total_default,
    Default_rate,
    CASE 
        WHEN default_rate >= 40 THEN 'Critical Risk'
        WHEN default_rate >= 25 THEN 'High Risk'
        WHEN default_rate >= 10 THEN 'Moderate Risk'
        ELSE 'Low Risk'
    END AS risk_category
FROM Rate_rank ;
-- from the Analysis Nakuru city is the leading with a total balance in account of KSh. 7786127.42 with a default rate 0f 30% 