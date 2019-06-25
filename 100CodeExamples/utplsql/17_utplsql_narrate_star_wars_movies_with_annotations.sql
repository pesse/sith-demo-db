create or replace package sw_story_base as
  -- %suite(Star Wars: Movies)

  -- %beforeall
  procedure in_a_galaxy_far_away;

  -- %afterall
  procedure the_good_wins;

  procedure epic_intro;

  -- %beforeeach
  procedure deleted_scenes;

  -- %aftereach(deleted_scenes)

end;
/

create or replace package body sw_story_base as

  procedure in_a_galaxy_far_away
	as
    begin
	    dbms_output.put_line('In a galaxy far, far away');
    end;

  procedure the_good_wins
  as
    begin
      dbms_output.put_line('Finally, the good always wins.');
    end;

  procedure epic_intro
  as
    begin
      dbms_output.put_line('An epic intro is shown');
    end;

  procedure deleted_scenes
  as
    begin
      dbms_output.put_line('Deleted scenes are obviously removed from all the movies, therefore not shown');
    end;
end;
/

create or replace package sw_story_episode4_to_6 as
  -- %suite(Episode IV-VI)
  -- %suitepath(sw_story_base)

  -- %beforeall
  procedure clone_troops_are_bad;

  -- %beforeall
  procedure rebels_are_good;

  -- %test(Scene: Construction plans of the deathstar are stolen (Rogue One))
  -- %beforetest(sw_story_base.epic_intro)
  -- %aftertest(rebels_flee)
  procedure rogue_one;

  -- %context(episode4)
  -- %displayname(Episode IV - A New Hope)

    -- %beforeall(sw_story_base.epic_intro)

    -- %beforeeach(c3po_is_afraid)

    -- %test(Scene: Rescue of princess Leia)
    -- %aftertest(death_of_obiwan)
    procedure rescue_of_leia;

    procedure death_of_obiwan;

    -- %test(Scene: Destruction of the deathstar)
    procedure destroy_deathstar;

    -- %aftereach
    procedure c3po_is_relieved;

  -- %endcontext

  -- %context(episode5)
  -- %displayname(Episode V - The Empire Strikes Back)

    -- %beforeall(sw_story_base.epic_intro,rebels_flee)

    -- %test(Scene: Battle for Hoth)
    -- %aftertest(rebels_flee)
    procedure battle_for_hoth;

  -- %endcontext

  -- %context(episode6)
  -- %displayname(Episode VI - Return of the Jedi)

    -- %beforeall(sw_story_base.epic_intro)

    -- %beforeeach(c3po_is_afraid)
    -- %aftereach(c3po_is_relieved)

    -- %test(Scene: Battle for Endor)
    procedure battle_for_endor;

  -- %endcontext

  procedure c3po_is_afraid;

  procedure rebels_flee;

end;
/

create or replace package body sw_story_episode4_to_6 as

  procedure clone_troops_are_bad
	as
    begin
	    dbms_output.put_line('Background-Setting: Clone troops are bad');
    end;

  procedure rebels_are_good
	as
    begin
	    dbms_output.put_line('Background-Setting: Rebels are good');
    end;

  procedure c3po_is_afraid
  as
    begin
      dbms_output.put_line('C3PO is afraid');
    end;

  procedure c3po_is_relieved
  as
    begin
      dbms_output.put_line('C3PO is relieved');
    end;

  procedure rogue_one
  as
    begin
      dbms_output.put_line('Rebels are able to steal the construction plans of the deathstar');
    end;

  procedure rescue_of_leia
  as
    begin
      dbms_output.put_line('Luke, Han and Chewie find Leia and escape');
    end;

  procedure death_of_obiwan
  as
    begin
      dbms_output.put_line('Obi-Wan Kenobi dies');
    end;

  procedure destroy_deathstar
	as
    begin
      dbms_output.put_line('The deathstar is actually destroyed.');
    end;

  procedure rebels_flee
  as
    begin
      dbms_output.put_line('The rebels have to flee');
    end;

  procedure battle_for_hoth
  as
    begin
      dbms_output.put_line('Imperium wins the battle for Hoth');
    end;

  procedure battle_for_endor
  as
    begin
      dbms_output.put_line('Cute teddy-bears totally own the imperial troops');
    end;
end;
/

call ut.run(':sw_story_base');