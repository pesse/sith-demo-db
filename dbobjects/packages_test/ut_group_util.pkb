create or replace package body ut_group_util as

  procedure get_group_name_normal
  as
    begin
      ut.expect( group_util.get_group_name(1, 'test', null)).to_equal('1st test');
      ut.expect( group_util.get_group_name(22, 'combat unit', null)).to_equal('22nd combat unit');
      ut.expect( group_util.get_group_name(53, 'ewok', null)).to_equal('53rd ewok');
      ut.expect( group_util.get_group_name(2556375, 'ewok', null)).to_equal('2556375th ewok');
    end;

  procedure get_group_name_honor
  as
    begin
      ut.expect( group_util.get_group_name(1, 'test', 'funny honor name')).to_equal('funny honor name');
      ut.expect( group_util.get_group_name(5416, 'test', 'we just ignore the number')).to_equal('we just ignore the number');
    end;

  procedure get_group_name_11_12
  as
    begin
      ut.expect( group_util.get_group_name(11, 'nasty edge case!', null)).to_equal('11th nasty edge case!');
      ut.expect( group_util.get_group_name(312, 'exception from the rule', null)).to_equal('312th exception from the rule');
    end;

  procedure get_group_name_no_null
  as
    l_result varchar2(2000);
    l_position int;
    l_type_label varchar2(200);
    begin
      l_result := group_util.get_group_name(l_position, l_type_label, null);
    end;
end;
/