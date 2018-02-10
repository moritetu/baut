#!/usr/bin/env bash

#: @BeforeEach
setup() {
  tmpfile="$(resolve_link "${TMPDIR:-.}/$$.sh")"
  include_file="$(resolve_link "${TMPDIR:-.}/$$_inc.sh")"
}

#: @AfterEach
teardown() {
  /bin/rm -rf "$tmpfile" "$include_file" ||:
}

test_option_count_only() {
  cat <<EOF | sed -e "s/^#//g" > "$tmpfile"
#test_hoge() {
#  echo "hoge"
#}
EOF
  run baut compile --count-only "$tmpfile"
  [[ "$result" =~ "1" ]]
}

test_option_show_functions() {
  cat <<EOF | sed -e "s/^#//g" > "$tmpfile"
##: @BeforeAll
#before_all() {
#  :
#}
##: @BeforeEach
#setup() {
#  :
#}
##: @AfterAll
#after_all() {
#  :
#}
##: @AfterEach
#teardown() {
#  :
#}
#test_hoge() {
#  echo "hoge"
#}
#test_foo() {
#  echo "foo"
#}
EOF
  run baut compile --show-functions "$tmpfile"
  [[ "$result" =~ "before_all" ]]
  [[ "$result" =~ "setup" ]]
  [[ "$result" =~ "after_all" ]]
  [[ "$result" =~ "teardown" ]]
  [[ "$result" =~ "test_hoge" ]]
  [[ "$result" =~ "test_foo" ]]
}

test_compile() {
  cat <<EOF | sed -e "s/^#//g" > "$tmpfile"
#test_hoge() {
#  echo "hoge"
#}
EOF
  local checksum="$(cat "$tmpfile" | $baut_hash | awk -F" " '{print $1}')"
  run baut compile "$tmpfile"
  [[ "$result" =~ "test_hoge" ]]
  [[ "$result" =~ "@filepath" ]]
  [[ "$result" =~ "@filepath=$tmpfile" ]]
  [[ "$result" =~ "@testcount=1" ]]
  [[ "$result" =~ "@checksum=$checksum" ]]
}

test_compile_annotation_Test() {
  cat <<EOF | sed -e "s/^#//g" > "$tmpfile"
##:@Test(testname)
#hoge() {
#  :
#}
EOF
  run baut compile "$tmpfile"
  [[ "$result" =~ "hoge" ]]
  [[ "$result" =~ "testname" ]]
  [[ "$result" =~ "baut_run_test" ]]
}

test_compile_annotation_TODO() {
  cat <<EOF | sed -e "s/^#//g" > "$tmpfile"
##:@TODO(message)
#hoge() {
#  :
#}
EOF
  run baut compile "$tmpfile"
  [[ "$result" =~ "baut_run_todo_test" ]]
  [[ "$result" =~ "message" ]]
}

test_compile_annotation_Ignore() {
  cat <<EOF | sed -e "s/^#//g" > "$tmpfile"
##:@Ignore
#hoge() {
#  :
#}
EOF
  run baut compile "$tmpfile"
  [[ ! "$result" =~ "hoge" ]]
}

test_compile_annotation_Deprecated() {
  cat <<EOF | sed -e "s/^#//g" > "$tmpfile"
##:@Deprecated(oldtest)
#hoge() {
#  :
#}
EOF
  run baut compile "$tmpfile"
  [[ "$result" =~ "deprecated" ]]
  [[ "$result" =~ "oldtest" ]]
}

test_compile_annotation_BeforeAll() {
  cat <<EOF | sed -e "s/^#//g" > "$tmpfile"
##:@BeforeAll
#before_all() {
#  :
#}
EOF
  run baut compile "$tmpfile"
  [[ "$result" =~ "before_all_functions=(before_all)" ]]
}

test_compile_annotation_AfterAll() {
  cat <<EOF | sed -e "s/^#//g" > "$tmpfile"
##:@AfterAll
#after_all() {
#  :
#}
EOF
  run baut compile "$tmpfile"
  [[ "$result" =~ "after_all_functions=(after_all)" ]]
}

test_compile_annotation_BeforeEach() {
  cat <<EOF | sed -e "s/^#//g" > "$tmpfile"
##:@BeforeEach
#setup() {
#  :
#}
EOF
  run baut compile "$tmpfile"
  [[ "$result" =~ "before_each_functions=(setup)" ]]
}

test_compile_annotation_AfterEach() {
  cat <<EOF | sed -e "s/^#//g" > "$tmpfile"
##:@AfterEach
#teardown() {
#  :
#}
EOF
  run baut compile "$tmpfile"
  [[ "$result" =~ "after_each_functions=(teardown)" ]]
}

test_compile_annotation_include() {
    cat <<EOF | sed -e "s/^#//g" > "$include_file"
##:@Test
#test_func() {
#  echo "test_func"
#}
EOF
  cat <<EOF | sed -e "s/^#//g" > "$tmpfile"
##:@.($include_file)
EOF
  run baut compile "$tmpfile"
  [[ "$result" =~ "test_func" ]]
  cat <<EOF | sed -e "s/^#//g" > "$tmpfile"
##:@source($include_file)
EOF
  run baut compile "$tmpfile"
  [[ "$result" =~ "test_func" ]]
  cat <<EOF | sed -e "s/^#//g" > "$tmpfile"
##:@include($include_file)
EOF
  run baut compile "$tmpfile"
  [[ "$result" =~ "test_func" ]]
}
