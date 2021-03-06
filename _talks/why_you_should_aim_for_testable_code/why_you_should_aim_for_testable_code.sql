create table locations (
  id integer generated by default on null as identity not null primary key,
  name varchar2(2000) not null,
  country_id integer
);

create table projects (
  id integer generated by default on null as identity not null primary key,
  name varchar2(2000) not null,
  is_default number(1,0) default 0 not null
);

create table tasks (
  id integer generated by default on null as identity not null primary key,
  name varchar2(2000) not null,
  project_id integer not null
    constraint tasks_fk_project references projects( id )
    deferrable initially deferred,
  location_id integer not null
    constraint projects_fk_location references locations( id )
);


/*create or replace procedure create_task(
  i_task_name varchar2,
  i_project_id integer,
  i_location_id integer
) as
begin
  insert into tasks ( name, project_id, location_id )
    values ( i_task_name, i_project_id, i_location_id );
end;
/
*/

/*create or replace procedure create_task(
  i_task_name varchar2
) as
begin
  insert into tasks ( name, project_id )
    select
      i_task_name,
      (select id
        from projects
        where is_default = 1
      )
    from dual;
end;
/*/

create or replace function default_project_id
  return integer as
  l_result integer;
begin
  select id into l_result
    from projects
    where is_default = 1;
  return l_result;
exception when no_data_found then
  raise_application_error(
    -20000,
    'No Default Project defined');
end;
/

create or replace procedure create_task(
  i_task_name varchar2
) as
begin
  create_task(
    i_task_name  => i_task_name,
    i_project_id => default_project_id());
end;
/

create or replace procedure assert(
  i_condition boolean,
  i_error varchar2
) as
begin
  if i_condition != true then
    raise_application_error(-20999, i_error);
  end if;
end;

create or replace procedure create_task(
  i_task_name varchar2,
  i_project_id integer,
  i_location_id integer
) as
begin
  assert(i_task_name is not null, 'i_task_name may not be NULL');
  assert(i_project_id is not null, 'i_project_id may not be NULL');
  assert(i_location_id is not null, 'i_location_id may not be NULL');

  insert into tasks ( name, project_id, location_id )
    values ( i_task_name, i_project_id, i_location_id );
end;
/


drop table tasks;
drop table projects;
drop table locations;