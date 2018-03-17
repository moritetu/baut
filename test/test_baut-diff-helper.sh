#!/usr/bin/env bash

load "diff-helper.sh"

test_run_diffx() {
  run_diffx echo "diffx"
}

test_run_diff() {
  run_diffx echo "diff"
  [ $status -eq 0 ]
}

test_comparing() {
  begin_comparing
  echo "hello"
  end_comparing
}

test_comparing_with_name() {
  begin_comparing "foo"
  echo "foo"
  end_comparing "foo"
}
