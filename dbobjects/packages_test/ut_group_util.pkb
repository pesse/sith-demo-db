create or replace package body ut_group_util as

  procedure get_group_name
  as
    begin
      ut.expect( group_util.GET_GROUP_NAME(1, 'test', null)).to_equal('1st test');
      ut.expect( group_util.GET_GROUP_NAME(11, 'nasty edge case!', null)).to_equal('11th nasty edge case!');
      ut.expect( group_util.GET_GROUP_NAME(312, 'exception from the rule', null)).to_equal('312th exception from the rule');
      ut.expect( group_util.GET_GROUP_NAME(22, 'combat unit', null)).to_equal('22nd combat unit');
      ut.expect( group_util.GET_GROUP_NAME(53, 'beer', null)).to_equal('53rd beer');
      ut.expect( group_util.GET_GROUP_NAME(2556375, 'beer', null)).to_equal('2556375th beer');

      ut.expect( group_util.GET_GROUP_NAME(1, 'test', 'funny honor name')).to_equal('funny honor name');
      ut.expect( group_util.GET_GROUP_NAME(5416, 'test', 'we just ignore the number')).to_equal('we just ignore the number');
    end;
end;
/