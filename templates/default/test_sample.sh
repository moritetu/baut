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
