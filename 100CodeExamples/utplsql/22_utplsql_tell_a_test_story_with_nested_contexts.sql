/***********
  Setup
 **********/
create or replace type t_person_appearance force is object (
  weapon_type varchar2(50),
  weapon_color varchar2(50),
  cloth_type varchar2(50),
  cloth_color varchar2(50)
);

create or replace package deathstar_security as

  const_friend constant varchar2(10) := 'FRIEND';
  const_foe constant varchar2(10) := 'FOE';
  const_unknown constant varchar2(10) := 'UNKNOWN';

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

/* Original Test-package */

create or replace package ut_deathstar_friend_or_foe as
  -- %suite(Friend or Foe detection)
  -- %suitepath(ut_deathstar.defense)

  -- %test(Red lightsaber means friend)
  procedure lightsaber_red_means_friend;

  -- %test(Blue lightsaber means foe)
  procedure lightsaber_blue_means_foe;

  -- %test(Black robe means friend)
  procedure robe_black_means_friend;

  -- %test(Brown robe means foe)
  procedure robe_brown_means_foe;

  -- %test(Red robe means unknown)
  procedure robe_red_means_unknown;

  -- %test(White armor means friend)
  procedure armor_white_means_friend;

  -- %test(Orange armor means foe)
  procedure armor_orange_means_foe;

  -- %test(Blue/Black armor means foe)
  procedure armor_blue_black_means_foe;

  -- %test(Green armor means unknown)
  procedure armor_green_means_unknown;
end;
/

create or replace package body ut_deathstar_friend_or_foe as
  procedure lightsaber_red_means_friend
  as
    begin
      ut.expect(deathstar_security.friend_or_foe(new t_person_appearance('lightsaber', 'red', null, null)))
        .to_equal('FRIEND');
    end;

  procedure lightsaber_blue_means_foe
  as
    begin
      ut.expect(deathstar_security.friend_or_foe(new t_person_appearance('lightsaber', 'blue', null, null)))
        .to_equal('FOE');
    end;

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

  procedure armor_white_means_friend
  as
    begin
      ut.expect(deathstar_security.friend_or_foe(new t_person_appearance(null, null, 'armor', 'white')))
        .to_equal('FRIEND');
    end;

  procedure armor_orange_means_foe
  as
    begin
      ut.expect(deathstar_security.friend_or_foe(new t_person_appearance(null, null, 'armor', 'orange')))
        .to_equal('FOE');
    end;

  procedure armor_blue_black_means_foe
  as
    begin
      ut.expect(deathstar_security.friend_or_foe(new t_person_appearance(null, null, 'armor', 'blue/black')))
        .to_equal('FOE');
    end;

  procedure armor_green_means_unknown
  as
    begin
      ut.expect(deathstar_security.friend_or_foe(new t_person_appearance(null, null, 'armor', 'green')))
        .to_equal('UNKNOWN');
    end;

end;
/

select * from table(ut.run('ut_deathstar_friend_or_foe'));

/* Now lets use nested contexts and change some descriptions */

create or replace package ut_deathstar_friend_or_foe as
  -- %suite(Friend or Foe detection)
  -- %suitepath(ut_deathstar.defense)

  -- %context(When a person has a lightsaber)
    -- %name(2_lightsaber)

    -- %test(that is red: FRIEND)
    procedure lightsaber_red_means_friend;
    -- %test(that is blue: FOE)
    procedure lightsaber_blue_means_foe;
  -- %endcontext

  -- %context(When a person has no lightsaber)
    -- %name(1_no_lightsaber)

    -- %context(but is wearing a robe)
      -- %name(robe)

      -- %test(that is black: FRIEND)
      procedure robe_black_means_friend;
      -- %test(that is brown: FOE)
      procedure robe_brown_means_foe;
      -- %test(that is red: UNKNOWN)
      procedure robe_red_means_unknown;
    -- %endcontext

    -- %context(but is wearing armor)
      -- %name(armor)

      -- %test(that is white: FRIEND)
      procedure armor_white_means_friend;
      -- %test(that is orange: FOE)
      procedure armor_orange_means_foe;
      -- %test(that is blue/black: FOE)
      procedure armor_blue_black_means_foe;
      -- %test(that is green: UNKNOWN)
      procedure armor_green_means_unknown;
    -- %endcontext;

  -- %endcontext
end;
/


select * from table(ut.run('ut_deathstar_friend_or_foe'));