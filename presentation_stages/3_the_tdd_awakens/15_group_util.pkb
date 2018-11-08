create or replace package body group_util as

  function get_group_name( i_nr_in_group in positiven, i_type_label in nn_varchar2, i_honor_name in varchar2 )
    return varchar2 deterministic
  as
    l_suffix varchar2(64);
    begin

      if ( i_honor_name is not null ) then
        return i_honor_name;
      else
        
        if mod(i_nr_in_group, 100) in (11, 12) then
          l_suffix := 'th';
        else
          l_suffix := case mod(i_nr_in_group,10)
                      when 1 then 'st'
                      when 2 then 'nd'
                      when 3 then 'rd'
                      else 'th' end;
        end if;
        
        return to_char(i_nr_in_group) || l_suffix || ' ' || i_type_label;
      end if;

    end;

end;
/