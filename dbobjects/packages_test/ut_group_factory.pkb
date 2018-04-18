create or replace package body ut_group_factory as

  procedure create_filled_squad
  as
    l_squad_id integer;
    l_actual_group_row v_groups%rowtype;
    l_actual_leader_rank int;
    begin

      -- Act
      l_squad_id := group_factory.CREATE_FILLED_GROUP(null, 2);

      -- Assert
      select * into l_actual_group_row from v_groups where id = l_squad_id;
      ut.expect(l_actual_group_row.label).to_equal('Squad');

      select rank into l_actual_leader_rank from v_soldiers where group_id = l_squad_id and is_leader = 1;
      ut.expect(l_actual_leader_rank).to_( be_greater_or_equal(13) );

      ut.expect(
          group_util.count_group_members(l_squad_id), 'Number of members not in bounds of group')
        .to_( be_between(l_actual_group_row.min_size, l_actual_group_row.max_size));

    end;
  
  procedure setup_soldiers
  as
    begin

      -- Assure we have enough soldiers
      for i in 1..10 loop
        insert into soldiers (ID, NAME, RANK_FK)
          select
            soldiers_seq.nextval,
            'Soldier #' || to_char(soldiers_seq.currval),
            r.id
            from
              soldier_ranks r
            where hierarchy_level <= 13;
      end loop;

    end;
end;
/