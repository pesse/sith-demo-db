create or replace package body ut_utl_versionstring as
    
    procedure sortable_basic as
    begin
        ut.expect(utl_versionstring.sortable('1.2.3')).to_equal('.00000001.00000002.00000003');
        ut.expect(utl_versionstring.sortable('100')).to_equal('.00000100');
        ut.expect(utl_versionstring.sortable('8888874.3.28.9.47')).to_equal('.08888874.00000003.00000028.00000009.00000047');
        
        -- Leading 0 doesn't matter
        ut.expect(utl_versionstring.sortable('001.000002.03')).to_equal('.00000001.00000002.00000003');
    end;
    
    procedure sortable_null as
    begin
        ut.expect(utl_versionstring.sortable(null)).to_be_null();
    end;
    
    procedure sortable_fragment_length_conf as
    begin
        ut.expect(utl_versionstring.sortable('1')).to_equal('.00000001');
        ut.expect(utl_versionstring.sortable('1', 10)).to_equal('.0000000001');
        ut.expect(utl_versionstring.sortable('1', i_fragment_length => 3)).to_equal('.001');
        ut.expect(utl_versionstring.sortable('33785', i_fragment_length => 15)).to_equal('.000000000033785');
    end;
    
    procedure sortable_fragment_length_inval as
    begin
        ut.expect(utl_versionstring.sortable('1', NULL)).to_equal('.00000001');
        ut.expect(utl_versionstring.sortable('1', -1)).to_equal('.00000001');
        ut.expect(utl_versionstring.sortable('1', 0)).to_equal('.00000001');
    end;
    
    procedure readable_basic as
    begin
        ut.expect(utl_versionstring.readable('.0000001')).to_equal('1');
        ut.expect(utl_versionstring.readable('.0000001.00000002')).to_equal('1.2');
        ut.expect(utl_versionstring.readable('.0000001.00000100.00000003')).to_equal('1.100.3');
        
        -- It doesn't matter how many leading zeros
        ut.expect(utl_versionstring.readable('.001.0000000000100.00003')).to_equal('1.100.3');
    end;
    
    procedure readable_without_lead_delim as
    begin
        ut.expect(utl_versionstring.readable('0000001')).to_equal('1');
        ut.expect(utl_versionstring.readable('0000001.00000002')).to_equal('1.2');
        ut.expect(utl_versionstring.readable('1.0000000000100.00003')).to_equal('1.100.3');
    end;
    
    procedure readable_null as
    begin
        ut.expect(utl_versionstring.readable(null)).to_be_null();
        ut.expect(utl_versionstring.readable('')).to_be_null();
    end;
    
    procedure sortable_cut_basic as
    begin
        ut.expect(utl_versionstring.sortable_cut('0001.2.3.04', 3)).to_equal('.00000001.00000002.00000003');
        ut.expect(utl_versionstring.sortable_cut('0001.2.3.04', 1)).to_equal('.00000001');
    end;
    
    procedure sortable_cut_fragment_len as
    begin
        ut.expect(utl_versionstring.sortable_cut('1.2.3.4.5', 2, 10)).to_equal('.0000000001.0000000002');
        ut.expect(utl_versionstring.sortable_cut('1.2.3.4.5', 12, i_fragment_length => 2)).to_equal('.01.02.03.04.05');
    end;
    
    procedure sortable_cut_invalid_maxdepth as
    begin
        ut.expect(utl_versionstring.sortable_cut('1.2.3.4.5.6.7.8.9.10.11.12', null, 2)).to_equal('.01.02.03.04.05.06.07.08.09.10.11.12');
        ut.expect(utl_versionstring.sortable_cut('1.2.3.4.5.6.7.8.9.10.11.12', -5, 3)).to_equal('.001.002.003.004.005.006.007.008.009.010.011.012');
    end;
    
end;
/