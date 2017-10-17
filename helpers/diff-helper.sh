#!/usr/bin/env bash
#
# Diff helper
#
# This helper helps you to vefiry that the output of your test program is as expected.
#
# load "diff-helper.sh"
#
DIFF_RESULTS_DIR="$(dirname "$BAUT_TEST_FILE")"/results
DIFF_EXPECTED_DIR="$(dirname "$BAUT_TEST_FILE")"/expected

mkdir -p "$DIFF_RESULTS_DIR" "$DIFF_EXPECTED_DIR"

#: run_diff <command>
#:   Run the command and do diff with unified format between a result file and a expected file.
#:   Even if exit status code is not 0, this call will not be trapped.
#: ex:
#:   run_diff psql -c "SELECT * FROM users WHERE id = 1;"
#:
run_diff() {
  disable_setopt "eET"
  local results_file="$DIFF_RESULTS_DIR/$BAUT_TEST_FUNCTION_NAME".out
  local expected_file="$DIFF_EXPECTED_DIR/$BAUT_TEST_FUNCTION_NAME".out
  local diff_file="$DIFF_RESULTS_DIR/$BAUT_TEST_FUNCTION_NAME".out.diff
  status="$("$@" &> "$results_file";
            [ ! -e "$expected_file" ] && echo 1 && exit;
            diff -u "$expected_file" "$results_file" &> "$diff_file";
            echo $?)"
  if [ $status -eq 0 ]; then
    rm "$diff_file"
  else
    echo "See $diff_file"
  fi
  pop_setopt
}

#: run_diffx <command>
#:   Run the command and do diff with unified format between a result file and a expected file.
#:   If exit status code is 0, this call is trapped.
#: ex:
#:   run_diff psql -c "SELECT * FROM users WHERE id = 1;"
#:
run_diffx() {
  disable_setopt "eET"
  local results_file="$DIFF_RESULTS_DIR/$BAUT_TEST_FUNCTION_NAME".out
  local expected_file="$DIFF_EXPECTED_DIR/$BAUT_TEST_FUNCTION_NAME".out
  local diff_file="$DIFF_RESULTS_DIR/$BAUT_TEST_FUNCTION_NAME".out.diff
  status="$("$@" &> "$results_file";
            [ ! -e "$expected_file" ] && echo 1 && exit;
            diff -u "$expected_file" "$results_file" &> "$diff_file";
            echo $?)"
  if [ $status -eq 0 ]; then
    [ -e "$diff_file" ] && rm "$diff_file"
  else
    echo "See $diff_file"
  fi
  pop_setopt
  return $status
}
