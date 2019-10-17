/*
 Indicators:
 - Weapon
    - Lightsaber-color -> Sure sign
    - Blaster -> Unsure
 - Hooded robe?
    - Black -> Sith
    - Brown or white -> Jedi
 - Armor?
    - White -> Imperial Trooper
    - Orange -> Rebel Pilot
    - Blue/Black -> Rebel
 */

create or replace type t_person_appearance force is object (
  weapon_type varchar2(50),
  weapon_color varchar2(50),
  cloth_type varchar2(50),
  cloth_color varchar2(50)
);

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

      if ( i_person_data.cloth_type = 'hooded_robe'
        and i_person_data.cloth_color = 'black') then
        return 'FRIEND';
      end if;

      if ( i_person_data.cloth_type = 'armor'
        and i_person_data.cloth_color = 'white') then
        return 'FRIEND';
      end if;

      return 'FOE';
    end;
end;
/

select deathstar_security.friend_or_foe( new t_person_appearance('lightsaber', 'red', 'something', 'something') ) from dual;
select deathstar_security.friend_or_foe( new t_person_appearance('lightsaber', 'blue', 'something', 'something') ) from dual;
select deathstar_security.friend_or_foe( new t_person_appearance('blaster', 'blue', 'hooded_robe', 'black') ) from dual;
select deathstar_security.friend_or_foe( new t_person_appearance('blaster', 'blue', 'hooded_robe', 'brown') ) from dual;
select deathstar_security.friend_or_foe( new t_person_appearance('blaster', 'blue', 'armor', 'white') ) from dual;
select deathstar_security.friend_or_foe( new t_person_appearance('blaster', 'blue', 'armor', 'orange') ) from dual;
select deathstar_security.friend_or_foe( new t_person_appearance('blaster', 'blue', 'armor', 'blue') ) from dual;