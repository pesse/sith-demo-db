create table deathstar_protocols (
  id integer not null primary key,
  label varchar2(256),
  alert_level varchar2(16) not null,
  defense_mode varchar2(32) not null,
  power_level number(5,2) not null
);