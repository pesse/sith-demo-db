create or replace package ut_test as
  -- %suite(My test suite)

  -- %test(My test)
  procedure the_test;
end;
/

create or replace package body ut_test as
  procedure the_test as
  begin
    ut.expect(1).to_equal(2);
  end;
end;
/

set serveroutput on
call ut.run('ut_test');