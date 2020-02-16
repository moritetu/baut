#!/usr/bin/env bash

#: @BeforeEach
setup() {
  tmpfile="$(resolve_link "${TMPDIR:-.}/$$.sh")"
}

#: @AfterEach
teardown() {
  if test -e "$tmpfile"; then
    /bin/rm -rf "$tmpfile"
  fi
}

test_baut_usage() {
  run baut
  [ "$result" = "Usage: baut [-v] [-h] [--d[0-4]] [run|<command>] [<args>]" ]
}

test_baut_help() {
  run baut help
  [[ "$result" =~ Usage: ]]
  [[ "$result" =~ OPTIONS ]]
  [[ "$result" =~ COMMANDS ]]
}

test_show_test_help() {
  cat <<EOF | sed -e "s/^#//g" > "$tmpfile"
#test_dummy() {
#  :
#}
#
##=begin HELP
##
## Help about test
##
##=end HELP
EOF

  run baut help "$tmpfile"
  [ "$result" = "Help about test" ] || fail "$result"
}
