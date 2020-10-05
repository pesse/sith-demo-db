


-- check for invalid objects
declare
  l_count int;
begin
  select count(*) into l_count
                        from user_objects uo
                        where uo.status <> 'VALID' and object_type not in ('MATERIALIZED VIEW');
  if ( l_count > 0 ) then
    raise_application_error(-20000, 'There are invalid objects!');
  end if;
end;
/