-- In order to use anydata.convertCollection in the utPLSQL
-- expectation later on, we need t_lines to be a global type.
-- Unfortunately we cannot use package-level types that way
create or replace type t_lines is table of varchar2(4000);

create or replace package ut_feuertips_13 as

  -- %suite(Feuertips 13: LogWriter)

  -- %beforeall
  procedure setup_test_data;

  -- %test(File abcd contains Room Action Log)
  procedure abcd_contains_actionlog;

  -- %test(File arty contains Room Repair Log)
  procedure arty_contains_repairlog;

end;
/

create or replace package body ut_feuertips_13 as

  procedure delete_file(
    p_file_name in varchar2
  ) as
  begin
    utl_file.fremove('TEMP', p_file_name);
  exception when others then
    null; -- File doesnt exist
  end;

  function read_lines (
      p_file_name  in  varchar2
   ) return t_lines as
      l_file utl_file.file_type;
      l_buffer varchar2(4000);
      l_result t_lines := t_lines();
   begin
      l_file := utl_file.fopen('TEMP', p_file_name, 'r');
      begin
        loop
          utl_file.get_line(l_file, l_buffer);
          l_result.extend;
          l_result(l_result.count) := l_buffer;
        end loop;
      exception when no_data_found then
        null; -- we are finished reading
      end;
      utl_file.fclose (l_file);
      return l_result;
   end read_lines;

  procedure setup_test_data as
  begin
    -- Make sure the tables we're using as input are empty
    delete from log_deathstar_room_actions;
    delete from log_deathstar_room_access;
    delete from log_deathstar_room_repairs;

    -- Add some test data for our tests
    insert into log_deathstar_room_access ( key_id, room_name, character_name ) values (1, 'Bridge', 'Darth Vader');
    insert into log_deathstar_room_access ( key_id, room_name, character_name ) values (1, 'Bridge', 'Mace Windu');
    insert into log_deathstar_room_access ( key_id, room_name, character_name ) values (2, 'Engine Room 1', 'R2D2');

    insert into log_deathstar_room_actions ( key_id, action, done_by ) values ( 1, 'Enter', 'Darth Vader');
    insert into log_deathstar_room_actions ( key_id, action, done_by ) values ( 1, 'Sit down', 'Darth Vader');
    insert into log_deathstar_room_actions ( key_id, action, done_by ) values ( 2, 'Enter', 'R2D2');
    insert into log_deathstar_room_actions ( key_id, action, done_by ) values ( 1, 'Enter', 'Mace Windu');
    insert into log_deathstar_room_actions ( key_id, action, done_by ) values ( 1, 'Activate Lightsaber', 'Mace Windu');
    insert into log_deathstar_room_actions ( key_id, action, done_by ) values ( 1, 'Jump up', 'Darth Vader');
    insert into log_deathstar_room_actions ( key_id, action, done_by ) values ( 2, 'Hack Console', 'R2D2');
    insert into log_deathstar_room_actions ( key_id, action, done_by ) values ( 1, 'Activate Lightsaber', 'Darth Vader');
    insert into log_deathstar_room_actions ( key_id, action, done_by ) values ( 1, 'Attack', 'Mace Windu');
    insert into log_deathstar_room_actions ( key_id, action, done_by ) values ( 2, 'Beep', 'R2D2');

    insert into log_deathstar_room_repairs ( key_id, action, repair_completion, repaired_by) values ( 1, 'Inspect', '50%', 'The Repairman');
    insert into log_deathstar_room_repairs ( key_id, action, repair_completion, repaired_by) values ( 1, 'Analyze', '53%', 'The Repairman');
    insert into log_deathstar_room_repairs ( key_id, action, repair_completion, repaired_by) values ( 1, 'Investigate', '57%', 'The Repairman');
    insert into log_deathstar_room_repairs ( key_id, action, repair_completion, repaired_by) values ( 2, 'Analyze', '25%', 'The Repairman');
    insert into log_deathstar_room_repairs ( key_id, action, repair_completion, repaired_by) values ( 1, 'Fix it', '95%', 'Lady Skillful');
    insert into log_deathstar_room_repairs ( key_id, action, repair_completion, repaired_by) values ( 2, 'Fix it', '100%', 'Lady Skillful');
  end;

  procedure abcd_contains_actionlog as
    l_actual t_lines;
    l_expect t_lines := t_lines();
  begin
    -- Arrange
    delete_file('abcd'); -- Make sure the file we want to check is empty at first

    -- Act
    feuertips_13_poc();

    l_actual := read_lines('abcd');
    l_expect.extend(10);
    l_expect(1) := '1|Bridge|Darth Vader|Enter';
    l_expect(2) := '1|Bridge|Darth Vader|Sit down';
    l_expect(3) := '1|Bridge|Mace Windu|Enter';
    l_expect(4) := '1|Bridge|Mace Windu|Activate Lightsaber';
    l_expect(5) := '1|Bridge|Darth Vader|Jump up';
    l_expect(6) := '1|Bridge|Darth Vader|Activate Lightsaber';
    l_expect(7) := '1|Bridge|Mace Windu|Attack';
    l_expect(8) := '2|Engine Room 1|R2D2|Enter';
    l_expect(9) := '2|Engine Room 1|R2D2|Hack Console';
    l_expect(10) := '2|Engine Room 1|R2D2|Beep';

    ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expect));
  end;

  procedure arty_contains_repairlog as
    l_actual t_lines;
    l_expect t_lines := t_lines();
  begin
    -- Arrange
    delete_file('arty'); -- Make sure the file we want to check is empty at first

    -- Act
    feuertips_13_poc();

    l_actual := read_lines('arty');
    l_expect.extend(6);
    l_expect(1) := '1|Bridge|50%|The Repairman|Inspect';
    l_expect(2) := '1|Bridge|53%|The Repairman|Analyze';
    l_expect(3) := '1|Bridge|57%|The Repairman|Investigate';
    l_expect(4) := '1|Bridge|95%|Lady Skillful|Fix it';
    l_expect(5) := '2|Engine Room 1|25%|The Repairman|Analyze';
    l_expect(6) := '2|Engine Room 1|100%|Lady Skillful|Fix it';

    ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expect));
  end;

end;
/

select * from (ut.run('ut_feuertips_13'));