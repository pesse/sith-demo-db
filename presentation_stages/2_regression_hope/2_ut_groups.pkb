create or replace package body ut_groups as

  procedure update_group_name
  as
    l_actual_name v_groups.group_name%type;
    begin
      -- Arrange
      insert into groups (id, group_type_fk, parent_fk, honor_name) values (-1, 3, null, null);

      -- Act
      update v_groups set group_name = 'utPLSQL Power-team' where id = -1;

      -- Assert
      select group_name into l_actual_name from v_groups where id = -1;
      ut.expect(l_actual_name).to_equal('utPLSQL Power-team');
    end;

end;
/