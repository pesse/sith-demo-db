declare
  l_alertMessage varchar2(200) := 'A bunch of "%s" is attacking with ' ||
                                  'an estimated fleet of %d ships';
begin
  -- Works with values
  dbms_output.put_line(utl_lms.format_message(
    l_alertMessage,
    'Values', 10));

  -- Doesn't replace anything if no values are provided
  dbms_output.put_line(utl_lms.format_message(
    l_alertMessage));

  -- Replaces missing values with empty string
  dbms_output.put_line(utl_lms.format_message(
     l_alertMessage,
     'Not_all_values_set'));

  -- Works with NVARCHAR and BINARY_INTEGER types
  declare
    l_inputString nvarchar2(40) := 'NVARCHAR2/BINARY_INTEGER';
    l_numOfShips binary_integer := 25;
  begin
    dbms_output.put_line(utl_lms.format_message(
      l_alertMessage, l_inputString, l_numOfShips));
  end;

  -- Works with VARCHAR and subtypes of BINARY_INTEGER like PLS_INTEGER
  declare
    l_inputString varchar2(40) := 'VARCHAR2/PLS_INTEGER';
    l_numOfShips pls_integer := 75;
  begin
    dbms_output.put_line(utl_lms.format_message(
      l_alertMessage, l_inputString, l_numOfShips));
  end;

  -- Order is important
  declare
    l_inputString varchar2(40) := 'Wrong Order';
    l_numOfShips pls_integer := 122;
  begin
    dbms_output.put_line(utl_lms.format_message(
       l_alertMessage, l_numOfShips, l_inputString));
  exception when others then
    dbms_output.put_line('Wrong Order: ' || sqlerrm);
  end;

  -- Fails silently with INTEGER types
  declare
    l_inputString varchar2(40) := 'INTEGER';
    l_numOfShips integer := 13;
  begin
    dbms_output.put_line(utl_lms.format_message(
      l_alertMessage, l_inputString, l_numOfShips));
  end;

  -- Fails silently with NUMBER types
  declare
    l_inputString varchar2(40) := 'NUMBER';
    l_numOfShips number(10,0) := 34;
  begin
    dbms_output.put_line(utl_lms.format_message(
      l_alertMessage, l_inputString, l_numOfShips));
  end;

  -- You can escape % with doubling it
  dbms_output.put_line(utl_lms.format_message(
    'Probability to survive: %s%%', to_char(12.5)));

end;
/