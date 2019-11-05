/*
--------------------------------------------------------------------------------
Setup
-------------------------------------------------------------------------------
*/
create table deathstar_sections (
  id integer not null primary key,
  label varchar2(200)
);

create table deathstar_rooms (
  id integer generated by default on null as identity primary key,
  name varchar2(200) not null,
  code varchar2(200) not null unique,
  section_id integer not null,
  nr_in_section integer,
  constraint deathstar_rooms_fk_section foreign key (section_id)
    references deathstar_sections( id )
);

insert into deathstar_sections(id, label) values ( 1, 'Section 1');
insert into deathstar_sections(id, label) values ( 2, 'Bridge');

insert into deathstar_rooms ( name, code, section_id, nr_in_section ) values ( 'Engine Room 1', 'ENG1', 1, 1 );
insert into deathstar_rooms ( name, code, section_id, nr_in_section ) values ( 'Vaders Chamber', 'VADER', 1, 2 );
insert into deathstar_rooms ( name, code, section_id, nr_in_section ) values ( 'Bridge', 'BRIDGE', 2, 1 );
insert into deathstar_rooms ( name, code, section_id, nr_in_section ) values ( 'Prison 1', 'PRISON1', 1, 3 );

commit;

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

create or replace package body deathstar_room_manager as
  procedure add_room(
    i_name varchar2_nn,
    i_section_id simple_integer,
    i_code varchar2 default null )
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

      insert into deathstar_rooms ( name, code, section_id, nr_in_section )
        values ( i_name, l_code, i_section_id, l_max_nr_in_section+1);
    end;
end;
/

select * from deathstar_rooms;
/*
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
*/



-- Task: Understand the functionality of DEATHSTAR_ROOMS-Table and ADD_ROOMS procedure

-- --> The goal is to be able to expand this table in the future









-- Let's first investigate what we have

select * from deathstar_rooms;
select * from deathstar_sections;


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









/*
--------------------------------------------------------------------------------
Cleanup
-------------------------------------------------------------------------------
*/
drop package ut_deathstar_add_rooms;
drop package deathstar_room_manager;
drop table deathstar_rooms;
drop table deathstar_sections;