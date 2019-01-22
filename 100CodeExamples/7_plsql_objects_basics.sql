-- First create a base type
create or replace type force_sensitive force as object
(
  -- First we define object-level attributes
  c_name varchar2(100),
  -- notice the comma instead of semicolon:
  -- this is a definition, similar to table definition - not
  -- an implemenntation.

  -- define a function we are going to implement
  member function name
    return varchar2,

  -- and one we are only going to implement
  -- inside the children
  not instantiable member function alignment
    return varchar2
)
-- For this is our base type we dont want it to be
-- instantiable, e.g. no "new force_sensitive()" possible
not final not instantiable;
/

-- Now implement the body of the base type
create or replace type body force_sensitive as
  member function name
    return varchar2
  as
    begin
      return c_name;
    end;
end;
/

-- We want to have a real type now
create or replace type jedi under force_sensitive (
  overriding member function alignment
    return varchar2
);
/

create or replace type body jedi as
  overriding member function alignment
    return varchar2
  as
    begin
      return 'light';
    end;
end;
/

-- And another real type with a specialty
create or replace type sith under force_sensitive (
  -- Default constructor has all member-attributes
  -- as parameters and assignes them. We can change
  -- this with our own constructor
  constructor function sith( c_name in varchar2 )
    return self as result,

  overriding member function alignment
    return varchar2
);
/

create or replace type body sith as
  constructor function sith( c_name in varchar2 )
    return self as result
  is
    begin
      -- self is a special built-in parameter
      -- which is passed to each member function as first
      -- parameter, no matter if explicitly defined or not.
      -- It holds an instance to the object
      self.c_name := 'Darth ' || c_name;

      -- however, in a constructor we dont return self
      -- but just return.
      return;
    end;

  overriding member function alignment
    return varchar2 is
    begin
      return 'dark';
    end;
end;
/

declare
  l_luke force_sensitive;
  l_vader force_sensitive;

  -- We can here see one of the first gifts of plsql-
  -- objects: We can build generalized methods which
  -- work for any subtype
  procedure output_alignment(
    i_force_user in out nocopy force_sensitive )
  as
    begin
      dbms_output.put_line(i_force_user.name() ||
        ' is aligned to ' || i_force_user.alignment());
    end;
begin
  -- Create a new instance of a concrete type
  l_luke := new jedi('Luke Skywalker');
  output_alignment(l_luke);

  l_vader := new sith('Vader');
  output_alignment(l_vader);
end;
/
