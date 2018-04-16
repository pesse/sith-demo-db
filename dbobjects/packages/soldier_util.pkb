create or replace package body soldier_util as

  function get_group_name( i_soldier_id in integer )
    return varchar2
  as
    l_group_id integer;
    begin

      select
        group_fk into l_group_id
        from group_members
          where soldier_fk = i_soldier_id;

      return group_util.GET_GROUP_NAME(l_group_id);
    end;
  
end;
/