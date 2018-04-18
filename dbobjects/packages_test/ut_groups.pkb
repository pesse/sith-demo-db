create or replace package body ut_groups as

  procedure check_group_names( i_id in integer, i_expected_group_name in varchar2, i_expected_full_name in varchar2 )
  as
    l_actual v_groups%rowtype;
    begin
      select * into l_actual from v_groups where id = i_id;

      ut.expect(l_actual.group_name).to_equal(i_expected_group_name);
      ut.expect(l_actual.full_group_name).to_equal(i_expected_full_name);
    end;

  procedure select_fire_unit
  as
    begin
      check_group_names(-3, '1st Fire team', '1st Fire team of 1st Squad of 1st Platoon');
      check_group_names(-4, 'utPLSQL team', '2nd Fire team of 1st Squad of 1st Platoon');
      check_group_names(-5, '3rd Fire team', '3rd Fire team of 1st Squad of 1st Platoon');
    end;

  procedure fail_on_duplicate_groupnr
  as
    begin
      update groups set nr_in_group = 1 where id = -4;
    end;

  procedure setup
  as
    begin

      insert into groups (id, group_type_fk, parent_fk, honor_name) values (-1, 3, null, null);
      insert into groups (id, group_type_fk, parent_fk, honor_name) values (-2, 2, -1, null);
      insert into groups (id, group_type_fk, parent_fk, honor_name) values (-3, 1, -2, null);
      insert into groups (id, group_type_fk, parent_fk, honor_name) values (-4, 1, -2, 'utPLSQL team');
      insert into groups (id, group_type_fk, parent_fk, honor_name) values (-5, 1, -2, null);

    end;
end;
/