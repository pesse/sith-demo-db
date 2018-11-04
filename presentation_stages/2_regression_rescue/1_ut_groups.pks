create or replace package ut_groups as
  
  -- %suite(Groups View V_GROUPS)
  
  -- %test(Update group-name via view)
  procedure update_group_name;

end;
/