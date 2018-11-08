create or replace package group_util as

  subtype nn_varchar2 is varchar2 not null;

  function get_group_name( i_nr_in_group in positiven, i_type_label in nn_varchar2, i_honor_name in varchar2 )
    return varchar2 deterministic;
  
end;
/