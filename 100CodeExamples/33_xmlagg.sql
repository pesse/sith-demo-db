
create table characters (
  id integer not null primary key,
  name varchar2(100) unique,
  faction varchar2(100)
);

create table favorite_food (
  character_id integer not null references characters( id ),
  food varchar2(4000)
);

insert into characters values (1, 'Chewbacca', 'Rebels');
insert into characters values (2, 'Darth Vader', 'Empire');
insert into characters values (3, 'Jar Jar Binks', 'Rebels');

insert into favorite_food values ( 1, 'Grilled Pork');
insert into favorite_food values ( 1, 'Cooked Pork');
insert into favorite_food values ( 1, 'Raw Pork');
insert into favorite_food values ( 2, 'Cheesecake');

commit;

select *
from characters c
  inner join favorite_food ff on c.id = ff.character_id;

--This will cause an ORA-00935
select
  xmlserialize(
    document
    xmlelement(
      "Factions",
      xmlagg(
        xmlelement(
          "Faction",
          xmlattributes(c.faction as "name"),
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
        )
      )
    )
    as clob indent size = 2
  )
from characters c
  left outer join favorite_food ff on c.id = ff.character_id
group by faction
;

-- As soon as we hit more than 2 levels of nesting, we need to use subqueries instead
select
  xmlserialize(
    document
    xmlelement(
      "Factions",
      xmlagg(
        xmlelement(
          "Faction",
          xmlattributes(c.faction as "name"),
          xmlelement("Characters",
            xmlagg(
              xmlelement("Character",
                xmlforest(
                  c.name as "name"
                ),
                xmlelement("favouriteFoods",
                  (
                    select
                      xmlagg(
                        xmlforest(
                          ff.food as "food"
                        )
                      )
                    from favorite_food ff
                    where c.id = ff.character_id
                  )
                )
              )
            )
          )
        )
      )
    )
    as clob indent size = 2
  )
from characters c
group by faction
;

-- We can even use a nice WITH clause to make it more readable
with character_foods as (
  select
    character_id,
    xmlagg(
      xmlforest(
        food as "food"
      )
    ) xml
  from favorite_food
  group by character_id
)
select
  xmlserialize(
    document
    xmlelement(
      "Factions",
      xmlagg(
        xmlelement(
          "Faction",
          xmlattributes(c.faction as "name"),
          xmlelement("Characters",
            xmlagg(
              xmlelement("Character",
                xmlforest(
                  c.name as "name"
                ),
                xmlelement("favouriteFoods",
                  (
                    select xml
                    from character_foods cf
                    where cf.character_id = c.id
                  )
                )
              )
            )
          )
        )
      )
    )
    as clob indent size = 2
  )
from characters c
group by faction


-- As JSON
select
  json_serialize(
    json_arrayagg(
      json_object(
        faction,
        'characters' value json_arrayagg(
          json_object(
            name,
            'favoriteFoods' value (
              select
                json_arrayagg(
                  ff.food
                )
              from favorite_food ff
              where c.id = ff.character_id
            )
          )
        )
      )
    )
    pretty
  )
from characters c
group by faction;