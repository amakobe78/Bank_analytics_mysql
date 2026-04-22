-- CREATING STORED PROCEDURE for get_customer_accounts,get_branch_performance and get_transaction_by_month
DELIMITER $$

CREATE PROCEDURE get_customer_accounts(IN cust_id INT)
BEGIN 
	SELECT 
		CONCAT(c.first_name, ' ' , c.last_name) AS customer_name,
        a.account_number,
        a.account_type,
        a.account_status,
        a.balance
	FROM customers c
    JOIN accounts a ON c.customer_id = a.customer_id
    where c.customer_id = cust_id;
END $$

DELIMITER ;
CALL get_customer_accounts(5);

-- CREATING A PROCEDURE FOR BRANCH PERFOMANCE
DELIMITER $$

CREATE PROCEDURE get_branch_performance(p_branch_name VARCHAR(50))
BEGIN 
	SELECT *
    FROM branch_default_rates
    WHERE branch_name = p_branch_name;
END $$

DELIMITER ;

CALL get_branch_performance('Meru Branch');
CALL get_branch_performance('Thika Branch');

-- CRETING A PROCEDURE FOR TRANSACTION BY MONTH
DELIMITER $$

CREATE PROCEDURE get_transaction_by_month(month_number INT)
BEGIN 
	SELECT *
    FROM monthly_transaction_summary
    WHERE month = month_number;
END $$

DELIMITER ;

CALL get_transaction_by_month(5);
CALL get_transaction_by_month(11);