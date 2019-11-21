create or replace package body ut_deathstar_security_welcome as

  g_friend_appearance t_person_appearance := new t_person_appearance('lightsaber', 'red', null, null);
  g_foe_appearance t_person_appearance := new t_person_appearance('lightsaber', 'blue', null, null);
  g_unknown_appearance t_person_appearance := new t_person_appearance('blaster', 'red', 'armor', 'green');

  procedure setup_protocol
  as
    begin
      insert into deathstar_protocols (id, label, defense_mode, alert_level, power_level)
        values ( -1, 'Test-Protocol', 'toBeDefined', 'Not_Important', 80);

      update deathstar_protocol_active set id = -1;
    end;

  procedure we_get_the_expected_protocol
  as
    begin
      -- Set Defense-mode
      update deathstar_protocols set defense_mode = 'BE_KIND' where id = -1;

      ut.expect(protocol_security.active_defense_mode())
        .to_equal('BE_KIND');

      update deathstar_protocols set defense_mode = 'BE_SUSPICIOUS' where id = -1;

      ut.expect(protocol_security.active_defense_mode())
        .to_equal('BE_SUSPICIOUS');
    end;

  procedure setup_protocol_be_kind
  as
    begin
      update deathstar_protocols set defense_mode = 'BE_KIND' where id = -1;
    end;

  procedure be_kind_friend_is_welcomed
  as
    begin
      ut.expect(protocol_security.welcome(g_friend_appearance))
        .to_equal('Be welcome!');
    end;

  procedure be_kind_foe_is_shouted_at
  as
    begin
      ut.expect(protocol_security.welcome(g_foe_appearance))
        .to_equal('Die rebel scum!');
    end;

  procedure be_kind_unknown_is_welcomed
  as
    begin
      ut.expect(protocol_security.welcome(g_unknown_appearance))
        .to_equal('Be welcome!');
    end;

  procedure setup_protocol_be_suspicious
  as
    begin
      update deathstar_protocols set defense_mode = 'BE_SUSPICIOUS' where id = -1;
    end;

  procedure be_suspicious_friend_is_welcomed
  as
    begin
      ut.expect(protocol_security.welcome(g_friend_appearance))
        .to_equal('Be welcome!');
    end;

  procedure be_suspicious_foe_is_shouted_at
  as
    begin
      ut.expect(protocol_security.welcome(g_foe_appearance))
        .to_equal('Die rebel scum!');
    end;

  procedure be_suspicious_unknown_is_asked
  as
    begin
      ut.expect(protocol_security.welcome(g_unknown_appearance))
        .to_equal('Are you a jedi?');
    end;

  procedure setup_protocol_be_aggressive
  as
    begin
      update deathstar_protocols set defense_mode = 'SHOOT_FIRST_ASK_LATER' where id = -1;
    end;

  procedure be_aggressive_friend_is_welcomed
  as
    begin
      ut.expect(protocol_security.welcome(g_friend_appearance))
        .to_equal('Be welcome!');
    end;

  procedure be_aggressive_foe_is_shouted_at
  as
    begin
      ut.expect(protocol_security.welcome(g_foe_appearance))
        .to_equal('Die rebel scum!');
    end;

  procedure be_aggressive_unknown_is_shouted_at
  as
    begin
      ut.expect(protocol_security.welcome(g_unknown_appearance))
        .to_equal('Die rebel scum!');
    end;
end;
/
