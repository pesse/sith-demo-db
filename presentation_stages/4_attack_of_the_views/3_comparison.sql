select * from v_groups
minus
select * from v_groups_2
union all
select * from v_groups_2
minus
select * from v_groups;




call ut.run();