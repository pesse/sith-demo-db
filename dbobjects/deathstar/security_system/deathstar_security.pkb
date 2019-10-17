create or replace package body deathstar_security as
  /* Returns the active security protocol of the deathstar
   */
  function active_protocol
    return deathstar_protocols%rowtype
  as
    l_result deathstar_protocols%rowtype;
  begin
    select p.* into l_result
      from deathstar_protocols p
        inner join deathstar_protocol_active pa
          on p.id = pa.id;
    return l_result;
  end;

  function friend_or_foe( i_person_data t_person_appearance )
    return varchar2
  as
    begin
      if ( i_person_data.weapon_type = 'lightsaber') then
        if ( i_person_data.weapon_color in ('red','orange')) then
          return const_friend;
        else
          return const_foe;
        end if;
      end if;

      if ( i_person_data.cloth_type = 'hooded_robe' ) then
        if ( i_person_data.cloth_color = 'black') then
          return const_friend;
        elsif ( i_person_data.cloth_color = 'red') then
          return const_unknown;
        else
          return const_foe;
        end if;
      end if;

      if ( i_person_data.cloth_type = 'armor' ) then
        if ( i_person_data.cloth_color = 'white') then
          return const_friend;
        elsif ( i_person_data.cloth_color in ('blue/black', 'orange')) then
          return const_foe;
        else
          return const_unknown;
        end if;
      end if;

      return const_unknown;
    end;

  function welcome( i_person_data t_person_appearance )
    return varchar2
  as
    l_friend_or_foe varchar2(10) := friend_or_foe(i_person_data);
    l_protocol deathstar_protocols%rowtype := active_protocol();
  begin
    if ( l_friend_or_foe = const_friend ) then
      return 'Be welcome!';
    elsif ( l_friend_or_foe = const_foe ) then
      return 'Die rebel scum!';
    end if;

    case l_protocol.defense_mode
      when 'BE_KIND' then
        return 'Be welcome!';
      when 'BE_SUSPICIOUS' then
        return 'Are you a jedi?';
      when 'SHOOT_FIRST_ASK_LATER' then
        return 'Die rebel scum!';
      else
        raise_application_error(-20000, 'Ooops, no welcome');
    end case;
  end;

  function access_allowed( i_person_data t_person_appearance )
    return boolean
  as
    l_protocol deathstar_protocols%rowtype := active_protocol();
  begin
    case l_protocol.alert_level
      when 'LOW' then
        return true;
      when 'MEDIUM' then
        return false;
      when 'VERY HIGH' then
        raise_application_error(-20100,
          'Unauthorized attempt to access a public area');
      else
        raise_application_error(-20000, 'Oooops, no access');
    end case;
  end;
end;
/