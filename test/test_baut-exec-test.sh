#!/usr/bin/env bash

#: @BeforeEach
setup() {
  testfile="$(resolve_link "${TMPDIR:-.}/test_$$.sh")"
  bautfile="$(resolve_link "${TMPDIR:-.}/test_$$.baut")"
  cat <<EOF | sed -e "s/^#//g" > "$testfile"
#test_hoge() {
#  [ 1 -eq 0 ]
#}
#test_hoge2() {
#  echo "hoge"
#}
EOF
  baut compile "$testfile" > "$bautfile"
}

#: @AfterEach
teardown() {
  /bin/rm -rf "$bautfile" "$testfile"
}

test_exec_test() {
  run baut test "$bautfile"
  [ -e "$bautfile" ]

  run baut test --remove-at-end "$bautfile"
  [ ! -e "$bautfile" ]
}
