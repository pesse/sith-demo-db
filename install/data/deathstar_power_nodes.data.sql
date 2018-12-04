delete from deathstar_power_nodes;
insert all
  into deathstar_power_nodes( id, primary_node_fk, label ) values ( 1, null, 'Primary 1' )
  into deathstar_power_nodes( id, primary_node_fk, label ) values ( 2, 1, 'Replica 1' )
  into deathstar_power_nodes( id, primary_node_fk, label ) values ( 3, 1, 'Replica 2' )
  into deathstar_power_nodes( id, primary_node_fk, label ) values ( 4, null, 'Primary 2' )
  into deathstar_power_nodes( id, primary_node_fk, label ) values ( 5, 4, 'Replica 2' )
  into deathstar_power_nodes( id, primary_node_fk, label ) values ( 6, null, 'Primary 3' )
select * from dual;