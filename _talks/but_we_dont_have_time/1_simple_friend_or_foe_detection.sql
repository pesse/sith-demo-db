/*
 Indicators:
 - Weapon
    - Lightsaber-color -> Sure sign
    - Blaster -> Unsure
 - Hooded robe?
    - Black -> Sith
    - Brown or white -> Jedi
    - Red -> Unsure...
 - Armor?
    - White -> Imperial Trooper
    - Orange -> Rebel Pilot
    - Blue/Black -> Rebel
    - Otherwise -> Unsure...

 T_PERSON_APPEARANCE:
    create or replace type t_person_appearance force is object (
      weapon_type varchar2(50),
      weapon_color varchar2(50),
      cloth_type varchar2(50),
      cloth_color varchar2(50)
    );
 */


-- Start
create or replace package deathstar_security as
  function friend_or_foe(
    i_person_data t_person_appearance
  ) return varchar2;
end;
/

create or replace package body deathstar_security as
  function friend_or_foe(
    i_person_data t_person_appearance
  ) return varchar2
  as
    begin
      null;
      -- Lightsaber

      -- Hooded Robe

      -- Armor
    end;
end;
/


-- Check

























-- Complete check as SQL
select 'Red lightsaber' test, deathstar_security.friend_or_foe( t_person_appearance('lightsaber', 'red', 'something', 'something') ) friend_or_foe from dual union all
select 'Blue lightsaber',     deathstar_security.friend_or_foe( t_person_appearance('lightsaber', 'blue', 'something', 'something') ) from dual union all
select 'Black hooded robe',   deathstar_security.friend_or_foe( t_person_appearance('blaster', 'blue', 'hooded_robe', 'black') ) from dual union all
select 'Brown hooded robe',   deathstar_security.friend_or_foe( t_person_appearance('blaster', 'blue', 'hooded_robe', 'brown') ) from dual union all
select 'White armor',         deathstar_security.friend_or_foe( t_person_appearance('blaster', 'blue', 'armor', 'white') ) from dual union all
select 'Orange armor',        deathstar_security.friend_or_foe( t_person_appearance('blaster', 'blue', 'armor', 'orange') ) from dual union all
select 'Blue armor',          deathstar_security.friend_or_foe( t_person_appearance('blaster', 'blue', 'armor', 'blue') ) from dual;







-- Complete (Backup)
create or replace package deathstar_security as
  /* Decides whether a person is friend or foe,
     based on their appearance
   */
  function friend_or_foe( i_person_data t_person_appearance )
    return varchar2;
end;
/

create or replace package body deathstar_security as
  function friend_or_foe( i_person_data t_person_appearance )
    return varchar2
  as
    begin
      if ( i_person_data.weapon_type = 'lightsaber'
        and i_person_data.weapon_color in ('red','orange')) then
        return 'FRIEND';
      end if;

      return 'FOE';
    end;
end;
/