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

/* 3 am half-asleep made new view */
create or replace view all_movie_characters_3
  as
  select
    sw_char.id,
    sw_char.name
  from
    star_wars_characters sw_char
    inner join appearance_in_episode ep
      on sw_char.id = ep.character_fk
;

select * from all_movie_characters_3;

/* And check if old and new view return
   the same results.
 */
(
  select * from all_movie_characters
  minus
  select * from all_movie_characters_3
)
union all
(
  select * from all_movie_characters_3
  minus
  select * from all_movie_characters
);

/* They seem to be equal but arent! */

/* Check if every row is unique by comparing
   count of distinct values with normal count
 */
select 'distinct' type, count(*)
from (
       select distinct *
         from all_movie_characters_3
     )
union all
select 'all', count(*) from all_movie_characters_3;


/* Lets add a number of equal rows to the check
 */
with old as (
  select id, name, count(*) number_of_equals
    from all_movie_characters
    group by id, name
  ),
  new as (
    select id, name, count(*) number_of_equals
    from all_movie_characters_3
    group by id, name
  )
(
  select * from old
  minus
  select * from new
)
union all
(
  select * from new
  minus
  select * from old
);


/* Tom Kytes GROUP BY solution to comparing query results
   Pro: Very elegant, high readability of results
   Contra: Quite some typing
*/
select id, name, sum(old_cnt), sum(new_cnt)
from (
  select id, name, 1 old_cnt, 0 new_cnt
    from all_movie_characters source
  union all
  select id, name, 0 old_cnt, 1 new_cnt
    from all_movie_characters_3 target
)
group by id, name
having sum(old_cnt) != sum(new_cnt);

/* Stew Ashtons tooling packages:
   https://stewashton.wordpress.com/list-of-my-posts-about-comparing-and-synchronizing-tables/
 */