create or replace package body ut_deathstar_security as

  /* Helper-function to get a hooded test-person
     Not really needed but everything gets
     better with hoods!
   */
  function get_hooded_person
    return t_person_appearance
  as
  begin
    return new t_person_appearance(
        null,
        null,
        'hooded_robe',
        null);
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

    /* In case no active protocol entry exists */
    insert into deathstar_protocol_active ( id )
      select -1 from dual
        where not exists (select 1 from deathstar_protocol_active);
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