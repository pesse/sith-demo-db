/*
create table deathstar_visitors (
  id integer generated by default as identity primary key,
  weapon_type varchar2(50),
  weapon_color varchar2(50),
  cloth_type varchar2(50),
  cloth_color varchar2(50),
  check_time timestamp,
  has_access number(1,0),
  active_defense_protocol varchar2(30),
  welcome_message varchar2(200)
);
*/

create or replace package visitor_security as

  /* Checks all the so-far unchecked for access
     based on the current security protocol
   */
  procedure check_visitors;
end;
/

create or replace package body visitor_security as

  procedure check_visitors as
    l_access number(1,0) := 0;
  begin
    for rec in (
      select id, t_person_appearance(weapon_type, weapon_color, cloth_type, cloth_color) appearance
        from deathstar_visitors
        where check_time is null)
    loop
      if deathstar_security.friend_or_foe(rec.appearance) = 'FRIEND' then
        l_access := 1;
      else
        l_access := 0;
      end if;

      update deathstar_visitors set
        has_access = l_access,
        check_time = current_timestamp,
        active_defense_protocol = protocol_security.active_defense_mode()
        where id = rec.id;
    end loop;
  end;

end;
/





-- Tests (in fact I wrote them before :D)
create or replace package ut_visitor_security as
  -- %suite(Visitor Security)
  -- %suitepath(ut_deathstar.defense)

  -- %beforeall
  procedure setup_protocol;

  -- %test(Friendly visitor gets access)
  procedure friendly_visitor_get_access;

  -- %test(Enemy gets no access)
  procedure enemy_get_no_access;
end;
/

create or replace package body ut_visitor_security as

  id_visitor constant integer := -10;

  procedure setup_protocol as
  begin
    insert into deathstar_protocols (id, label, defense_mode, alert_level, power_level)
      values ( -1, 'Test-Protocol', 'BE_KIND', 'Not_Important', 80);
    update deathstar_protocol_active set id = -1;
  end;

  procedure setup_visitor(
    i_id integer,
    i_weapon_type varchar2,
    i_weapon_color varchar2 )
  as
  begin
    insert into deathstar_visitors (id, weapon_type, weapon_color)
      values ( i_id, i_weapon_type, i_weapon_color);
  end;

  procedure friendly_visitor_get_access as
    l_actual deathstar_visitors%rowtype;
    l_start_time timestamp := current_timestamp;
  begin
    -- Arrange
    setup_visitor(id_visitor, 'lightsaber', 'red');

    -- Act
    visitor_security.check_visitors();

    -- Assert
    select * into l_actual from deathstar_visitors where id = id_visitor;
    ut.expect(l_actual.has_access).to_equal(1);
    ut.expect(l_actual.active_defense_protocol).to_equal('BE_KIND');
    ut.expect(l_actual.check_time).to_be_between(l_start_time, to_timestamp(current_timestamp));
  end;

  procedure enemy_get_no_access as
    l_actual deathstar_visitors%rowtype;
    l_start_time timestamp := current_timestamp;
  begin
    setup_visitor(id_visitor, 'lightsaber', 'green');

    visitor_security.check_visitors();

    select * into l_actual from deathstar_visitors where id = id_visitor;
    ut.expect(l_actual.has_access).to_equal(0);
    ut.expect(l_actual.active_defense_protocol).to_equal('BE_KIND');
    ut.expect(l_actual.check_time).to_be_between(l_start_time, to_timestamp(current_timestamp));
  end;

end;
/


select * from table(ut.run('ut_visitor_security'));