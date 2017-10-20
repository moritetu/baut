#!/usr/bin/env bash

#: @BeforeEach
setup() {
  tmpfile="$(resolve_link "${TMPDIR:-.}/$$.tmp")"
}

#: @AfterEach
teardown() {
  /bin/rm -rf "$tmpfile" ||:
}

test_error() {
  eval2 'echo "error" | error'
  [ "$stderr" = "error" ]
  [ $status -eq 0 ]

  eval2 'error "error"'
  [ "$stderr" = "error" ]
  [ $status -eq 0 ]

  eval2 'error "error\nfailed"'
  [ "${stderr_lines[0]}" = "error" ]
  [ "${stderr_lines[1]}" = "failed" ]
  [ $status -eq 0 ]
}

test_abort() {
  eval2 'echo "error" | abort'
  [ "$stderr" = "error" ]
  [ $status -eq 1 ]

  eval2 'abort "error"'
  [ "$stderr" = "error" ]
  [ $status -eq 1 ]
}

test__FILE__() {
  [ "$(__FILE__)" = "$BASH_SOURCE" ]
}

test__DIR__() {
  [ "$(__DIR__)" = "$(dirname "$BASH_SOURCE")" ]
}

test__LINE__() {
  [ "$(__LINE__)" = "$LINENO" ]
}

test_self__in_function() {
  [ "$(self)" = "test_self__in_function" ]
}

TEST_SELF_IN_FILE="$(self)"
test_self__in_file() {
  [ "$(basename "`__FILE__`")" = "$TEST_SELF_IN_FILE" ]
}

test_load() {
  cat <<EOF > "$tmpfile"
__TEST_LOAD_VARIABLE=\$1
EOF
  load "$tmpfile" "arg1"
  [ "$__TEST_LOAD_VARIABLE" = "arg1" ]
  [ "${__baut_loaded_path[$tmpfile]}" = "1" ]

  cat <<EOF > "$tmpfile"
__TEST_LOAD_VARIABLE=A\$1
EOF
  load "$tmpfile" "arg1"
  [ "$__TEST_LOAD_VARIABLE" = "Aarg1" ]
  [ "${__baut_loaded_path[$tmpfile]}" = "1" ]

  run load "$$.dummy" "arg"
  [ $status -eq 1 ]
  [[ "$result" =~ "file not found" ]]
}

test_load_if_exists() {
  cat <<EOF > "$tmpfile"
__TEST_LOAD_VARIABLE=\$1
EOF
  load_if_exists "$tmpfile" "arg1"
  [ "$__TEST_LOAD_VARIABLE" = "arg1" ]
  [ "${__baut_loaded_path[$tmpfile]}" = "1" ]

  cat <<EOF > "$tmpfile"
__TEST_LOAD_VARIABLE=A\$1
EOF
  load_if_exists "$tmpfile" "arg1"
  [ "$__TEST_LOAD_VARIABLE" = "Aarg1" ]
  [ "${__baut_loaded_path[$tmpfile]}" = "1" ]

  run load_if_exists "$$.dummy" "arg"
  [ $status -eq 1 ]
  [ "$result" = "" ]
}

test_loadable() {
  touch "$tmpfile"

  run loadable "$tmpfile"
  [ $status -eq 0 ]

  run loadable "${tmpfile}.dummy"
  [ $status -eq 1 ]
}

test_require() {
  cat <<EOF > "$tmpfile"
__TEST_LOAD_VARIABLE=\$1
EOF

  require "$tmpfile" "arg1"
  [ $? -eq 0 ]
  [ "$__TEST_LOAD_VARIABLE" = "arg1" ]
  [ "${__baut_loaded_path[$tmpfile]}" = "1" ]

  cat <<EOF > "$tmpfile"
__TEST_LOAD_VARIABLE=A\$1
EOF

  require "$tmpfile" "arg1"
  [ $? -eq 0 ]
  [ "$__TEST_LOAD_VARIABLE" = "arg1" ]
  [ "${__baut_loaded_path[$tmpfile]}" = "1" ]

  run require "${tmpfile}.dummy"
  [ $status -eq 1 ]
}

test_resolve_link() {
  local absdir="$(cd "${TMPDIR:-.}" && pwd -P)"
  local org_file="$$.txt"
  local symlink="$$.symlink"
  add_trap_commands "EXIT" "rm '$absdir/$org_file' '$absdir/$symlink'"
  (cd "$absdir" && touch "$org_file" && ln -s "$org_file" "$symlink")
  local filepath="$(resolve_link "$absdir/$symlink")"
  [ "$absdir/$org_file" = "$filepath" ]
}

test_abs_dirname() {
  local absdir="$(cd "${TMPDIR:-.}" && pwd -P)"
  local realdir="r-$$"
  local symdir="s-$$"
  add_trap_commands "EXIT" "rm -rf '$absdir/$realdir' '$absdir/$symdir'"

  run abs_dirname "$(__FILE__)"
  [ "$result" = "$(__DIR__)" ]
  [ $status -eq 0 ]
  (cd "$absdir" && mkdir "$realdir" && ln -s "$realdir" "$symdir")
  run abs_dirname "$absdir/$symdir/a"
  [ "$result" = "$absdir/$realdir" ]
}

test_datetime() {
  BAUT_LOG_DATE_FORMAT='%Y'
  run datetime
  [ "$result" = "$(date +'%Y')" ]
  [ $status -eq 0 ]
}

test_log_xxx() {
  BAUT_LOG_LEVEL=0
  run log_trace "trace"
  [[ "$result" =~ TRACE ]]
  [[ "$result" =~ trace ]]

  BAUT_LOG_LEVEL=1
  run log_debug "debug"
  [[ "$result" =~ DEBUG ]]
  [[ "$result" =~ debug ]]

  BAUT_LOG_LEVEL=2
  run log_info "info"
  [[ "$result" =~ INFO ]]
  [[ "$result" =~ info ]]

  BAUT_LOG_LEVEL=3
  run2 log_warn "warn"
  [[ "$stderr" =~ WARN ]]
  [[ "$stderr" =~ warn ]]

  BAUT_LOG_LEVEL=4
  run2 log_error "error"
  [[ "$stderr" =~ ERROR ]]
  [[ "$stderr" =~ ERROR ]]
}

test_println() {
  run println "foo" "bar"
  [[ "${lines[0]}" =~ foo ]]
  [[ "${lines[1]}" =~ bar ]]

  run println_log "foo\nbar"
  [[ "${lines[0]}" =~ foo ]]
  [[ "${lines[1]}" =~ bar ]]
}

test_get_comment_block() {
  cat <<EOF > "$tmpfile"
#
#=begin BLOCK
#
# block content
#
#=end BLOCK
#
EOF
  run get_comment_block "$tmpfile" "BLOCK"
  [ "$result" = "block content" ]
  run get_comment_block "$tmpfile" "NONE"
  [ "$result" = "" ]
  run get_comment_block "" ""
  [ "$result" = "" ]
}

test_get_comment_line() {
  cat <<EOF > "$tmpfile"
echo "#:foo"
#: @Test #:
#
EOF
  run get_comment_line "$tmpfile"
  [ "$result" = "@Test #:" ]
  run get_comment_line ""
  [ "$result" = "" ]
}

test_enable_setopt() {
  local before_opts="$-"
  eval2 'enable_setopt "x" && echo "$-" && pop_setopt'
  [ $status -eq 0 ]
  [[ ! "$before_opts" =~ x ]]
  [[ "$result" =~ x ]]
}

test_disable_setopt() {
  local before_opts="$-"
  eval2 'disable_setopt "x" && echo "$-" && pop_setopt'
  [ $status -eq 0 ]
  [[ ! "$result" =~ x ]]
} &> /dev/null

test_pop_setopt() {
  disable_setopt "x"
  local before_opts="$-"
  pop_setopt
  [[ ! "$before_opts" =~ x ]]
  enable_setopt "x"
  [[ "$-" =~ x ]]
  pop_setopt
  [ "$before_opts" = "$-" ]
} &> /dev/null

test_seq_char() {
  local strings="abc"
  eval2 'seq_char "$strings" | sort -r | xargs printf "%s"'
  [ "$result" = "cba" ]
}

test_plural() {
  run plural "%d test" -1
  [ "$result" = "-1 test" ]
  run plural "%d test" 0
  [ "$result" = "0 test" ]
  run plural "%d test" 1
  [ "$result" = "1 test" ]
  run plural "%d test" 2
  [ "$result" = "2 tests" ]
}

test_hash_get_set_delete() {
  eval2 'hash_set "a" "b" "c"; hash_get "a" "b"'
  [ "$result" = "c" ]
  eval2 'hash_set "abc"; hash_get "abc"'
  [ "$result" = "" ]
  eval2 'hash_set "abc" 1; hash_delete "abc"; hash_get "abc"'
  [ "$result" = "" ]
  run hash_delete "abc"
  [ "$result" = "" ]
  [ $status -eq 0 ]
}

test_array_reverse() {
  local ar=(1 2 3 4 "hello world")
  local reverse_ar=( $(array_reverse "${ar[@]}") )
  [ "${reverse_ar[0]}" = "hello" ]
  [ "${reverse_ar[*]}" = "hello world 4 3 2 1" ]
  local array_str="$(array_reverse "${ar[@]}")"
  OLDIFS="$IFS"
  IFS=$'\n' ||:
  reverse_ar=( $array_str )
  [ "${reverse_ar[0]}" = "hello world" ]
  IFS="$OLDIFS"
}

test_add_trap_callback() {
  add_trap_callback "USR1" "touch $tmpfile"
  register_trap_callback "USR1"
  kill -SIGUSR1 $BASHPID
  [ -e "$tmpfile" ]
  unregister_trap_callback "USR1"
}

test_add_trap_commands() {
  add_trap_commands "USR1" "echo 1 > $tmpfile"
  register_trap_callback "USR1"
  kill -SIGUSR1 $BASHPID
  [ -e "$tmpfile" ]
  [ "$(cat "$tmpfile")" = "1" ]
  unregister_trap_callback "USR1"
}

test_add_reset_trap_callback() {
  add_trap_callback "USR1" "touch $tmpfile"
  register_trap_callback "USR1"
  reset_trap_callback "USR1"
  [ "$(hash_get "trap_USR1")" = "" ]
  [ "${__baut_enable_trap["trap_USR1"]:-}" = "" ]
  kill -SIGUSR1 $BASHPID
  [ ! -e "$tmpfile" ]
  unregister_trap_callback "USR1"
}

test_enable_disable_trap() {
  add_trap_callback "USR1" "touch $tmpfile"
  register_trap_callback "USR1"
  disable_trap "USR1"
  kill -SIGUSR1 $BASHPID
  [ ! -e "$tmpfile" ]
  enable_trap "USR1"
  kill -SIGUSR1 $BASHPID
  [ -e "$tmpfile" ]
  unregister_trap_callback "USR1"
}
