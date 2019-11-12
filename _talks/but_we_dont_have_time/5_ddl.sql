
-- Let's try out the Room-View generator
call deathstar_room_view_generator.create_view('room_test', sys.odcinumberlist(1));

select * from room_test;
drop view room_test;


-- Let's test it!
create or replace package ut_deathstar_room_view_generator as
  -- %suite(Room-View Generator)

  -- %test(Creating a new view)
  procedure create_view;

end;
/

create or replace package body ut_deathstar_room_view_generator as

  procedure create_view
  as
    l_count integer;
    begin
      -- Control the input/state
      insert into deathstar_sections ( id, label )
        values ( -1, 'Test Section');
      insert into deathstar_rooms ( id, name, code, section_id )
        values ( -1, 'Test Room', 'TESTROOM', -1);
      insert into deathstar_rooms ( id, name, code, section_id )
        values ( -2, 'Test Room 2', 'TESTROOM2', -1);

      deathstar_room_view_generator.create_view('room_test_view', sys.odcinumberlist(-1, -2));

      -- Check if there is a view
      select count(*) into l_count
        from user_views where view_name = 'ROOM_TEST_VIEW';
      ut.expect(l_count).to_equal(1);
    end;

end;
/


call ut.run('ut_deathstar_room_view_generator');


-- Warnings!



call ut.run('ut_deathstar_room_view_generator');


-- Even worse: Polluted tables!
select * from deathstar_rooms where id < 0;
select * from deathstar_sections where id < 0;
select * from room_test_view;

-- Let's clean up
delete from deathstar_rooms where id < 0;
delete from deathstar_sections where id < 0;
drop view room_test_view;


-- Dealing with DDL
create or replace package ut_deathstar_room_view_generator as
  -- %suite(Room-View Generator)
  -- %rollback(manual)

  -- %test(Creating a new view)
  -- %aftertest(cleanup_test_view)
  procedure create_view;

  procedure cleanup_test_view;

  -- %afterall
  procedure cleanup_data;

end;
/


create or replace package body ut_deathstar_room_view_generator as

  procedure create_view
  as
    l_count integer;
    begin
      -- Control the input/state
      insert into deathstar_sections ( id, label )
        values ( -1, 'Test Section');
      insert into deathstar_rooms ( id, name, code, section_id )
        values ( -1, 'Test Room', 'TESTROOM', -1);
      insert into deathstar_rooms ( id, name, code, section_id )
        values ( -2, 'Test Room 2', 'TESTROOM2', -1);

      deathstar_room_view_generator.create_view('room_test_view', sys.odcinumberlist(-1, -2));

      -- Check if there is a view
      select count(*) into l_count
        from user_views where view_name = 'ROOM_TEST_VIEW';
      ut.expect(l_count).to_equal(1);
    end;

    procedure cleanup_test_view
    as
      begin
        execute immediate 'drop view room_test_view';
      end;

    procedure cleanup_data
    as
      begin
        delete from deathstar_rooms where id < 0;
        delete from deathstar_sections where id < 0;
        commit;
      end;

end;
/


-- Now we can run it multiple times!
call ut.run('ut_deathstar_room_view_generator');




-- So ... what are we testing?




-- Let's improve the test
create or replace package body ut_deathstar_room_view_generator as

  procedure create_view
  as
    l_actual sys_refcursor;
    l_expected sys_refcursor;
    begin
      -- Control the input/state
      insert into deathstar_sections ( id, label )
        values ( -1, 'Test Section');
      insert into deathstar_rooms ( id, name, code, section_id )
        values ( -1, 'Test Room', 'TESTROOM', -1);
      insert into deathstar_rooms ( id, name, code, section_id )
        values ( -2, 'Test Room 2', 'TESTROOM2', -1);

      deathstar_room_view_generator.create_view('room_test_view', sys.odcinumberlist(-1, -2));

      -- Check if it is THE RIGHT view
      open l_expected for
        select -1 id, 'Test Room' name, 'TESTROOM' code, -1 section_id, 'Test Section' section_label from dual union all
        select -2   , 'Test Room 2'   , 'TESTROOM2'    , -1           , 'Test Section'               from dual;

      open l_actual for
        select * from room_test_view;

      ut.expect(l_actual)
        .to_equal(l_expected)
        .join_by('ID');
    end;

    procedure cleanup_test_view
    as
      begin
        execute immediate 'drop view room_test_view';
      end;

    procedure cleanup_data
    as
      begin
        delete from deathstar_rooms where id < 0;
        delete from deathstar_sections where id < 0;
        commit;
      end;

end;
/



call ut.run('ut_deathstar_room_view_generator');




create or replace package body deathstar_room_view_generator as

  procedure create_view(
    i_view_name varchar2,
    i_room_ids sys.odcinumberlist
  )
  as
    l_room_ids_str varchar2(4000);
    l_stmt varchar2(4000);
    begin
      if ( i_room_ids.count <= 0 ) then
        raise_application_error(-20000, 'No rooms given');
      end if;

      select listagg(column_value, ',') within group (order by rownum)
        into l_room_ids_str
        from table(i_room_ids)
        where rownum <= 1
      ;

      l_stmt := 'create view ' || dbms_assert.SIMPLE_SQL_NAME(i_view_name) || ' as
      select
        rooms.id,
        rooms.name,
        rooms.code,
        sections.id section_id,
        sections.label section_label
      from
        deathstar_rooms rooms
        inner join deathstar_sections sections
          on rooms.section_id = sections.id
      where rooms.id in (' || l_room_ids_str || ')';

      execute immediate l_stmt;
    end;
end;
/



call ut.run('ut_deathstar_room_view_generator');