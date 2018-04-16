@cleanup.sql

@../dbobjects/table/soldier_ranks.sql
@../dbobjects/table/soldiers.sql
@../dbobjects/sequences/soldiers_seq.sql

/* Insert ranks */
insert into soldier_ranks (id, label, hierarchy_level) values (1, 'General', 19);
insert into soldier_ranks (id, label, hierarchy_level) values (2, 'Colonel', 18);
insert into soldier_ranks (id, label, hierarchy_level) values (3, 'Major', 17);
insert into soldier_ranks (id, label, hierarchy_level) values (4, 'Captain', 16);
insert into soldier_ranks (id, label, hierarchy_level) values (5, 'Lieutenant', 15);
insert into soldier_ranks (id, label, hierarchy_level) values (6, 'Ensign', 14);
insert into soldier_ranks (id, label, hierarchy_level) values (7, 'Sergeant', 13);
insert into soldier_ranks (id, label, hierarchy_level) values (8, 'Corporal', 12);
insert into soldier_ranks (id, label, hierarchy_level) values (9, 'Specialist', 11);
insert into soldier_ranks (id, label, hierarchy_level) values (10, 'Private', 10);

commit;

@../dbobjects/table/group_types.sql

/* Insert Group Types */
insert into group_types (id, label, min_size, max_size, min_lead_rank) values (1, 'Fire team', 2, 3, 12);
insert into group_types (id, label, min_size, max_size, min_lead_rank) values (2, 'Squad', 5, 10, 13);
insert into group_types (id, label, min_size, max_size, min_lead_rank) values (3, 'Platoon', 50, 100, 15);
insert into group_types (id, label, min_size, max_size, min_lead_rank) values (4, 'Company', 100, 300, 16);
insert into group_types (id, label, min_size, max_size, min_lead_rank) values (5, 'Battalion', 700, 1500, 17);
insert into group_types (id, label, min_size, max_size, min_lead_rank) values (6, 'Brigade', 5000, 7500, 18);
insert into group_types (id, label, min_size, max_size, min_lead_rank) values (7, 'Division', 20000, 40000, 19);
insert into group_types (id, label, min_size, max_size, min_lead_rank) values (8, 'Assault Group', 40000, 100000, 20);

commit;

@../dbobjects/table/groups.sql
@../dbobjects/sequences/groups_seq.sql
@../dbobjects/triggers/groups_set_nr.sql


@../dbobjects/table/group_members.sql


-- Views
@../dbobjects/views/v_group_names.sql
@../dbobjects/views/v_groups.sql
@../dbobjects/triggers/trg_save_v_groups.sql
@../dbobjects/views/v_group_soldiers.sql
@../dbobjects/views/v_soldiers.sql
@../dbobjects/triggers/trg_save_v_soldiers.sql


-- packages
@../dbobjects/packages/group_management.pks
@../dbobjects/packages/group_management.pkb
@../dbobjects/procedures/get_soldier_group_name.fnc




@create_soldiers.sql
@create_groups.sql

call group_management.fill_groups();

commit;