create table group_types (
  id int not null primary key,
  label varchar2(256) not null,
  min_size int default 0 not null,
  max_size int default 0 not null,
  min_lead_rank int not null
);
