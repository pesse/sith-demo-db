create or replace package utl_versionstring as

  /**
	  Make a versionstring sortable

	  i_version           a .-delimited version string
	  i_fragment_length   Length of the resulting fragments, default 8
   */
  function sortable(
    i_version in varchar2,
    i_fragment_length in integer default 8
  ) return varchar2 deterministic ;

  /**
	  Make a versionstring sortable and cut it at a max depth

	  i_version           a .-delimited version string
    i_max_depth         The maximum number of fragments to return
	  i_fragment_length   Length of the resulting fragments, default 8
   */
  function sortable_cut(
    i_version in varchar2,
    i_max_depth in integer,
    i_fragment_length in integer default null
  ) return varchar2 deterministic ;

  /**
	  Normalizes a versionstring into a readable format. Removes all the leading 0s of each fragment

	  i_version           a .-delimited version string
   */
  function readable(
    i_version in varchar2
  ) return varchar2 deterministic ;

end;
/