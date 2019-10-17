create or replace package deathstar_room_manager as
  /** Adds a new room to a section
   */
  procedure add_room(
    i_name varchar2,
    i_section_id simple_integer,
    i_code varchar2 default null );
end;
/