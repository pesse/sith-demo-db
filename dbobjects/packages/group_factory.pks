create or replace package group_factory as

  function create_group(i_parent in integer, i_group_type in integer )
    return integer;

  function create_filled_group( i_parent in integer, i_group_type in integer )
    return integer;

end;
/