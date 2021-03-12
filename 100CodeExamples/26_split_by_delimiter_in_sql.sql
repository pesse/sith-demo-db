create table wookies
(
  id int generated always as identity,
  name varchar2(200),
  height number(5,2)
);

select dbms_metadata.get_ddl('TABLE', 'WOOKIES')
  from dual;

with
  /* Let's have a config-subquery so we can
     easily change the delimiter if we want */
  config as (
    select
      chr(10) as delimiter
    from dual
  ),
  /* This is our input, the DDL of the WOOKIES table
     Of course, this could be any other input */
  ddl as (
    select
      dbms_metadata.get_ddl('TABLE', 'WOOKIES') as text
    from dual
  ),
  /* Here is where the magic happens: a recursive query
   */
  lines(start_pos, end_pos, line, line_no, text) as (
    /* We start with the first line, which also
       is our staring point and anchor
     */
    select
      -- Start position inside the text is always 1
      1 as start_pos,
      -- End position: first occurence of delimiter
      instr(text, config.delimiter) as end_pos,
      -- Line: all text between start and end position
      substr(text, 1, instr(text, config.delimiter)-1) as line,
      -- Line-Number: obvious
      1 as line_no,
      -- We pass the text along so we don't need to
      -- select it every time from the DDL query
      text
    from ddl, config
    /* Now the recursion starts, defining all
       fruther lines. What we do here is pretty much
       the same as before, it's just more text, because
       we need to give some additional boundaries, like
       starting point for INSTR search
     */
    union all
    select
        prev.end_pos+1 as start_pos,
        instr(prev.text, config.delimiter, prev.end_pos+1) as end_pos,
        substr(prev.text, prev.end_pos+1, instr(prev.text, config.delimiter, prev.end_pos+1)-1) as line,
        prev.line_no+1,
        prev.text
    from lines prev, config
    -- We add lines as long as there are more delimiters
    where instr(prev.text, config.delimiter, prev.end_pos+1) > 0
  )
select line_no, line from lines;
