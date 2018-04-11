create table groups (
  id int not null primary key,
  group_type_fk int not null,
  nr_in_group int default 1 not null,
  parent_fk int,
  honor_name varchar2(256),
  constraint groups_fk_type foreign key ( group_type_fk ) references group_types (id),
  constraint groups_fk_parent foreign key ( parent_fk ) references groups ( id ) on delete set null
);