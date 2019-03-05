create table characters_of_force (
  name varchar2(128) not null primary key,
  alignment varchar2(10) not null,
  constraint characters_of_force_chk
    check (alignment in ('dark','light','neutral'))
);

insert into characters_of_force
  values ('Darth Vader', 'dark');
insert into characters_of_force
  values ('Luke Skywalker', 'light');
insert into characters_of_force
  values ('Aurra Sing', 'neutral');

select * from characters_of_force;

/* We want to have constants for the possible alignment-
   values so typos are less likely and our IDE can help us
*/
create or replace package alignment_types as
  /* the constant keyword prevents the package variable
     from being overridden at a later time */
  dark constant varchar2(10) := 'dark';
  light constant varchar2(10) := 'light';
  neutral constant varchar2(10) := 'neutral';
end;
/

/* We can now use the constants from PL/SQL.
   Note how we dont need a package body if we just
   want to provide constants */
begin
  dbms_output.put_line(
    'Anakin was first aligned to '
    || alignment_types.light
    || ' but turned to '
    || alignment_types.dark
    || ' later');
end;
/

/* But we can not access package variables from SQL */
select alignment_types.light from dual;

/* To overcome this we can change our package */
create or replace package alignment_types as
  /* No public constants anymore,
     but functions without parameters */
  function light return varchar2;
  function dark return varchar2;
  function neutral return varchar2;
end;
/

create or replace package body alignment_types as
  /* Here we have our constants again,
     hiding them from public access */
  g_dark constant varchar2(10) := 'dark';
  g_light constant varchar2(10) := 'light';
  g_neutral constant varchar2(10) := 'neutral';

  /* The functions are our only publicly available item */
  function light return varchar2
  as
    begin
      return g_light;
    end;

  function dark return varchar2
  as
    begin
      return g_dark;
    end;

  function neutral return varchar2
  as
    begin
      return g_neutral;
    end;
end;
/


/* Now we can access the constant from SQL, too */
select alignment_types.light from dual;

/* We can, however, not use it in the check constraint */
alter table characters_of_force
  drop constraint characters_of_force_chk;

alter table characters_of_force
  add constraint characters_of_force_chk
  check ( alignment in
    (alignment_types.light,
     alignment_types.dark,
     alignment_types.neutral)
  );

/* But we can work around this with a virtual column */
create or replace package alignment_types as
  function light return varchar2;
  function dark return varchar2;
  function neutral return varchar2;
  /* We need a deterministic check-function */
  function valid_type(i_value in varchar2)
    return int deterministic;
end;
/

create or replace package body alignment_types as
  g_dark constant varchar2(10) := 'dark';
  g_light constant varchar2(10) := 'light';
  g_neutral constant varchar2(10) := 'neutral';

  function light return varchar2
  as
    begin
      return g_light;
    end;

  function dark return varchar2
  as
    begin
      return g_dark;
    end;

  function neutral return varchar2
  as
    begin
      return g_neutral;
    end;

  /* This function can just check against our constants */
  function valid_type(i_value in varchar2)
    return int deterministic
  as
    begin
      if ( i_value in (light, dark, neutral)) then
        return 1;
      else
        return 0;
      end if;
    end;
end;
/

/* We create a virtual column with this function */
alter table characters_of_force
  add (alignment_check number generated always as (
    alignment_types.valid_type(alignment)
  ));

/* And can then check the content of this virtual column */
alter table characters_of_force
  add constraint characters_of_force_chk
  check ( alignment_check = 1 );

insert into characters_of_force ( name, alignment )
  values ('Anakin Skywalker', 'confused');
