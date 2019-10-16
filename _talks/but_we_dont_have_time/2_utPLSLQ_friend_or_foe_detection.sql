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
      return 'FOE';
    end;
end;
/

create or replace package ut_security_util as
  -- %suite(Friend or Foe detection)

  -- %test(Red or orange lightsaber means friend)
  procedure lightsaber_red_orange_means_friend;
end;
/

create or replace package body ut_security_util as
  procedure lightsaber_red_orange_means_friend
  as
    begin
      ut.expect(security_util.friend_or_foe(new person_analyis('lightsaber', 'red', null, null)))
        .to_equal('FRIEND');
      ut.expect(security_util.friend_or_foe(new person_analyis('lightsaber', 'orange', null, null)))
        .to_equal('FRIEND');
    end;

end;

call ut.run('ut_security_util');