create or replace package ut_groups as
  -- %suite(Groups View)

  -- %test
  procedure select_fire_unit;

  -- %beforeall
  procedure setup;
end;
/