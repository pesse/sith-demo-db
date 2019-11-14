
-- Let's first investigate what we have

create or replace package deathstar_room_manager as
  subtype varchar2_nn is varchar2 not null;

  /** Adds a new room to a section
   */
  procedure add_room(
    i_name varchar2_nn,
    i_section_id simple_integer,
    i_code varchar2 default null );
end;
/

select * from deathstar_sections;
select * from deathstar_rooms;




-- Start adding a new test package for exploration
create or replace package ut_deathstar_add_rooms as
  -- %suite(Exploration: Adding rooms to the deathstar)
  -- %suitepath(ut_deathstar.rooms)

  -- %test(Add some rooms)
  procedure add_rooms;
end;
/

create or replace package body ut_deathstar_add_rooms as

  procedure add_rooms
  as
    begin
      -- Add 2 different Sections
      insert into deathstar_sections ( id, label )
        values ( -1, 'Test Section');
      insert into deathstar_sections ( id, label )
        values ( -2, 'Test Section 2');

      -- Add 2 rooms for Section 1, one for Section 2
      deathstar_room_manager.add_room('Testroom 1', -1, 'TEST1');
      deathstar_room_manager.add_room('Testroom 2', -1, 'TEST2');
      deathstar_room_manager.add_room('Testroom 3', -2, 'TEST3');
      -- Add another room without CODE provided
      deathstar_room_manager.add_room('Testroom 4 - NULL code', -1);
    end;
end;
/

call ut.run('ut_deathstar_add_rooms');



-- Oh ... great. A test showing nothing.
select * from deathstar_sections;
select * from deathstar_rooms;







-- Let's try it again with foce-manual-rollback
begin
  ut.run('ut_deathstar_add_rooms', a_force_manual_rollback=>true);
end;

select * from deathstar_sections;
select * from deathstar_rooms;

-- Oooooohhh... now we can see something.
select * from deathstar_rooms where section_id < 0;



-- Conclusions:
-- > NR_IN_SECTION is filled automatically, based on the order of adding
-- > Code seems to be auto-generated from name when not provided



-- Don't forget to rollback
rollback;

select * from deathstar_rooms where section_id < 0;


-- Let's add another room to verify our assumptions
create or replace package body ut_deathstar_add_rooms as

  procedure add_rooms
  as
    begin
      insert into deathstar_sections ( id, label )
        values ( -1, 'Test Section');
      insert into deathstar_sections ( id, label )
        values ( -2, 'Test Section 2');

      deathstar_room_manager.add_room('Testroom 1', -1, 'TEST1');
      deathstar_room_manager.add_room('Testroom 2', -1, 'TEST2');
      deathstar_room_manager.add_room('Testroom 3', -2, 'TEST3');
      deathstar_room_manager.add_room('Testroom 4 - NULL code', -1);
      -- Add another room with similar naming
      deathstar_room_manager.add_room('Testroom 5 - how will the code be', -1);
      -- And one to the 2nd section
      deathstar_room_manager.add_room('Testroom 6 - Section 2', -2);
    end;
end;
/

-- Let's investigate what happened again
begin
  ut.run('ut_deathstar_add_rooms', a_force_manual_rollback=>true);
end;

select * from deathstar_rooms where section_id < 0;
select * from deathstar_sections;

rollback;

-- SQLcl



-- Now make it an approval test
create or replace package body ut_deathstar_add_rooms as

  procedure add_rooms
  as
    c_actual sys_refcursor;
    c_expect sys_refcursor;
    begin
      insert into deathstar_sections ( id, label )
        values ( -1, 'Test Section');
      insert into deathstar_sections ( id, label )
        values ( -2, 'Test Section 2');

      deathstar_room_manager.add_room('Testroom 1', -1, 'TEST1');
      deathstar_room_manager.add_room('Testroom 2', -1, 'TEST2');
      deathstar_room_manager.add_room('Testroom 3', -2, 'TEST3');
      deathstar_room_manager.add_room('Testroom 4 - NULL code', -1);
      deathstar_room_manager.add_room('Testroom 5 - how will the code be', -1);
      deathstar_room_manager.add_room('Testroom 6 - Section 2', -2);

      -- Actual

      -- Expectation

      -- Compare them
    end;
end;
/

call ut.run('ut_deathstar_add_rooms');


-- 1. Join_by
-- 2. exclude columns we don't need










-- Add the new column
alter table deathstar_rooms
  add security_level integer default 1 not null;


-- Implement the functionality
create or replace package deathstar_room_manager as
  subtype varchar2_nn is varchar2 not null;

  /** Adds a new room to a section
   */
  procedure add_room(
    i_name varchar2_nn,
    i_section_id simple_integer,
    i_code varchar2 default null,
    i_security_level positive default null);
end;
/

create or replace package body deathstar_room_manager as
  procedure add_room(
    i_name varchar2_nn,
    i_section_id simple_integer,
    i_code varchar2 default null,
    i_security_level positive default null )
  as
    l_max_nr_in_section integer;
    l_code varchar2(20) := i_code;
    l_code_max_nr integer;
    begin
      select nvl(max(nr_in_section),0) into l_max_nr_in_section
        from deathstar_rooms
        where section_id = i_section_id;

      if ( i_code is null ) then
        l_code := upper(replace(substr(i_name, 1, 6), ' ', '_'));
        select
          nvl(max(regexp_substr(substr(code, 7), '[0-9]+', 1, 1)),0)
            into l_code_max_nr
          from deathstar_rooms
          where
            substr(code, 1, 6) = l_code
            and regexp_like(substr(code, 7), '^[0-9]+$');

        l_code := l_code || to_char(l_code_max_nr+1);
      end if;

      insert into deathstar_rooms ( name, code, section_id, nr_in_section, security_level )
        values ( i_name, l_code, i_section_id, l_max_nr_in_section+1, nvl(i_security_level,1));
    end;
end;
/



call ut.run('ut_deathstar_add_rooms');


-- Improve test for new functionality
-- We want a new column "security_level"
create or replace package body ut_deathstar_add_rooms as

  procedure add_rooms
  as
    c_actual sys_refcursor;
    c_expect sys_refcursor;
    begin
      insert into deathstar_sections ( id, label )
        values ( -1, 'Test Section');
      insert into deathstar_sections ( id, label )
        values ( -2, 'Test Section 2');

      -- We expect the new add_room procedure to have an additional parameter
      deathstar_room_manager.add_room('Testroom 1', -1, 'TEST1', 1);
      deathstar_room_manager.add_room('Testroom 2', -1, 'TEST2', 2);
      deathstar_room_manager.add_room('Testroom 3', -2, 'TEST3', 3);
      -- Default value of security_level parameter
      deathstar_room_manager.add_room('Testroom 4 - NULL code', -1);
      -- NULL-value of code parameter
      deathstar_room_manager.add_room('Testroom 5 - how will the code be', -1, null, 4);
      deathstar_room_manager.add_room('Testroom 6 - Section 2', -2, null, 4);

      -- Insert our new expectation
      open c_expect for
      	select 43 id , 'Testroom 1' name                   , 'TEST1' code , -1 section_id , 1 nr_in_section, 1 security_level  from dual union all
        select 44    , 'Testroom 2'                        , 'TEST2'      , -1            , 2              , 2                 from dual union all
        select 45    , 'Testroom 3'                        , 'TEST3'      , -2            , 1              , 3                 from dual union all
        select 46    , 'Testroom 4 - NULL code'            , 'TESTRO1'    , -1            , 3              , 1                 from dual union all
        select 47    , 'Testroom 5 - how will the code be' , 'TESTRO2'    , -1            , 4              , 4                 from dual union all
        select 48    , 'Testroom 6 - Section 2'            , 'TESTRO3'    , -2            , 2              , 4                 from dual;

      open c_actual for
        select * from deathstar_rooms where section_id < 0 order by id desc;

      ut.expect(c_actual)
        .to_equal(c_expect)
        .exclude(ut_varchar2_list('ID'))
        .join_by('CODE')
      ;
    end;
end;
/

call ut.run('ut_deathstar_add_rooms');