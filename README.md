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
$ source install.sh
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


## For more detail

See [Baut Documentation](http://baut.readthedocs.io/en/latest/)

## License

[![MIT License](http://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE)
