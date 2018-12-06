create or replace package ut_deathstar_power_nodes as

  -- %suite(Deathstar power nodes - Primary/Secondary lookup)
  -- %suitepath(deathstar.powerNodes)

  -- %test(Get a result even if there is no secondary power node)
  procedure get_result_for_only_one_entry;

  -- %test(Get whole group of related power nodes, no matter which node-ID queried)
  procedure get_whole_group_multiple_secondaries;

end;
/