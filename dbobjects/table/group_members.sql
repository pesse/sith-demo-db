create table group_members (
  group_fk int not null,
  soldier_fk int not null,
  is_leader number(1) default 0 not null,
  constraint group_members_pk primary key ( soldier_fk ),
  constraint group_members_fk_group foreign key (group_fk) references groups ( id ) on delete cascade,
  constraint group_members_fk_soldier foreign key (soldier_fk) references soldiers(id) on delete cascade
);

create index group_members_idx_group on group_members ( group_fk );
create index group_members_idx_group_lead on group_members ( group_fk, is_leader );