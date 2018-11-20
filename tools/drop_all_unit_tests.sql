begin
  for rec in (select object_name
                from table (
                  ut3.ut_annotation_manager.get_annotated_objects(sys_context('USERENV', 'CURRENT_SCHEMA'), 'PACKAGE')
                  ) annotated_objects
                cross join table (annotated_objects.annotations) annotations
                where annotations.name = 'suite') loop
    execute immediate 'drop package "' || rec.object_name || '"';
    dbms_output.put_line(rec.object_name || ' dropped.');
  end loop;
end;
/
;