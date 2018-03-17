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
    /bin/rm "$diff_file"
  else
    echo "See $diff_file"
  fi
  pop_setopt
}

#: run_diffx <command>
#:   Run the command and do diff with unified format between a result file and a expected file.
#:   If exit status code is 0, this call is trapped.
#: ex:
#:   run_diffx psql -c "SELECT * FROM users WHERE id = 1;"
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

#: begin_comparing [filename]
#:   Redirect output to the result file 'name' after this calling.
#:   We use descriptor number 5 for stdout saving and 6 for stderr saving in this process.
#: ex:
#:   begin_comparing
#:   echo "this result is written to the result file"
begin_comparing() {
  disable_setopt "eET"
  local results_file="$DIFF_RESULTS_DIR/$BAUT_TEST_FUNCTION_NAME".out
  if [ $# -gt 0 ]; then
    results_file="$DIFF_RESULTS_DIR/$1".out
  fi

  log_trace "save stdout as 5 and stderr as 6"

  # save stdout and stderr
  exec 5>&1
  exec 6>&2
  # redirect stdout to the result_file
  exec > "$results_file"
}

#: end_comparing [filename]
#:   Stop redirect and compare the result with the expected.
#: ex:
#:   begin_comparing
#:   echo "this result is written to the result file"
#:   end_comparing
end_comparing() {
  # at first, we close the temporary file descriptor
  exec 1>&5 5>&-
  exec 2>&6 6>&-

  local results_file="$DIFF_RESULTS_DIR/$BAUT_TEST_FUNCTION_NAME".out
  local expected_file="$DIFF_EXPECTED_DIR/$BAUT_TEST_FUNCTION_NAME".out
  local diff_file="$DIFF_RESULTS_DIR/$BAUT_TEST_FUNCTION_NAME".out.diff

  if [ $# -gt 0 ]; then
    results_file="$DIFF_RESULTS_DIR/$1".out
    expected_file="$DIFF_EXPECTED_DIR/$1".out
    diff_file="$DIFF_RESULTS_DIR/$1".out.diff
  fi

  status="$([ ! -e "$expected_file" ] && echo 1 && exit;
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
