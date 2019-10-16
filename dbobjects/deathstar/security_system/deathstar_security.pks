create or replace package deathstar_security as

  const_friend constant varchar2(10) := 'FRIEND';
  const_foe constant varchar2(10) := 'FOE';
  const_unknown constant varchar2(10) := 'UNKNOWN';

  /* Decides whether a person is friend or foe,
     based on their appearance
   */
  function friend_or_foe( i_person_data t_person_appearance )
    return varchar2;

  /* Returns a welcome message based on the
     active Deathstar protocols DEFENSE_MODE
   */
  function welcome( i_person_data t_person_appearance )
    return varchar2;

  /* Checks whether access is allowed based on
     the active Deathstar protocols ALERT_MODE
   */
  function access_allowed( i_person_data t_person_appearance )
    return boolean;
end;
/
