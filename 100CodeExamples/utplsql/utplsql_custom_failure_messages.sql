
create table starships (
  id integer not null primary key,
  name varchar2(100),
  hull_health number(5,2) default 100 not null,
  repair_runs integer default 0 not null
);

insert into starships values ( 1, 'Millenium Falcon', 85.6, 3);
insert into starships values ( 2, 'X-Wing 775', 23.6, 4);
insert into starships values ( 3, 'X-Wing 2224', 50, 0);
insert into starships values ( 4, 'Y-Wing One', 12, 17);


create or replace package starship_workshop as
  procedure repair_all;
end;
/

create or replace package body starship_workshop as
  procedure repair_all
  as
    begin
      update starships
        set hull_health = 100,
            repair_runs = repair_runs+1
        where hull_health between 30 and 100;
    end;
end;
/

create or replace package ut_starship_workshop as
  -- %suite(Starship-Workshop)

  -- %test(Repair all increases repair-count of each repaired starship)
  procedure repair_increased_count;
end;
/

create or replace package body ut_starship_workshop as

  procedure check_increased_count(
    i_id simple_integer,
    i_previous_run simple_integer
  )
  as
    l_actual_run integer;
    l_ship_name varchar2(100);
    begin
      select repair_runs, name
        into l_actual_run, l_ship_name
        from starships
        where id = i_id;

      ut.expect(l_actual_run,
                'The repair-run of starship '
                || l_ship_name
                || ' was not increased')
        .to_equal(i_previous_run+1);
    end;

  procedure repair_increased_count
  as
    type t_ships is table of starships%rowtype;
    l_ships_to_repair t_ships;
    begin

      select *
        bulk collect into l_ships_to_repair
        from starships
        where hull_health < 100;

      -- Act
      starship_workshop.repair_all();

      -- Assert for all the ships to repair
      for i in l_ships_to_repair.first..l_ships_to_repair.last loop
        check_increased_count(
          l_ships_to_repair(i).id,
          l_ships_to_repair(i).repair_runs
        );
      end loop;

    end;

end;
/

call ut.run('ut_starship_workshop');

/****************
* Cleanup
*****************/

drop package ut_starship_workshop;
drop package starship_workshop;
drop table starships;