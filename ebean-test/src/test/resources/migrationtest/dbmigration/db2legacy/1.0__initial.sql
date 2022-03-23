-- Migrationscripts for ebean unittest
-- apply changes
create table migtest_ckey_assoc (
  id                            integer generated by default as identity not null,
  assoc_one                     varchar(255),
  constraint pk_migtest_ckey_assoc primary key (id)
);

create table migtest_ckey_detail (
  id                            integer generated by default as identity not null,
  something                     varchar(255),
  constraint pk_migtest_ckey_detail primary key (id)
);

create table migtest_ckey_parent (
  one_key                       integer not null,
  two_key                       varchar(127) not null,
  name                          varchar(255),
  version                       integer not null,
  constraint pk_migtest_ckey_parent primary key (one_key,two_key)
);

create table migtest_fk_cascade (
  id                            bigint generated by default as identity not null,
  one_id                        bigint,
  constraint pk_migtest_fk_cascade primary key (id)
);

create table migtest_fk_cascade_one (
  id                            bigint generated by default as identity not null,
  constraint pk_migtest_fk_cascade_one primary key (id)
);

create table migtest_fk_none (
  id                            bigint generated by default as identity not null,
  one_id                        bigint,
  constraint pk_migtest_fk_none primary key (id)
);

create table migtest_fk_none_via_join (
  id                            bigint generated by default as identity not null,
  one_id                        bigint,
  constraint pk_migtest_fk_none_via_join primary key (id)
);

create table migtest_fk_one (
  id                            bigint generated by default as identity not null,
  constraint pk_migtest_fk_one primary key (id)
);

create table migtest_fk_set_null (
  id                            bigint generated by default as identity not null,
  one_id                        bigint,
  constraint pk_migtest_fk_set_null primary key (id)
);

create table migtest_e_basic (
  id                            integer generated by default as identity not null,
  status                        varchar(1),
  status2                       varchar(1) default 'N' not null,
  name                          varchar(127),
  description                   varchar(127),
  description_file              blob(64M),
  json_list                     clob(16K) inline length 500 compact,
  a_lob                         clob(16K) inline length 500 not logged default 'X' not null,
  some_date                     timestamp,
  old_boolean                   boolean default false not null,
  old_boolean2                  boolean,
  eref_id                       integer,
  indextest1                    varchar(127),
  indextest2                    varchar(127),
  indextest3                    varchar(127),
  indextest4                    varchar(127),
  indextest5                    varchar(127),
  indextest6                    varchar(127),
  user_id                       integer not null,
  constraint ck_mgtst__bsc_stts check ( status in ('N','A','I')),
  constraint ck_mgtst__b_z543fg check ( status2 in ('N','A','I')),
  constraint pk_migtest_e_basic primary key (id)
) in TSTABLES index in INDEXTS long in TSTABLES;

create table migtest_e_enum (
  id                            integer generated by default as identity not null,
  test_status                   varchar(1),
  constraint ck_mgtst__n_773sok check ( test_status in ('N','A','I')),
  constraint pk_migtest_e_enum primary key (id)
);

create table migtest_e_history (
  id                            integer generated by default as identity not null,
  test_string                   varchar(255),
  constraint pk_migtest_e_history primary key (id)
) in MAIN index in MAIN long in MAIN;

create table migtest_e_history2 (
  id                            integer generated by default as identity not null,
  test_string                   varchar(255),
  obsolete_string1              varchar(255),
  obsolete_string2              varchar(255),
  constraint pk_migtest_e_history2 primary key (id)
);

create table migtest_e_history3 (
  id                            integer generated by default as identity not null,
  test_string                   varchar(255),
  constraint pk_migtest_e_history3 primary key (id)
);

create table migtest_e_history4 (
  id                            integer generated by default as identity not null,
  test_number                   integer,
  constraint pk_migtest_e_history4 primary key (id)
);

create table migtest_e_history5 (
  id                            integer generated by default as identity not null,
  test_number                   integer,
  constraint pk_migtest_e_history5 primary key (id)
);

create table migtest_e_history6 (
  id                            integer generated by default as identity not null,
  test_number1                  integer,
  test_number2                  integer not null,
  constraint pk_migtest_e_history6 primary key (id)
);

create table "migtest_QuOtEd" (
  id                            varchar(255) not null,
  status1                       varchar(1),
  status2                       varchar(1),
  constraint ck_mgtst_qtd_stts1 check ( status1 in ('N','A','I')),
  constraint ck_mgtst_qtd_stts2 check ( status2 in ('N','A','I')),
  constraint pk_migtest_quoted primary key (id)
);

create table migtest_e_ref (
  id                            integer generated by default as identity not null,
  name                          varchar(127) not null,
  constraint pk_migtest_e_ref primary key (id)
);

create table migtest_e_softdelete (
  id                            integer generated by default as identity not null,
  test_string                   varchar(255),
  constraint pk_migtest_e_softdelete primary key (id)
);

create table "table" (
  "index"                       varchar(255) not null,
  "from"                        varchar(255),
  "to"                          varchar(255),
  "varchar"                     varchar(255),
  "foreign"                     varchar(255),
  constraint pk_table primary key ("index")
);
comment on column "table"."index" is 'this is a comment';

create table migtest_mtm_c (
  id                            integer generated by default as identity not null,
  name                          varchar(255),
  constraint pk_migtest_mtm_c primary key (id)
);

create table migtest_mtm_m (
  id                            bigint generated by default as identity not null,
  name                          varchar(255),
  constraint pk_migtest_mtm_m primary key (id)
);

create table migtest_oto_child (
  id                            integer generated by default as identity not null,
  name                          varchar(255),
  constraint pk_migtest_oto_child primary key (id)
);

create table migtest_oto_master (
  id                            bigint generated by default as identity not null,
  name                          varchar(255),
  constraint pk_migtest_oto_master primary key (id)
);

-- apply alter tables
alter table "table" add column sys_period_start timestamp(12) not null generated always as row begin;
alter table "table" add column sys_period_end timestamp(12) not null generated always as row end;
alter table "table" add column sys_period_txn timestamp(12) generated always as transaction start id;
alter table "table" add period system_time (sys_period_start,sys_period_end);
alter table migtest_e_history2 add column sys_period_start timestamp(12) not null generated always as row begin;
alter table migtest_e_history2 add column sys_period_end timestamp(12) not null generated always as row end;
alter table migtest_e_history2 add column sys_period_txn timestamp(12) generated always as transaction start id;
alter table migtest_e_history2 add period system_time (sys_period_start,sys_period_end);
alter table migtest_e_history3 add column sys_period_start timestamp(12) not null generated always as row begin;
alter table migtest_e_history3 add column sys_period_end timestamp(12) not null generated always as row end;
alter table migtest_e_history3 add column sys_period_txn timestamp(12) generated always as transaction start id;
alter table migtest_e_history3 add period system_time (sys_period_start,sys_period_end);
alter table migtest_e_history4 add column sys_period_start timestamp(12) not null generated always as row begin;
alter table migtest_e_history4 add column sys_period_end timestamp(12) not null generated always as row end;
alter table migtest_e_history4 add column sys_period_txn timestamp(12) generated always as transaction start id;
alter table migtest_e_history4 add period system_time (sys_period_start,sys_period_end);
alter table migtest_e_history5 add column sys_period_start timestamp(12) not null generated always as row begin;
alter table migtest_e_history5 add column sys_period_end timestamp(12) not null generated always as row end;
alter table migtest_e_history5 add column sys_period_txn timestamp(12) generated always as transaction start id;
alter table migtest_e_history5 add period system_time (sys_period_start,sys_period_end);
alter table migtest_e_history6 add column sys_period_start timestamp(12) not null generated always as row begin;
alter table migtest_e_history6 add column sys_period_end timestamp(12) not null generated always as row end;
alter table migtest_e_history6 add column sys_period_txn timestamp(12) generated always as transaction start id;
alter table migtest_e_history6 add period system_time (sys_period_start,sys_period_end);
-- apply post alter
create unique index uq_mgtst__b_4aybzy on migtest_e_basic(indextest2) exclude null keys;
create unique index uq_mgtst__b_4ayc02 on migtest_e_basic(indextest6) exclude null keys;
create table migtest_e_history2_history as (select * from migtest_e_history2) with no data;
alter table migtest_e_history2 add versioning use history table migtest_e_history2_history;
create table migtest_e_history3_history as (select * from migtest_e_history3) with no data;
alter table migtest_e_history3 add versioning use history table migtest_e_history3_history;
create table migtest_e_history4_history as (select * from migtest_e_history4) with no data;
alter table migtest_e_history4 add versioning use history table migtest_e_history4_history;
create table migtest_e_history5_history as (select * from migtest_e_history5) with no data;
alter table migtest_e_history5 add versioning use history table migtest_e_history5_history;
create table migtest_e_history6_history as (select * from migtest_e_history6) with no data;
alter table migtest_e_history6 add versioning use history table migtest_e_history6_history;
create unique index uq_mgtst_qtd_stts2 on "migtest_QuOtEd"(status2) exclude null keys;
alter table migtest_e_ref add constraint uq_mgtst__rf_nm unique  (name);
create unique index uq_table_to on "table"("to") exclude null keys;
create unique index uq_table_varchar on "table"("varchar") exclude null keys;
create table table_history as (select * from "table") with no data;
alter table "table" add versioning use history table table_history;
-- foreign keys and indices
create index ix_mgtst_fk_mok1xj on migtest_fk_cascade (one_id);
alter table migtest_fk_cascade add constraint fk_mgtst_fk_65kf6l foreign key (one_id) references migtest_fk_cascade_one (id) on delete cascade on update restrict;

create index ix_mgtst_fk_c4p3mv on migtest_fk_set_null (one_id);
alter table migtest_fk_set_null add constraint fk_mgtst_fk_wicx8x foreign key (one_id) references migtest_fk_one (id) on delete set null on update restrict;

create index ix_mgtst__bsc_rf_d on migtest_e_basic (eref_id);
alter table migtest_e_basic add constraint fk_mgtst__bsc_rf_d foreign key (eref_id) references migtest_e_ref (id) on delete restrict on update restrict;

create index ix_table_foreign on "table" ("foreign");
alter table "table" add constraint fk_table_foreign foreign key ("foreign") references "table" ("index") on delete restrict on update restrict;

create index ix_mgtst__b_eu8csq on migtest_e_basic (indextest1);
create index ix_mgtst__b_eu8csu on migtest_e_basic (indextest5);
create index ix_mgtst_qtd_stts1 on "migtest_QuOtEd" (status1);
create index ix_table_from on "table" ("from");
