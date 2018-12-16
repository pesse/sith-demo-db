create table planets (
  id integer primary key,
  name varchar(256)
);

create or replace package ut_planet_setup as
  -- %suite(planetSetup)
  -- %suitepath(galaxy)

  -- %beforeall
  procedure setup_test_planet;
end;
/

create or replace package body ut_planet_setup as
  procedure setup_test_planet
  as
    begin
      insert into planets ( id, name )
        values ( -1, 'Korriban');
    end;
end;
/


create or replace package ut_planets as
  -- %suite(Planets)
  /* Hierarchic Suitepath must contain any parent suitepaths
     and the name of the parent test-package
   */
  -- %suitepath(galaxy.ut_planet_setup)

  -- %test(Check if test-plantes exist: 1 planet)
  procedure test_planets_exist;
end;
/

create or replace package body ut_planets as
  procedure test_planets_exist
  as
    l_count int;
    begin
      select count(*) into l_count from planets where id < 0;
      ut.expect(l_count).to_equal(1);
    end;
end;
/

create or replace package ut_garrisons as
  -- %suite(Garrisons)
  -- %suitepath(galaxy.ut_planet_setup)

  -- %beforeall
  procedure setup_another_test_planet;

  -- %test(Check if test-plantes exist: 2 planets)
  procedure test_planets_exist;

  /* We could add some more tests for Planet-Garrisons here */
end;
/

create or replace package body ut_garrisons as
  procedure setup_another_test_planet
  as
    begin
      insert into planets ( id, name )
        values (-2, 'Dromund Kaas');
    end;

  procedure test_planets_exist
  as
    l_count int;
    begin
      select count(*) into l_count from planets where id < 0;
      ut.expect(l_count).to_equal(2);
    end;
end;
/

/* Parent Suite-name is shown with its displayname
   but has to be called by its package-name.
   Beginning ":" means we search for a suitepath
 */
call ut.run(':galaxy.ut_planet_setup');

/* If we call it by package-name only, utPLSQL
   doesnt run the child suites
 */
call ut.run('ut_planet_setup');

/* But we can call it with either of the concrete
   test suites names
 */
call ut.run('ut_planets');
call ut.run('ut_garrisons');