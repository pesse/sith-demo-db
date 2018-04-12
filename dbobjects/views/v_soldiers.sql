create or replace view v_soldiers as
select
  s.id,
  s.name,
  r2.label rank_label,
  r2.hierarchy_level rank,
  gn.group_name,
  gn.id group_id,
  gn.full_group_name,
  gm.is_leader
from
  soldiers s
  inner join soldier_ranks r2 on s.rank_fk = r2.id
  left outer join group_members gm on s.id = gm.soldier_fk
  left outer join v_groups gn on gm.group_fk = gn.id
;