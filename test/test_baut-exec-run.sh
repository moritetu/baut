#!/usr/bin/env bash

#: @BeforeEach
setup() {
  tmpfile="$(resolve_link "${TMPDIR:-.}/test_$$.sh")"
  tmpfile2="$(resolve_link "${TMPDIR:-.}/test_$$.2.sh")"
  wrap_script="$(resolve_link "${TMPDIR:-.}/_all.sh")"
  not_test_file="$(resolve_link "${TMPDIR:-.}/test_$$.dummy")"
  not_test_file2="$(resolve_link "${TMPDIR:-.}/notest_$$.sh")"
}

#: @AfterEach
teardown() {
  /bin/rm -rf "$tmpfile" "$tmpfile2" "$wrap_script" "$not_test_file" "$not_test_file2" ||:
}

test_run_option_s() {
  cat <<EOF | sed -e "s/^#//g" > "$tmpfile"
#test_hoge() {
#  [ 1 -eq 0 ]
#}
#test_hoge2() {
#  echo "hoge"
#}
EOF
  run baut run -s "$tmpfile"
  [[ "$result" =~ "x test_hoge" ]]
  [[ "$result" =~ "1 file, 1 test, 0 ok, 1 failed, 0 skipped" ]]
  [[ "$result" =~ "Error detected in $tmpfile#test_hoge" ]]
}

test_run_option_d() {
  cat <<EOF | sed -e "s/^#//g" > "$wrap_script"
#_setup() {
#  :
#}
#_cleanup() {
#  :
#}
EOF

  cat <<EOF | sed -e "s/^#//g" > "$tmpfile"
##:@BeforeEach
#setup() {
#  :
#}
#test_hoge() {
#  echo "hoge"
#}
#test_hoge2() {
#  echo "hoge"
#}
##:@AfterEach
#teardown() {
#  :
#}
EOF
  run baut run -d "$tmpfile"
  [[ "$result" =~ "_setup" ]]
  [[ "$result" =~ "(0) before_all_functions =>" ]]
  [[ "$result" =~ "(1) before_each_functions => setup" ]]
  [[ "$result" =~ "(2) test_functions => test_hoge test_hoge2" ]]
  [[ "$result" =~ "(1) after_each_functions => teardown" ]]
  [[ "$result" =~ "(0) after_all_functions =>" ]]
  [[ "$result" =~ "_cleanup" ]]
  [[ "$result" =~ "1 file, 2 tests" ]]
}


test_run_option_f_tap() {
  cat <<EOF | sed -e "s/^#//g" > "$tmpfile"
#test_hoge() {
#  :
#}
#test_hoge2() {
#  :
#}
#test_fail() {
#  [ 0 -eq 1 ]
#}
#test_skip() {
#  skip
#}
##:@TODO(todo_test)
#test_todo() {
#  :
#}
EOF
  run baut run --no-debug -f tap "$tmpfile"
  [[ "${lines[0]}" =~ "1..5" ]]
  [[ "${lines[1]}" =~ "ok 1" ]]
  [[ "${lines[2]}" =~ "ok 2" ]]
  [[ "${lines[3]}" =~ "not ok 3" ]]
  [[ "${lines[4]}" =~ "ok 4" ]]
  [[ "${lines[4]}" =~ "# SKIP" ]]
  [[ "${lines[5]}" =~ "ok 5" ]]
  [[ "${lines[5]}" =~ "# TODO" ]]
}


test_run_option_f_oneline() {
  cat <<EOF | sed -e "s/^#//g" > "$tmpfile"
#test_hoge() {
#  echo "hoge"
#}
#test_hoge2() {
#  echo "hoge"
#}
#test_fail() {
#  [ 0 -eq 1 ]
#}
EOF
  run baut run -f oneline --no-color "$tmpfile"
  [ 2 -eq $(printf "$result" | grep -e "^o" | wc -l) ]
  [ 1 -eq $(printf "$result" | grep -e "^x" | wc -l) ]
}

test_run_option_match() {
  cat <<EOF | sed -e "s/^#//g" > "$tmpfile"
#test_hoge() {
#  echo "hoge"
#}
#test_foo() {
#  echo "hoge"
#}
#test_fail() {
#  [ 0 -eq 1 ]
#}
EOF
  run baut run -m "hoge" --no-color "$tmpfile"
  [[ "$result" =~ "1 file, 3 tests" ]]
  [[ "$result" =~ "1 file, 1 test, 1 ok, 0 failed, 0 skipped" ]]
}

test_run_option_wrap_script() {
  cat <<EOF | sed -e "s/^#//g" > "$tmpfile"
#test_hoge() {
#  echo "hoge"
#}
EOF
  cat <<EOF > "$wrap_script"
_setup() {
  echo "_setup"
}
_cleanup() {
  echo "_cleanup"
}
EOF
  run baut run --no-color -w "$wrap_script" "$tmpfile"
  [[ "$result" =~ "_setup" ]] || fail "$result"
  [[ "$result" =~ "_cleanup" ]]
}

test_run_invalid_test_file() {
  cat <<EOF | sed -e "s/^#//g" > "$not_test_file"
#test_hoge() {
#  echo "hoge"
#}
EOF
  run baut run "$not_test_file"
  [[ "${lines[0]}" =~ "test file is invalid" ]]
  [ $status -eq 1 ]

  cat <<EOF | sed -e "s/^#//g" > "$not_test_file2"
#test_hoge() {
#  echo "hoge"
#}
EOF
  run baut run "$not_test_file2"
  [[ "${lines[0]}" =~ "test file is invalid" ]]
  [ $status -eq 1 ]
}


test_run_clean_up() {
  cat <<EOF | sed -e "s/^#//g" > "$tmpfile"
#test_hoge() {
#  echo "hoge"
#}
EOF
  run baut run "$tmpfile"
  local baut_file="$(echo "$tmpfile" | $baut_hash)"
  [ ! -e "$BAUT_TMPDIR/$baut_file" ]
}
