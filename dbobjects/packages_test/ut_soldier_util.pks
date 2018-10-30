create or replace package ut_soldier_util as

  -- %suite(Soldier-Util)
  -- %suitepath(soldier)

  -- %test(Get soldier's group-name)
  -- %beforetest(setup_soldier_and_group)
  procedure get_soldier_group_name;

  procedure setup_soldier_and_group;

end;
/