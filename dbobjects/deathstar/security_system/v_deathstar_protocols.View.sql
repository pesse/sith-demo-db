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