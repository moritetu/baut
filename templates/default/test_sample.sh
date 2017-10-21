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
  [ $status -ne 0 ] || fail "exit status should not be 0, but '$status'"
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

#: @AfterEach
function teardown() {
  :
}

#: @AfterAll
function after_all() {
  :
}
