create or replace package body ut_deathstar_room_manager as

  function cursor_current_test_rooms
    return sys_refcursor
  as
    l_result sys_refcursor;
    begin
      open l_result for
        select * from deathstar_rooms
          where section_id < 0;
      return l_result;
    end;

  procedure setup_section
  as
    begin
      insert into deathstar_sections ( id, label )
        values ( -1, 'Test-Section 1');
      insert into deathstar_sections ( id, label )
        values ( -2, 'Test-Section 2');
    end;

  procedure add_room_default
  as
    c_expectation sys_refcursor;
    begin
      deathstar_room_manager.add_room('Test Room 1', -1, 'TESTROOM1');
      deathstar_room_manager.add_room('Test Room 2', -1, 'TESTROOM2');
      deathstar_room_manager.add_room('Test Room 3', -2, 'TESTROOM3');

      open c_expectation for
        select 1 id , 'Test Room 1' name , 'TESTROOM1' code , -1 section_id , 1 nr_in_section  from dual union all
        select 2    , 'Test Room 2'      , 'TESTROOM2'      , -1            , 2                from dual union all
        select 3    , 'Test Room 3'      , 'TESTROOM3'      , -2            , 1                from dual;

      ut.expect(cursor_current_test_rooms())
        .to_equal(c_expectation)
        .exclude(new ut_varchar2_list('ID'))
        .join_by('CODE')
        ;
    end;

  procedure add_room_auto_generated_code
  as
    c_expectation sys_refcursor;
    begin
      deathstar_room_manager.add_room('Test Room 1', -1 );

      open c_expectation for
        select 1 id , 'Test Room 1' name , 'TEST_R1' code , -1 section_id , 1 nr_in_section  from dual;

      ut.expect(cursor_current_test_rooms())
        .to_equal(c_expectation)
        .exclude(new ut_varchar2_list('ID'))
        ;
    end;
    
  procedure add_room_auto_generated_code_twice
  as
    c_expectation sys_refcursor;
    begin
      deathstar_room_manager.add_room('Test Room 1', -1 );
      deathstar_room_manager.add_room('Test Room 2', -1 );

      open c_expectation for
        select 1 id , 'Test Room 1' name , 'TEST_R1' code , -1 section_id , 1 nr_in_section from dual union all
        select 2    , 'Test Room 2'      , 'TEST_R2'      , -1            , 2               from dual;

      ut.expect(cursor_current_test_rooms())
        .to_equal(c_expectation)
        .exclude(new ut_varchar2_list('ID'))
        ;
    end;
  
end;
/