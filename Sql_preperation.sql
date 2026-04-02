--//Second Heighest Salary//
select max(salary) as SecondHighestSalary
from Employee
where salary < (select max(salary) from Employee);

-- Second Heighest Salary using DENSE_RANK
with ranked_salaries as (
    select *,dense_rank() over(order by salary desc) as rnk
    from Employee
)
select salary as SecondHighestSalary
from ranked_salaries
where rnk = 2;


--2. Duplicate Emails
select count(*) as count, email from users
group by email
having count(*) > 1

--3. Employees Above Average Salary

select * from Employee
where salary > (select avg(salary) from Employee);

--4.Total Salary per Department
select sum(salary), dept_id from Employee
group by dept_id;

--5.Count Employees per Department
select count(*), dept_id from Employee
group by dept_id;

--6.Highest 2nd heighest Salary per Department

with ranked_salaries as (
    select *,dense_rank() over(partition by dept_id order by salary desc) as rnk
    from Employee
)
select dept_id, salary as SecondHighestSalary
from ranked_salaries
where rnk = 2;


---7.Employees Without Department

select e.* from employee e
Left join department d
on e.id = d.id
where d.dept_id is null;

--8. Top 3 Salaries
select distinct salary from employee
order by sal desc
Limit 3

---Using Ranking

with ranking as (
    select *, dense_rank() over(order by salary desc) as rnk from employees 
)

select * from ranking
where rnk<=3

---9.Recent Joinees
--Table: employees(joining_date)
--👉 Find employees who joined in last 30 days.
select employ_name,Joining_date 
from Employee
where joining_date >=current_date()- INTERVAL '30 days';

-- 11. Rank Employees by Salary
-- 👉 Rank employees within each department.

With ranking as (
    select employ_name,salary,
    dense_rank() over(PARTITION by department, order by salary desc)
) as rank

select * fromm ranking;

-- 12. Running Total
-- Table: sales(date, amount)
-- 👉 Calculate cumulative sales.

with running_total as (
    select date, amount,
    SUM (amount) over(order by date) as runn_total
    from sales
)
select * from running_total

-- 13. Remove Duplicates (Keep Latest)
-- Table: orders(id, user_id, order_date)
-- 👉 Keep only latest order per user, delete others.

with rnk_dulicates as(
    select *,
    with row_number() over(partition by user_id order by date desc) as rnk
)
delete from rnk_dulicates
where rnk > 1

-- 14. Find Missing IDs
-- 👉 Find gaps in sequence of IDs.

with recursive missing_id as(
    select 
    id + 1 as missing_id,
    lead(id) over (order by id) as next_id
    from user

    union all

    select missing_id + 1,
    next_id
    from missing_id
    where missing_id+1 <next_id
)
 select missing_id from missing_id 
 where missing_id < next_id;

--16. Customers with No Orders
-- Tables:
-- customers(id, name)
-- orders(id, customer_id)
-- 👉 Find customers who never placed orders.

select c.* from customer as c 
left join orders as o
on c.id=o.customer_id
where o.customer_id is null

--Customers with exactly 1 order

select c.* from customer as c 
left join orders as o
on c.id=o.customer_id
group by c.name,c.id
having(o.id) =1

---Customers with more than 3 orders
select c.* from customer as c 
left join orders as o
on c.id=o.customer_id
group by c.name,c.id
having(c.id) >=3

---Customers with no orders in last 30 days

select c.id,
c.name,
o.oreder_date
left join orders as o
on c.id=o.customer_id
where order_date is null 
and order_date =  >=current_date()- INTERVAL '30 days';


--17.Highest Salary Employee per Department (Full Row)
--👉 Return complete employee details.

with ranked as(
    select *,dense_rank() over(partition by dept_id, order by salary desc) as rnk
    from employee
)
select * from ranked 
where rnk=1


-- 18. Consecutive Login Days
-- Table: logins(user_id, login_date)
-- 👉 Find users who logged in 3 consecutive days.

with logins_x as(
    select *,
    row_number() over(partition by user_id order by login_date) as rnk
    from logins
),

group as (
    select *,
    login_date - rnk * interval '1 day' as grp_key
    from logins_x 
) 

select user_id
from group
group by user_id,grp_key
Having count(*)>= 3










