create or replace package body group_factory as

  function create_group(i_parent in integer, i_group_type in integer)
    return integer
  as
    l_sub_type       int;
    l_sub_avg_size   int;
    l_group_min_size int;
    l_id             int;
    l_subgroups      int;
    l_child_group_id int;
    begin

      select
        groups_seq.nextval,
        min_size
      into l_id, l_group_min_size
      from group_types
      where id = i_group_type;

      insert into groups (id, group_type_fk, parent_fk, honor_name) values (l_id, i_group_type, i_parent, null);

      begin
        select
          sub_type,
          sub_avg_size
        into l_sub_type, l_sub_avg_size
        from (
          select
            first_value(id)
            over (
              order by min_size desc ) sub_type,
            first_value(min_size + round((max_size - min_size) / 2))
            over (
              order by min_size desc ) sub_avg_size,
            rownum                     rn
          from group_types
          where min_size < l_group_min_size
        )
        where rn = 1;

        l_subgroups := ceil(l_group_min_size / l_sub_avg_size);

        for i in 1..l_subgroups loop
          l_child_group_id := create_group(l_id, l_sub_type);
        end loop;

      exception when no_data_found then
        null;
      end;

      return l_id;
    end;

  function create_filled_group( i_parent in integer, i_group_type in integer )
    return integer
  as
    l_id integer;
    begin

      l_id := create_group(i_parent, i_group_type);

      group_management.FILL_GROUP(l_id);

      return l_id;
    end;

end;
/