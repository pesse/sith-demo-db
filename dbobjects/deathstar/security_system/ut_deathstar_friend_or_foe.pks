create or replace package ut_deathstar_friend_or_foe as
  -- %suite(Friend or Foe detection)
	-- %suitepath(deathstar.defense)

  -- %test(Red or orange lightsaber means friend)
  procedure lightsaber_red_orange_means_friend;
end;
/