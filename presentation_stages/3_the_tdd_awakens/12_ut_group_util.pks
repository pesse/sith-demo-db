create or replace package ut_group_util as

  -- %suite(Group-Util)
  -- %suitepath(army.groups)

  -- %test(get_group_name returns name of group type and number)
  procedure get_group_name_normal;

  -- %test(get_group_name honor name if one is available)
  procedure get_group_name_honor;
  
  -- %test(get_group_name correctly for 11th and 12th (no honor name available))
  procedure get_group_name_11_12;

  -- %test(get_group_name does not allow NULL-arguments)
  procedure get_group_name_no_null;
end;
/