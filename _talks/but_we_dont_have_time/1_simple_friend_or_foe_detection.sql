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

create or replace type person_analyis is object (
  weapon_type varchar2(50),
  weapon_color varchar2(50),
  cloth_type varchar2(50),
  cloth_color varchar2(50)
);

create or replace package security_util as
  function friend_or_foe( i_person_data person_analyis )
    return varchar2;
end;
/
create or replace package body security_util as
  function friend_or_foe( i_person_data person_analyis )
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

select security_util.friend_or_foe( new person_analyis('lightsaber', 'red', 'something', 'something') ) from dual;
select security_util.friend_or_foe( new person_analyis('lightsaber', 'blue', 'something', 'something') ) from dual;
select security_util.friend_or_foe( new person_analyis('blaster', 'blue', 'hooded_robe', 'black') ) from dual;
select security_util.friend_or_foe( new person_analyis('blaster', 'blue', 'hooded_robe', 'brown') ) from dual;
select security_util.friend_or_foe( new person_analyis('blaster', 'blue', 'armor', 'white') ) from dual;
select security_util.friend_or_foe( new person_analyis('blaster', 'blue', 'armor', 'orange') ) from dual;
select security_util.friend_or_foe( new person_analyis('blaster', 'blue', 'armor', 'blue') ) from dual;