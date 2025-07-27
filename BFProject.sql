CREATE SCHEMA LOAN;

-- Create Customers table
CREATE TABLE loan.Customers (
    customer_id UUID PRIMARY KEY,
    years_in_current_job VARCHAR(20),
    home_ownership VARCHAR(50)
);

-- Create Loans table
CREATE TABLE loan.Loans (
    loan_id UUID PRIMARY KEY,
    customer_id UUID REFERENCES loan.Customers(customer_id),
    loan_status VARCHAR(20),
    current_loan_amount INT,
    term VARCHAR(20),
    loan_type VARCHAR(100),
    credit_score FLOAT,
    annual_income FLOAT,
    monthly_debt FLOAT,
    years_credit_history FLOAT,
    months_since_last_delinquent FLOAT,
    number_open_accounts INT,
    number_credit_problems INT,
    current_credit_balance INT,
    maximum_open_credit INT,
    bankruptcies FLOAT,
    tax_liens FLOAT
);
/* QUERIES TO GAIN BUSINESS INSIGHTS*/


--QUERY 1: Average Loan Amount by Loan Type
SELECT 
	Loan_type,
COUNT(*) AS total_loans,
ROUND(AVG(current_loan_amount), 2) AS avg_loan_amount
FROM loan.Loans
GROUP BY loan_type
ORDER BY avg_loan_amount DESC;

--QUERY 2: CREDIT SCORE ANALYSIS
SELECT c.customer_id, l.credit_score,
       COUNT(*) AS count
FROM loan.customers c
JOIN loan.loans l
ON c.customer_id = l.customer_id
WHERE l.credit_score IS NOT NULL
GROUP BY c.customer_id, l.credit_score
ORDER BY l.credit_score DESC
LIMIT 5;

--QUERY 3: MONTHLY REVENUE FROM PERFORMING LOANS

SELECT ROUND(SUM(monthly_debt)::NUMERIC, 2) AS expected_monthly_income
FROM loan.loans
WHERE loan_status = 'Fully Paid';


--QUERY 4: Months passed since a borrower last missed a scheduled loan payment

SELECT l.credit_score,l.current_loan_amount
FROM loan.loans l
JOIN loan.customers c ON l.customer_id = c.customer_id
WHERE l.credit_score IS NOT NULL
ORDER BY l.current_loan_amount
LIMIT 10;

-- QUERY 5: Total number of Open Accounts per customer:
select c.customer_id, l.number_open_accounts
from loan.customers c
join loan.loans l ON c.customer_id = l.customer_id
where l.number_open_accounts IS NOT NULL
order by l.number_open_accounts DESC
LIMIT 10;

--QUERY 6: Number pf Credit Problems
select c.customer_id, l.months_since_last_delinquent
from loan.customers c
join loan.loans l ON c.customer_id = l.customer_id
where l.months_since_last_delinquent IS NOT NULL
order by l.months_since_last_delinquent DESC
LIMIT 10;

-- 7. DEFAULT RATE BY LOAN TYPE

SELECT 
  c.years_in_current_job,
  COUNT(*) AS total_loans,
  SUM(CASE WHEN l.loan_status = 'Charged Off' THEN 1 ELSE 0 END) AS defaults,
  ROUND(100.0 * SUM(CASE WHEN l.loan_status = 'Charged Off' THEN 1 ELSE 0 END) / COUNT(*), 2) AS default_rate_percent
FROM Loans l
JOIN Customers c ON l.customer_id = c.customer_id
GROUP BY c.years_in_current_job
ORDER BY default_rate_percent DESC;


--8 OVERALL DEFAULT RATE
SELECT 
  term,
  COUNT(*) AS total_loans,
  SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) AS defaults,
  ROUND(100.0 * SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) / COUNT(*), 2) AS default_rate_percent
FROM loan.Loans
GROUP BY term
ORDER BY default_rate_percent DESC;

--QUERY 9: Loan status by Job tenure
SELECT 
    c.years_in_current_job,
    l.loan_status,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY c.years_in_current_job), 2) AS percentage
FROM loan.Loans l
JOIN loan.Customers c ON l.customer_id = c.customer_id
GROUP BY c.years_in_current_job, l.loan_status
ORDER BY c.years_in_current_job ASC
LIMIT 10;

--QUERY 10 : Home Ownership
SELECT home_ownership, term, COUNT(*) AS count
FROM loan.Loans l
JOIN loan.Customers c ON l.customer_id = c.customer_id
GROUP BY home_ownership, term
ORDER BY count,
count DESC;

-- QUERY 11. Average Loan Amount y Home Ownership
SELECT c.customer_id, l.credit_score,
       COUNT(*) AS count
FROM loan.customers c
JOIN loan.loans l
ON c.customer_id = l.customer_id
WHERE l.credit_score IS NOT NULL
GROUP BY c.customer_id, l.credit_score
ORDER BY l.credit_score DESC;

