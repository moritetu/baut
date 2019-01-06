# Baut (Bash Unit Test Tool)

[![Build Status](https://travis-ci.org/moritetu/baut.svg?branch=master)](https://travis-ci.org/moritetu/baut)

Baut is a unit testing tool runs on Bash. With baut, you can verify that the programs on Unix/Linux
behave as expected.

A test file is just a Bash script, so you can write test codes using your favorite editor as always. Do not need special editors
or editor modes.

This is a short example of a Baut test script.

``` shell
# test_sample.sh

#: @BeforeEach
function setup() {
  echo "==> $(self)"
  export PATH=/usr/local/bin:"$PATH"
}

#: @Test(The usage should be displayed when command line options are invalid)
function parse_cli_options() {
  run echo "usage: baut"
  [[ "$result" =~ usage: ]]
}

#: @Test
#: @Ignore
function this_test_is_ignored() {
  echo "This test is ignored"
}

#: @AfterEach
function teardown() {
  echo "==> $(self)"
}
```

## Installation

Baut runs on Bash 4 or higher.

``` shell
$ git clone https://github.com/moritoru81/baut.git
$ cd baut
$ source install.sh
$ baut run test
```

`source install.sh` is a optional step, it adds the directory path of `baut` to `PATH`.


## Running tests

You can run tests with `run` command. `run` command takes test files or directories which include test files.

``` shell
$ baut run test_sample.sh
1 file, 1 test
#1 /Users/guest/test_sample.sh
o The usage should be displayed when command line options are invalid
  ==> setup
  ==> teardown
#$ 1 test, 1 ok, 0 failed, 0 skipped

🎉  1 file, 1 test, 1 ok, 0 failed, 0 skipped
Time: 0 hour, 0 minute, 0 second
```

## Quick Start

You can make a test project with `init` command. There are some project templates under template directory. Without options, the default template is selected.

``` shell
$ baut init test
$ ./test/run-test.sh
1 file, 4 tests
#1 /Users/guest/baut/test/test_sample.sh
x test_ng_sample
  Not implemented
  # Error(1) detected at the following:
  #       13	#: @Test
  #       14	test_ng_sample() {
  #=>     15	  fail "Not implemented"
  #       16	}
  #       17
x test_ng_sample2
  exit status should not be 0, but '0'
  result: bar
  # Error(1) detected at the following:
  #       19	test_ng_sample2() {
  #       20	  run echo "bar"
  #=>     21	  [ $status -ne 0 ] || fail "exit status should not be 0, but '$status'" "result: $result"
  #       22	}
  #       23
o test_ok_sample
~ test_skip_sample # SKIP Good bye!
#$ 4 tests, 1 ok, 2 failed, 1 skipped

💥  1 file, 4 tests, 1 ok, 2 failed, 1 skipped
Time: 0 hour, 0 minute, 0 second
```

## Test Using Diff

This example shows test comparing expected results with actual results like PostgreSQL regression test. Expected results are put under `expected` directory, and actual results are written under `results` directory.

``` shell
$ tree
.
├── expected
│   ├── test_count.out
│   ├── test_from_file.out
│   ├── test_limit.out
│   ├── test_offset.out
│   └── test_where.out
├── results
├── sql
│   └── test.sql
└── test_sample.sh
```

``` shell
#!/usr/bin/env bash
# test_sample.sh

load "diff-helper.sh"

SQLDIR="$(__DIR__)/sql"

#: @BeforeAll
setup_all() {
  export PGDATABASE=sample
  dropdb --if-exists sample
  createdb --encoding=utf8 sample
  psql -c "create table users (id int primary key, name varchar(128) not null);"
  psql -c "insert into users select i , 'name-' || i from generate_series(1, 100) as i;"
}

test_where() {
  run_diffx psql -c "select id, name from users where id = 1;"
}

test_count() {
  run_diffx psql -c "select count(*) from users;"
}

test_limit() {
  run_diffx psql -c "select id, name from users order by id limit 10;"
}

test_offset() {
  run_diffx psql -c "select id, name from users order by id limit 10 offset 50;"
}

test_from_file() {
  run_diffx psql -f "$SQLDIR"/test.sql
}

#: @AfterAll
after_all() {
  dropdb sample
}
```

``` shell
$ cat expected/test_count.out
 count
-------
   100
(1 row)

```

The execution result is as follows.

``` shell
$ baut run test_sample.sh
1 file, 5 tests
#1 /Users/guest/workspace/baut/postgres/test_sample.sh
NOTICE:  database "sample" does not exist, skipping
CREATE TABLE
INSERT 0 100
o test_where
o test_count
o test_limit
o test_offset
o test_from_file
#$ 5 tests, 5 ok, 0 failed, 0 skipped

🎉  1 file, 5 tests, 5 ok, 0 failed, 0 skipped
Time: 0 hour, 0 minute, 0 second
```

## For more detail

See [Baut Document](http://baut.readthedocs.io/en/latest/)

## License

[![MIT License](http://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE)
