create or replace package body deathstar_room_manager as
  procedure add_room(
    i_name varchar2_nn,
    i_section_id simple_integer,
    i_code varchar2 default null )
  as
    l_max_nr_in_section integer;
    l_code varchar2(20) := i_code;
    l_code_max_nr integer;
    begin
      select nvl(max(nr_in_section),0) into l_max_nr_in_section
        from deathstar_rooms
        where section_id = i_section_id;

      if ( i_code is null ) then
        l_code := upper(replace(substr(i_name, 1, 6), ' ', '_'));
        select
          nvl(max(regexp_substr(substr(code, 7), '[0-9]+', 1, 1)),0)
            into l_code_max_nr
          from deathstar_rooms
          where
            substr(code, 1, 6) = l_code
            and regexp_like(substr(code, 7), '^[0-9]+$');

        l_code := l_code || to_char(l_code_max_nr+1);
      end if;

      insert into deathstar_rooms ( name, code, section_id, nr_in_section )
        values ( i_name, l_code, i_section_id, l_max_nr_in_section+1);
    end;
end;
/