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

create or replace package ut_deathstar_friend_or_foe as
  -- %suite(Friend or Foe detection)
	-- %suitepath(ut_deathstar.defense)

  -- %test(Black robe means friend)
  procedure robe_black_means_friend;

  -- %test(Brown robe means foe)
  procedure robe_brown_means_foe;
end;
/

create or replace package body ut_deathstar_friend_or_foe as
  procedure robe_black_means_friend
  as
    begin
      ut.expect(deathstar_security.friend_or_foe(new t_person_appearance(null, null, 'hooded_robe', 'black')))
        .to_equal('FRIEND');
    end;

  procedure robe_brown_means_foe
  as
    begin
      ut.expect(deathstar_security.friend_or_foe(new t_person_appearance(null, null, 'hooded_robe', 'brown')))
        .to_equal('FOE');
    end;

end;



call ut.run('ut_deathstar_friend_or_foe');




-- Green armor + Red robe
create or replace package ut_deathstar_friend_or_foe as
  -- %suite(Friend or Foe detection)
	-- %suitepath(ut_deathstar.defense)

  -- %test(Black robe means friend)
  procedure robe_black_means_friend;

  -- %test(Brown robe means foe)
  procedure robe_brown_means_foe;

  -- %test(Red robe means unknown)
  procedure robe_red_means_unknown;

  -- %test(Green armor means unknown)
  procedure armor_green_means_unknown;
end;
/


create or replace package body ut_deathstar_friend_or_foe as
  procedure robe_black_means_friend
  as
    begin
      ut.expect(deathstar_security.friend_or_foe(new t_person_appearance(null, null, 'hooded_robe', 'black')))
        .to_equal('FRIEND');
    end;

  procedure robe_brown_means_foe
  as
    begin
      ut.expect(deathstar_security.friend_or_foe(new t_person_appearance(null, null, 'hooded_robe', 'brown')))
        .to_equal('FOE');
    end;

  procedure robe_red_means_unknown
  as
    begin
      ut.expect(deathstar_security.friend_or_foe(new t_person_appearance(null, null, 'hooded_robe', 'red')))
        .to_equal('UNKNOWN');
    end;

  procedure armor_green_means_unknown
  as
    begin
      ut.expect(deathstar_security.friend_or_foe(new t_person_appearance(null, null, 'armor', 'green')))
        .to_equal('UNKNOWN');
    end;

end;
/



call ut.run('ut_deathstar_friend_or_foe');



-- Even bigger changes don't matter with a strong test suite
create or replace package body deathstar_security as

  const_friend  constant varchar2(20) := 'FRIEND';
  const_foe     constant varchar2(20) := 'FOE';
  const_unknown constant varchar2(20) := 'UNKNOWN';

  function friend_or_foe( i_person_data t_person_appearance )
    return varchar2
  as
    begin
      if ( i_person_data.weapon_type = 'lightsaber') then
        if ( i_person_data.weapon_color in ('red','orange')) then
          return const_friend;
        else
          return const_foe;
        end if;
      end if;

      if ( i_person_data.cloth_type = 'hooded_robe' ) then
        if ( i_person_data.cloth_color = 'black') then
          return const_friend;
        elsif ( i_person_data.cloth_color = 'red') then
          return const_unknown;
        else
          return const_foe;
        end if;
      end if;

      if ( i_person_data.cloth_type = 'armor' ) then
        if ( i_person_data.cloth_color = 'white') then
          return const_friend;
        elsif ( i_person_data.cloth_color in ('blue/black', 'orange')) then
          return const_foe;
        else
          return const_unknown;
        end if;
      end if;

      return const_unknown;
    end;
end;
/



call ut.run('ut_deathstar_friend_or_foe');