with
  /* Let's have a config-subquery so we can
     easily change the delimiter if we want */
  config as (
    select
      ',' as delimiter
    from dual
  ),
  /* This is our input, a comma separated list of wookies */
  input as (
    select
      'Chewbacca,Chewnucca,Orlyn,Babba' as text
    from dual
  ),
  /* Here is where the magic happens: a recursive query
   */
  elements(start_pos, end_pos, element, element_no, text) as (
    /* We start with the first line, which also
       is our staring point and anchor
     */
    select
      -- Start position inside the text is always 1
      1 as start_pos,
      -- End position: first occurence of delimiter or if no delimiter
      -- exists, the length of the whole string
      coalesce(
        nullif(instr(text, config.delimiter),0), -- NULL if delimiter not found
        length(text)+1
      ) as end_pos,
      -- Line: all text between start and end position
      substr(
        text,
        1,
        coalesce(
          nullif(instr(text, config.delimiter),0),
          length(text)+1
        )-1) as line,
      -- Line-Number: obvious
      1 as line_no,
      -- We pass the text along so we don't need to
      -- select it every time from the DDL query
      text
    from input, config
    /* Now the recursion starts, defining all
       further lines. What we do here is pretty much
       the same as before, it's just more text, because
       we need to give some additional boundaries, like
       starting point for INSTR search
     */
    union all
    select
        prev.end_pos+1 as start_pos,
        coalesce(
          nullif(instr(text, config.delimiter, prev.end_pos+1),0), -- NULL if delimiter not found
          length(text)+1
        ) as end_pos,
        substr(
          prev.text,
          prev.end_pos+1,
          coalesce(
            nullif(instr(text, config.delimiter, prev.end_pos+1),0),
            length(text)+1
          )-(prev.end_pos+1)
        ) as line,
        prev.element_no+1,
        prev.text
    from elements prev, config
    -- We add lines as long as there have been delimiters
    where instr(prev.text, config.delimiter, prev.start_pos) > 0
  )
select element_no, element from elements;
