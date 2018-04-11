create or replace view v_group_soldiers as 
select g.id group_id, vg.group_name, vg.full_group_name, s2.id soldier_id, s2.name, m.is_leader from
  groups g
  inner join v_groups vg on g.id = vg.id
  left outer join (
    group_members m
    inner join soldiers s2 on m.soldier_fk = s2.id
  )  on g.id = m.group_fk
  connect by prior g.id = g.parent_fk
  start with g.parent_fk is null
;