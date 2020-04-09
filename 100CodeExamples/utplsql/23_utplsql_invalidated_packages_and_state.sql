create table popular_sith (
  id integer primary key not null,
  name varchar2(200)
);

create sequence popular_sith_seq start with 1;

create or replace package sith_manager as
  procedure add_popular_sith( i_name varchar2 );
end;
/

create or replace package body sith_manager as

  /* To better reveal our intention and to keep
     things that might change separated from the
     implementation, we use a constant for the default
     sith name
  */
  gc_default_name constant varchar2(200) := 'Darth'||' Ora';

  procedure add_popular_sith( i_name varchar2 )
  as
  begin
    insert into popular_sith (id, name )
      values (
        popular_sith_seq.nextval,
        nvl(i_name, gc_default_name)
      );
  end;
end;
/

create or replace package ut_sith_manager as
  -- %suite(Sith Manager)
  -- %suitepath(darkSide.management)

  procedure control_sequence;

  -- %test(ADD_POPULAR_SITH uses default name on NULL param)
  -- %beforetest(control_sequence)
  procedure add_sith_default_on_null_param;

  -- %afterall
  procedure reset_sequence;
end;
/

create or replace package body ut_sith_manager as

  /* To control which ID our test-entry will be get,
     we control the underlying sequence
   */
  procedure control_sequence as
    pragma autonomous_transaction;
  begin
    /* I am aware that this is not a good way to reset
       sequences. But the whole purpose of this example
       *is* to invalidate the dependent object.
       For a better approach google
       "oracle reset sequence tom kyte"
     */
    execute immediate 'drop sequence popular_sith_seq';
    execute immediate 'create sequence popular_sith_seq' ||
      ' minvalue -100 start with -100';
  end;

  /* After the test is done, we want to set the
     sequence back to its highest value
   */
  procedure reset_sequence as
    pragma autonomous_transaction;
    l_max_id integer;
  begin
    select nvl(max(id),0)+1 into l_max_id from popular_sith;
    execute immediate 'drop sequence popular_sith_seq';
    execute immediate 'create sequence popular_sith_seq'||
      ' start with '||l_max_id;
  end;

  procedure add_sith_default_on_null_param
  as
    l_actual_row popular_sith%rowtype;
  begin
    -- Act
    sith_manager.add_popular_sith(null);

    -- Assert
    select * into l_actual_row
      from popular_sith
      where id = -100;
    ut.expect(l_actual_row.name).to_equal('Darth Ora');
  end;
end;
/

call ut.run('ut_sith_manager');

select object_name, status, last_ddl_time from user_objects where status <> 'VALID';

create or replace package sith_generator as
  procedure generate_popular_sith(
    i_name varchar2,
    i_count integer
  );
end;
/

create or replace package body sith_generator as
  procedure generate_popular_sith(
    i_name varchar2,
    i_count integer
  ) as
  begin
    if nvl(i_count,0) > 0 then
      for i in 1..i_count loop
        sith_manager.add_popular_sith(
          i_name || ' ' || i
        );
      end loop;
    end if;
  end;
end;
/

create or replace package ut_sith_generator as
  -- %suite(Sith Generator)
  -- %suitepath(darkSide)

  -- %test(GENERATE_POPULAR_SITH creates correct number of Sith with name "<GIVEN_NAME> <COUNTER>")
  procedure generate_popular_sith;
end;
/

create or replace package body ut_sith_generator as

  procedure generate_popular_sith as
    c_actual sys_refcursor;
    c_expect sys_refcursor;
  begin
    -- Act
    sith_generator.generate_popular_sith('MyTest_Popular_Sith', 3);

    -- Assert
    open c_actual for
      select name from popular_sith
        where name like 'MyTest_Popular_Sith%'
        order by name;
    open c_expect for
      select column_value name
        from table(sys.odcivarchar2list(
          'MyTest_Popular_Sith 1',
          'MyTest_Popular_Sith 2',
          'MyTest_Popular_Sith 3'
          ));
    ut.expect(c_actual).to_equal(c_expect);
  end;

end;
/

call ut.run('ut_sith_generator');
call ut.run(':darkside');

-- Option 1: Constants recognized by the compiler
create or replace package body sith_manager as

  gc_default_name constant varchar2(200) := 'Darth Ora';

  procedure add_popular_sith( i_name varchar2 )
  as
  begin
    insert into popular_sith (id, name )
      values (
        popular_sith_seq.nextval,
        nvl(i_name, gc_default_name)
      );
  end;
end;
/

call ut.run(':darkside');

-- Option 2: PRAGMA SERIALLY_REUSABLE
create or replace package sith_manager as
  pragma serially_reusable;

  procedure add_popular_sith( i_name varchar2 );
end;
/

create or replace package body sith_manager as
  pragma serially_reusable;
  gc_default_name constant varchar2(200) := 'Darth'||' Ora';

  procedure add_popular_sith( i_name varchar2 )
  as
  begin
    insert into popular_sith (id, name )
      values (
        popular_sith_seq.nextval,
        nvl(i_name, gc_default_name)
      );
  end;
end;
/

call ut.run(':darkside');

-- Problem - no access from SQL
create or replace package sith_manager as
  pragma serially_reusable;

  procedure add_popular_sith( i_name varchar2 );

  function id_by_name( i_name varchar2 )
    return varchar2;
end;
/

create or replace package body sith_manager as
  pragma serially_reusable;
  gc_default_name constant varchar2(200) := 'Darth'||' Ora';

  procedure add_popular_sith( i_name varchar2 )
  as
  begin
    insert into popular_sith (id, name )
      values (
        popular_sith_seq.nextval,
        nvl(i_name, gc_default_name)
      );
  end;

  function id_by_name( i_name varchar2 )
    return varchar2
  as
    l_result integer;
  begin
    select id into l_result
      from popular_sith
      where name = i_name;
    return l_result;
  exception when no_data_found then
    return null;
  end;
end;
/

call sith_manager.add_popular_sith('Darth Vader');
select sith_manager.id_by_name('Darth Vader') from dual;

-- Option 3: Extra-Package for constants
create or replace package sith_manager_const as
  gc_default_name constant varchar2(200) := 'Darth'||' Ora';
end;
/

create or replace package sith_manager as
  procedure add_popular_sith( i_name varchar2 );
end;
/

create or replace package body sith_manager as
  procedure add_popular_sith( i_name varchar2 )
  as
  begin
    insert into popular_sith (id, name )
      values (
        popular_sith_seq.nextval,
        nvl(i_name, sith_manager_const.gc_default_name)
      );
  end;
end;
/

-- Option 4: Use Functions
create or replace package sith_manager as
  function gc_default_name
    return varchar2 deterministic;

  procedure add_popular_sith( i_name varchar2 );
end;
/

create or replace package body sith_manager as

  function gc_default_name
    return varchar2 deterministic as
  begin
    return 'Darth '||'Ora';
  end;

  procedure add_popular_sith( i_name varchar2 )
  as
  begin
    insert into popular_sith (id, name )
      values (
        popular_sith_seq.nextval,
        nvl(i_name, gc_default_name)
      );
  end;
end;
/

call ut.run(':darkside');

