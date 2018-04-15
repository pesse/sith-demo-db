declare

  procedure create_group( i_parent in integer, i_group_type in integer )
  as
    l_sub_type int;
    l_sub_avg_size int;
    l_group_min_size int;
    l_id int;
    l_subgroups int;
    begin

      select groups_seq.nextval, min_size into l_id, l_group_min_size from group_types where id = i_group_type;

      insert into groups (ID, GROUP_TYPE_FK, PARENT_FK, HONOR_NAME) values ( l_id, i_group_type, i_parent, null);

      begin
	  select sub_type, sub_avg_size into l_sub_type, l_sub_avg_size
	  from (
        select first_value(id) over (order by min_size desc) sub_type,
               first_value(min_size+round((max_size-min_size)/2)) over (order by min_size desc) sub_avg_size,
			   rownum rn
        from group_types where min_size < l_group_min_size 
		 ) where rn = 1;

        l_subgroups := ceil(l_group_min_size / l_sub_avg_size);

        for i in 1..l_subgroups loop
          create_group(l_id, l_sub_type);
        end loop;

      exception when no_data_found then
        null;
      end;
    end;
begin
  create_group(null, 7);
  create_group(null, 7);
  create_group(null, 7);
end;
/

-- Special Groups
update groups set honor_name = '68th Legion' where id = (select min(id) from groups where group_type_fk = 5);
update groups set honor_name = 'Brenda''s Brigade' where id = (select max(id) from groups where group_type_fk = 6);


commit;