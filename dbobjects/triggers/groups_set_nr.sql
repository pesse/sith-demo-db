create or replace trigger groups_set_nr before insert or update on groups
  for each row
begin
  if ( :new.parent_fk is not null and (:old.parent_fk is null or :new.parent_fk <> :old.parent_fk)) then -- Update nr in group
    declare
      l_max_nr int;
    begin
      select max(nr_in_group) into l_max_nr from groups where parent_fk = :new.parent_fk;
      :new.nr_in_group := nvl(l_max_nr,0)+1;
    end;
  elsif ( :new.parent_fk is null and (inserting  or :old.parent_fk is not null)) then
    declare
      l_max_nr int;
    begin
      select max(nr_in_group) into l_max_nr from groups where parent_fk is null;
      :new.nr_in_group := nvl(l_max_nr,0)+1;
    end;
  end if;
end;
/