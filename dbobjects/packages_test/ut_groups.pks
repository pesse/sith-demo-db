create or replace package ut_groups as
  -- %suite(Groups View V_GROUPS)
  -- %suitepath(army.groups)

  -- %test(Groups will show up with the correct group_name and full_group_name, taking honor names into account)
  procedure select_fire_unit;

  -- %test(Fail update when the number in group is not unique)
  -- %throws(-00001)
  procedure fail_on_duplicate_groupnr;

  -- %beforeall
  procedure setup;
end;
/