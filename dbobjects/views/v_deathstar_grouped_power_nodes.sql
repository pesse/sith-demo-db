create or replace view v_deathstar_grouped_power_nodes as
  with node_groups as (
    select prime.id group_id,
           replica.id member_id
      from deathstar_power_nodes prime
      inner join deathstar_power_nodes replica
             on prime.id = nvl(replica.primary_node_fk, replica.id)
      where prime.primary_node_fk is null
  )
  select nodes.id power_node_id,
         groups.group_id,
         groups.member_id,
         member.label member_label,
         case
           when member.primary_node_fk is null then 1
           else 0
         end is_primary
    from deathstar_power_nodes nodes
    inner join node_groups groups
           on nvl(nodes.primary_node_fk, nodes.id) = groups.group_id
    inner join deathstar_power_nodes member
           on groups.member_id = member.id;