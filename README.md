# Baut (Bash Unit Test Tool)

[![Build Status](https://travis-ci.org/moritoru81/baut.svg?branch=master)](https://travis-ci.org/moritoru81/baut)

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

## For more detail

See [Baut Documentation](http://baut.readthedocs.io/en/latest/)

## License

[![MIT License](http://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE)
