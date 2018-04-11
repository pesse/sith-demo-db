create table soldiers (
  id int not null primary key,
  name varchar2(256) not null,
  bio_short varchar2(4000),
  rank_fk int not null,
  constraint soldiers_fk_rank foreign key (rank_fk) references soldier_ranks( id )
);