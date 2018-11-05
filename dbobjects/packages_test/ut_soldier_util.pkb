create or replace package body ut_soldier_util as

  procedure get_soldier_group_name
  as
    begin
      ut.expect(soldier_util.GET_GROUP_NAME(-1)).to_equal('utPLSQL team');
    end;

  procedure setup_soldier_and_group
  as
    begin
      insert into groups (id, group_type_fk, parent_fk, honor_name) values (-1, 1, null, 'utPLSQL team');
      insert into soldiers (ID, NAME, RANK_FK) values ( -1, 'Jacek', 7);
      insert into group_members (GROUP_FK, SOLDIER_FK, IS_LEADER) values ( -1, -1, 1);
    end;

end;
/