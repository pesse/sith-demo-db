create or replace package deathstar_room_view_generator as

  /** Creates a view that only allows access on several rooms
   */
  procedure create_view(
    i_view_name varchar2,
    i_room_ids sys.odcinumberlist
  );

end;
/