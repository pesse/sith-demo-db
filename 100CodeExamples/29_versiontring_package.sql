/*
 Please run utl_versiontring.pkb and .pks for this to work
 */

/* Sorting is now dead easy */
with
  input as (
    select '1.5.185.3' as version from dual union all
    select '1.5.001'   as version from dual union all
    select '1.5'       as version from dual union all
    select '1.5.18.29' as version from dual union all
    select '12.4.1'    as version from dual union all
    select '2.04.1'    as version from dual union all
    select '2.4.3'     as version from dual union all
    select '1.6'       as version from dual union all
    select '2'         as version from dual
  )
select
  version,
  utl_versionstring.sortable(version, 2) sortable_version
from input
order by utl_versionstring.sortable(version);

/* As is getting as getting a normalized, readable version */
with
  input as (
    select '1.5.185.3' as version from dual union all
    select '1.5.001'   as version from dual union all
    select '1.5'       as version from dual union all
    select '1.5.18.29' as version from dual union all
    select '12.4.1'    as version from dual union all
    select '2.04.1'    as version from dual union all
    select '2.4.3'     as version from dual union all
    select '1.6'       as version from dual union all
    select '2'         as version from dual
  )
select
  utl_versionstring.readable(version) version
from input
order by utl_versionstring.sortable(version);

/* But what if we want to know the max version? */
with
  input as (
    select '1.5.185.3' as version from dual union all
    select '1.5.001'   as version from dual union all
    select '1.5'       as version from dual union all
    select '1.5.18.29' as version from dual union all
    select '12.4.1'    as version from dual union all
    select '2.04.1'    as version from dual union all
    select '2.4.3'     as version from dual union all
    select '1.6'       as version from dual union all
    select '2'         as version from dual
  )
select
  utl_versionstring.readable(
    max(utl_versionstring.sortable(version))
  ) as version
from input;


/*
 Or if we want to know what major versions we have and how many versions belong to each major version?
 */
with
  input as (
    select '1.5.185.3' as version from dual union all
    select '1.5.001'   as version from dual union all
    select '1.5'       as version from dual union all
    select '1.5.18.29' as version from dual union all
    select '12.4.1'    as version from dual union all
    select '2.04.1'    as version from dual union all
    select '2.4.3'     as version from dual union all
    select '1.6'       as version from dual union all
    select '2'         as version from dual
  )
select
  utl_versionstring.readable(
    utl_versionstring.sortable_cut(version, 1)
  ) as version,
  count(*) number_of_child_versions
from input
group by rollup ( utl_versionstring.sortable_cut(version, 1) )
order by utl_versionstring.sortable_cut(version, 1)
;

/*
 Or the latest version of each major version?
 */
with
  input as (
    select '1.5.185.3' as version from dual union all
    select '1.5.001'   as version from dual union all
    select '1.5'       as version from dual union all
    select '1.5.18.29' as version from dual union all
    select '12.4.1'    as version from dual union all
    select '2.04.1'    as version from dual union all
    select '2.4.3'     as version from dual union all
    select '1.6'       as version from dual union all
    select '2'         as version from dual
  )
select
  utl_versionstring.readable(
    utl_versionstring.sortable_cut(version, 1)
  ) as major_version,
  utl_versionstring.readable(
    max(utl_versionstring.sortable(version))
  ) as latest_version
from input
group by ( utl_versionstring.sortable_cut(version, 1) )
order by utl_versionstring.sortable_cut(version, 1)
;