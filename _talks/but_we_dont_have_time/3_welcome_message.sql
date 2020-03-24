-- Prepare WELCOME functionality
create or replace package protocol_security as

  /* Returns the active DEFENSE_MODE of the deathstar
   */
  function active_defense_mode
    return varchar2;

  /* Returns a welcome message based on the
     active Deathstar protocols DEFENSE_MODE
   */
  function welcome( i_person_data t_person_appearance )
    return varchar2;

end;
/

create or replace package body protocol_security as
  function active_defense_mode
    return varchar2
  as
    l_result varchar2(200);
  begin
    select p.defense_mode into l_result
      from deathstar_protocols p
        inner join deathstar_protocol_active pa
          on p.id = pa.id;
    return l_result;
  end;

  function welcome( i_person_data t_person_appearance )
    return varchar2
  as
    begin
      return null;
    end;
end;
/


-- Complete Test Suite
create or replace package ut_deathstar_security_welcome as
  -- %suite(Deathstar-Security: Welcome message)
  -- %suitepath(ut_deathstar.defense)

  -- %beforeall
  procedure setup_protocol;

  -- %test(We expect to receive the controlled protocol)
  procedure we_get_the_expected_protocol;

  -- %context(When protocol in Defense-Mode: BE_KIND)
		-- %name(be_kind)

		-- %beforeall
		procedure setup_protocol_be_kind;

		-- %test(Friend is welcomed)
		procedure be_kind_friend_is_welcomed;

		-- %test(Foe is shouted at)
		procedure be_kind_foe_is_shouted_at;

		-- %test(Unknown is welcomed)
		procedure be_kind_unknown_is_welcomed;
	-- %endcontext

  -- %context(When protocol in Defense-Mode: BE_SUSPICIOUS)
		-- %name(be_suspicious)

		-- %beforeall
		procedure setup_protocol_be_suspicious;

		-- %test(Friend is welcomed)
		procedure be_suspicious_friend_is_welcomed;

		-- %test(Foe is shouted at)
		procedure be_suspicious_foe_is_shouted_at;

		-- %test(Unknown is asked whether they are a jedi)
		procedure be_suspicious_unknown_is_asked;
	-- %endcontext

  -- %context(When protocol in Defense-Mode: SHOOT_FIRST_ASK_LATER)
		-- %name(be_aggressive)

		-- %beforeall
		procedure setup_protocol_be_aggressive;

		-- %test(Friend is welcomed)
		procedure be_aggressive_friend_is_welcomed;

		-- %test(Foe is shouted at)
		procedure be_aggressive_foe_is_shouted_at;

		-- %test(Unknown is shouted at)
		procedure be_aggressive_unknown_is_shouted_at;
	-- %endcontext

end;
/

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

  procedure setup_protocol_be_suspicious as
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


select * from table(ut.run('ut_deathstar_security_welcome'));




-- Implement the functionality
create or replace package body protocol_security as
  function active_defense_mode
    return varchar2
  as
    l_result varchar2(200);
  begin
    select p.defense_mode into l_result
      from deathstar_protocols p
        inner join deathstar_protocol_active pa
          on p.id = pa.id;
    return l_result;
  end;

  function welcome( i_person_data t_person_appearance )
    return varchar2
  as
    -- Make clear what's the input
    l_friend_or_foe varchar2(10) := deathstar_security.friend_or_foe(i_person_data);
    l_defense_mode varchar2(200) := active_defense_mode();
    begin
      -- What we know from our up-front analysis
      if ( l_friend_or_foe = 'FRIEND' ) then
        return 'Be welcome!';
      elsif ( l_friend_or_foe = 'FOE' ) then
        return 'Die rebel scum!';
      end if;

      case l_defense_mode
        when 'BE_KIND' then
          return 'Be welcome!';
        when 'BE_SUSPICIOUS' then
          return 'Are you a jedi?';
        when 'SHOOT_FIRST_ASK_LATER' then
          return 'Die rebel scum!';
      end case;
    end;
end;
/


call ut.run('ut_deathstar_security_welcome');

-- Single context
call ut.run(':ut_deathstar.defense.ut_deathstar_security_welcome.be_kind');


-- All Deathstar.defense tests
call ut.run(':ut_deathstar.defense');