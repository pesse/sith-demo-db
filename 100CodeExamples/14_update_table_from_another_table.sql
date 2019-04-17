create table planets (
  id integer primary key,
  name varchar(256),
  faction varchar2(10)
);

insert into planets values ( 1, 'Korriban', 'imperium');
insert into planets values ( 2, 'Dromund Kaas', 'imperium');
insert into planets values ( 3, 'Hoth', 'republic');


create table garrisons (
  id integer primary key,
  fk_planet integer not null,
  constraint garrisons_fk_planet foreign key ( fk_planet )
    references planets( id )
);

insert into garrisons values ( 1, 1 );
insert into garrisons values ( 2, 1 );
insert into garrisons values ( 3, 2 );
insert into garrisons values ( 4, 3 );

alter table garrisons
  add name varchar2(300);

/* We want to update the following garrisons and
   assign them a name: PlanetName (ID)
 */
select
  garrisons.id garrison_id,
  planets.name planet_name
  from
    garrisons
    inner join planets
      on garrisons.fk_planet = planets.id
  where
    planets.faction = 'imperium'
  ;

/* Possibility #1: Ugly and very slow */
begin
  for rec in (select
    garrisons.id,
    planets.name
    from
      garrisons
      inner join planets
        on garrisons.fk_planet = planets.id
    where
      planets.faction = 'imperium'
  )
  loop
    update garrisons
      set name = rec.name || ' (' || to_char(rec.id) || ')'
      where id = rec.id;
  end loop;
end;
/

select * from garrisons;
rollback;

/* Possibility #2: Complicated to read */
update garrisons
  set name = (
    select
        planets.name || ' (' || to_char(garrisons.id) || ')'
      from planets
      where planets.id = garrisons.fk_planet
    )
where exists ( -- Limitation to Imperium
  select 1 from planets
    where planets.id = garrisons.fk_planet
      and planets.faction = 'imperium'
  )
;

select * from garrisons;
rollback;

/* Possibility #3: Doesnt work if you want to
   update columns you use in the ON clause
 */
merge into garrisons target
  using (
    select
      garrisons.id,
      planets.name
      from
        garrisons
        inner join planets
          on garrisons.fk_planet = planets.id
      where
        planets.faction = 'imperium'
  ) source
  on (target.id = source.id)
  when matched then
    update set
      target.name = source.name || ' (' || to_char(source.id) || ')'
;

select * from garrisons;
rollback;

-- Possibility #4: Works only for key-preserved tables
update (
  select
    garrisons.id,
    garrisons.name garrison_name,
    planets.name planet_name
    from
      garrisons
      inner join planets
        on garrisons.fk_planet = planets.id
    where
      planets.faction = 'imperium'
)
  set garrison_name = planet_name || ' (' || to_char(id) || ')';

select * from garrisons;
rollback;
