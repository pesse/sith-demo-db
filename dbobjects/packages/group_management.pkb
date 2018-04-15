create or replace package body group_management as

  function get_next_groupless_soldier( i_min_rank in int, i_max_rank in int )
    return integer
  as
    l_result int;
    begin
      select id into l_result from (
      select
        s.id,
        ROW_NUMBER() OVER (ORDER BY sr.hierarchy_level desc) rn
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

  procedure fill_group_leaders
  as
    l_soldier int;
    begin

      for rec in (select
                    g.id group_id,
                    gt.min_lead_rank
                    from groups g
                      inner join group_types gt on g.group_type_fk = gt.id
                      left outer join group_members member2 on g.id = member2.group_fk and member2.is_leader = 1
                  where
                    member2.soldier_fk is null) loop
        l_soldier := get_next_groupless_soldier(rec.min_lead_rank, rec.min_lead_rank+1);

        if ( l_soldier is not null ) then
          insert into group_members (GROUP_FK, SOLDIER_FK, IS_LEADER) values ( rec.group_id, l_soldier, 1);
        end if;
      end loop;

    end;

  procedure fill_group_members
  as
    begin
      for rec in (select g.id, gt.max_size, members.members, (gt.max_size-members.members) open_space from
                    groups g
                    inner join group_types gt on g.group_type_fk = gt.id
                    left outer join (
                      select group_fk, count(*) members from group_members gm
                      group by gm.group_fk
                    ) members on g.id = members.group_fk
                  where
                    g.group_type_fk = 1
                    and gt.max_size > members.members) loop
        insert into group_members (GROUP_FK, SOLDIER_FK, IS_LEADER)
          select
            rec.id,
            s.id,
            0
          from
            soldiers s
            inner join soldier_ranks sr on s.rank_fk = sr.id
            left outer join group_members member2 on s.id = member2.soldier_fk
          where
            member2.group_fk is null
            and sr.hierarchy_level between 10 and 12
            and rownum <= rec.open_space
         ;
      end loop;
    end;

  procedure fill_groups
  as
    begin
      fill_group_leaders();
      fill_group_members();
    end;

end;
/