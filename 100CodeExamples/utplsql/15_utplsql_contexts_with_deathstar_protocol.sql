/* Setup known from Deathstar-Protocol example
 */
create table deathstar_protocols (
  id integer not null primary key,
  label varchar2(256),
  alert_level varchar2(16) not null,
  defense_mode varchar2(32) not null,
  power_level number(5,2) not null
);

create table deathstar_protocol_active (
  id integer not null primary key,
  only_one number(1) default 1 not null,
  constraint deathstar_prot_act_fk
    foreign key ( id )
    references deathstar_protocols ( id )
    on delete cascade,
  constraint deathstar_prot_act_uq
    unique ( only_one ),
  constraint deathstar_prot_act_chk
    check ( only_one = 1 )
);

create or replace package deathstar_security as

  /* This is just for making the setting a
     little bit more realistic. Implementation-wise
     we dont make a distinction whether a person
     is hooded (which is a sure sign for an
     undercover jedi) or not
   */
  type t_person is record (
    is_hooded boolean
	);

  /* Returns a welcome message based on the
     active Deathstar protocols DEFENSE_MODE
   */
  function welcome(i_person t_person)
    return varchar2;

  /* Checks whether access is allowed based on
     the active Deathstar protocols ALERT_MODE
   */
  function access_allowed( i_person t_person )
    return boolean;
end;
/

create or replace package body deathstar_security as
  /* Helper-function to get the active
     Deathstar protocol row
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

  function welcome(i_person t_person)
    return varchar2
  as
    l_protocol deathstar_protocols%rowtype
      := active_protocol();
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

  function access_allowed( i_person t_person )
    return boolean
  as
    l_protocol deathstar_protocols%rowtype
      := active_protocol();
  begin
    case l_protocol.alert_level
      when 'LOW' then
        return true;
      when 'MEDIUM' then
        return false;
      when 'VERY HIGH' then
        raise_application_error(-20100,
          'Unauthorized attempt to access a public area');
      else
        raise_application_error(-20000, 'Oooops, no access');
    end case;
  end;
end;
/

create or replace package ut_deathstar_security as
	-- %suite(Deathstar Security)
	-- %suitepath(deathstar.defense)

	/* This first beforeall is only issued
	   once for the whole suite - which can be
	   a massive speed boost
	 */
	-- %beforeall
	procedure setup_test_protocols;

	/* Every context can have an identifier */
	-- %context(low)
		/* With the displayname-annotation we can also
	       give a label */
		-- %displayname(Protocol: Low)

		/* This is only issued once in this context */
		-- %beforeall
		procedure setup_protocol_low;

		-- %test(Hooded Person gets a kind welcome message)
		procedure low_welcome_message;

		-- %test(Entry to public area is allowed)
		procedure low_entry_allowed;
	/* Every context needs to be closed */
	-- %endcontext

	-- %context(medium)
		-- %displayname(Protocol: Medium)

		-- %beforeall
		procedure setup_protocol_medium;

		-- %test(Hooded Person gets a suspicious welcome message)
		procedure medium_welcome_message;

		-- %test(Entry to public area is denied)
		procedure medium_entry_allowed;
	-- %endcontext

	-- %context(high)
		-- %displayname(Protocol: High)

		-- %beforeall
		procedure setup_protocol_high;

		-- %test(Hooded Person is yelled at)
		procedure high_welcome_message;

		-- %test(Try to access public area throws exception)
		-- %throws(-20100)
		procedure high_entry_allowed;
	-- %endcontext
end;
/

create or replace package body ut_deathstar_security as

  /* Helper-function to get a hooded test-person
     Not really needed but everything gets
     better with hoods!
   */
  function get_hooded_person
    return deathstar_security.t_person
  as
    l_result deathstar_security.t_person;
  begin
    l_result.is_hooded := true;
    return l_result;
  end;

  /* Helper-Function to make the tests
     more expressive
   */
  procedure expect_welcome_message(
    i_expected_msg varchar2)
  as
  begin
    ut.expect(
      deathstar_security.welcome(
          get_hooded_person()
        )
      ).to_equal(i_expected_msg);
  end;

  /* Helper-Function to make the tests
     more expressive
   */
  procedure expect_access(
    i_expected_access boolean)
  as
  begin
    ut.expect(
      deathstar_security.access_allowed(
          get_hooded_person()
        )
      ).to_equal(i_expected_access);
  end;

  procedure setup_test_protocols
  as
  begin
    /* For we want to completely control our tests,
       we also set up specific test-protocols because we
       cannot be sure they stay the same over time.
       This is highly dependent on the use case, of course
     */
    insert into deathstar_protocols
      values (-1, 'Test Low', 'LOW', 'BE_KIND', 80);
    insert into deathstar_protocols
      values (-2, 'Test Medium', 'MEDIUM', 'BE_SUSPICIOUS', 90);
    insert into deathstar_protocols
      values (-3, 'Test High', 'VERY HIGH', 'SHOOT_FIRST_ASK_LATER', 120);
  end;

  procedure setup_protocol_low
  as
  begin
    update deathstar_protocol_active
      set id = -1;
  end;

  procedure low_welcome_message
  as
  begin
    expect_welcome_message('Be welcome!');
  end;

  procedure low_entry_allowed
  as
  begin
    expect_access(true);
  end;

  procedure setup_protocol_medium
  as
  begin
    update deathstar_protocol_active
      set id = -2;
  end;

  procedure medium_welcome_message
  as
  begin
    expect_welcome_message('Are you a jedi?');
  end;

  procedure medium_entry_allowed
  as
  begin
    expect_access(false);
  end;

  procedure setup_protocol_high
  as
  begin
    update deathstar_protocol_active
      set id = -3;
  end;

  procedure high_welcome_message
  as
  begin
    expect_welcome_message('Die rebel scum!');
  end;

  procedure high_entry_allowed
  as
  begin
    expect_access(false);
  end;
end;
/

call ut.run('ut_deathstar_security');
call ut.run(':deathstar.defense.ut_deathstar_security.high');