/* We have several protocols for the deathstar
  but its important we only have one active protocol
  at a time
 */
create table deathstar_protocols (
  id integer not null primary key,
  label varchar2(256),
  alert_level varchar2(16) not null,
  defense_mode varchar2(32) not null,
  power_level number(5,2) not null
);

insert into deathstar_protocols
  values (1, 'Everything easy', 'LOW', 'BE_KIND', 80);
insert into deathstar_protocols
  values (2, 'Be careful', 'MEDIUM', 'BE_SUSPICIOUS', 90);
insert into deathstar_protocols
  values (3, 'OMG the rebels!', 'VERY HIGH', 'SHOOT_FIRST_ASK_LATER', 120);

select * from deathstar_protocols;

/* To make sure there is only one possibly
  active protocol, we can use basic relational modeling
  in combination with constraints
 */
create table deathstar_protocol_active (
  id integer not null primary key,
  only_one number(1) default 1 not null,
  -- ID is also foreign key
  constraint deathstar_prot_act_fk
    foreign key ( id )
    references deathstar_protocols ( id )
    on delete cascade,
  -- Make sure there can only be one row
  constraint deathstar_prot_act_uq
    unique ( only_one ),
  -- by limiting the possible value of the
  -- helper-column
  constraint deathstar_prot_act_chk
    check ( only_one = 1 )
);

/* This also means the technique is usable in
  every relational database with check-constraints
 */

insert into deathstar_protocol_active ( id ) values (1 );

-- We cannot have more than one active protocol
insert into deathstar_protocol_active ( id ) values ( 2 );

/* We can even have a view which shows
  the active protocol
 */
create or replace view v_deathstar_protocols
  as
  select
    prot.id, label, alert_level, defense_mode, power_level,
    coalesce(active.only_one, 0) is_active
  from
    deathstar_protocols prot
    left outer join deathstar_protocol_active active
      on prot.id = active.id
;

select * from v_deathstar_protocols;

update deathstar_protocol_active set id = 2;

select * from v_deathstar_protocols;


/******************************
* CLEANUP
 *****************************/
drop view v_deathstar_protocols;
drop table deathstar_protocol_active;
drop table deathstar_protocols;