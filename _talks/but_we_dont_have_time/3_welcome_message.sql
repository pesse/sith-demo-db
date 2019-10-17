

create or replace package deathstar_security as

  const_friend constant varchar2(10) := 'FRIEND';
  const_foe constant varchar2(10) := 'FOE';
  const_unknown constant varchar2(10) := 'UNKNOWN';

  /* Decides whether a person is friend or foe,
     based on their appearance
   */
  function friend_or_foe( i_person_data t_person_appearance )
    return varchar2;

  /* Returns a welcome message based on the
     active Deathstar protocols DEFENSE_MODE
   */
  function welcome( i_person_data t_person_appearance )
    return varchar2;
end;
/

create or replace package body deathstar_security as
  /* Returns the active security protocol of the deathstar
   */
  function active_protocol
    return deathstar_protocols%rowtype
  as
    l_result deathstar_protocols%rowtype;
  begin
    select p.* into l_result
      from deathstar_protocols p
        inner join deathstar_protocol_active pa
          on p.id = pa.id;
    return l_result;
  end;

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

  function welcome( i_person_data t_person_appearance )
    return varchar2
  as
    l_protocol deathstar_protocols%rowtype := active_protocol();
  begin
    case l_protocol.defense_mode
      when 'BE_KIND' then
        return 'Be welcome!';
      when 'BE_SUSPICIOUS' then
        return 'Are you a jedi?';
      when 'SHOOT_FIRST_ASK_LATER' then
        return 'Die rebel scum!';
      else
        raise_application_error(-20000, 'Ooops, no welcome');
    end case;
  end;
end;
/

create or replace package ut_deathstar_security_welcome as
  -- %suite(Deathstar-Security: Welcome message)
  -- %suitepath(deathstar.defense)

  -- %beforeall
  procedure setup_protocol;

  -- %context(be_kind)
		-- %displayname(When protocol in Defense-Mode: BE_KIND)

		-- %beforeall
		procedure setup_protocol_be_kind;

		-- %test(Friend is welcomed)
		procedure be_kind_friend_is_welcomed;

		-- %test(Foe is shouted at)
		procedure be_kind_foe_is_shouted_at;

		-- %test(Unknown is welcomed)
		procedure be_kind_unknown_is_welcomed;
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
      insert into deathstar_protocols (ID, LABEL, DEFENSE_MODE, alert_level, power_level)
        values ( -1, 'Test-Protocol', 'toBeDefined', 'Not_Important', 80);

      update deathstar_protocol_active set id = -1;
    end;

  procedure setup_protocol_be_kind
  as
    begin
      update deathstar_protocols
        set defense_mode = 'BE_KIND'
        where id = -1;
    end;

  procedure be_kind_friend_is_welcomed
  as
    begin
      ut.expect(deathstar_security.welcome(g_friend_appearance))
        .to_equal('Be welcome!');
    end;

  procedure be_kind_foe_is_shouted_at
  as
    begin
      ut.expect(deathstar_security.welcome(g_foe_appearance))
        .to_equal('Die rebel scum!');
    end;

  procedure be_kind_unknown_is_welcomed
  as
    begin
      ut.expect(deathstar_security.welcome(g_unknown_appearance))
        .to_equal('Be welcome!');
    end;
end;
/

call ut.run('ut_deathstar_security_welcome');

create or replace package body deathstar_security as
  /* Returns the active security protocol of the deathstar
   */
  function active_protocol
    return deathstar_protocols%rowtype
  as
    l_result deathstar_protocols%rowtype;
  begin
    select p.* into l_result
      from deathstar_protocols p
        inner join deathstar_protocol_active pa
          on p.id = pa.id;
    return l_result;
  end;

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

  function welcome( i_person_data t_person_appearance )
    return varchar2
  as
    l_protocol deathstar_protocols%rowtype := active_protocol();
  begin

    if ( friend_or_foe(i_person_data) = const_foe ) then
      return 'Die rebel scum!';
    end if;

    case l_protocol.defense_mode
      when 'BE_KIND' then
        return 'Be welcome!';
      when 'BE_SUSPICIOUS' then
        return 'Are you a jedi?';
      when 'SHOOT_FIRST_ASK_LATER' then
        return 'Die rebel scum!';
      else
        raise_application_error(-20000, 'Ooops, no welcome');
    end case;
  end;
end;
/





call ut.run('ut_deathstar_security_welcome');




-- Next Defense-Mode
create or replace package ut_deathstar_security_welcome as
  -- %suite(Deathstar-Security: Welcome message)
  -- %suitepath(deathstar.defense)

  -- %beforeall
  procedure setup_protocol;

  -- %context(be_kind)
		-- %displayname(When protocol in Defense-Mode: BE_KIND)

		-- %beforeall
		procedure setup_protocol_be_kind;

		-- %test(Friend is welcomed)
		procedure be_kind_friend_is_welcomed;

		-- %test(Foe is shouted at)
		procedure be_kind_foe_is_shouted_at;

		-- %test(Unknown is welcomed)
		procedure be_kind_unknown_is_welcomed;
	-- %endcontext

  -- %context(be_suspicious)
		-- %displayname(When protocol in Defense-Mode: BE_SUSPICIOUS)

		-- %beforeall
		procedure setup_protocol_be_suspicious;

		-- %test(Friend is welcomed)
		procedure be_suspicious_friend_is_welcomed;

		-- %test(Foe is shouted at)
		procedure be_suspicious_foe_is_shouted_at;

		-- %test(Unknown is asked whether they are a jedi)
		procedure be_suspicious_unknown_is_asked;
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
      insert into deathstar_protocols (ID, LABEL, DEFENSE_MODE, alert_level, power_level)
        values ( -1, 'Test-Protocol', 'toBeDefined', 'Not_Important', 80);

      update deathstar_protocol_active set id = -1;
    end;

  procedure setup_protocol_be_kind
  as
    begin
      update deathstar_protocols
        set defense_mode = 'BE_KIND'
        where id = -1;
    end;

  procedure be_kind_friend_is_welcomed
  as
    begin
      ut.expect(deathstar_security.welcome(g_friend_appearance))
        .to_equal('Be welcome!');
    end;

  procedure be_kind_foe_is_shouted_at
  as
    begin
      ut.expect(deathstar_security.welcome(g_foe_appearance))
        .to_equal('Die rebel scum!');
    end;

  procedure be_kind_unknown_is_welcomed
  as
    begin
      ut.expect(deathstar_security.welcome(g_unknown_appearance))
        .to_equal('Be welcome!');
    end;

  procedure setup_protocol_be_suspicious
  as
    begin
      update deathstar_protocols
        set defense_mode = 'BE_SUSPICIOUS'
        where id = -1;
    end;

  procedure be_suspicious_friend_is_welcomed
  as
    begin
      ut.expect(deathstar_security.welcome(g_friend_appearance))
        .to_equal('Be welcome!');
    end;

  procedure be_suspicious_foe_is_shouted_at
  as
    begin
      ut.expect(deathstar_security.welcome(g_foe_appearance))
        .to_equal('Die rebel scum!');
    end;

  procedure be_suspicious_unknown_is_asked
  as
    begin
      ut.expect(deathstar_security.welcome(g_unknown_appearance))
        .to_equal('Are you a jedi?');
    end;
end;
/






call ut.run('ut_deathstar_security_welcome');




-- Add rule for friend
create or replace package body deathstar_security as
  /* Returns the active security protocol of the deathstar
   */
  function active_protocol
    return deathstar_protocols%rowtype
  as
    l_result deathstar_protocols%rowtype;
  begin
    select p.* into l_result
      from deathstar_protocols p
        inner join deathstar_protocol_active pa
          on p.id = pa.id;
    return l_result;
  end;

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

  function welcome( i_person_data t_person_appearance )
    return varchar2
  as
    l_protocol deathstar_protocols%rowtype := active_protocol();
  begin

    if ( friend_or_foe(i_person_data) = const_foe ) then
      return 'Die rebel scum!';
    end if;
    if ( friend_or_foe(i_person_data) = const_friend ) then
      return 'Be welcome!';
    end if;

    case l_protocol.defense_mode
      when 'BE_KIND' then
        return 'Be welcome!';
      when 'BE_SUSPICIOUS' then
        return 'Are you a jedi?';
      when 'SHOOT_FIRST_ASK_LATER' then
        return 'Die rebel scum!';
      else
        raise_application_error(-20000, 'Ooops, no welcome');
    end case;
  end;
end;
/





call ut.run('ut_deathstar_security_welcome');




create or replace package ut_deathstar_security_welcome as
  -- %suite(Deathstar-Security: Welcome message)
  -- %suitepath(deathstar.defense)

  -- %beforeall
  procedure setup_protocol;

  -- %context(be_kind)
		-- %displayname(When protocol in Defense-Mode: BE_KIND)

		-- %beforeall
		procedure setup_protocol_be_kind;

		-- %test(Friend is welcomed)
		procedure be_kind_friend_is_welcomed;

		-- %test(Foe is shouted at)
		procedure be_kind_foe_is_shouted_at;

		-- %test(Unknown is welcomed)
		procedure be_kind_unknown_is_welcomed;
	-- %endcontext

  -- %context(be_suspicious)
		-- %displayname(When protocol in Defense-Mode: BE_SUSPICIOUS)

		-- %beforeall
		procedure setup_protocol_be_suspicious;

		-- %test(Friend is welcomed)
		procedure be_suspicious_friend_is_welcomed;

		-- %test(Foe is shouted at)
		procedure be_suspicious_foe_is_shouted_at;

		-- %test(Unknown is asked whether they are a jedi)
		procedure be_suspicious_unknown_is_asked;
	-- %endcontext

  -- %context(be_aggressive)
		-- %displayname(When protocol in Defense-Mode: SHOOT_FIRST_ASK_LATER)

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
      insert into deathstar_protocols (ID, LABEL, DEFENSE_MODE, alert_level, power_level)
        values ( -1, 'Test-Protocol', 'toBeDefined', 'Not_Important', 80);

      update deathstar_protocol_active set id = -1;
    end;

  procedure setup_protocol_be_kind
  as
    begin
      update deathstar_protocols
        set defense_mode = 'BE_KIND'
        where id = -1;
    end;

  procedure be_kind_friend_is_welcomed
  as
    begin
      ut.expect(deathstar_security.welcome(g_friend_appearance))
        .to_equal('Be welcome!');
    end;

  procedure be_kind_foe_is_shouted_at
  as
    begin
      ut.expect(deathstar_security.welcome(g_foe_appearance))
        .to_equal('Die rebel scum!');
    end;

  procedure be_kind_unknown_is_welcomed
  as
    begin
      ut.expect(deathstar_security.welcome(g_unknown_appearance))
        .to_equal('Be welcome!');
    end;

  procedure setup_protocol_be_suspicious
  as
    begin
      update deathstar_protocols
        set defense_mode = 'BE_SUSPICIOUS'
        where id = -1;
    end;

  procedure be_suspicious_friend_is_welcomed
  as
    begin
      ut.expect(deathstar_security.welcome(g_friend_appearance))
        .to_equal('Be welcome!');
    end;

  procedure be_suspicious_foe_is_shouted_at
  as
    begin
      ut.expect(deathstar_security.welcome(g_foe_appearance))
        .to_equal('Die rebel scum!');
    end;

  procedure be_suspicious_unknown_is_asked
  as
    begin
      ut.expect(deathstar_security.welcome(g_unknown_appearance))
        .to_equal('Are you a jedi?');
    end;

  procedure setup_protocol_be_aggressive
  as
    begin
      update deathstar_protocols
        set defense_mode = 'SHOOT_FIRST_ASK_LATER'
        where id = -1;
    end;

  procedure be_aggressive_friend_is_welcomed
  as
    begin
      ut.expect(deathstar_security.welcome(g_friend_appearance))
        .to_equal('Be welcome!');
    end;

  procedure be_aggressive_foe_is_shouted_at
  as
    begin
      ut.expect(deathstar_security.welcome(g_foe_appearance))
        .to_equal('Die rebel scum!');
    end;

  procedure be_aggressive_unknown_is_shouted_at
  as
    begin
      ut.expect(deathstar_security.welcome(g_unknown_appearance))
        .to_equal('Die rebel scum!');
    end;
end;
/


call ut.run('ut_deathstar_security_welcome');