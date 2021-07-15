with
  input as (
    select '1.5.185.3' as version from dual union all
    select '1.5.0'     as version from dual union all
    select '1.5'       as version from dual union all
    select '12.4.1'    as version from dual union all
    select '1.6'       as version from dual union all
    select '2'         as version from dual
  ),
  -- Known Split-solution with fixed delimiter "."
  split_positions(version, depth, start_pos, end_pos) as (
    select
      version     as version,
      1           as depth,
      1           as start_pos,
      coalesce(
        nullif(instr(version, '.', 1, 1),0),
        length(version)+1
      )           as end_pos
    from input
    union all
    select
      version     as version,
      depth+1 	  as depth,
      end_pos+1   as start_pos,
      coalesce(
        nullif(instr(version, '.', 1, depth+1),0),
        length(version)+1
      )           as end_pos
    from split_positions
    where instr(version, '.', start_pos) > 0
  ),
  split as (
    select
      version,
      depth,
      substr(version, start_pos, end_pos-start_pos) as elem_value
    from split_positions
  ),
  /* Now we calculate a comparison-string for each depth
     The comparison string should have the char-length of the
     longest element in all of the versions, filled with 0 at
     the beginning */
  comparison_elments as (
    select
      version,
      depth,
      lpad(
        elem_value,
        max(length(elem_value)) over (),
        '0'
      ) as comparison_part
    from split
  ),
  /* Now we can listagg all the comparison-strings per version
     and order the strings by depth. That way we get a comparable
     and therefore sortable string */
  comparison_grouped as (
    select
      version,
      listagg(comparison_part) within group ( order by depth ) sort_value
      from comparison_elments
      group by version
  )
select version
  from comparison_grouped
  order by sort_value
;



