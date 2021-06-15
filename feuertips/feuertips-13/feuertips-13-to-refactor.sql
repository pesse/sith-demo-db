-- Preparation: Create directory TEMP as SYS and GRANT rights to this user

-- In order to properly test something, we need some input data, so let's just create some imaginary log-tables

-- Log Table: All the rooms in the deathstar that were accessed at some point
create table log_deathstar_room_access
(
  id integer generated always as identity primary key,
  key_id integer,
  room_name varchar2(4000),
  character_name varchar2(4000),
  log_date timestamp default current_timestamp
);

-- Log Table: All the actions that happened in a room, but we don't have the room name, just some key_id
create table log_deathstar_room_actions
(
  id integer generated always as identity primary key,
  key_id integer,
  action varchar2(4000),
  done_by varchar2(4000),
  log_date timestamp default current_timestamp
);

-- Log Table: Repairs done in a room, but again we don't have the room name
create table log_deathstar_room_repairs
(
  id integer generated always as identity primary key,
  key_id integer,
  action varchar2(4000),
  repair_completion varchar2(100),
  repaired_by varchar2(4000),
  log_date timestamp default current_timestamp
);

create or replace procedure feuertips_13_poc as
   type T_LINES is
      table of varchar2(4000);
   k_full_date_format  constant varchar2(20) := 'mm/dd/yy';
   k_half_date_format  constant varchar2(20) := 'mm/yyyy';
   k_file1_name        constant varchar2(20) := 'abcd';
   k_file2_name        constant varchar2(20) := 'arty';
   k_file3_name        constant varchar2(20) := 'rett';
   k_file4_name        constant varchar2(20) := 'qsur';
   k_file5_name        constant varchar2(20) := 'wede';
   k_file6_name        constant varchar2(20) := 'cfrt';
   k_file7_name        constant varchar2(20) := 'ored';
   l_file1_lines       T_LINES;
   l_file2_lines       T_LINES;
   l_file3_lines       T_LINES;
   l_file4_lines       T_LINES;
   l_file6_lines       T_LINES;
   l_file5_lines       T_LINES;
   l_file7_lines       T_LINES;
   l_file1_lines_cnt   number := 0;
   l_file2_lines_cnt   number := 0;
   l_file3_lines_cnt   number := 0;
   l_file4_lines_cnt   number := 0;
   l_file6_lines_cnt   number := 0;
   l_file5_lines_cnt   number := 0;
   l_file7_lines_cnt   number := 0;
   l_file1_line        varchar2(4000);
   l_file2_line        varchar2(4000);
   l_file3_line        varchar2(4000);
   l_file4_line        varchar2(4000);
   l_file6_line        varchar2(4000);
   l_file5_line        varchar2(4000);
   l_file7_line        varchar2(4000);
   l_file1_name        varchar2(100) := k_file1_name;
   l_file2_name        varchar2(100) := k_file2_name;
   l_file3_name        varchar2(100) := k_file3_name;
   l_file4_name        varchar2(100) := k_file4_name;
   l_file6_name        varchar2(100) := k_file5_name;
   l_file5_name        varchar2(100) := k_file6_name;
   l_file7_name        varchar2(100) := k_file7_name;
   l_current_key       number default 0;
   l_first_time        number default 0;

   procedure init as
   begin
      l_file1_lines  := T_LINES();
      l_file2_lines  := T_LINES();
      l_file3_lines  := T_LINES();
      l_file4_lines  := T_LINES();
      l_file6_lines  := T_LINES();
      l_file5_lines  := T_LINES();
      l_file7_lines  := T_LINES();
   end init;

   procedure print_lines (
      p_file_name  in  varchar2,
      p_lines      in  T_LINES
   ) as
      l_file utl_file.file_type;
   begin
      l_file := utl_file.fopen('TEMP', p_file_name, 'w');
      for i in p_lines.first..p_lines.last loop
         utl_file.put_line(l_file, p_lines(i));
      end loop;
      utl_file.fclose (l_file);
   end print_lines;

   procedure add_line (
      p_file_name  in  varchar2,
      p_line       in  varchar2
   ) as
   begin
      case p_file_name
         when k_file1_name then
            l_file1_lines.extend();
            l_file1_lines(l_file1_lines.count)      := p_line;
            l_file1_lines_cnt                        := l_file1_lines_cnt + 1;
         when k_file2_name then
            l_file2_lines.extend();
            l_file2_lines(l_file2_lines.count)      := p_line;
            l_file2_lines_cnt                        := l_file2_lines_cnt + 1;
         when k_file3_name then
            l_file3_lines.extend();
            l_file3_lines(l_file3_lines.count)      := p_line;
            l_file3_lines_cnt                        := l_file3_lines_cnt + 1;
         when k_file4_name then
            l_file4_lines.extend();
            l_file4_lines(l_file4_lines.count)      := p_line;
            l_file4_lines_cnt                        := l_file4_lines_cnt + 1;
         when k_file5_name then
            l_file5_lines.extend();
            l_file5_lines(l_file5_lines.count)      := p_line;
            l_file5_lines_cnt                        := l_file5_lines_cnt + 1;
         when k_file6_name then
            l_file6_lines.extend();
            l_file6_lines(l_file6_lines.count)      := p_line;
            l_file6_lines_cnt                        := l_file6_lines_cnt + 1;
         when k_file7_name then
            l_file7_lines.extend();
            l_file7_lines(l_file7_lines.count)      := p_line;
            l_file7_lines_cnt                        := l_file7_lines_cnt + 1;
      end case;
   end add_line;

begin
   init;
   for crs in (
      select *
        from log_deathstar_room_access
   ) loop
      case
         when l_current_key != crs.key_id then
            l_first_time   := 1;
            l_current_key  := crs.key_id;
         else
            l_first_time := 2;
      end case;

      if l_first_time = 1 then
         for crs2 in (
            select *
              from log_deathstar_room_actions
              where key_id = crs.key_id
         ) loop
            l_file1_line := crs.key_id
                            || '|'
                            || crs.room_name
                            || '|'
                            || crs2.done_by
                            || '|'
                            || crs2.action;

            add_line(
               p_file_name  => k_file1_name,
               p_line       => l_file1_line
            );
         end loop;
      end if;

   end loop;

   print_lines(l_file1_name, l_file1_lines);

    /* Next! */

   for crs in (
      select *
        from log_deathstar_room_access) loop
      case
         when l_current_key != crs.key_id then
            l_first_time   := 1;
            l_current_key  := crs.key_id;
         else
            l_first_time := 2;
      end case;

      if l_first_time = 1 then
         for crs2 in (
            select *
              from log_deathstar_room_repairs
              where key_id = crs.key_id) loop
            l_file2_line := crs.key_id
                            || '|'
                            || crs.room_name
                            || '|'
                            || crs2.repair_completion
                            || '|'
                            || crs2.repaired_by
                            || '|'
                            || crs2.action;

            add_line(
               p_file_name  => k_file2_name,
               p_line       => l_file2_line
            );
         end loop;
      end if;

   end loop;

   print_lines(l_file2_name, l_file2_lines);

    /* And so on.... */
end;
/

call FEUERTIPS_13_POC();
