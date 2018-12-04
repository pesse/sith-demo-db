create table deathstar_power_nodes (
  id integer not null,
  label varchar2(100),
  primary_node_fk integer,
  constraint deathstar_power_nodes_pk primary key (id),
  constraint deathstar_power_node_fk_prim foreign key ( primary_node_fk )
    references deathstar_power_nodes( id )
);

--drop table deathstar_power_nodes;