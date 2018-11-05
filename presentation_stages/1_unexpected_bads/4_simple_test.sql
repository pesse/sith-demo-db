declare
  l_group_name varchar2(2000);
begin
  update v_groups set group_name = 'Test-Name' where id = 1;

  select group_name into l_group_name from v_groups where id = 1;

  if ( l_group_name <> 'Test-Name') then
    raise_application_error(-20000, 'Update did not work!');
  end if;
end;
/