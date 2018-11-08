create or replace trigger trg_save_v_groups instead of update or insert or delete on v_groups
for each row
  declare
  begin
    if (:new.group_name is not null and (:old.group_name is null or :new.group_name <> :old.group_name)) then
      update groups set honor_name = :new.group_name where id = :new.id;
    end if;
  end;
/