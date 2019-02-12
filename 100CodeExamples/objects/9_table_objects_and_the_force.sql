-- We can use attribute-only objects without
-- any methods. We dont even have to specify
-- a body in that case
create or replace type t_disturbance is object
(
  planet_name varchar2(1000),
  strength number(10,4)
);
/

-- And we can create a table of objects
-- so we can select objects from SQL
create or replace type t_disturbances
  is table of t_disturbance;
/


-- Little helper function to create
-- disturbances
create or replace function get_disturbances
  return t_disturbances
as
  l_result t_disturbances := t_disturbances();
  begin
    l_result.extend;
    l_result(1) := new t_disturbance('Alderaan', 10000);
    return l_result;
  end;
/

select *
from table(get_disturbances());

-- What if we want to change the underlying object now?
create or replace type t_disturbance is object
(
  planet_name varchar2(1000),
  strength number(10,4),
  alignment varchar2(10)
);
/

-- Error.
-- The problem is, that our object-type is a
-- dependency of the table-type.
-- But we can use the force (since 11.2)!
create or replace type t_disturbance force is object
(
  planet_name varchar2(1000),
  strength number(10,4),
  alignment varchar2(10)
);
/

-- Caution! This doesnt work if the type is used
-- in a table:
create table disturbance_history (
  id integer not null primary key,
  disturbance t_disturbance,
  occured timestamp with local time zone
    default current_timestamp
);

create or replace type t_disturbance force is object
(
  planet_name varchar2(1000),
  strength number(10,4),
  alignment varchar2(10),
  cause_name varchar2(1000)
);
/

-- So lets just not do this for the moment
drop table disturbance_history;
/

create or replace type t_disturbance force is object
(
  planet_name varchar2(1000),
  strength number(10,4),
  alignment varchar2(10),
  cause_name varchar2(1000)
);
/

-- Check for invalid objects
select * from user_objects where status <> 'VALID';

-- The table-type is invalid, but
-- we can just compile it without any
-- additional change
alter type t_disturbances compile;

-- We now need to adapt our helper function
-- because the default constructor of
-- objects requires each attribute to be
-- passed
create or replace function get_disturbances
  return t_disturbances
as
  l_result t_disturbances := t_disturbances();
  begin
    l_result.extend;
    l_result(1) := new t_disturbance('Alderaan', 10000, null, null);
    return l_result;
  end;
/

select *
from table(get_disturbances());


/**************
* Cleanup
 ***********/

drop type t_disturbances;
drop type t_disturbance;
drop function get_disturbances;
