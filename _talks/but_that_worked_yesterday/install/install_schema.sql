whenever sqlerror exit failure rollback
whenever oserror exit failure rollback
set echo off
set feedback off
set heading off
set verify off

define sith_user       = &1
define sith_password   = &2
define sith_tablespace = &3

prompt Creating utPLSQL user &&sith_user

create user &sith_user identified by &sith_password default tablespace &sith_tablespace quota unlimited on &sith_tablespace;

grant create session, create sequence, create procedure, create type, create table, create view, create synonym, create trigger to &sith_user;

grant execute on dbms_lock to &sith_user;

grant execute on dbms_crypto to &sith_user;

grant alter session to &sith_user;