create or replace package ut_group_factory as
  -- %suite(Group Factory)
  -- %suitepath(army.groups)

  -- %test(Create filled Squad, having minimum number of soldiers and a leader of at least Sergeant rank)
  -- %beforetest(setup_soldiers)
  procedure create_filled_squad;

  -- %test(Trying to create new squad with not enough available soldiers throws exception)
  -- %beforetest(delete_available_soldiers)
  -- %throws(-20010)
  procedure fail_no_soldiers_available;

  procedure setup_soldiers;

  procedure delete_available_soldiers;
end;
/