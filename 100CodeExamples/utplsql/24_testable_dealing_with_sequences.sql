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
  procedure add_popular_sith( i_name varchar2 )
  as
  begin
    insert into popular_sith (id, name )
      values (
        popular_sith_seq.nextval,
        nvl(i_name, 'Darth Ora')
      );
  end;
end;
/

-- Iteration 1: Allow control over the indirect ID parameter
create or replace package ut_sith_manager as
  -- %suite(Sith Manager)
  -- %suitepath(darkSide.management)

  -- %test(ADD_POPULAR_SITH uses default name on NULL param)
  procedure add_sith_default_on_null_param;
end;
/

create or replace package body ut_sith_manager as
  procedure add_sith_default_on_null_param
  as
    l_actual_row popular_sith%rowtype;
  begin
    -- Act
    sith_manager.add_popular_sith(
      i_name => null,
      i_id => -1);

    -- Assert
    select * into l_actual_row
      from popular_sith
      where id = -1;
    ut.expect(l_actual_row.name).to_equal('Darth Ora');
  end;
end;
/

call ut.run('ut_sith_manager');


create or replace package sith_manager as
  procedure add_popular_sith(
    i_name varchar2,
    i_id integer default null);
end;
/

create or replace package body sith_manager as
  procedure add_popular_sith(
    i_name varchar2,
    i_id integer default null)
  as
  begin
    insert into popular_sith (id, name )
      values (
        nvl(i_id, popular_sith_seq.nextval),
        nvl(i_name, 'Darth Ora')
      );
  end;
end;
/

call ut.run('ut_sith_manager');

-- Iteration 2: Use sequence when no ID provided
create or replace package ut_sith_manager as
  -- %suite(Sith Manager)
  -- %suitepath(darkSide.management)

  -- %test(ADD_POPULAR_SITH uses default name on NULL param)
  procedure add_sith_default_on_null_param;

  -- %test(ADD_POPULAR_SITH generates ID when not provided)
  procedure add_sith_generate_id_on_null;
end;
/

create or replace package body ut_sith_manager as
  procedure add_sith_default_on_null_param
  as
    l_actual_row popular_sith%rowtype;
  begin
    -- Act
    sith_manager.add_popular_sith(
      i_name => null,
      i_id => -1);

    -- Assert
    select * into l_actual_row
      from popular_sith
      where id = -1;
    ut.expect(l_actual_row.name).to_equal('Darth Ora');
  end;

  procedure add_sith_generate_id_on_null
  as
    l_actual_row popular_sith%rowtype;
    l_name varchar2(100) := 'My special test Sith';
  begin
    -- Act
    sith_manager.add_popular_sith(l_name);

    -- Assert
    select * into l_actual_row
      from popular_sith
      where name = l_name;
    ut.expect(l_actual_row.id).not_to_be_null();
  end;
end;
/

call ut.run('ut_sith_manager');

-- Iteration 3: But I don't want my public API to allow providing ID
create or replace package sith_manager as
  procedure add_popular_sith(
    i_name varchar2);

  procedure add_popular_sith(
    i_name varchar2,
    i_id integer)
    accessible by (package ut_sith_manager);
end;
/

create or replace package body sith_manager as
  procedure add_popular_sith(
    i_name varchar2)
  as
  begin
    add_popular_sith(i_name, null);
  end;

  procedure add_popular_sith(
    i_name varchar2,
    i_id integer)
    accessible by (package ut_sith_manager)
  as
  begin
    insert into popular_sith (id, name )
      values (
        nvl(i_id, popular_sith_seq.nextval),
        nvl(i_name, 'Darth Ora')
      );
  end;
end;
/

call ut.run('ut_sith_manager');

call sith_manager.add_popular_sith('Darth Vader', 42);

-- We don't need the ut_sith_manager package to be present, by the way
drop package ut_sith_manager;

call sith_manager.add_popular_sith('Darth Vader', 42);
call sith_manager.add_popular_sith('Darth Vader');

-- Bonus Iteration: Avoid Unnecessary Sequence Increment
create or replace package body sith_manager as
  procedure add_popular_sith(
    i_name varchar2)
  as
  begin
    add_popular_sith(i_name, null);
  end;

  procedure add_popular_sith(
    i_name varchar2,
    i_id integer)
    accessible by (package ut_sith_manager)
  as
    l_id integer := coalesce(i_id, popular_sith_seq.nextval);
  begin
    insert into popular_sith (id, name )
      values (
        l_id,
        nvl(i_name, 'Darth Ora')
      );
  end;
end;
/

-- Proof that the sequence doesn't increase anymore
select popular_sith_seq.nextval from dual;
select * from table(
  ut.run('ut_sith_manager.add_sith_default_on_null_param')
);
select popular_sith_seq.currval from dual;
