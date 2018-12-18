/* Simple table which contains starship-flights */
create table starport_flights (
  id integer not null primary key,
  ship_id integer not null,
  arrival date default sysdate,
  departure date
);

create or replace package ut_starport as
  -- %suite(Starport functionality)

  -- %test(Ship gets Arrival date on insert)
  procedure ship_gets_default_arrival;
end;

create or replace package body ut_starport as
  procedure ship_gets_default_arrival
  as
    /* Expected arrival is the current date */
    l_expected_arrival date := current_date;
    l_actual_arrival date;
    begin
      /* Act */
      insert into starport_flights ( id, ship_id )
        values ( -1, -1 );

      /* Assert: Actual arrival should be within 5
         seconds more or less than the expected arrival */
      select arrival into l_actual_arrival
        from starport_flights where id = -1;

      ut.expect(l_actual_arrival)
        .to_be_between( /* Assert with a bit of inaccuracy */
          l_expected_arrival - interval '5' second,
          l_expected_arrival + interval '5' second
        );
    end;
end;
/

call ut.run('ut_starport');

/****************************
* SYSDATE vs. CURRENT_DATE
*****************************/
/* Simple procedure to output sysdate, current_date and timezones
   Difference is CURRENT_DATE - SYSDATE */
create or replace procedure output_dates
as
  l_sysdate date := sysdate;
  l_dbtimezone varchar2(16) := dbtimezone;
  l_curdate date := current_date;
  l_sessiontimezone varchar2(16) := sessiontimezone;
  begin
    dbms_output.PUT_LINE(
      'Sysdate (' || l_dbtimezone || '): '
      || to_char(l_sysdate, 'HH24:MI')
      || ', Current_Date (' || l_sessiontimezone || '): '
      || to_char(l_curdate, 'HH24:MI') ||
      ', Difference (in hours): ' || to_char((l_curdate-l_sysdate)*24));
  end;
/

alter session set time_zone = '-6:00';
call output_dates();

alter session set time_zone = '+2:00';
call output_dates();