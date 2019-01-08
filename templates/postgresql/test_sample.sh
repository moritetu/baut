#!/usr/bin/env bash

load "diff-helper.sh"

SQLDIR="$(__DIR__)/sql"

#: @BeforeAll
setup_all() {
  local status=0
  export PGDATA="$(__DIR__)/pgdata"
  export PGDATABASE=sample
  {
    if [ -d "$PGDATA" ]; then
      rm -rf "$PGDATA"
    fi
    initdb --encoding=utf8 "$PGDATA"
    pg_ctl -w start
  } &> /dev/null || status=$?
  if [ $status -ne 0 ]; then
    fail "cannot start server"
  fi
#  export PGPORT=11003
  dropdb --if-exists sample
  createdb --encoding=utf8 sample
  psql -c "create table users (id int primary key, name varchar(128) not null);"
  psql -c "insert into users select i , 'name-' || i from generate_series(1, 100) as i;"
}

test_where() {
  run_diffx psql -c "select id, name from users where id = 1;"
}

test_count() {
  run_diffx psql -c "select count(*) from users;"
}

test_limit() {
  run_diffx psql -c "select id, name from users order by id limit 10;"
}

test_offset() {
  run_diffx psql -c "select id, name from users order by id limit 10 offset 50;"
}

test_from_file() {
  run_diffx psql -f "$SQLDIR"/test.sql
}

#: @AfterAll
after_all() {
  dropdb sample
  pg_ctl -w stop &> /dev/null
  rm -rf "$PGDATA"
}
