create or replace function get_soldier_group_name ( i_soldier_id in integer )
  return varchar2
as
  l_group_name varchar2(250);
  begin
    /*select
        gn.group_name into l_group_name
      from
        soldiers s
        inner join group_members gm on s.id = gm.soldier_fk
        inner join v_group_names gn on gm.group_fk = gn.id
      where s.id = i_soldier_id;*/
    select
        -- 1 as id
        gn.group_name into l_group_name
      from
        soldiers s
        left outer join group_members gm
          on s.id = gm.soldier_fk
             --and gm.is_leader = 0
        -- left outer join groups g on gm.group_fk = g.id
        left outer join v_group_names gn on gm.group_fk = gn.id
      where s.id = i_soldier_id
    ;

--  if l_group_name is null then
--          l_group_name := 'Empty';
--       end if;

    return l_group_name;
  end;