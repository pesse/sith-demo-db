declare
  l_rank int;
begin
  for i in 1..50000 loop

    if ( mod(i,3) = 0 ) then
      l_rank := 11;
    else
      l_rank := 10;
    end if;

    for gt in (select * from group_types where min_lead_rank < 20 order by min_size desc) loop
      if ( mod(i, gt.min_size) = 0 ) then
        l_rank := gt.min_lead_rank;
        exit;
      end if;
    end loop;

    insert into soldiers ( ID, NAME, BIO_SHORT, RANK_FK)
      values ( soldiers_seq.nextval, 'Solder #'||to_char(i), null, (select id from soldier_ranks where hierarchy_level = l_rank) );

  end loop;
end;
/

commit;