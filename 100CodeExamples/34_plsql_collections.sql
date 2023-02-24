-- Associative Array
declare
  type t_map is table of varchar2(100) index by varchar2(100);
  character_species t_map;

  -- Procedure to save a bit of screen width ;)
  procedure log(i_msg varchar2) as
  begin
    dbms_output.put_line(i_msg);
  end;
begin
  log('Associative Arrays');
  log('------------------');

  if character_species is null then
    log('Uninitialized collection is NULL');
  else
    log('Uninitialized collection is not NULL');
  end if;

  /****************
  * Construction
  ****************/
  character_species('Chewbacca') := 'Wookie';
  character_species('Darth Vader') := 'Human';

  -- Since 18c: Possible with Qualified Expressions
  character_species := t_map(
    'Chewbacca'=>'Wookie',
    'Darth Vader'=>'Human'
    );

  /****************
  * Access
  ****************/
  log('Access via index: '||character_species('Chewbacca'));

  /****************
  * Methods
  ****************/
  -- EXISTS:
  if character_species.exists('Chewbacca') then
    log('Exists: true');
  else
    log('Exists: false');
  end if;

  -- EXTEND: Not possible
  log('Extend: Not possible');

  -- COUNT:
  log('Count: '||character_species.count);

  -- LIMIT: Not possible
  log('Limit: Not possible');

  -- FIRST:
  log('First: '||character_species.first);

  -- LAST:
  log('Last: '||character_species.last);

  -- NEXT:
  log('Next: '||character_species.next('Chewbacca'));

  -- PRIOR:
  log('Prior: '||character_species.prior('Darth Vader'));

  -- TRIM: Not possible
  log('Trim: Not possible');

  -- DELETE:
  character_species.delete('Chewbacca');
  log('Delete: Remaining elements: '||character_species.count);

  log('Caution! Associative arrays cannot be used in SQL');
end;
/


-- Varying Array (Varray)
declare
  type t_list is varray(100) of varchar2(100);
  characters t_list;

  -- Procedure to save a bit of screen width ;)
  procedure log(i_msg varchar2) as
  begin
    dbms_output.put_line(i_msg);
  end;
begin
  log('Varying Array (Varray)');
  log('------------------');

  if characters is null then
    log('Uninitialized collection is NULL');
  else
    log('Uninitialized collection is not NULL');
  end if;

  /****************
  * Construction
  ****************/
  characters := t_list(); -- Empty but initialized

  characters := t_list('Chewbacca', 'Darth Vader');

  /****************
  * Access
  ****************/
  log('Access via num-index: '||characters(1));

  /****************
  * Methods
  ****************/
  -- EXISTS:
  if characters.exists(1) then
    log('Exists: true');
  else
    log('Exists: false');
  end if;

  -- EXTEND:
  characters.extend;
  characters(3) := 'Leia Organa';
  log('Extend: New element count: '||characters.count);

  -- COUNT:
  log('Count: '||characters.count);

  -- LIMIT:
  log('Limit: '||characters.limit);

  -- FIRST:
  log('First: '||characters.first);

  -- LAST:
  log('Last: '||characters.last);

  -- NEXT:
  log('Next: '||characters.next(1));

  -- PRIOR:
  log('Prior: '||characters.prior(2));

  -- TRIM:
  characters.trim;
  log('Trim: Remaining elements: '||characters.count);

  -- DELETE: Only without parameter, empties the collection
  characters.delete;
  log('Delete: Remaining elements: '||characters.count);
end;
/

-- Nested Table
declare
  type t_set is table of varchar2(100);
  characters t_set;

  -- Procedure to save a bit of screen width ;)
  procedure log(i_msg varchar2) as
  begin
    dbms_output.put_line(i_msg);
  end;
begin
  log('Nested Tables');
  log('------------------');

  if characters is null then
    log('Uninitialized collection is NULL');
  else
    log('Uninitialized collection is not NULL');
  end if;

  /****************
  * Construction
  ****************/
  characters := t_set(); -- Empty but initialized

  characters := t_set('Chewbacca', 'Darth Vader');

  /****************
  * Access
  ****************/
  log('Access via num-index: '||characters(1));

  /****************
  * Methods
  ****************/
  -- EXISTS:
  if characters.exists(1) then
    log('Exists: true');
  else
    log('Exists: false');
  end if;

  -- EXTEND:
  characters.extend;
  characters(3) := 'Leia Organa';
  log('Extend: New element count: '||characters.count);

  -- COUNT:
  log('Count: '||characters.count);

  -- LIMIT: Works but returns NULL
  log('Limit: '||characters.limit);

  -- FIRST:
  log('First: '||characters.first);

  -- LAST:
  log('Last: '||characters.last);

  -- NEXT:
  log('Next: '||characters.next(1));

  -- PRIOR:
  log('Prior: '||characters.prior(2));

  -- TRIM:
  characters.trim;
  log('Trim: Remaining elements: '||characters.count);

  -- DELETE:
  characters.delete(1);
  log('Delete: Remaining elements: '||characters.count);
end;
/

-- Using collections as table source in SQL
create type t_set_of_strings is table of varchar2(100);

select *
from t_set_of_strings('Chewbacca', 'Darth Vader');

-- Handy existing Varray SYS Types
select
  -- Output a combined description
    type_name||' '||elem_type_name||
    case when elem_type_name = 'VARCHAR2' then '('||length||')'
    else ''
    end||
    ', Max '||upper_bound||' elements'
  as description,
  type_name, elem_type_name, length, upper_bound
from all_coll_types
where owner = 'SYS'
  and coll_type = 'VARYING ARRAY'
  and type_name not like '%$%'
  and elem_type_name in ('VARCHAR2', 'NUMBER', 'INTEGER', 'DATE', 'CLOB', 'BFILE', 'BINARY_FLOAT', 'BINARY_DOUBLE', 'ANYDATA', 'XMLTYPE')
order by type_name;

-- Handy existing Nested Table SYS Types
select
  -- Output a combined description
    type_name||' '||elem_type_name||
    case when elem_type_name = 'VARCHAR2' then '('||length||')'
    else ''
    end
  as description,
  type_name, elem_type_name, length
from all_coll_types
    where owner = 'SYS'
      and coll_type = 'TABLE'
      and type_name not like '%$%'
      and elem_type_name in ('VARCHAR2', 'NUMBER', 'INTEGER', 'DATE', 'CLOB', 'BFILE', 'BINARY_FLOAT', 'BINARY_DOUBLE', 'ANYDATA', 'XMLTYPE')
    order by type_name;