begin
  for rec in (select object_name
                from table (ut_runner.get_suites_info())
                where item_type = 'UT_SUITE'
                 ) loop
    execute immediate 'drop package "' || rec.object_name || '"';
    dbms_output.put_line(rec.object_name || ' dropped.');
  end loop;
end;
/
;