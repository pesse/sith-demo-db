create or replace package group_management as

  subtype bit is pls_integer range 0..1 not null;

  /** Fills existing groups with soldiers
   */
  procedure fill_groups( i_gracefully in bit default 0 );

  /** Fills a given group with soldiers
   */
  procedure fill_group( i_group in integer, i_gracefully in bit default 0 );

end;
/