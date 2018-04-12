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
end;
/