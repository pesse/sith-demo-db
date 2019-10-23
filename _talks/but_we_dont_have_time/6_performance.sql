-- Running a suite hierarchy - by selection
select * from table(ut.run(':ut_deathstar'));


-- Adding a Parent-Suite
create or replace package ut_deathstar as
  -- %suite(Tests around the Deathstar)

end;
/

call ut.run(':ut_deathstar');


-- Use it for some heavy-lifting setup
create or replace package ut_deathstar as
  -- %suite(Tests around the Deathstar)

  -- %beforeall
  procedure setup_deathstar;
end;
/

create or replace package body ut_deathstar as
  procedure setup_deathstar
  as
    begin
      dbms_output.put_line('Setting up the deathstar');
      dbms_lock.SLEEP(3);
    end;
end;
/

-- Calling the whole suite-hierarchy
call ut.run(':ut_deathstar');


-- It also works when only running a part of the suite-path
call ut.run(':ut_deathstar.rooms');


-- It also works when calling a suite directly
call ut.run('ut_deathstar_friend_or_foe');




-- How to deal with long-running tests
create or replace package ut_defeat_rebels as
  -- %suite(Defeating the rebels - can take a while)
  -- %suitepath(imperium)
  -- %tags(long_running)

  -- %test(Defeat them)
  -- %tags(very_long_running)
  procedure defeat_them;

  -- %test(Boast about your victory)
  -- %tags(quick)
  procedure boast;
end;
/


create or replace package body ut_defeat_rebels as
  procedure defeat_them
  as
    begin
      dbms_lock.sleep(5);
    end;

  procedure boast
  as
    begin
      dbms_output.put_line('WE ARE SOOOO AWESOME!');
    end;
end;
/

-- Run a specific tag
call ut.run('', a_tags=>'quick');


-- Run all with any of the given tags
call ut.run('', a_tags=>'quick,long_running');


-- Run all except a tag
call ut.run('', a_tags=>'long_running,-very_long_running');
