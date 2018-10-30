create or replace package body group_management as

  function get_next_groupless_soldier( i_min_rank in int, i_max_rank in int )
    return integer
  as
    l_result int;
    begin
      select id into l_result from (
      select
        s.id,
        row_number() over (order by sr.hierarchy_level desc) rn
      from
        soldiers s
        inner join soldier_ranks sr on s.rank_fk = sr.id
        left outer join group_members member2 on s.id = member2.soldier_fk
      where
        member2.group_fk is null
        and sr.hierarchy_level between i_min_rank and i_max_rank
      )
      where rn = 1;

      return l_result;

    exception when no_data_found then
      return null;
    end;

  procedure fill_group_leader( i_group in integer, i_min_lead_rank in integer, i_gracefully bit )
  as
    l_soldier int;
    l_errmsg varchar2(2000);
    begin
      l_soldier := get_next_groupless_soldier(i_min_lead_rank, i_min_lead_rank+1);

      if ( l_soldier is not null ) then
        insert into group_members (GROUP_FK, SOLDIER_FK, IS_LEADER)
          values ( i_group, l_soldier, 1);
      else
        l_errmsg := 'Could not assign a leader to group ' || to_char(i_group) || ': No soldier of rank '
            || to_char(i_min_lead_rank) || ' to ' || to_char( i_min_lead_rank+1) || ' available';
        if ( i_gracefully = 1 ) then
          dbms_output.put_line(l_errmsg);
        else
          raise_application_error(-20010, l_errmsg);
        end if;
      end if;

    end;

  procedure fill_group_leaders( i_gracefully in bit )
  as
    l_soldier int;
    begin

      for rec in (select
                    g.id group_id,
                    gt.min_lead_rank
                    from groups g
                      inner join group_types gt on g.group_type_fk = gt.id
                      left outer join group_members gm on g.id = gm.group_fk and gm.is_leader = 1
                  where
                    gm.soldier_fk is null) loop
        fill_group_leader(rec.group_id, rec.min_lead_rank, i_gracefully);
      end loop;

    end;

  procedure fill_group_members( i_group in integer default null )
  as
    begin
      for rec in (select g.id, gt.max_size, nvl(members.members,0), (gt.max_size-nvl(members.members,0)) open_space from
                    groups g
                    inner join group_types gt on g.group_type_fk = gt.id
                    left outer join (
                      select group_fk, count(*) members from group_members gm
                      group by gm.group_fk
                    ) members on g.id = members.group_fk
                  where
                    g.group_type_fk = 1
                    and gt.max_size > nvl(members.members,0)
                    and (i_group is null or g.id in (
                      select id from groups connect by prior id = parent_fk start with id = i_group
                    ))) loop
        insert into group_members (GROUP_FK, SOLDIER_FK, IS_LEADER)
          select
            rec.id,
            s.id,
            0
          from
            soldiers s
            inner join soldier_ranks sr on s.rank_fk = sr.id
            left outer join group_members gm on s.id = gm.soldier_fk
          where
            gm.group_fk is null
            and sr.hierarchy_level between 10 and 12
            and rownum <= rec.open_space
         ;
      end loop;
    end;

  procedure fill_groups( i_gracefully in bit default 0 )
  as
    begin
      fill_group_leaders( i_gracefully );
      fill_group_members();
    end;

  procedure fill_group( i_group in integer, i_gracefully in bit default 0 )
  as
    l_min_rank int;
    begin

      select gt.min_lead_rank into l_min_rank from groups g inner join group_types gt on g.group_type_fk = gt.id where g.id = i_group;

      fill_group_leader(i_group, l_min_rank, i_gracefully);
      fill_group_members(i_group);
    end;

end;
/