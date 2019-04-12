/* Prepare some base tables with
   Star-Wars characters and their appearance
   in official movie episodes
 */
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

/* This is our old view we want to replace */
create or replace view all_movie_characters
  as
  select
    sw_char.id,
    sw_char.name
  from
    star_wars_characters sw_char
    inner join appearance_in_episode ep
      on sw_char.id = ep.character_fk
  group by sw_char.id, sw_char.name
;

/* We found this handy function and thought we could
   improve readability of our view.
   Unfortunately, this function does only consider
   the "original" movies */
create or replace function appears_in_movie(
    i_character_id integer
  ) return integer result_cache
  as
    l_count integer;
  begin
    select count(*)
      into l_count
      from appearance_in_episode
      where character_fk = i_character_id
        and episode_no between 4 and 6;
    if l_count > 0 then
      return 1;
    else
      return 2;
    end if;
  end;
/

/* To not break anything we first create
   our first approach with a different name
 */
create or replace view all_movie_character_2
  as
  select
    sw_char.id,
    sw_char.name
  from
    star_wars_characters sw_char
  where appears_in_movie(sw_char.id) = 1
;

/* And check if old and new view return
   the same results
 */
select * from all_movie_characters
minus
select * from all_movie_character_2
union all
select * from all_movie_character_2
minus
select * from all_movie_characters;


/* They do! Oh how great.
   Not.
   Look at the result of our new view:*/
select * from all_movie_character_2;

/* UNION ALL and MINUS have same precedence,
   so they are applied in order of occurence. */
select * from all_movie_characters
minus
select * from all_movie_character_2;


select * from all_movie_characters
minus
select * from all_movie_character_2
union all
select * from all_movie_character_2;


select * from all_movie_characters
minus
select * from all_movie_character_2
union all
select * from all_movie_character_2
minus
select * from all_movie_characters;


/* To prevent this, we have to put both
   MINUS comparisons in parenthesis */
(
  select * from all_movie_characters
  minus
  select * from all_movie_character_2
)
union all
(
  select * from all_movie_character_2
  minus
  select * from all_movie_characters
);