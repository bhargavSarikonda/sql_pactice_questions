--1. Sessionization Problem
-- Table: events(user_id, event_time)
-- 👉 Group events into sessions (30 min gap rule).


with sessionizati as(
    select*,
    lead(event_time) over(partition by user_id order by event_time) next_time
from events
),
cal as(
    select*,
    case
        when (next_time - event_time) > interval '30 min' then 1 
        when next_time is null then 1 
        else 0
    end as is_new_session
 from sessionizati
)

select *,
sum(is_new_session) over(partition by user_id order by event_time ) as session_id
 from cal


--2. Detect Duplicate Transactions
-- Table: transactions(user_id, amount, timestamp)
-- 👉 Find duplicate transactions within 10 minutes.

 with trans as(
    select*,
    lag(timestamp) over(partition by user_id,amount order by timestamp) as prev_trans
    from transactions
 )

select * from trans 
where timestamp - prev_trans <= interval '10 minuts' and
      prev_trans is null

--3. Rolling Average
-- 👉 Calculate 7-day rolling average of sales.

SELECT 
    sale_date,
    sales,
    AVG(sales) OVER (
        ORDER BY sale_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS rolling_avg_7_days
FROM sales;

