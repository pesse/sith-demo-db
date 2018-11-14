select * from v_groups;




























create or replace view v_groups as
select
  g1.id,
  coalesce(g1.honor_name, g1.group_name) group_name,
  g1.group_name
    || case when g2.group_name is not null then ' of ' || g2.group_name else null end
    || case when g3.group_name is not null then ' of ' || g3.group_name else null end
    || case when g4.group_name is not null then ' of ' || g4.group_name else null end
    || case when g5.group_name is not null then ' of ' || g5.group_name else null end
    || case when g6.group_name is not null then ' of ' || g6.group_name else null end
    || case when g7.group_name is not null then ' of ' || g7.group_name else null end
    || case when g8.group_name is not null then ' of ' || g8.group_name else null end
    as full_group_name,
  g1.group_type_id,
  g1.parent_fk parent_group_id,
  gt.label,
  gt.min_size,
  gt.max_size,
  s.name leader_name,
  r.label leader_rank_label
from
  v_group_names g1
  left outer join v_group_names g2 on g1.parent_fk = g2.id
  left outer join v_group_names g3 on g2.parent_fk = g3.id
  left outer join v_group_names g4 on g3.parent_fk = g4.id
  left outer join v_group_names g5 on g4.parent_fk = g5.id
  left outer join v_group_names g6 on g5.parent_fk = g6.id
  left outer join v_group_names g7 on g6.parent_fk = g7.id
  left outer join v_group_names g8 on g7.parent_fk = g8.id
  inner join group_types gt on g1.group_type_id = gt.id
  left outer join group_members gm
    on g1.id = gm.group_fk
         and gm.is_leader = 1
  left outer join soldiers s on gm.soldier_fk = s.id
  left outer join soldier_ranks r on s.rank_fk = r.id
  ;



















-- WE TEST IT!
select group_name, leader_name, leader_rank_label from v_groups;


























/*       ___________
                             .---'::'        `---.
                            (::::::'              )
                            |`-----._______.-----'|
                            |              :::::::|
                           .|               ::::::!-.
                           \|               :::::/|/
                            |               ::::::|
                            | Darth Ora arrives ::|
                            |    for ceremony ::::|
                            |               ::::::|
                            |              .::::::|
                            J              :::::::F
                             \            :::::::/
                              `.        .:::::::'
                                `-._  .::::::-'
____________________________________|  """|"_________________________________________
                                    |  :::|
                                    F   ::J
                                   /     ::\
                              __.-'      :::`-.__
                             (_           ::::::_)
                               `"""---------"""'

*/





select group_name, leader_name, leader_rank_label from v_groups where id = 775;





update v_groups set group_name = 'Revan''s ghosts' where id = 775;

















/*




,_._._._._._._._._|
|_|_|_|_|_|_|_|_|_|
                  !



































 ZZZZZZZZEEEEEESSSSSSHHHHHHHH.....

,_._._._._._._._._|__________________________________________________________
|_|_|_|_|_|_|_|_|_|__________________________________________________________|
                  !

 */
















declare
  l_group_name varchar2(2000);
begin
  update v_groups set group_name = 'Test-Name' where id = 1;

  select group_name into l_group_name from v_groups where id = 1;

  if ( l_group_name <> 'Test-Name') then
    raise_application_error(-20000, 'Update did not work!');
  end if;
end;
/











