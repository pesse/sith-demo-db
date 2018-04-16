create or replace package body ut_object_validity as

  procedure no_invalid_objects
  as
    c_actual sys_refcursor;
    begin

      open c_actual for select object_name, object_type
                        from user_objects uo
                        where uo.status <> 'VALID' and object_type not in ('MATERIALIZED VIEW');

      ut.expect( c_actual ).to_( be_empty() );
    end;

end;
/