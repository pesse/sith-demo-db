/* Sometimes it's important to eliminate the possibility for NULL parameters.
   I advocated to use PL/SQL subtypes to enforce that in the past
 */
create or replace package wookie_complimentor as
    subtype name_not_null is varchar2(20) not null;
    function make_compliment( i_wookie name_not_null ) return varchar2;
end;
/

create or replace package body wookie_complimentor as
    function make_compliment( i_wookie name_not_null ) return varchar2 as
    begin
        return 'You got awesome hair, '||i_wookie;
    end;
end;
/

/* It doesn't work - as it shouldn't - when inserting data directly */
select wookie_complimentor.make_compliment(null) from dual;

/* But it works when the parameter is a resultset column */
with data as (
	select cast(null as varchar2(20)) wookie from dual
)
select wookie_complimentor.make_compliment(wookie) from data;

/* It even works with a wrong datatype */
with data as (
	select cast(null as number) wookie from dual
)
select wookie_complimentor.make_compliment(wookie) from data;

/* The length constraint is also not validated  */
with data as (
	select 'Chewbacca''s son with a very long name, way more than the intended 20 chars' wookie from dual
)
select wookie_complimentor.make_compliment(wookie) from data;

/* When we add a private variable, we can at least enforce the length constraint */
create or replace package body wookie_complimentor as
    function make_compliment( i_wookie name_not_null ) return varchar2 as
      l_wookie name_not_null := i_wookie;
    begin
        return 'You got awesome hair, '||l_wookie;
    end;
end;
/

with data as (
	select 'Chewbacca''s son with a very long name, way more than the intended 20 chars' wookie from dual
)
select wookie_complimentor.make_compliment(wookie) from data;

/* But NULL and data type are still not enforced.
   The data type is just cast to varchar lazily.
 */
with data as (
	select
	  cast(null as varchar2(20)) wookie_null,
	  cast(1 as number) wookie_num
	from dual
)
select
  wookie_complimentor.make_compliment(wookie_null),
  wookie_complimentor.make_compliment(wookie_num)
from data;

/* So, if your PL/SQL API is called from SQL and you want be sure to not get NULL parameters,
   you'll need to explicitly assert for it.
 */
create or replace package body wookie_complimentor as
    function make_compliment( i_wookie name_not_null ) return varchar2 as
    begin
      if i_wookie is null then raise_application_error(-20000, 'param is NULL'); end if;
      return 'You got awesome hair, '||i_wookie;
    end;
end;
/

with data as (
	select cast(null as varchar2(20)) wookie from dual
)
select wookie_complimentor.make_compliment(wookie) from data;