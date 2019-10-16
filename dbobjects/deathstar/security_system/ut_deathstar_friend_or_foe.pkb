create or replace package body ut_deathstar_friend_or_foe as
  procedure lightsaber_red_orange_means_friend
  as
    begin
      ut.expect(deathstar_security.friend_or_foe(new t_person_appearance('lightsaber', 'red', null, null)))
        .to_equal('FRIEND');
      ut.expect(deathstar_security.friend_or_foe(new t_person_appearance('lightsaber', 'orange', null, null)))
        .to_equal('FRIEND');
    end;

end;
/