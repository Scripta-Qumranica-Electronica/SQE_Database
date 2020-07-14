#####################################################################
## Redesign of parallel system

##



## Add comments to parallel_group

alter table parallel_group modify parallel_group_id int unsigned auto_increment comment 'Unique identifier';

alter table parallel_group comment 'Provides a unique identifier for groups of sign_stream_sections representing parallel chunks of text';

## Redefine parallel_word => parallel_sign_stream_section

rename table parallel_word to parallel_sign_stream_section;

alter table parallel_sign_stream_section change parallel_word_id parallel_sign_stream_section_id int unsigned auto_increment comment 'Unique identifier';

alter table parallel_sign_stream_section change word_id sign_stream_section_id int unsigned not null comment 'Reference to sign_stream_section';

alter table parallel_sign_stream_section modify parallel_group_id int unsigned not null comment 'Reference to parallel_group';

drop index unique_word_id_parallel_group_id_sup_group on parallel_sign_stream_section;

alter table parallel_sign_stream_section drop column sub_group;

alter table parallel_sign_stream_section drop foreign key fk_par_owrd_to_word;

alter table parallel_sign_stream_section drop foreign key fk_par_word_to_group;

drop index fk_par_owrd_to_word_idx on parallel_sign_stream_section;

create index fk_par_sss_to_word_idx
	on parallel_sign_stream_section (sign_stream_section_id);

drop index fk_par_word_to_group_idx on parallel_sign_stream_section;

create index fk_par_sss_to_group_idx
	on parallel_sign_stream_section (parallel_group_id);

alter table parallel_sign_stream_section
	add constraint unique_sign_stream_section_id_parallel_group_id_idx
		unique (parallel_group_id, sign_stream_section_id);

alter table parallel_sign_stream_section
	add constraint fk_par_sss_to_soign_stream_section
		foreign key (sign_stream_section_id) references sign_stream_section (sign_stream_section_id);


alter table parallel_sign_stream_section
	add constraint fk_par_sss_to_parallel_group
		foreign key (parallel_group_id) references parallel_group (parallel_group_id);

## Adjust parallel_word_owner => parallel_sign_stream_section_owner

rename table parallel_word_owner to parallel_sign_stream_section_owner;

alter table parallel_sign_stream_section_owner change parallel_word_id parallel_sign_stream_section_id int unsigned not null;

alter table parallel_sign_stream_section_owner drop foreign key fk_par_word_owner_to_par_word;

alter table parallel_sign_stream_section_owner drop foreign key fk_parallel_word_to_edition;

alter table parallel_sign_stream_section_owner drop foreign key fk_parallel_word_to_edition_editor;

drop index fk_par_word_owner_to_sc_idx on parallel_sign_stream_section_owner;

create index fk_par_sss_owner_to_sc_idx
	on parallel_sign_stream_section_owner (edition_editor_id);

drop index fk_parallel_word_to_edition on parallel_sign_stream_section_owner;

create index fk_parallel_sss_to_edition
	on parallel_sign_stream_section_owner (edition_id);


alter table parallel_sign_stream_section_owner
	add constraint fk_par_sss_owner_to_par_sss
		foreign key (parallel_sign_stream_section_id) references parallel_sign_stream_section (parallel_sign_stream_section_id);

alter table parallel_sign_stream_section_owner
	add constraint fk_parallel_sss_to_edition
		foreign key (edition_id) references edition (edition_id);


alter table parallel_sign_stream_section_owner
	add constraint fk_parallel_sss_to_edition_editor
		foreign key (edition_editor_id) references edition_editor (edition_editor_id);


#### Create the connection between parallel_groups

create table parallel_group_pair
(
	parallel_group_pair_id int unsigned auto_increment comment 'Unique identifier',
	parallel_group_a_id int unsigned not null comment 'Refers to the first parallel_group',
	parallel_group_b_id int unsigned not null comment 'Refers to second parallel_group',
	constraint parallel_group_pair_pk
		primary key (parallel_group_pair_id),
	constraint fk_parallel_group_pair_parallel_group_a
		foreign key (parallel_group_a_id) references parallel_group (parallel_group_id),
	constraint fk_parallel_group_pair_parallel_group_b
		foreign key (parallel_group_b_id) references parallel_group (parallel_group_id)
)
comment 'Creates a pair of parallel_groups';

create unique index parallel_group_pairs__index
	on parallel_group_pair (parallel_group_a_id, parallel_group_b_id);

#### Add an owner to parallel_group_pair

create table parallel_group_pair_owner
(
    parallel_group_pair_id int unsigned           not null,
    edition_editor_id               int unsigned default 0 not null,
    edition_id                      int unsigned default 0 not null,
    primary key (parallel_group_pair_id, edition_id),
    constraint fk_par_group_pair_owner_to_pararalle_group_pair
        foreign key (parallel_group_pair_id) references parallel_group_pair (parallel_group_pair_id),
    constraint fk_parallel_group_pair_to_edition
        foreign key (edition_id) references edition (edition_id),
    constraint fk_parallel_group_pair_to_edition_editor
        foreign key (edition_editor_id) references edition_editor (edition_editor_id)
)
    collate = utf8mb4_unicode_ci;



### Create parallel_type table

create table parallel_type
(
	parallel_type_id int unsigned auto_increment comment 'Unique identifier',
	parent_type_id int unsigned null comment 'Refers to a parent type',
	name varchar(255) not null comment 'Name of the type.',
	description text null,
	constraint parallel_type_pk
		primary key (parallel_type_id),
	constraint fk_parallel_type_to_parent
		foreign key (parent_type_id) references parallel_type (parallel_type_id)
)
comment 'Hierarchical list which defines parallel_types';

create index parallel_type_name_index
	on parallel_type (name);


#### Add an owner to parallel_type

create table parallel_type_owner
(
    parallel_type_id int unsigned           not null,
    edition_editor_id               int unsigned default 0 not null,
    edition_id                      int unsigned default 0 not null,
    primary key (parallel_type_id, edition_id),
    constraint fk_par_type_owner_to_pararalle_type
        foreign key (parallel_type_id) references parallel_type (parallel_type_id),
    constraint fk_parallel_type_to_edition
        foreign key (edition_id) references edition (edition_id),
    constraint fk_parallel_type_to_edition_editor
        foreign key (edition_editor_id) references edition_editor (edition_editor_id)
)
    collate = utf8mb4_unicode_ci;

#### Add a connectionbetween parallel_group_pairs and parallel_types

create table parallel_group_pair_to_type
(
	parallel_group_pair_to_type_id int unsigned auto_increment comment 'Unique identifier',
	parallel_group_pair_id int unsigned not null comment 'Refers to a parallel_group_pair',
	parallel_type_id int unsigned not null comment 'Refers to a parallel_type.',
	constraint parallel_group_pair_to_type_pk
		primary key (parallel_group_pair_to_type_id),
	constraint fk_parallel_group_pair_to_parallel_group_pair
		foreign key (parallel_group_pair_id) references parallel_group_pair (parallel_group_pair_id),
	constraint fk_parallel_group_pair_to_type
		foreign key (parallel_type_id) references parallel_type (parallel_type_id)
)
comment 'Connexts a parallel_group_pair with a parallel type';

create unique index parallel_group_pair_to_type_index
	on parallel_group_pair_to_type (parallel_group_pair_id, parallel_type_id);


#### Add an owner to parallel_type

create table parallel_group_pair_to_type_owner
(
    parallel_group_pair_to_type_id int unsigned           not null,
    edition_editor_id               int unsigned default 0 not null,
    edition_id                      int unsigned default 0 not null,
    primary key (parallel_group_pair_to_type_id, edition_id),
    constraint fk__group_pair_to_type_owner_to_pararalle_type
        foreign key (parallel_group_pair_to_type_id) references parallel_group_pair_to_type (parallel_group_pair_to_type_id),
    constraint fk_parallel_group_pair_to_type_to_edition
        foreign key (edition_id) references edition (edition_id),
    constraint fk_parallel_group_pair_to_type_to_edition_editor
        foreign key (edition_editor_id) references edition_editor (edition_editor_id)
)
    collate = utf8mb4_unicode_ci;


#####################################################################

