create database if not exists bts;
use bts;

drop table if exists users;

create table users (
username varchar(32),
first_name varchar(32),
last_name varchar(32),
email varchar(32),
role_id integer,
index (username),
index (email),
index (role_id)
)

