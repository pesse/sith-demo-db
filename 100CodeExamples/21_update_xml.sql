select * from star_wars_characters;

create table starfighter_models (
  id integer primary key,
  name varchar2(200) not null unique,
  technical_details clob
);

insert into starfighter_models ( id, name, technical_details )
values ( 1, 'X-Wing T65B',
'<starfighter>
  <Manufacturer>Incom Corporation</Manufacturer>
  <Line>X-Wing</Line>
  <Class>T65B</Class>
  <Hyperdrive>
    <RatingClass>1</RatingClass>
    <System>Equipped</System>
  </Hyperdrive>
</starfighter>');

insert into starfighter_models ( id, name, technical_details )
values ( 2, 'TIE Fighter',
'<starfighter>
  <Manufacturer>Sienar Fleet System</Manufacturer>
  <Line>TIE Series</Line>
  <Class>Starfighter</Class>
  <Hyperdrive>
    <System>None</System>
  </Hyperdrive>
</starfighter>');

insert into starfighter_models ( id, name, technical_details )
values ( 3, 'Millennium Falcon',
'<starfighter>
  <Manufacturer>Corellian Engineering Corporation</Manufacturer>
  <Line>YT Series</Line>
  <Class>Light Freighter</Class>
  <Hyperdrive>
    <RatingClass>0.5</RatingClass>
    <System>Isu-Sim SSP05 hyperdrive</System>
  </Hyperdrive>
</starfighter>');

select id, name, xmltype(technical_details) from starfighter_models;