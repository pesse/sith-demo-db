create or replace package ut_groups as
  -- %suite(Groups View V_GROUPS)

  -- %beforeall
  procedure setup;

  -- %test(Update group-name via view)
  procedure update_group_name;

  -- %test(Group with 2 parents shows generated name and full name)
  procedure select_3rd_level_team;

  -- %test(Group with parents and honor name shows honor name but generated full name)
  procedure select_honor_team;
end;
/



create or replace package body ut_groups as

  id_type_platoon constant integer := -10;
  id_type_squad constant integer := -11;
  id_type_team constant integer := -12;

  procedure setup as
  begin
    insert into group_types ( id, label ) values ( id_type_platoon, 'Platoon');
    insert into group_types ( id, label ) values ( id_type_squad, 'Squad');
    insert into group_types ( id, label ) values ( id_type_team, 'Fire Team');
  end;

  /** Helper to easily create a GROUPS entry with default values */
  procedure create_group(
    i_id integer,
    i_group_type integer,
    i_parent_id integer default null,
    i_honor_name varchar2 default null )
  as
  begin
    insert into groups (id, group_type_fk, parent_fk, honor_name)
      values (i_id, i_group_type, i_parent_id, i_honor_name);
  end;

  /** Returns V_GROUPS%ROWTYPE by ID */
  function row_by_id( i_id integer ) return v_groups%rowtype as
    l_result v_groups%rowtype;
  begin
    select * into l_result from v_groups where id = i_id;
    return l_result;
  end;

  procedure update_group_name as
  begin
    -- Arrange
    create_group(-1, id_type_platoon);

    -- Act
    update v_groups set
      group_name = 'utPLSQL Power-team'
      where id = -1;

    -- Assert
    ut.expect(row_by_id(-1).group_name)
      .to_equal('utPLSQL Power-team');
  end;

  procedure select_3rd_level_team as
  begin
    create_group(-1, id_type_platoon);
    create_group(-2, id_type_squad, -1);
    create_group(-3, id_type_team, -2);

    ut.expect(row_by_id(-3).group_name)
      .to_equal('1st Fire team');
    ut.expect(row_by_id(-3).full_group_name)
      .to_equal('1st Fire team of 1st Squad of 1st Platoon');
  end;

  procedure select_honor_team as
  begin
    create_group(-1, id_type_platoon);
    create_group(-2, id_type_squad, -1);
    create_group(-3, id_type_team, -2, 'Revan''s Ghosts');

    ut.expect(row_by_id(-3).group_name)
      .to_equal('Revan''s Ghosts');
    ut.expect(row_by_id(-3).full_group_name)
      .to_equal('1st Fire team of 1st Squad of 1st Platoon');
  end;

end;
/



select * from table(ut.run('ut_groups'));