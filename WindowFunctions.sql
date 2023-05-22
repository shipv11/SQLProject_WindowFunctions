
###############################################################
-- SQL Window Functions
###############################################################


-- 1: Viewing all the data in the projectdb database
SELECT * FROM employees;
SELECT * FROM departments;
SELECT * FROM regions;
SELECT * FROM customers;
SELECT * FROM sales;


-- 2: Retrieving a list of employee_id, first_name, hire_date, 
-- and department of all employees ordered by the hire date
SELECT employee_id, first_name, department, hire_date,
ROW_NUMBER() OVER (ORDER BY hire_date) AS Row_N
FROM employees;

-- 3: Retrieving the employee_id, first_name, 
-- hire_date of employees for different departments
SELECT employee_id, first_name, department, hire_date,
ROW_NUMBER() OVER (partition by department 
                   ORDER BY hire_date) AS Row_N
FROM employees;


-- 4: Using ROW_NUMBER()
SELECT first_name, email, department, salary,
ROW_NUMBER() OVER(PARTITION BY department
				  ORDER BY salary DESC)
FROM employees;

-- 5:  Using the RANK() function
SELECT first_name, email, department, salary,
rank() OVER(PARTITION BY department
				  ORDER BY salary DESC) rank_n
FROM employees;

-- 6: Retrieving the hire_date. Return details of
-- employees hired on or before 31st Dec, 2005 and are in
-- First Aid, Movies and Computers departments 
SELECT first_name, email, department, salary, hire_date,
RANK() OVER(PARTITION BY department
			ORDER BY salary DESC)
FROM employees
where hire_date <= '2005-12-31' 
AND department in ('First Aid','Movies','Computers') ;

-- This returns how many employees are in each department
SELECT department, COUNT(*) dept_count
FROM employees
GROUP BY department
ORDER BY dept_count DESC;

-- 7: Returning the fifth ranked salary for each department
select * from 
(SELECT first_name, email, department, salary,
rank() OVER(PARTITION BY department
				  ORDER BY salary DESC) rank_n
FROM employees) t1
where rank_n = 5;

-- Creating a common table expression to retrieve the customer_id, 
-- and how many times the customer has purchased from the mall 
WITH purchase_count AS (
SELECT customer_id, COUNT(sales) AS purchase
FROM sales
GROUP BY customer_id
ORDER BY purchase DESC
)
-- 8: Understanding the difference between ROW_NUMBER, RANK, DENSE_RANK
SELECT customer_id, purchase,
ROW_NUMBER() OVER (ORDER BY purchase DESC) AS Row_N,
RANK() OVER (ORDER BY purchase DESC) AS Rank_N,
DENSE_RANK() OVER (ORDER BY purchase DESC) AS Dense_Rank_N
FROM purchase_count
ORDER BY purchase DESC;


-- 9: Grouping the employees table into five groups
-- based on the order of their salaries
select first_name , department , salary , ntile(5) over(order by salary desc) as group1
from employees e 

-- 10: Grouping the employees table into five groups for 
-- each department based on the order of their salaries
SELECT first_name, email, department, salary,
NTILE(5) OVER(PARTITION BY department
			  ORDER BY salary DESC)
FROM employees;


-- Creating a CTE that returns details of an employee
-- and grouping the employees into five groups
-- based on the order of their salaries
WITH salary_ranks AS (
SELECT first_name, email, department, salary,
NTILE(5) OVER(ORDER BY salary DESC) AS rank_of_salary
FROM employees)
-- 11: Finding the average salary for each group of employees
select rank_of_salary, avg(salary)
from salary_ranks
group by rank_of_salary
order by rank_of_salary


-- 12: This returns how many employees are in each department
SELECT department, COUNT(*) AS dept_count
FROM employees
GROUP BY department
ORDER BY department;

-- 13: Retrieving the first names, department and 
-- number of employees working in that department
SELECT first_name, department, 
COUNT(*) over(partition by department ORDER by department) AS dept_count
FROM employees e


-- 14: Total Salary for all employees
select first_name , department , hire_date ,
sum(salary) over(order by hire_date) as totalsalary
from employees e 


-- 15: Total Salary for each department
select first_name , department , hire_date ,
sum(salary) over(partition by department order by department) as totalsalary
from employees e 


-- 16: Total Salary for each department and
-- ordered by the hire date.
SELECT first_name, hire_date, department, salary,
sum(salary) over(partition by department order by hire_date) as running_total
FROM employees;


-- Retrieving the different region ids
SELECT DISTINCT region_id
FROM employees;

-- 17: Retrieving the first names, department and 
-- number of employees working in that department and region
SELECT first_name, department, 
count(*)OVER(partition by department) AS dept_count, region_id,
count(*)OVER(partition by region_id) AS region_count
FROM employees


-- 18: Retrieving the first names, department and 
-- number of employees working in that department and in region 2
SELECT first_name, department, 
count(*)OVER(partition by department) AS dept_count
FROM employees
where region_id = 2;


-- Creating a common table expression to retrieve the customer_id, 
-- ship_mode, and how many times the customer has purchased from the mall
WITH purchase_count AS (
SELECT customer_id, ship_mode, COUNT(sales) AS purchase
FROM sales
GROUP BY customer_id, ship_mode
ORDER BY purchase DESC
)
-- 19: Calculating the cumulative sum of customers purchase
-- for the different ship mode
SELECT customer_id, ship_mode, purchase, 
sum(purchase) OVER(partition  by ship_mode
				   ORDER BY customer_id ASC) AS sum_of_sales
FROM purchase_count;


-- 20: Calculating the running total of salary
SELECT first_name, hire_date, salary,
sum(salary) over(order by hire_date
                 range between
                 unbounded preceding and current row)
FROM employees


-- 21: Adding the current row and previous row
SELECT first_name, hire_date, salary,
sum(salary) over(order by hire_date
                 rows between
                 1 preceding and current row)
FROM employees


-- 22: Finding the running average
SELECT first_name, hire_date, salary,
avg(salary) over(order by hire_date
                 range between
                 unbounded preceding and current row)
from employees e 



-- 23: Using the FIRST_VALUE() function
SELECT department, division,
FIRST_VALUE(department) OVER(ORDER BY department ASC) first_department
FROM departments;

-- 24: Retrieving the last department in the departments table
SELECT department, division,
last_value(department) OVER(ORDER BY department asc
                            range between unbounded preceding
                            and unbounded following) last_department
FROM departments;



-- 25: Finding the sum of the quantity for different ship modes
SELECT ship_mode, SUM(quantity) 
FROM sales
GROUP BY ship_mode;

-- 26: Finding the sum of the quantity for different categories
SELECT category, SUM(quantity) 
FROM sales
GROUP BY category;

-- 27: Finding the sum of the quantity for different subcategories
SELECT sub_category, SUM(quantity) 
FROM sales
GROUP BY sub_category;


-- 28: Using the GROUPING SETS clause
SELECT ship_mode , category , sub_category, SUM(quantity) 
FROM sales
GROUP by grouping sets (ship_mode, category, sub_category, ()); -- first row returns the grand total


--  29: Using the ROLLUP clause
SELECT ship_mode , category , sub_category, SUM(quantity) 
FROM sales
GROUP by rollup (ship_mode, category, sub_category);


-- 30: Using the CUBE clause
SELECT ship_mode , category , sub_category, SUM(quantity) 
FROM sales
GROUP by cube (ship_mode, category, sub_category);
