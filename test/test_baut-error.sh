#!/usr/bin/env bash

#: @BeforeEach
setup() {
  tmpfile="$(resolve_link "${TMPDIR:-.}/test_$$.sh")"
}

#: @AfterEach
teardown() {
  if test -e "$tmpfile"; then
    /bin/rm -rf "$tmpfile"
  fi
}

test_error_in_before_all() {
  cat <<EOF | sed -e "s/^#//g" > "$tmpfile"
##: @BeforeAll
#before_all() {
#  return 1
#}
#test_dummy() {
#  :
#}
#
EOF

  run baut r --no-color "$tmpfile"
  [[ "${lines[2]}" =~ ^!ERROR\ before_all$ ]]
  [[ "$result" =~ return\ 1 ]]
}

test_error_in_before_each() {
  cat <<EOF | sed -e "s/^#//g" > "$tmpfile"
##: @BeforeEach
#before_each() {
#  return 1
#}
#test_dummy() {
#  :
#}
#
EOF

  run baut r --no-color "$tmpfile"
  [[ "${lines[2]}" =~ test_dummy ]]
  [[ "$result" =~ return\ 1 ]]
}

test_error_in_test() {
  cat <<EOF | sed -e "s/^#//g" > "$tmpfile"
##: @BeforeEach
#before_each() {
#  return 0
#}
#test_dummy() {
#  [ 1 -ne 1 ]
#}
#
EOF

  run baut r --no-color "$tmpfile"
  [[ "${lines[2]}" =~ test_dummy ]]
  regex="=>.+\[.+1.-ne.1.\]"
  [[ "$result" =~  $regex ]]
}

test_error_in_after_each() {
  cat <<EOF | sed -e "s/^#//g" > "$tmpfile"
##: @AfterEach
#after_each() {
#  return 1
#}
#test_dummy() {
#  [ 1 -eq 1 ]
#}
#
EOF

  run baut r --no-color "$tmpfile"
  [[ "${lines[2]}" =~ test_dummy ]]
  [[ "$result" =~  return\ 1 ]]
}

test_error_in_after_all() {
  cat <<EOF | sed -e "s/^#//g" > "$tmpfile"
##: @AfterAll
#after_all() {
#  return 1
#}
#test_dummy() {
#  [ 1 -eq 1 ]
#}
#
EOF

  run baut r --no-color "$tmpfile"
  [[ "${lines[3]}" =~ after_all ]]
  [[ "$result" =~  return\ 1 ]]
}


