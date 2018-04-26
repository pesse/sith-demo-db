declare
  l_id integer;
begin
  l_id := group_factory.CREATE_GROUP(null, 7);
  l_id := group_factory.CREATE_GROUP(null, 7);
end;
/

-- Special Groups
update groups set honor_name = '68th Legion' where id = (select min(id) from groups where group_type_fk = 5);
update groups set honor_name = 'Brenda''s Brigade' where id = (select max(id) from groups where group_type_fk = 6);


commit;