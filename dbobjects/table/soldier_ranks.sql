create table soldier_ranks (
  id int not null primary key,
  label varchar2(256),
  hierarchy_level int default 99 not null
);