create or replace package group_util as

  function get_group_name( i_nr_in_group in integer, i_type_label in varchar2, i_honor_name in varchar2 )
    return varchar2 deterministic;

  function get_group_name ( i_group_id in integer )
    return varchar2 result_cache;

  function count_group_members( i_group_id in integer )
    return integer;
  
end;
/