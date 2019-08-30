create or replace package info_util as
  /* We want to have a list of information concatenated
     but some information might be NULL and we want to
     exclude this.
     Three approaches:
   */
  function person_concatenate(
    i_name varchar2,
    i_title varchar2 default null,
    i_alignment varchar2 default null,
    i_comment varchar2 default null
  ) return varchar2 deterministic;

  function person_listagg(
    i_name varchar2,
    i_title varchar2 default null,
    i_alignment varchar2 default null,
    i_comment varchar2 default null
  ) return varchar2 deterministic;

  function person_plsql_comb(
    i_name varchar2,
    i_title varchar2 default null,
    i_alignment varchar2 default null,
    i_comment varchar2 default null
  ) return varchar2 deterministic;
end;
/

create or replace package body info_util as
function person_concatenate(
  i_name varchar2,
  i_title varchar2,
  i_alignment varchar2,
  i_comment varchar2
) return varchar2 deterministic
as
  l_result varchar2(32000);
  begin
    /* The simplest solution is just to go
       over everything with some if-logic and
       concatenating the strings
     */
    if i_name is not null then
      l_result := l_result || i_name;
    end if;

    if i_title is not null then
      if l_result is not null then
        l_result := l_result || ', ';
      end if;
      l_result := l_result || i_title;
    end if;

    if i_alignment is not null then
      if l_result is not null then
        l_result := l_result || ', ';
      end if;
      l_result := l_result || i_alignment;
    end if;

    if i_comment is not null then
      if l_result is not null then
        l_result := l_result || ', ';
      end if;
      l_result := l_result || i_comment;
    end if;

    return substr(l_result, 1, 4000);
    /* But this is very hard to read,
       understand and maintain.
       Its also tedious and boring
     */
  end;

  function person_listagg(
    i_name varchar2,
    i_title varchar2,
    i_alignment varchar2,
    i_comment varchar2
  ) return varchar2 deterministic
  as
    /* We have the LISTAGG functionality,
       so why dont we use it?
       Therefore we have to collect all parts
       in a nested table collection first
     */
    l_parts sys.odcivarchar2list := new sys.odcivarchar2list();
    l_result varchar2(4000);

    /* With this function we make our code a bit
       more readable: just extending our
       collection and add an item
     */
    procedure add_part( i_string varchar2 )
    as
      begin
        l_parts.extend;
        l_parts(l_parts.last) := i_string;
      end;
    begin
      /* Now we can simple add the parts */
      add_part(i_name);
      add_part(i_title);
      add_part(i_alignment);
      add_part(i_comment);

      /* And can use LISTAGG to aggregate */
      select listagg(column_value, ', ') within group (order by rownum)
				into l_result
			  from table(l_parts);

      return l_result;
      /* But this will probably be very slow
         due to the PL/SQL -> SQL context switches
       */
    end;

  function person_plsql_comb(
    i_name varchar2,
    i_title varchar2,
    i_alignment varchar2,
    i_comment varchar2
  ) return varchar2 deterministic
  as
    /* So lets take the thing that improves readability */
    l_parts sys.odcivarchar2list := new sys.odcivarchar2list();
    l_result varchar2(4000);
    procedure add_part( i_string varchar2 )
    as
      begin
        l_parts.extend;
        l_parts(l_parts.last) := i_string;
      end;
    begin
      add_part(i_name);
      add_part(i_title);
      add_part(i_alignment);
      add_part(i_comment);

      /* But handle the concatenation in PL/SQL */
      for i in l_parts.first..l_parts.last loop
	      if l_parts(i) is not null then
	        if l_result is not null then
			      l_result := l_result || ', ';
		      end if;
	        l_result := l_result || l_parts(i);
	      end if;
      end loop;

      return l_result;
    end;
end;
/

declare
  /* Lets do some performance measurement - without DETERMINISTIC advantage */
  l_ts timestamp := current_timestamp;
  l_info varchar2(4000);
begin
	for i in 1..10000 loop
		l_info := info_util.person_concatenate('Luke Skywalker'||to_char(i), null, 'light', 'Most powerful jedi of all times');
		l_info := info_util.person_concatenate('Vader'||to_char(i), 'Darth', 'dark', 'Pretty evil');
	end loop;
	dbms_output.put_line('Basic concatenation: ' || to_char(current_timestamp-l_ts));
end;
/

declare
  l_ts timestamp := current_timestamp;
  l_info varchar2(4000);
begin
	for i in 1..10000 loop
		l_info := info_util.person_listagg('Luke Skywalker'||to_char(i), null, 'light', 'Most powerful jedi of all times');
		l_info := info_util.person_listagg('Vader'||to_char(i), 'Darth', 'dark', 'Pretty evil');
	end loop;
	dbms_output.put_line('LISTAGG: ' || to_char(current_timestamp-l_ts));
end;
/

declare
  l_ts timestamp := current_timestamp;
  l_info varchar2(4000);
begin
	for i in 1..10000 loop
		l_info := info_util.person_plsql_comb('Luke Skywalker'||to_char(i), null, 'light', 'Most powerful jedi of all times');
		l_info := info_util.person_plsql_comb('Vader'||to_char(i), 'Darth', 'dark', 'Pretty evil');
	end loop;
	dbms_output.put_line('PL/SQL Loop: ' || to_char(current_timestamp-l_ts));
end;
/

declare
  /* Now lets do a comparison with DETERMINISTIC advantage */
  l_ts timestamp := current_timestamp;
  l_info varchar2(4000);
begin
	for i in 1..10000 loop
		l_info := info_util.person_plsql_comb('Luke Skywalker', null, 'light', 'Most powerful jedi of all times');
		l_info := info_util.person_plsql_comb('Vader', 'Darth', 'dark', 'Pretty evil');
	end loop;
	dbms_output.put_line('Basic concatenation (deterministic): ' || to_char(current_timestamp-l_ts));
end;
/

declare
  l_ts timestamp := current_timestamp;
  l_info varchar2(4000);
begin
	for i in 1..10000 loop
		l_info := info_util.person_concatenate('Luke Skywalker', null, 'light', 'Most powerful jedi of all times');
		l_info := info_util.person_concatenate('Vader', 'Darth', 'dark', 'Pretty evil');
	end loop;
	dbms_output.put_line('PL/SQL Loop (deterministic): ' || to_char(current_timestamp-l_ts));
end;
/

create or replace type t_string_aggregator force is object
(
  /* We can extract the whole functionality
     and make it more generic and even more
     readable with the help of object types
   */

  /* The nested table is now part of our object */
  c_parts sys.odcivarchar2list,

  constructor function t_string_aggregator return self as result,
  member procedure add_string( i_string varchar2 ),
  member function get_aggregate( i_delimiter varchar2 default ', ' )
    return varchar2
);
/

create or replace type body t_string_aggregator as

  constructor function t_string_aggregator return self as result
  as
    begin
      /* Lets not forget to initialize the collection */
      c_parts := new sys.odcivarchar2list();
      return;
    end;

  /* This is basically the same as the internal procedure
     we used in the other approaches
   */
  member procedure add_string( i_string varchar2 )
  as
    begin
      c_parts.extend;
      c_parts(c_parts.last) := i_string;
    end;

  /* We can even make the delimiter dynamic */
  member function get_aggregate( i_delimiter varchar2 )
    return varchar2
  as
    l_result varchar2(4000);
    begin
      /* Little tweak if we dont have any items */
      if c_parts.count < 0 then
        return null;
      end if;

      for i in c_parts.first..c_parts.last loop
	      if c_parts(i) is not null then
	        if l_result is not null then
			      l_result := l_result || i_delimiter;
		      end if;
	        l_result := l_result || c_parts(i);
	      end if;
      end loop;

      return l_result;
    end;
end;
/


create or replace package info_util as
  function person_concatenate(
    i_name varchar2,
    i_title varchar2 default null,
    i_alignment varchar2 default null,
    i_comment varchar2 default null
  ) return varchar2 deterministic;

  function person_listagg(
    i_name varchar2,
    i_title varchar2 default null,
    i_alignment varchar2 default null,
    i_comment varchar2 default null
  ) return varchar2 deterministic;

  function person_plsql_comb(
    i_name varchar2,
    i_title varchar2 default null,
    i_alignment varchar2 default null,
    i_comment varchar2 default null
  ) return varchar2 deterministic;

  function person_plsql_obj(
    i_name varchar2,
    i_title varchar2 default null,
    i_alignment varchar2 default null,
    i_comment varchar2 default null
  ) return varchar2 deterministic;
end;
/

create or replace package body info_util as
  function person_concatenate(
    i_name varchar2,
    i_title varchar2,
    i_alignment varchar2,
    i_comment varchar2
  ) return varchar2 deterministic
  as
    l_result varchar2(32000);
    begin
      if i_name is not null then
	      l_result := l_result || i_name;
      end if;

      if i_title is not null then
	      if l_result is not null then
		      l_result := l_result || ', ';
	      end if;
	      l_result := l_result || i_title;
      end if;

      if i_alignment is not null then
	      if l_result is not null then
		      l_result := l_result || ', ';
	      end if;
	      l_result := l_result || i_alignment;
      end if;

      if i_comment is not null then
	      if l_result is not null then
		      l_result := l_result || ', ';
	      end if;
	      l_result := l_result || i_comment;
      end if;

      return substr(l_result, 1, 4000);
    end;

  function person_listagg(
    i_name varchar2,
    i_title varchar2,
    i_alignment varchar2,
    i_comment varchar2
  ) return varchar2 deterministic
  as
    l_parts sys.odcivarchar2list := new sys.odcivarchar2list();
    l_result varchar2(4000);
    procedure add_part( i_string varchar2 )
    as
      begin
        l_parts.extend;
        l_parts(l_parts.last) := i_string;
      end;
    begin
      add_part(i_name);
      add_part(i_title);
      add_part(i_alignment);
      add_part(i_comment);

      select listagg(column_value, ', ') within group (order by rownum)
				into l_result
			  from table(l_parts);

      return l_result;
    end;

  function person_plsql_comb(
    i_name varchar2,
    i_title varchar2,
    i_alignment varchar2,
    i_comment varchar2
  ) return varchar2 deterministic
  as
    l_parts sys.odcivarchar2list := new sys.odcivarchar2list();
    l_result varchar2(4000);
    procedure add_part( i_string varchar2 )
    as
      begin
        l_parts.extend;
        l_parts(l_parts.last) := i_string;
      end;
    begin
      add_part(i_name);
      add_part(i_title);
      add_part(i_alignment);
      add_part(i_comment);

      for i in l_parts.first..l_parts.last loop
	      if l_parts(i) is not null then
	        if l_result is not null then
			      l_result := l_result || ', ';
		      end if;
	        l_result := l_result || l_parts(i);
	      end if;
      end loop;

      return l_result;
    end;

  function person_plsql_obj(
    i_name varchar2,
    i_title varchar2,
    i_alignment varchar2,
    i_comment varchar2
  ) return varchar2 deterministic
  as
    /* Now look how clean and easy to read this function is */
    l_aggregator t_string_aggregator := new t_string_aggregator();
    begin
      l_aggregator.add_string(i_name);
      l_aggregator.add_string(i_title);
      l_aggregator.add_string(i_alignment);
      l_aggregator.add_string(i_comment);

      return l_aggregator.get_aggregate();
    end;
end;
/


declare
  /* Lets see how this one performs - without determinisitc advantage */
  l_ts timestamp := current_timestamp;
  l_info varchar2(4000);
begin
	for i in 1..10000 loop
		l_info := info_util.person_plsql_obj('Luke Skywalker'||to_char(i), null, 'light', 'Most powerful jedi of all times');
		l_info := info_util.person_plsql_obj('Vader'||to_char(i), 'Darth', 'dark', 'Pretty evil');
	end loop;
	dbms_output.put_line('PL/SQL Object: ' || to_char(current_timestamp-l_ts));
end;
/