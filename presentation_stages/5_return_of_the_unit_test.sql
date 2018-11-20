create or replace package ut_groups as

  -- %suite(Groups View V_GROUPS)

  -- %test(Update group-name via view)
  procedure update_group_name;

  -- %test(Groups will show up with the correct group_name and full_group_name, taking honor names into account)
  procedure select_fire_unit;

  -- %beforeall
  procedure setup;
end;
/



create or replace package body ut_groups as

  procedure update_group_name
  as
    l_actual_name v_groups.group_name%type;
    begin
      -- Act
      update v_groups set group_name = 'utPLSQL Power-team' where id = -1;

      -- Assert
      select group_name into l_actual_name from v_groups where id = -1;
      ut.expect(l_actual_name).to_equal('utPLSQL Power-team');
    end;

  procedure check_group_names(
    i_id in integer,
    i_expected_group_name in varchar2,
    i_expected_full_name in varchar2 )
  as
    l_actual v_groups%rowtype;
    begin
      select * into l_actual from v_groups where id = i_id;

      ut.expect(l_actual.group_name)
        .to_equal(i_expected_group_name);
      ut.expect(l_actual.full_group_name)
        .to_equal(i_expected_full_name);
    end;

  procedure select_fire_unit
  as
    begin
      check_group_names(-3, '1st Fire team', '1st Fire team of 1st Squad of 1st Platoon');
      check_group_names(-4, 'Revan''s Ghosts', '2nd Fire team of 1st Squad of 1st Platoon');
      check_group_names(-5, '3rd Fire team', '3rd Fire team of 1st Squad of 1st Platoon');
    end;

  procedure setup_group(
    i_id integer,
    i_group_type integer,
    i_parent_id integer default null,
    i_honor_name varchar2 default null )
  as
    begin
      insert into groups (id, group_type_fk, parent_fk, honor_name)
        values (i_id, i_group_type, i_parent_id, i_honor_name);
    end;

  procedure setup
  as
    begin
      setup_group(
        i_id => -1,
        i_group_type => 3
      );
      setup_group(
        i_id => -2,
        i_group_type => 2,
        i_parent_id => -1
      );
      setup_group(
        i_id => -3,
        i_group_type => 1,
        i_parent_id => -2
      );
      setup_group(
        i_id => -4,
        i_group_type => 1,
        i_parent_id => -2,
        i_honor_name => 'Revan''s Ghosts'
      );
      setup_group(
        i_id => -5,
        i_group_type => 1,
        i_parent_id => -2
      );
    end;
end;
/



call ut.run();