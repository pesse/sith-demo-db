create table deathstar_protocol_active (
  id integer not null primary key,
  only_one number(1) default 1 not null,
  constraint deathstar_prot_act_fk
    foreign key ( id )
    references deathstar_protocols ( id )
    on delete cascade,
  constraint deathstar_prot_act_uq
    unique ( only_one ),
  constraint deathstar_prot_act_chk
    check ( only_one = 1 )
);