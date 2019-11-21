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