create or replace package body group_util as

  function get_number_name( i_number in integer ) return varchar2
  as
    l_mod int := mod(i_number,10);
    begin
      return to_char(i_number) || case l_mod when 1 then 'st' when 2 then 'nd' when 3 then 'rd' else 'th' end;
    end;

  function get_group_name( i_nr_in_group in integer, i_type_label in varchar2, i_honor_name in varchar2 )
    return varchar2 deterministic
  as
    begin

      if ( i_honor_name is not null ) then
        return i_honor_name;
      else
        return get_number_name(i_nr_in_group) || ' ' || i_type_label;
      end if;

    end;

  function get_group_name ( i_group_id in integer )
    return varchar2 result_cache
  as
    l_nr_in_group int;
    l_type_label varchar2(200);
    l_honor_name varchar2(200);
    begin

      select
        g.nr_in_group,
        gt.label,
        g.honor_name
      into
        l_nr_in_group,
        l_type_label,
        l_honor_name
      from groups g
        inner join group_types gt on g.group_type_fk = gt.id
      where g.id = i_group_id;

      return get_group_name(l_nr_in_group, l_type_label, l_honor_name);

    end;
end;
/