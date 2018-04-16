declare
  v_compilestmt varchar2(4000);
  v_count       integer := 0;
  v_success     integer := 0;
  v_error       integer := 0;
begin
  for rec in ( select uo.*
               from user_objects uo
               where uo.status <> 'VALID') loop
    v_compilestmt := 'ALTER ';
    if rec.object_type = 'PACKAGE BODY'
    then
      v_compilestmt := v_compilestmt || 'PACKAGE "' || rec.object_name || '" COMPILE BODY';
    else
      v_compilestmt := v_compilestmt || rec.object_type || ' "' || rec.object_name || '" COMPILE';
    end if;

    dbms_output.PUT_LINE(v_compilestmt);
    begin
      v_count := v_count + 1;
      execute immediate v_compilestmt;
      v_success := v_success + 1;
      exception
      when others then
      v_error := v_error + 1;
      dbms_output.PUT_LINE('Error: ' || SQLERRM);
    end;
  end loop;

  dbms_output.PUT_LINE(
      'RECOMPILED ' || TO_CHAR(v_count) || ' objects (' || TO_CHAR(v_success) || ' successful, ' || TO_CHAR(v_error) ||
      ' errors)');

end;
/