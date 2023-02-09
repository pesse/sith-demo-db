
create table characters (
  id integer not null primary key,
  name varchar2(100) unique
);

create table favorite_food (
  character_id integer not null references characters( id ),
  food varchar2(4000)
);

insert into characters values (1, 'Chewbacca');
insert into characters values (2, 'Darth Vader');

insert into favorite_food values ( 1, 'Grilled Pork');
insert into favorite_food values ( 1, 'Cooked Pork');
insert into favorite_food values ( 1, 'Raw Pork');
insert into favorite_food values ( 2, 'Cheesecake');

commit;

select *
from characters c
  inner join favorite_food ff on c.id = ff.character_id;

select
    xmlelement("Characters",
      xmlagg(
        xmlelement("Character",
          xmlforest(
            c.name as "name"
          ),
          xmlelement("favouriteFoods",
            xmlagg(
              xmlforest(
                ff.food as "food"
              )
            )
          )
        )
      )
    )
from characters c
  inner join favorite_food ff on c.id = ff.character_id
group by name
;

select
    xmlelement("sam:Characters",
      xmlattributes(
        'http://developer-sam.de/codeexamples' as "xmlns:sam"
      ),
      xmlagg(
        xmlelement("sam:Character",
          xmlforest(
            c.name as "name"
          ),
          xmlelement("favouriteFoods",
            xmlagg(
              xmlforest(
                ff.food as "food"
              )
            )
          )
        )
      )
    )
from characters c
  inner join favorite_food ff on c.id = ff.character_id
group by name
;