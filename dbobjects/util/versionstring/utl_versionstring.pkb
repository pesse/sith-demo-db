create or replace package body utl_versionstring as
    
    function sortable(
        i_version in varchar2,
        i_fragment_length in integer default 8
    ) return varchar2 deterministic
    as
        lc_fragment_length constant integer :=
            case
                when nvl(i_fragment_length, 0) <= 0 then 8
                else i_fragment_length
            end;
    begin
        if i_version is null then return null; end if;
        return
            regexp_replace(
                replace('.'||i_version, '.', rpad('.', lc_fragment_length+1, '0')),
                '\.0+([0-9]{'||lc_fragment_length||'})',
                '.\1'
            );
    end;
    
    function sortable_cut(
        i_version in varchar2,
        i_max_depth in integer,
        i_fragment_length in integer default null
    ) return varchar2 deterministic
    as
    begin
        return
            regexp_replace(
                sortable(i_version, i_fragment_length),
                '^((\.[0-9]+){1,' || i_max_depth || '}).*',
                '\1'
            );
    end;
    
    function readable(
        i_version in varchar2
    ) return varchar2 deterministic
    as
    begin
        return
            substr(
                regexp_replace(
                    regexp_replace(i_version, '^([^|\.])', '.\1'), -- add leading delimiter if it doesn't have one
                    '\.[0]+([0-9]*)',
                    '.\1'
                ),
                2
            );
    end;
        
end;
/