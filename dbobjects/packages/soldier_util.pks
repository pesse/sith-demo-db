create or replace package soldier_util as

  function get_group_name( i_soldier_id in integer )
    return varchar2;

end;
/