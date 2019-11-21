create or replace package ut_deathstar_friend_or_foe as
  -- %suite(Friend or Foe detection)
	-- %suitepath(ut_deathstar.defense)

  -- %test(Red lightsaber means friend)
  procedure lightsaber_red_means_friend;

  -- %test(Blue lightsaber means friend)
  procedure lightsaber_blue_means_foe;

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