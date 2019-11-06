create or replace package body deathstar_room_view_generator as

  procedure create_view(
    i_view_name varchar2,
    i_room_ids sys.odcinumberlist
  )
  as
    l_room_ids_str varchar2(4000);
    l_stmt varchar2(4000);
    begin
      if ( i_room_ids.count <= 0 ) then
        raise_application_error(-20000, 'No rooms given');
      end if;

      select listagg(column_value, ',') within group (order by rownum)
        into l_room_ids_str
        from table(i_room_ids)
        where rownum <= 1;

      l_stmt := 'create view ' || dbms_assert.SIMPLE_SQL_NAME(i_view_name) || ' as
      select
        rooms.id,
        rooms.name,
        rooms.code,
        sections.id section_id,
        sections.label section_label
      from
        deathstar_rooms rooms
        inner join deathstar_sections sections
          on rooms.section_id = sections.id
      where rooms.id in (' || l_room_ids_str || ')';

      execute immediate l_stmt;
    end;
end;
/