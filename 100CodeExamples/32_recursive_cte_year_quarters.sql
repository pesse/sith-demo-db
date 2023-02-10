-- We start with the recursive CTE that gives us
-- one row per quarter per year
with year_quarter(quarter, year) as (
  -- Recursive CTEs always start with a base row
  select 1 quarter, 2023 year from dual
  union all
  -- and are then followed by sql that describes
  -- how each following row is created
  select
    -- For quarter we count backwards until 1 is reached
    case
      when prev.quarter <= 1 then 4
      else                        prev.quarter-1
    end as quarter,
    -- For year we only count backwards if quarter is 1
    case
      when prev.quarter <= 1 then prev.year-1
      else                        prev.year
    end as year
  from year_quarter prev
  -- it's very important to have a limit for the recursion
  where prev.year >= 2019
    --and prev.quarter between 1 and 4
)
select * from year_quarter
-- We will get one 2018 row by the recursive CTE
-- so let's remove it
where year >= 2019;

with year_quarter(quarter, year) as (
  select 1 quarter, 2023 year from dual
  union all
  select
    case
      when prev.quarter <= 1 then 4
      else                        prev.quarter-1
    end as quarter,
    case
      when prev.quarter <= 1 then prev.year-1
      else                        prev.year
    end as year
  from year_quarter prev
  where prev.year >= 2019
    and prev.quarter between 1 and 4
),
  dates as (
    select
      year,
      quarter,
      to_date(year||'-'||(quarter*3-2), 'YYYY-MM') start_date,
      -- we're using the very handy last_day function here
      last_day(to_date(year||'-'||(quarter*3), 'YYYY-MM')) end_date
    from year_quarter
  )
select *
from dates
where year >= 2019;

/* Example 2:
   The "and prev.quarter between 1 and 4" in the CTE is not really needed,
   but Oracle will use the columns that are use in the where clause of the
   joining select to determine the cycle columns.
   If you want to omit it, you need to add a "cycle" clause where you tell
   Oracle which columns to use for cycle detection.
 */
with year_quarter(quarter, year) as (
  select 1 quarter, 2023 year from dual
  union all
  select
    case
      when prev.quarter <= 1 then 4
      else                        prev.quarter-1
    end as quarter,
    case
      when prev.quarter <= 1 then prev.year-1
      else                        prev.year
    end as year
  from year_quarter prev
  where prev.year >= 2019
)
cycle quarter, year set is_loop to 'Y' default 'N',
dates as (
    select
      year,
      quarter,
      to_date(year||'-'||(quarter*3-2), 'YYYY-MM') start_date,
      last_day(to_date(year||'-'||(quarter*3), 'YYYY-MM')) end_date
    from year_quarter
  )
select *
from dates
where year >= 2019;