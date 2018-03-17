#!/usr/bin/env bash

load "diff-helper.sh"

DBPATH="$(__DIR__)/data"
LOGPATH="$(__DIR__)/logs"

mkdir -p "$LOGPATH" "$DBPATH"

#: @BeforeAll
setup_all() {
  log_warn "==> start mongod"
  mongod --fork --dbpath=$DBPATH --logpath=$LOGPATH/mongod.log
}


#: @AfterAll
after_all() {
  log_warn "==> shutdown mongod"
  mongo --quiet <<EOF
use admin;
db.shutdownServer();
EOF
  rm -rf "$DBPATH"
}

#: @BeforeEach
setup() {
  mongo --quiet <<EOF
use test;
for (var i = 0; i < 100; ++i) {
  db.users.insert({userid: i, username: "name-" + i});
}
EOF
}

#: @AfterEach
teardown() {
  mongo --quiet <<EOF
use test;
db.users.remove({});
EOF
}

test_query() {
  run_diffx mongo --quiet <<EOF
use test;
db.users.count();
EOF
}
