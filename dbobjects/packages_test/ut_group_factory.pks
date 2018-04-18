create or replace package ut_group_factory as
  -- %suite(Group Factory)
  -- %suitepath(army.groups)

  -- %test(Create filled Squad, having minimum number of soldiers and a leader of at least Sergeant rank)
  -- %beforetest(setup_soldiers)
  procedure create_filled_squad;
  
  procedure setup_soldiers;
end;
/