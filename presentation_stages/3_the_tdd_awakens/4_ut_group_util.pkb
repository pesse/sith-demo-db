create or replace package body ut_group_util as

  procedure get_group_name_normal
  as
    begin
      ut.expect( group_util.get_group_name(1, 'test', null)).to_equal('1st test');
      ut.expect( group_util.get_group_name(22, 'combat unit', null)).to_equal('22nd combat unit');
      ut.expect( group_util.get_group_name(53, 'ewok', null)).to_equal('53rd ewok');
      ut.expect( group_util.get_group_name(2556375, 'ewok', null)).to_equal('2556375th ewok');
    end;
end;
/