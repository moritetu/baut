#!/usr/bin/env bash

load "diff-helper.sh"

SQLDIR="$(__DIR__)/sql"
MYSQL_DEFAULTS_FILE="$(__DIR__)/my.conf"

# Helper function
mysql_query() {
  mysql --defaults-file="$MYSQL_DEFAULTS_FILE" -e "$*" sample
}

#: @BeforeAll
setup_all() {
  cat > "$MYSQL_DEFAULTS_FILE" <<EOF
[client]
user=root
password=
EOF
  mysql --defaults-file="$MYSQL_DEFAULTS_FILE" <<EOF
  drop database if exists sample;
  create database sample;
EOF

  mysql_query "create table users (id int primary key, name varchar(128) not null);"
  for seqno in $(seq 1 100); do
    mysql_query "insert into users (id, name) values ($seqno, 'name-$seqno');"
  done
}

test_where() {
  run_diffx mysql_query "select id, name from users where id = 1;"
}

test_count() {
  run_diffx mysql_query "select count(*) from users;"
}

test_limit() {
  run_diffx mysql_query "select id, name from users order by id limit 10;"
}

test_offset() {
  run_diffx mysql_query "select id, name from users order by id limit 10 offset 50;"
}

test_from_file() {
  run_diffx mysql_query "source $SQLDIR/test.sql"
}

#: @AfterAll
after_all() {
  mysql_query "drop database sample;"
}
