create or replace package group_util as

  function get_group_name(
    i_nr_in_group in integer,
    i_type_label in varchar2 )
    return varchar2 deterministic;

end;
/

create or replace package body group_util as

  function get_group_name(
    i_nr_in_group in integer,
    i_type_label in varchar2 )
    return varchar2 deterministic
  as
    begin
      return null;
    end;

end;
/








/***********************
* Test normal behaviour
 ***********************/

create or replace package ut_group_util as

  -- %suite(Group-Util)
  -- %suitepath(army.groups)

  -- %test(get_group_name returns name of group type and number)
  procedure get_group_name_normal;
end;
/

create or replace package body ut_group_util as
  procedure get_group_name_normal
  as
    begin
      ut.expect( group_util.get_group_name(1, 'test'))
        .to_equal('1st test');
      ut.expect( group_util.get_group_name(22, 'combat unit'))
        .to_equal('22nd combat unit');
      ut.expect( group_util.get_group_name(53, 'ewok'))
        .to_equal('53rd ewok');
      ut.expect( group_util.get_group_name(2556375, 'ewok'))
        .to_equal('2556375th ewok');
    end;
end;
/



call ut.run('ut_group_util.get_group_name_normal');









create or replace package body group_util as
  function get_group_name(
    i_nr_in_group in integer,
    i_type_label in varchar2 )
    return varchar2 deterministic
  as
    l_mod int := mod(i_nr_in_group,10);
    begin

      return to_char(i_nr_in_group)
             || case l_mod
                when 1 then 'st'
                when 2 then 'nd'
                when 3 then 'rd'
                else 'th' end
             || ' ' || i_type_label;
    end;
end;
/


call ut.run('ut_group_util');









/****************************
* Test honor name behaviour
 ***************************/

create or replace package ut_group_util as

  -- %suite(Group-Util)
  -- %suitepath(army.groups)

  -- %test(get_group_name returns name of group type and number)
  procedure get_group_name_normal;

  -- %test(get_group_name honor name if one is available)
  procedure get_group_name_honor;
end;
/


create or replace package body ut_group_util as

  procedure get_group_name_normal
  as
    begin
      ut.expect( group_util.get_group_name(1, 'test'))
        .to_equal('1st test');
      ut.expect( group_util.get_group_name(22, 'combat unit'))
        .to_equal('22nd combat unit');
      ut.expect( group_util.get_group_name(53, 'ewok'))
        .to_equal('53rd ewok');
      ut.expect( group_util.get_group_name(2556375, 'ewok'))
        .to_equal('2556375th ewok');
    end;

  procedure get_group_name_honor
  as
    begin
      ut.expect( group_util.get_group_name(1, 'test', 'funny honor name'))
        .to_equal('funny honor name');
      ut.expect( group_util.get_group_name(5416, 'test', 'we just ignore the number'))
        .to_equal('we just ignore the number');
    end;
end;
/







-- Compilation Error!

create or replace package group_util as

  function get_group_name(
    i_nr_in_group in integer,
    i_type_label in varchar2,
    i_honor_name in varchar2 default null)
    return varchar2 deterministic;

end;
/

create or replace package body group_util as
  function get_group_name(
    i_nr_in_group in integer,
    i_type_label in varchar2,
    i_honor_name in varchar2 default null )
    return varchar2 deterministic
  as
    l_mod int := mod(i_nr_in_group,10);
    begin

      return to_char(i_nr_in_group)
             || case l_mod
                when 1 then 'st'
                when 2 then 'nd'
                when 3 then 'rd'
                else 'th' end
             || ' ' || i_type_label;
    end;
end;
/



call ut.run('ut_group_util');

-- Test Fail!


create or replace package body group_util as
  function get_group_name(
    i_nr_in_group in integer,
    i_type_label in varchar2,
    i_honor_name in varchar2 default null )
    return varchar2 deterministic
  as
    l_mod int := mod(i_nr_in_group,10);
    begin

      if ( i_honor_name is not null ) then
        return i_honor_name;
      else
        return to_char(i_nr_in_group)
               || case l_mod
                  when 1 then 'st'
                  when 2 then 'nd'
                  when 3 then 'rd'
                  else 'th' end
               || ' ' || i_type_label;
      end if;
    end;
end;
/




call ut.run('ut_group_util');











/*


                    ____
                 _.' :  `._
             .-.'`.  ;   .'`.-.
    __      / : ___\ ;  /___ ; \      __
  ,'_ ""--.:__;".-.";: :".-.":__;.--"" _`,
  :' `.t""--.. '<@.`;_  ',@>` ..--""j.' `;
       `:-.._J '-.-'L__ `-- ' L_..-;'
         "-.__ ;  .-"  "-.  : __.-"                        WHAT ABOUT 11th and 12th?
             L ' /.------.\ ' J
              "-.   "--"   .-"
             __.l"-:_JL_;-";.__
          .-j/'.;  ;""""  / .'\"-.
        .' /:`. "-.:     .-" .';  `.
     .-"  / ;  "-. "-..-" .-"  :    "-.
  .+"-.  : :      "-.__.-"      ;-._   \
  ; \  `.; ;                    : : "+. ;
  :  ;   ; ;                    : ;  : \:
 : `."-; ;  ;                  :  ;   ,/;
  ;    -: ;  :                ;  : .-"'  :
  :\     \  : ;             : \.-"      :
   ;`.    \  ; :            ;.'_..--  / ;
   :  "-.  "-:  ;          :/."      .'  :
     \       .-`.\        /t-""  ":-+.   :
      `.  .-"    `l    __/ /`. :  ; ; \  ;
        \   .-" .-"-.-"  .' .'j \  /   ;/
         \ / .-"   /.     .'.' ;_:'    ;
          :-""-.`./-.'     /    `.___.'
                \ `t  ._  /  bug :F_P:
                 "-.t-._:'
(by Blazej Kozlowski & Faux_Pseudo)

 */



create or replace package ut_group_util as
  -- %suite(Group-Util)
  -- %suitepath(army.groups)

  -- %test(get_group_name returns name of group type and number)
  procedure get_group_name_normal;

  -- %test(get_group_name honor name if one is available)
  procedure get_group_name_honor;

  -- %test(get_group_name correctly for 11th and 12th (no honor name available))
  procedure get_group_name_11_12;
end;
/

create or replace package body ut_group_util as

  procedure get_group_name_normal
  as
    begin
      ut.expect( group_util.get_group_name(1, 'test'))
        .to_equal('1st test');
      ut.expect( group_util.get_group_name(22, 'combat unit'))
        .to_equal('22nd combat unit');
      ut.expect( group_util.get_group_name(53, 'ewok'))
        .to_equal('53rd ewok');
      ut.expect( group_util.get_group_name(2556375, 'ewok'))
        .to_equal('2556375th ewok');
    end;

  procedure get_group_name_honor
  as
    begin
      ut.expect( group_util.get_group_name(1, 'test', 'funny honor name'))
        .to_equal('funny honor name');
      ut.expect( group_util.get_group_name(5416, 'test', 'we just ignore the number'))
        .to_equal('we just ignore the number');
    end;

  procedure get_group_name_11_12
  as
    begin
      ut.expect( group_util.get_group_name(11, 'nasty edge case!', null))
        .to_equal('11th nasty edge case!');
      ut.expect( group_util.get_group_name(312, 'exception from the rule', null))
        .to_equal('312th exception from the rule');
    end;
end;
/





call ut.run('ut_group_util');






-- Implementation


create or replace package body group_util as

  function get_group_name(
    i_nr_in_group in integer,
    i_type_label in varchar2,
    i_honor_name in varchar2 default null )
    return varchar2 deterministic
  as
    l_suffix varchar2(64);
    begin

      if ( i_honor_name is not null ) then
        return i_honor_name;
      else
        if mod(i_nr_in_group, 100) in (11, 12) then
          l_suffix := 'th';
        else
          l_suffix := case mod(i_nr_in_group,10)
                      when 1 then 'st'
                      when 2 then 'nd'
                      when 3 then 'rd'
                      else 'th' end;
        end if;

        return to_char(i_nr_in_group) || l_suffix || ' ' || i_type_label;
      end if;

    end;

end;
/



call ut.run('ut_group_util');














/*


                    ____
                 _.' :  `._
             .-.'`.  ;   .'`.-.
    __      / : ___\ ;  /___ ; \      __
  ,'_ ""--.:__;".-.";: :".-.":__;.--"" _`,
  :' `.t""--.. '<@.`;_  ',@>` ..--""j.' `;
       `:-.._J '-.-'L__ `-- ' L_..-;'
         "-.__ ;  .-"  "-.  : __.-"                  JUST THE HAPPY PATH YOU CHECKED!
             L ' /.------.\ ' J
              "-.   "--"   .-"
             __.l"-:_JL_;-";.__
          .-j/'.;  ;""""  / .'\"-.
        .' /:`. "-.:     .-" .';  `.
     .-"  / ;  "-. "-..-" .-"  :    "-.
  .+"-.  : :      "-.__.-"      ;-._   \
  ; \  `.; ;                    : : "+. ;
  :  ;   ; ;                    : ;  : \:
 : `."-; ;  ;                  :  ;   ,/;
  ;    -: ;  :                ;  : .-"'  :
  :\     \  : ;             : \.-"      :
   ;`.    \  ; :            ;.'_..--  / ;
   :  "-.  "-:  ;          :/."      .'  :
     \       .-`.\        /t-""  ":-+.   :
      `.  .-"    `l    __/ /`. :  ; ; \  ;
        \   .-" .-"-.-"  .' .'j \  /   ;/
         \ / .-"   /.     .'.' ;_:'    ;
          :-""-.`./-.'     /    `.___.'
                \ `t  ._  /  bug :F_P:
                 "-.t-._:'
(by Blazej Kozlowski & Faux_Pseudo)

 */


/***************************
* Check for NULL params
 ****************************/

create or replace package ut_group_util as
  -- %suite(Group-Util)
  -- %suitepath(army.groups)

  -- %test(get_group_name returns name of group type and number)
  procedure get_group_name_normal;

  -- %test(get_group_name honor name if one is available)
  procedure get_group_name_honor;

  -- %test(get_group_name correctly for 11th and 12th (no honor name available))
  procedure get_group_name_11_12;

  -- %test(get_group_name does not allow NULL-arguments)
  procedure get_group_name_no_null;
end;
/

create or replace package body ut_group_util as

  procedure get_group_name_normal
  as
    begin
      ut.expect( group_util.get_group_name(1, 'test'))
        .to_equal('1st test');
      ut.expect( group_util.get_group_name(22, 'combat unit'))
        .to_equal('22nd combat unit');
      ut.expect( group_util.get_group_name(53, 'ewok'))
        .to_equal('53rd ewok');
      ut.expect( group_util.get_group_name(2556375, 'ewok'))
        .to_equal('2556375th ewok');
    end;

  procedure get_group_name_honor
  as
    begin
      ut.expect( group_util.get_group_name(1, 'test', 'funny honor name'))
        .to_equal('funny honor name');
      ut.expect( group_util.get_group_name(5416, 'test', 'we just ignore the number'))
        .to_equal('we just ignore the number');
    end;

  procedure get_group_name_11_12
  as
    begin
      ut.expect( group_util.get_group_name(11, 'nasty edge case!', null))
        .to_equal('11th nasty edge case!');
      ut.expect( group_util.get_group_name(312, 'exception from the rule', null))
        .to_equal('312th exception from the rule');
    end;

  procedure get_group_name_no_null
  as
    l_result varchar2(2000);
    l_position int;
    l_type_label varchar2(200);
    begin
      l_result := group_util.get_group_name(l_position, l_type_label, null);
    end;
end;
/


call ut.run('ut_group_util');












-- Success ist das falsche Ergebnis!

-- Vorhersage als Übung







create or replace package group_util as

  subtype nn_varchar2 is varchar2 not null;

  function get_group_name(
    i_nr_in_group in positiven,
    i_type_label in nn_varchar2,
    i_honor_name in varchar2 default null)
    return varchar2 deterministic;

end;
/

create or replace package body group_util as

  function get_group_name(
    i_nr_in_group in positiven,
    i_type_label in nn_varchar2,
    i_honor_name in varchar2 default null )
    return varchar2 deterministic
  as
    l_suffix varchar2(64);
    begin

      if ( i_honor_name is not null ) then
        return i_honor_name;
      else
        if mod(i_nr_in_group, 100) in (11, 12) then
          l_suffix := 'th';
        else
          l_suffix := case mod(i_nr_in_group,10)
                      when 1 then 'st'
                      when 2 then 'nd'
                      when 3 then 'rd'
                      else 'th' end;
        end if;

        return to_char(i_nr_in_group) || l_suffix || ' ' || i_type_label;
      end if;

    end;

end;
/



call ut.run('ut_group_util');








-- Fail! Yes!




/****************
* Anpassen des Tests
 ****************/

create or replace package ut_group_util as
  -- %suite(Group-Util)
  -- %suitepath(army.groups)

  -- %test(get_group_name returns name of group type and number)
  procedure get_group_name_normal;

  -- %test(get_group_name honor name if one is available)
  procedure get_group_name_honor;

  -- %test(get_group_name correctly for 11th and 12th (no honor name available))
  procedure get_group_name_11_12;

  -- %test(get_group_name does not allow NULL-arguments)
  -- %throws(-06502)
  procedure get_group_name_no_null;
end;
/


call ut.run('ut_group_util');

