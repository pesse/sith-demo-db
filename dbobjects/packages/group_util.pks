create or replace package group_util as

  subtype nn_varchar2 is varchar2 not null;

  function get_group_name( i_nr_in_group in positiven, i_type_label in nn_varchar2, i_honor_name in varchar2 )
    return varchar2 deterministic;

  function get_group_name ( i_group_id in simple_integer )
    return varchar2 result_cache;

  function count_group_members( i_group_id in integer )
    return integer;
  
end;
/