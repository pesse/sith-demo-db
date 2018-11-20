create or replace view v_group_names as
select
  g.id,
  case
    when mod(g.nr_in_group, 10) = 1 then
      to_char(g.nr_in_group) || 'st ' || type2.label
    when mod(g.nr_in_group, 10) = 2 then
      to_char(g.nr_in_group) || 'nd ' || type2.label
    when mod(g.nr_in_group, 10) = 3 then
      to_char(g.nr_in_group) || 'rd ' || type2.label
    else
      to_char(g.nr_in_group) || 'th ' || type2.label
  end group_name,
  g.honor_name,
  g.parent_fk,
  type2.id group_type_id
from groups g
inner join group_types type2 on g.group_type_fk = type2.id;
