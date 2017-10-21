# Baut (Bash Unit Test Tool)

[![Build Status](https://travis-ci.org/moritoru81/baut.svg?branch=master)](https://travis-ci.org/moritoru81/baut)

Baut is a unit testing tool runs on Bash. With baut, you can verify that the programs on Unix/Linux
behave as expected.

A test file is just a Bash script, so you can write test codes using your favorite editor as always. Do not need special editors
or editor modes.

This is a short example of a Baut test script.

``` shell
#: @BeforeEach
function setup() {
  export PATH=/usr/local/bin:"$PATH"
}

#: @Test(The usage should be displayed when command line options are invalid)
function parse_cli_options() {
  run ./my.sh
  [[ "$result" =~ usage: ]]
}

#: @Test
#: @Ignore
function this_test_is_ignored() {
  echo "This test is ignored"
}

#: @AfterEach
function teardown() {
  echo "clean up a test."
}
```

## Installation

``` shell
$ git clone https://github.com/moritoru81/baut.git
$ source install.sh
```

`source install.sh` is a optional step, it adds the directory path of `baut` to `PATH`.


## Running tests

You can run tests with `run` command. `run` command takes test files or directories which include test files.

``` shell
$ baut run test_sample.sh test_dir
```


## For more detail

See [Baut Documentation](http://baut.readthedocs.io/en/latest/)
