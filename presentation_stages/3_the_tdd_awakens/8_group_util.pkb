create or replace package body group_util as

  function get_group_name( i_nr_in_group in integer, i_type_label in varchar2, i_honor_name in varchar2 )
    return varchar2 deterministic
  as
    l_mod int := mod(i_nr_in_group,10);
    begin

      if ( i_honor_name is not null ) then
        return i_honor_name;
      else
        return to_char(i_nr_in_group)
               || case l_mod
                  when 1 then 'st'
                  when 2 then 'nd'
                  when 3 then 'rd'
                  else 'th' end
               || ' ' || i_type_label;
      end if;

    end;

end;
/