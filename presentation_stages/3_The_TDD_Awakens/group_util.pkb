create or replace package body group_util as

  function get_group_name(
    i_nr_in_group in integer,
    i_type_label in varchar2 )
    return varchar2 deterministic
  as
    begin
      return null;
    end;

end;
/