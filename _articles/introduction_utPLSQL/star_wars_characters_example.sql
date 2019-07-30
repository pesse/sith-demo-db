create table star_wars_characters (
  id integer primary key,
  name varchar2(100)
);

create table appearance_in_episode (
  character_fk integer not null
    references star_wars_characters ( id )
      on delete cascade,
  episode_no number(2,0) not null
);

insert into star_wars_characters
  values ( 1, 'Darth Vader' );
insert into star_wars_characters
  values ( 2, 'Luke Skywalker' );
insert into star_wars_characters
  values ( 3, 'Rey' );

insert into appearance_in_episode values ( 1, 3 );
insert into appearance_in_episode values ( 1, 4 );
insert into appearance_in_episode values ( 1, 5 );
insert into appearance_in_episode values ( 1, 6 );
insert into appearance_in_episode values ( 2, 4 );
insert into appearance_in_episode values ( 2, 5 );
insert into appearance_in_episode values ( 2, 7 );
insert into appearance_in_episode values ( 2, 9 );
insert into appearance_in_episode values ( 3, 8 );
insert into appearance_in_episode values ( 3, 9 );

create or replace view v_starwars_characters
  as
  select
    sw_char.id,
    sw_char.name,
    listagg(ep.episode_no, ',') within group ( order by ep.episode_no ) episodes
  from
    star_wars_characters sw_char
    left outer join appearance_in_episode ep
      on sw_char.id = ep.character_fk
  group by sw_char.id, sw_char.name;

select * from v_starwars_characters;


-- Listing 1
declare
  l_name varchar2(2000);
begin
  update v_starwars_characters set name = 'Anakin Skywalker' where id = 1;
  select name into l_name
    from v_starwars_characters where id = 1;

  if ( l_name <> 'Anakin Skywalker') then
    raise_application_error(-20000, 'Update did not work!');
  end if;
end;

-- Listing 2
create or replace package ut_v_starwars_characters as
  -- %suite(View: V_STARWARS_CHARACTERS)

  -- %test(Update character-name via view)
  procedure update_name;
end;
/

-- Listing 3
create or replace package body ut_v_starwars_characters as
  procedure update_name
  as
    l_actual_name v_starwars_characters.name%type;
  begin
    -- Arrange: Setup test-data
    insert into star_wars_characters (id, name) values (-1, 'Test-Char');

    -- Act: Do the actual update
    update v_starwars_characters set name = 'Darth utPLSQL' where id = -1;

    -- Assert: Check the output
    select name into l_actual_name from v_starwars_characters where id = -1;
    ut.expect(l_actual_name).to_equal('Darth utPLSQL');
  end;
end;
/

-- Listing 4
set serveroutput on
call ut.run('ut_v_starwars_characters');

-- Listing 5
create or replace trigger save_v_starwars_characters
  instead of update on v_starwars_characters
  for each row
  begin
    null;
  end;
/

-- Listing 6
call ut.run();

-- Listing 7
create or replace trigger save_v_starwars_characters
  instead of update on v_starwars_characters
  for each row
  begin
    update star_wars_characters
      set name = :new.name
      where id = :new.id;
  end;
/

call ut.run();

-- Listing 8
create or replace package ut_v_starwars_characters as
  -- %suite(View: V_STARWARS_CHARACTERS)

  -- %beforeall
  procedure setup_test_data;

  -- %test(Update character-name via view)
  procedure update_name;

  -- %test(View returns correct list of episodes)
  procedure return_list_of_episodes;
end;
/

-- Listing 9
create or replace package body ut_v_starwars_characters as

  function get_view_row
    return v_starwars_characters%rowtype
  as
    l_result v_starwars_characters%rowtype;
  begin
    select * into l_result
      from v_starwars_characters
      where id = -1;
    return l_result;
  end;

  procedure setup_test_data
  as
  begin
    insert into star_wars_characters (id, name) values (-1, 'Test-Char');
    insert into appearance_in_episode (character_fk, episode_no)
      values ( -1, 3 );
    insert into appearance_in_episode (character_fk, episode_no)
      values ( -1, 5 );
  end;

  procedure update_name
  as
  begin
    update v_starwars_characters set name = 'Darth utPLSQL' where id = -1;

    ut.expect(get_view_row().name)
      .to_equal('Darth utPLSQL');
  end;

  procedure return_list_of_episodes
  as
  begin
    ut.expect(get_view_row().episodes)
      .to_equal('3,5');
  end;
end;
/

call ut.run();

-- Listing 10
create or replace package ut_v_starwars_characters as
  -- %suite(View: V_STARWARS_CHARACTERS)

  -- %beforeall
  procedure setup_test_data;

  -- %test(Update character-name via view)
  procedure update_name;

  -- %test(View returns correct list of episodes)
  procedure return_list_of_episodes;

  -- %test(View returns row but empty list of episodes when character has no appearance)
  procedure return_empty_list_of_episodes;
end;
/

create or replace package body ut_v_starwars_characters as

  function get_view_row
    return v_starwars_characters%rowtype
  as
    l_result v_starwars_characters%rowtype;
  begin
    select * into l_result
      from v_starwars_characters
      where id = -1;
    return l_result;
  end;

  procedure setup_test_data
  as
  begin
    insert into star_wars_characters (id, name) values (-1, 'Test-Char');
    insert into appearance_in_episode (character_fk, episode_no)
      values ( -1, 3 );
    insert into appearance_in_episode (character_fk, episode_no)
      values ( -1, 5 );
  end;

  procedure update_name
  as
  begin
    update v_starwars_characters set name = 'Darth utPLSQL' where id = -1;

    ut.expect(get_view_row().name)
      .to_equal('Darth utPLSQL');
  end;

  procedure return_list_of_episodes
  as
  begin
    ut.expect(get_view_row().episodes)
      .to_equal('3,5');
  end;

  procedure return_empty_list_of_episodes
  as
  begin
    delete from appearance_in_episode where character_fk = -1;

    ut.expect(get_view_row().episodes)
      .to_be_null();
  end;
end;
/

call ut.run();