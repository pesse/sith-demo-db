create or replace view v_groups as
  with
      group_names as (
        select
          g.id,
          parent_fk,
          group_util.get_group_name(g.nr_in_group, gt.label, g.honor_name) group_name,
          group_util.get_group_name(g.nr_in_group, gt.label, null)         full_group_name_part,
          group_type_fk                                                    group_type_id
        from groups g
          inner join group_types gt on g.group_type_fk = gt.id
      ),
      group_hierarchic(id, parent_id, group_name, full_group_name, group_type_id) as (
      select
        g.id,
        parent_fk            parent_id,
        group_name,
        full_group_name_part full_group_name,
        group_type_id
      from group_names g
      where g.parent_fk is null
      union all
      select
        g.id,
        g.parent_fk parent_id,
        g.group_name,
        g.full_group_name_part || ' of ' || gh.full_group_name,
        g.group_type_id
      from group_names g, group_hierarchic gh
      where g.parent_fk = gh.id
    )
  select
    gh.id,
    group_name,
    full_group_name,
    group_type_id,
    parent_id parent_group_id,
    gt.label,
    gt.min_size,
    gt.max_size,
    s.name leader_name,
    r.label leader_rank_label
  from group_hierarchic gh
    inner join group_types gt on gh.group_type_id = gt.id
    left outer join group_members gm
        on gh.id = gm.group_fk
             and gm.is_leader = 1
      left outer join soldiers s on gm.soldier_fk = s.id
      left outer join soldier_ranks r on s.rank_fk = r.id;
