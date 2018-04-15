create or replace package body ut_group_util as

  procedure get_group_name
  as
    begin
      ut.expect( group_util.GET_GROUP_NAME(1, 'test', null)).to_equal('1st test');
      ut.expect( group_util.GET_GROUP_NAME(22, 'combat unit', null)).to_equal('22nd combat unit');
      ut.expect( group_util.GET_GROUP_NAME(53, 'beer', null)).to_equal('53rd beer');
      ut.expect( group_util.GET_GROUP_NAME(1994, 'beer', null)).to_equal('1994th beer');
      ut.expect( group_util.GET_GROUP_NAME(2556375, 'beer', null)).to_equal('2556375th beer');
      ut.expect( group_util.GET_GROUP_NAME(1, 'test', 'funny honor name')).to_equal('funny honor name');
    end;
end;
/