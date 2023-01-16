-- Normal approach with case when logic. Very verbose.
with test_data as (
  select 'Chewbacca' wookie_name, 86 age from dual union all
  select null                   , null   from dual
)
select
  td1.wookie_name wookie_name1,
  td2.wookie_name wookie_name2,
  case when (
          td1.wookie_name is not null
      and td2.wookie_name is not null
      and td1.wookie_name = td2.wookie_name)
    or (
          td1.wookie_name is null
      and td2.wookie_name is null)
    then 'equal'
    else 'not equal'
  end names_match
from test_data td1
  cross join test_data td2
;

-- This can be shortened a little bit, because a = b will always fail if a is not null and b is
-- But still, very verbose
with test_data as (
  select 'Chewbacca' wookie_name, 86 age from dual union all
  select null                   , null   from dual
)
select
  td1.wookie_name wookie_name1,
  td2.wookie_name wookie_name2,
  case when (
          td1.wookie_name is not null
      and td1.wookie_name = td2.wookie_name)
    or (
          td1.wookie_name is null
      and td2.wookie_name is null)
    then 'equal'
    else 'not equal'
  end names_match
from test_data td1
  cross join test_data td2
;

-- We can also use that neat DECODE function to compare data NULL-aware
with test_data as (
  select 'Chewbacca' wookie_name, 86 age from dual union all
  select null                   , null   from dual
)
select
  td1.wookie_name wookie_name1,
  td2.wookie_name wookie_name2,
  decode(td1.wookie_name, td2.wookie_name, 'equal', 'not equal') names_match
from test_data td1
  cross join test_data td2
;

-- This works with all data types, which is pretty awesome
with test_data as (
  select 'Chewbacca' wookie_name, 86 age from dual union all
  select null                   , null   from dual
)
select
  td1.age age1,
  td2.age age2,
  decode(td1.age, td2.age, 'equal', 'not equal') age_match
from test_data td1
  cross join test_data td2
;

-- And you can use it in the where-clause, too
with test_data as (
  select 'Chewbacca' wookie_name, 86 age from dual union all
  select null                   , null   from dual
)
select
  td1.wookie_name wookie_name1,
  td2.wookie_name wookie_name2
from test_data td1
  cross join test_data td2
where decode(td1.wookie_name, td2.wookie_name, 1, 0) = 1
