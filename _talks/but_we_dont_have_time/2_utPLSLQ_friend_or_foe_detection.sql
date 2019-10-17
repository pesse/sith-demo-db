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
      return 'FOE';
    end;
end;
/

create or replace package ut_deathstar_friend_or_foe as
  -- %suite(Friend or Foe detection)
	-- %suitepath(deathstar.defense)

  -- %test(Red or orange lightsaber means friend)
  procedure lightsaber_red_orange_means_friend;
end;
/

create or replace package body ut_deathstar_friend_or_foe as
  procedure lightsaber_red_orange_means_friend
  as
    begin
      ut.expect(security_util.friend_or_foe(new person_analyis('lightsaber', 'red', null, null)))
        .to_equal('FRIEND');
      ut.expect(security_util.friend_or_foe(new person_analyis('lightsaber', 'orange', null, null)))
        .to_equal('FRIEND');
    end;

end;

call ut.run('ut_deathstar_friend_or_foe');