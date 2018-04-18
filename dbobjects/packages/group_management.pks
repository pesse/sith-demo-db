create or replace package group_management as

  /** Fills existing groups with soldiers
   */
  procedure fill_groups;

  /** Fills a given group with soldiers
   */
  procedure fill_group( i_group in integer );

end;
/