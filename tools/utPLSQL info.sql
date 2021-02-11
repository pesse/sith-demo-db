select substr(ut.version(),1,60) as ut_version from dual;


select
  xmlserialize( content xmltype(ut_run_info()) as clob indent size = 2 )
  from dual;


select * from
  table(ut_runner.get_suites_info())
  where item_type = 'UT_SUITE';

begin
  if ut_runner.has_suites(USER) then
    dbms_output.put_line( 'User '||USER||' owns test suites' );
  else
    dbms_output.put_line( 'User '||USER||' does not own test suites' );
  end if;
end;
