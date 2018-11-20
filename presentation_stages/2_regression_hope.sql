create or replace package ut_groups as

  -- %suite(Groups View V_GROUPS)

  -- %test(Update group-name via view)
  procedure update_group_name;

end;
/















create or replace package body ut_groups as
  procedure update_group_name
  as
    l_actual_name v_groups.group_name%type;
    begin
      -- Arrange
      insert into groups (id, group_type_fk, parent_fk, honor_name)
        values (-1, 3, null, null);

      -- Act
      update v_groups set group_name = 'utPLSQL Power-team' where id = -1;

      -- Assert
      select group_name into l_actual_name from v_groups where id = -1;
      ut.expect(l_actual_name)
        .to_equal('utPLSQL Power-team');
    end;
end;
/












call ut.run('ut_groups');
















/********************
*** FIX IT
 ********************/



create or replace trigger trg_save_v_groups instead of update or insert or delete on v_groups
for each row
  declare
  begin
    if (:new.group_name is not null and (:old.group_name is null or :new.group_name <> :old.group_name)) then
      update groups set honor_name = :new.group_name where id = :new.id;
    end if;
  end;
/





call ut.  run('ut_groups');



