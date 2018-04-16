create or replace package ut_object_validity as

  -- %suite(High-Level check for object validity)
  -- %suitepath(common.highlevel)

  -- %test(Assure no invalid objects exist)
  procedure no_invalid_objects;

end;
/