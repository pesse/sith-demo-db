create or replace package ut_deathstar_friend_or_foe as
  -- %suite(Friend or Foe detection)
	-- %suitepath(ut_deathstar.defense)

  -- %context(When a person has a lightsaber)
    -- %name(lightsaber)

    -- %test(that is red: FRIEND)
    procedure lightsaber_red_means_friend;
    -- %test(that is blue: FOE)
    procedure lightsaber_blue_means_foe;
  -- %endcontext

  -- %context(When a person has no lightsaber)
    -- %name(no_lightsaber)

    -- %context(but is wearing a robe)
      -- %name(robe)

      -- %test(that is black: FRIEND)
      procedure robe_black_means_friend;
      -- %test(that is brown: FOE)
      procedure robe_brown_means_foe;
      -- %test(that is red: UNKNOWN)
      procedure robe_red_means_unknown;
    -- %endcontext

    -- %context(but is wearing an armor)
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