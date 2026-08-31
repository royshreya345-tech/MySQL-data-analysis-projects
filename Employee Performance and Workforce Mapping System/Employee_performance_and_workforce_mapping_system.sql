/*
1.	Create a database named employee, then import data_science_team.csv 
proj_table.csv and emp_record_table.csv into the employee database from the given resources.
*/
CREATE database employee ;
select * from employee.data_science_team ;
select * from employee.emp_record_table;
select * from employee.proj_table ;

USE employee ;
desc data_science_team ;
desc emp_record_table ;

/*
3.	Write a query to fetch EMP_ID, FIRST_NAME, LAST_NAME, GENDER, and DEPARTMENT 
from the employee record table, 
and make a list of employees and details of their department. 
*/
USE employee ;
SELECT 
    EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT AS 'Department'
FROM
    emp_record_table
order by 1 ;

/*
4.	Write a query to fetch EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPARTMENT, 
and EMP_RATING if the EMP_RATING is: 
●	less than two
●	greater than four = WHERE EMP_RATING > 4
●	between two and four = WHERE EMP_RATING BETWEEN 2 AND 4
*/
SELECT 
    EMP_ID,
    FIRST_NAME,
    LAST_NAME,
    GENDER,
    DEPT AS 'Department',
    EMP_RATING
FROM
    emp_record_table
WHERE
    EMP_RATING < 2
    OR EMP_RATING > 4
    OR EMP_RATING BETWEEN 2 AND 4
ORDER BY 1;

/*
5.	Write a query to concatenate the FIRST_NAME and the LAST_NAME of employees 
in the Finance department from the employee table and then
give the resultant column alias as NAME.
*/
SELECT EMP_ID, DEPT as 'Department', 
UPPER(concat(TRIM(FIRST_NAME),' ',TRIM(LAST_NAME))) AS 'Name'
FROM emp_record_table
WHERE DEPT = 'Finance';

/*
6. Write a query to list only those employees 
who have someone reporting to them. 
Also, show the number of reporters (including the President).
*/

SELECT 
    e.EMP_ID AS 'Manager_ID',
    COUNT(e.EMP_ID) AS 'NumberofReportees'
FROM
    emp_record_table e
        JOIN
    emp_record_table m ON e.EMP_ID = m.MANAGER_ID
GROUP BY 1
ORDER BY 1;

/*
7.Write a query to list down all the employees from the 
healthcare and finance departments using union.
Take data from the employee record table.
*/

SELECT EMP_ID, DEPT as 'Department', 
UPPER(concat(TRIM(FIRST_NAME),' ',TRIM(LAST_NAME))) AS 'Name'
FROM emp_record_table
WHERE DEPT = 'Finance' OR DEPT = 'healthcare'
order by 2 ;

/*
8.	Write a query to list down employee details such as EMP_ID, FIRST_NAME, LAST_NAME, ROLE, DEPARTMENT,
and EMP_RATING grouped by dept. Also include the respective employee rating along with the max emp rating
for the department.
WINDOWS FUNCTION -- max() over(partiton by)
*/
SELECT EMP_ID, UPPER(concat(TRIM(FIRST_NAME),' ',TRIM(LAST_NAME))) AS 'Name',
DEPT as 'Department', ROLE, EMP_RATING,
MAX(EMP_RATING) OVER(partition by DEPT) AS 'Max_empRate_Dept'
FROM emp_record_table ;

/*
9.Write a query to calculate the minimum and the maximum salary of the employees in each role.
*/
SELECT EMP_ID, UPPER(concat(TRIM(FIRST_NAME),' ',TRIM(LAST_NAME))) AS 'Name', ROLE,SALARY,
MAX(SALARY) OVER(partition by ROLE) AS 'Max_Salary_Role',
MIN(SALARY) OVER(partition by ROLE) AS 'Min_Salary_Role'
FROM emp_record_table ;

select ROLE, max(SALARY) AS 'Max_Salary', MIN(SALARY) AS 'Min_SAlary'
from emp_record_table
group by 1 ;

/*
10.	Write a query to assign ranks to each employee based on their experience. 
*/
select EMP_ID, UPPER(concat(TRIM(FIRST_NAME),' ',TRIM(LAST_NAME))) AS 'Name',EXP,
dense_rank() OVER(order by EXP desc) AS 'DenseRankbyEXP'
from emp_record_table ;

/*
11.	Write a query to create a view that displays employees in various countries 
whose salary is more than six thousand.
*/
CREATE VIEW EmployeeSalaryView
AS
select EMP_ID, UPPER(concat(TRIM(FIRST_NAME),' ',TRIM(LAST_NAME))) AS 'Name',
COUNTRY, SALARY
from emp_record_table
WHERE SALARY > 6000 ;

select * from employeesalaryview ;

/*
12.	Write a nested query to find employees with experience of more than ten years. 
*/
SELECT 
    *
FROM
    emp_record_table
WHERE
    EMP_ID IN (SELECT 
            EMP_ID
        FROM
            emp_record_table
        WHERE
            EXP > 10);
            
select *
from emp_record_table
where EXP > 10;

/*
13.	Write a query to create a stored procedure to 
retrieve the details of the employees whose experience is more than three years. 
*/
DELIMITER //
create procedure EMP_DETAILS()
BEGIN
SELECT * FROM  emp_record_table WHERE EXP > 3 ;
END //
DELIMITER ;
call employee.EMP_DETAILS();

/*
14.	Write a query using stored functions in the project table to check whether the 
job profile assigned to each employee in the data science team matches the organization’s set standard.
The standard being:
For an employee with experience less than or equal to 2 years assign 'JUNIOR DATA SCIENTIST',
For an employee with the experience of 2 to 5 years assign 'ASSOCIATE DATA SCIENTIST',
For an employee with the experience of 5 to 10 years assign 'SENIOR DATA SCIENTIST',
For an employee with the experience of 10 to 12 years assign 'LEAD DATA SCIENTIST',
For an employee with the experience of 12 to 16 years assign 'MANAGER'.
*/
DELIMITER //
CREATE FUNCTION ASSIGN_JOB_PROFILES(Exp_in_years INT)
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
    DECLARE job_profile VARCHAR(50);
    IF Exp_in_years <= 2 THEN 
        SET job_profile = 'JUNIOR DATA SCIENTIST';
    ELSEIF Exp_in_years <= 5 THEN 
        SET job_profile = 'ASSOCIATE DATA SCIENTIST';
    ELSEIF Exp_in_years <= 10 THEN 
        SET job_profile = 'SENIOR DATA SCIENTIST';
    ELSEIF Exp_in_years <= 12 THEN 
        SET job_profile = 'LEAD DATA SCIENTIST';
    ELSEIF Exp_in_years <= 16 THEN 
        SET job_profile = 'MANAGER';
    ELSE 
        SET job_profile = 'DIRECTOR';   -- catch-all for >16 yrs so it never falls through to NULL
    END IF;
    RETURN (job_profile);
END //
DELIMITER ;


SELECT EMP_ID,EXP, ASSIGN_JOB_PROFILES(EXP)
FROM data_science_team ;
select employee.ASSIGN_JOB_PROFILES(10);
select employee.ASSIGN_JOB_PROFILES(5);

/*
15. Pay-equity query: flag employees whose salary deviates 
significantly from the average salary for their ROLE.
*/

SELECT 
    EMP_ID,
    UPPER(CONCAT(TRIM(FIRST_NAME), ' ', TRIM(LAST_NAME))) AS Name,
    ROLE,
    COUNTRY,
    SALARY,
    ROUND(avg_role_salary, 0) AS Avg_Role_Salary,
    ROUND((SALARY - avg_role_salary) / avg_role_salary * 100, 1) AS Pct_Deviation,
    CASE 
        WHEN ABS((SALARY - avg_role_salary) / avg_role_salary * 100) > 10
        THEN 'OUTLIER' 
        ELSE 'WITHIN RANGE' 
    END AS Equity_Flag
FROM (
    SELECT 
        e.*,
        AVG(SALARY) OVER (PARTITION BY ROLE) AS avg_role_salary,
        COUNT(*) OVER (PARTITION BY ROLE) AS role_count
    FROM emp_record_table e
) sub
WHERE role_count > 1         
ORDER BY ABS(Pct_Deviation) DESC;


/*
15. Stored function to calculate performance-based bonus from EMP_RATING.
Standard: 
Rating 5 -> 15% of salary
Rating 4 -> 10% of salary
Rating 3 -> 5% of salary
Rating 1-2 -> 0% (flagged for manual review instead of an automatic bonus)
*/
DELIMITER //
CREATE FUNCTION CALCULATE_BONUS(rating INT, salary INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE bonus_amt DECIMAL(10,2);
    IF rating = 5 THEN SET bonus_amt = salary * 0.15;
    ELSEIF rating = 4 THEN SET bonus_amt = salary * 0.10;
    ELSEIF rating = 3 THEN SET bonus_amt = salary * 0.05;
    ELSE SET bonus_amt = 0;  /* ratings 1-2 don't auto-qualify*/
    END IF;
    RETURN (bonus_amt);
END //
DELIMITER ;
select employee.CALCULATE_BONUS(5, 9000);

/*
16. Apply the bonus function across all employees, and flag low performers 
(rating <= 2) for manual review instead of an automatic payout.
*/
SELECT 
    EMP_ID,
    UPPER(CONCAT(TRIM(FIRST_NAME), ' ', TRIM(LAST_NAME))) AS NAME,
    DEPT,
    EMP_RATING,
    SALARY,
    CALCULATE_BONUS(EMP_RATING, SALARY) AS Bonus_Amount,
    CASE 
        WHEN EMP_RATING <= 2 THEN 'FLAGGED FOR MANUAL REVIEW'
        ELSE 'AUTO-APPROVED'
    END AS Review_Status
FROM emp_record_table
ORDER BY EMP_RATING DESC;
