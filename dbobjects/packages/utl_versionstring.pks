create or replace package utl_versionstring as
    
    function sortable(
        i_version in varchar2,
        i_fragment_length in integer default 8
    ) return varchar2 deterministic ;
    
    
    function sortable_cut(
        i_version in varchar2,
        i_max_depth in integer,
        i_fragment_length in integer default null
    ) return varchar2 deterministic ;
    
    function readable(
        i_version in varchar2
    ) return varchar2 deterministic ;
    
end;
/