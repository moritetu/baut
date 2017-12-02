#!/usr/bin/env bash

#: @BeforeAll
function setup_all() {
  :
}

#: @BeforeEach
function setup() {
  :
}

#: @Test
test_ng_sample() {
  fail "Not implemented"
}

#: @Test
test_ng_sample2() {
  run echo "bar"
  [ $status -ne 0 ] || fail "exit status should not be 0, but '$status'" "result: $result"
}

#: @Test
test_ok_sample() {
  run echo "hello baut"
  [ "$result" = "hello baut" ]
  [ $status -eq 0 ]
}

#: @Test
test_skip_sample() {
  run echo "hello baut"
  skip "Good bye!"
  echo "Not reach here"
}

#: @Test
test_wait_until() {
  local pidfile="$(__DIR__)/sample.pid"
  eval "sleep 2 && echo $BASHPID > $pidfile" &
  wait_until --retry-max 3 "[ -e '$pidfile' ]"
  rm $pidfile ||:
}

#: @AfterEach
function teardown() {
  :
}

#: @AfterAll
function after_all() {
  :
}
