create or replace package ut_utl_versionstring as
    -- %suite(UTL_VERSIONSTRING: Utility to deal with versionstrings)
    
    -- %context(SORTABLE: Make a versionstring sortable)
    
        -- %test(Turns a .-delimited string into a sortable one)
        procedure sortable_basic;
        
        -- %test(Returns NULL on input NULL)
        procedure sortable_null;
        
        -- %test(i_fragment_length defaults to 8 and defines how long the version-fragments will be)
        procedure sortable_fragment_length_conf;
        
        -- %test(invalid i_fragment_length defaults to 8)
        procedure sortable_fragment_length_inval;
        
    -- %endcontext
    
    -- %context(READABLE: Make a sortable versionstring readable)
    
        -- %test(Turns a sortable string into a readable one without leading 0s)
        procedure readable_basic;
        
        -- %test(Doesn't require leading .-delimiter)
        procedure readable_without_lead_delim;
        
        -- %test(Returns NULL on input NULL)
        procedure readable_null;
        
    -- %endcontext
    
    -- %context(SORTABLE_CUT: Turns a versionstring into a sortable one, cut to a given max depth)
        
        -- %test(Turns a .-delimited string into a sortable one, cut at max depth)
        procedure sortable_cut_basic;
        
        -- %test(i_fragment_length can be set to define fragment-length)
        procedure sortable_cut_fragment_len;
        
        -- %test(On invalid i_max_depth, uses a high default)
        procedure sortable_cut_invalid_maxdepth;
        
    -- %endcontext

end;
/