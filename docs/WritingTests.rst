=============
Writing Tests
=============

A test is just a shell function. You can write multiple tests in a file. A test file is included by Baut and tests are executed in their written order in Baut's test running process.

The name of a test file must start with ``test_`` and end with ``.sh``. Baut regards a file like ``test_a.sh`` as a test file.

Quick Start
===========

.. code-block:: bash

   $ mkdir test && cd test
   $ baut init
   $ ./run-test.sh
   1 file, 3 tests
   #1 /Users/guest/workspace/baut/test/test_sample.sh
   x test_ng_sample
   Not implemented
   # Error(1) detected at the following:
   #       13	#: @Test
   #       14	test_ng_sample() {
   #=>     15	  fail "Not implemented"
   #       16	}
   #       17
   o test_ok_sample
   ~ test_skip_sample # SKIP Good bye!
   3 tests, 1 ok, 1 failed, 1 skipped

   💥  1 file, 3 tests, 1 ok, 1 failed, 1 skipped
   Time: 0 hour, 0 minute, 0 second


Test Function
=============

To tell Baut that a shell function is a test function, you need to learn the following rules.

1. The function which name starts with ``test_``.
2. ``@Test`` annotation before a function definition.

This example shows you how to write a unit test.

.. code-block:: bash

   # (1) This is a test with 'test_' prefix.
   function test_mytest() {
     run echo "mytest"
     [ "$result" = "mytest" ]
   }

   # (2) This is a test with 'test_' prefix.
   # function keyword is not required.
   test_mytest2() {
     run echo "mytest2"
     [ "$result" = "mytest2" ]
   }

   # (3) This is a test with '@Test' annotation.
   #: @Test(mytest3 should be ok)
   mytest3() {
     run echo "mytest3"
     [ "$result" = "mytest3" ]
   }

All functions of the above are tests. Tests are executed in written order in a file.

Test Context
============

Each test runs in subshell. This means that you cannot read variables or functions defined in other tests.

Here is a example.

.. code-block:: bash

   test_1() {
     MY_VAR=1
     [ $MY_VAR -eq 1 ]
   }

   test_2() {
     [ $MY_VAR -eq 1 ] # This test should be failed.
   }

``MY_VAR`` defined in ``test_1`` cannot be read from ``test_2``, and ``test_2`` will fail.

To set up a test and clean up a test, you can use ``@BeforeEach`` and ``@BeforeAfter`` annotations. The functions specified with these annotations are executed before a test starts or after a test ends.

.. code-block:: bash

   #: @BeforeEach
   setup() {
     MY_VAR=1
     echo "hello" > flagfile
   }

   test_1() {
     run cat flagfile
     [ $MY_VAR -eq 1 ]
     [ "$result" = "hello" ]
   }

   test_2() {
     run cat flagfile
     [ $MY_VAR -eq 1 ]
     [ "${lines[0]}" = "hello" ]
   }

   #: @AfterEach
   teardown() {
     MY_VAR=1
     rm flagfile
   }

``setup`` function is executed in the same context as ``test_1`` and ``test_2``, so ``MY_VAR`` defined in ``setup`` is visible from ``test_1`` and ``test_2``. ``setup`` and ``teardown`` functions are called for each test.

There may be when you want to read variables from all tests, in that case you can use ``@BeforeAll`` or ``@AfterAll`` annotations. Variables, which are defined in the functions specified with these annotations, can be read from all test functions.

.. code-block:: bash

   EVALUATED_ONCE="var"

   #: @BeforeAll
   setup_all() {
     GLOBAL_VAR="global"
   }

   test_3() {
     [ "$GLOBAL_VAR" = "global" ]
   }

   #: @AfterAll
   teardown_all() {
     : # Nothing
   }

``setup_all`` function with ``@BeforeAll`` annotation is called only once before all tests start, and ``teardown_all`` function with ``@AfterAll`` annotation is called only once after all tests ends. These functions are executed in parent shell of tests, ``GLOBAL_VAR`` is visible from all tests. Outside of functions, ``EVALUATED_ONCE`` is also evaluated once with ``source`` command.


Commands
========

run
---

.. code-block:: bash

   run <command>

``run`` executes the specified command  in subshell. You can get its output with ``$result``, and get the exit status code with ``$status``. And also you can use ``$lines``, you can access each line with ``${lines[0]}``.

.. code-block:: bash

   test_run() {
     run echo "hoge"
     [ "$result" = "hoge" ]
     [ $status -eq 0 ]
     [ "${lines[0]}" = "hoge" ]
   }


run2
----

.. code-block:: bash

   run2 <command>

``run2`` executes the specified command in subshell as ``run``, but you can separately get its output with ``$stdout`` and ``$stderr``. Then the exit status code can be read with ``$status``. If you separately handle each line of output, you can access each line with ``${stdout_lines[0]}`` or ``${stderr_lines[0]}``.

This is a small script.

.. code-block:: bash

   # hello.sh
   echo "hello"
   echo "world" >&2

You can use ``run2`` as the following.

.. code-block:: bash

   test_run() {
     run2 ./hello.sh
     [ "$stdout" = "hello" ]
     [ "${stdout_lines[0]}" = "hello" ]
     [ $status -eq 0 ]
     [ "$stderr" = "world" ]
     [ "${stderr_lines[0]}" = "world" ]
   }


eval2
-----

.. code-block:: bash

   eval2 <command>

``eval2`` executes the specifiled commans with ``eval`` command. You can get output or exit status code as ``run2``.

.. code-block:: bash

   test_eval2() {
     eval2 'echo "hello" >&2'
     [ $status -eq 0 ]
     [ "$stdout" = "" ]
     [ "$stderr" = "hello" ]
     [ "${stderr_lines[0]}" = "hello" ]
   }

fail
----

.. code-block:: bash

   fail [<text>]

``fail`` makes a test fail.

.. code-block:: bash

   test_fail() {
     fail "Not implemented"
   }

skip
----

.. code-block:: bash

   skip [<text>]

``skip`` skips the rest codes after it.

.. code-block:: bash

   test_skip() {
     if [ -e flagfile ]; then
       skip "found flagfile, so we skip."
     fi
     echo "If flagfile exists, not reach here."
   }


Annotations
===========

An annotation line needs to start with ``#:``, ``#`` is interpreted just as a comment.

@BeforeAll
----------

.. code-block:: bash

   #: @BeforeAll

A function with ``@BeforeAll`` is executed **only once** before all tests start. You can specify this annotation for multiple functions, and those functions will be executed in written order.

.. code-block:: bash

   # (1)
   #: @BeforeAll
   setup_all1() {
     GLOBAL_VAR1=10
   }

   # (2)
   #: @BeforeAll
   setup_all2() {
     export PATH=/usr/local/bin:"$PATH"
   }


@BeforeEach
-----------

.. code-block:: bash

   #: @BeforeEach

A function with ``@BeforeEach`` is executed before a test starts, the function is called **for each test**. You can specify this annotation for multiple functions, and those functions will be executed in written order.

.. code-block:: bash

   #: @BeforeEach
   setup1() {
     touch flagfile
   }

   #: @BeforeEach
   setup2() {
     TEST_VAR2=20
   }


@Test
---------------

.. code-block:: bash

   #: @Test[(<text>)]

A function with ``@Test`` is regarded as a test. You can also tell Baut by writing a function name starts with ``test_``. If you write ``<text>`` after ``@Test`` annotation, the text will be displayed as a test name in a test report.

.. code-block:: bash

   #: @Test(This test should be absolutely passed)
   test_passed() {
     [ 1 -eq 1 ]
   }

Here is the result.

.. code-block:: bash

   $ baut run test_sample.sh
   1 file, 1 test
   #1 /Users/guest/workspace/baut/test_hoge.sh
   o This test should be absolutely passed
   1 test, 1 ok, 0 failed, 0 skipped

   1 file, 1 test, 1 ok, 0 failed, 0 skipped
   Time: 0 hour, 0 minute, 0 second

@TODO
-----

.. code-block:: bash

   #: @TODO[(<text>)]

A function with ``@TODO`` is regarded as a test. If you write ``<text>`` after ``@TODO`` annotation, a result of a test will be displayed with ``# TODO <text>`` tag in a test report.


@Ignore
-------

.. code-block:: bash

   #: @Ignore

A test function with ``@Ignore``  is absolutelly ignored.


@Deprecated
-----------

.. code-block:: bash

   #: @Deprecated[(<text>)]

A function with ``@Deprecated`` is regarded as a test. If you write ``<text>`` after ``@Deprecated`` annotation, a result of a test will be displayed with ``# DEPRECATED <text>`` tag in a test report.


@AfterEach
----------

.. code-block:: bash

   #: @AfterEach

A function with ``@AfterEach`` is executed after a test ends, the function is called **for each test**. You can specify this annotation for multiple functions, and those functions will be executed in written order.

.. code-block:: bash

   #: @AfterEach
   teardown() {
     rm flagfile ||:
   }

@AfterAll
---------

.. code-block:: bash

   #: @AfterAll

A function with ``@AfterAll`` is executed **only once** after all tests ends. You can specify this annotation for multiple functions, and those functions will be executed in written order.

.. code-block:: bash

   #: @AfterAll
   teardown_all() {
     rm "$TMPDIR/*.tmp" ||:
   }


Common Variables
================

``BAUT_TEST_FUNCTION_NAME``

``BAUT_TEST_FILE``

``BAUT_TEST_FUNCTIONS``

``before_all_functions`` (Array)

``before_each_functions`` (Array)

``after_all_functions`` (Array)

``after_each_functions`` (Array)


Other APIs
==========

load
----

**load <file> [<arg> ...]**

Loads the file with the specified arguments. This calls ``source`` command internally. If the file does not exist, it will abort. You can load the file multiple times.

**load_if_exists <file> [<arg> ...]**

Loads the file with the specified arguments. This calls ``source`` command internally. If the file does not exist, it will return ``1``. You can load the file multiple times.

**require <file> [<arg> ...]**

Loads the file with the specified arguments. This calls ``source`` command internally. If the file does not exist, it will abort. You can load the file multiple times, but if the file has already been loaded, it will not be loaded again.


.. code-block:: bash

   # Load configurations.
   load "conf.sh" "arg1"
   # At first, load optional settings. But if it does not be found, we load default settings.
   load_if_exists "options.sh" || load "default.sh"
   # Load 'mylib' only once.
   require "mylib.sh"


log
---

These functions can be used for debug, and you can control which level of message is output with ``--d[0-4]`` option or ``BAUT_LOG_LEVEL`` variable.

**Syntax**

.. code-block:: bash

   log_trace <text>
   log_debug <text>
   log_info <text>
   log_warn <text>
   log_error <text>

**Examples**

.. code-block:: bash

   log_trace "Level trace"
   log_debug "Level debug"
   log_info  "Level info"
   log_warn  "Level warn"
   log_error "Level error"


Here is a example in a test.

.. code-block:: bash

   # test_log.sh
   test_log() {
     run echo "sample"
     if [ $status -eq 0 ]; then
       log_info "status code is ok."
     else
       log_error "status code is not ok."
       fail
     fi
   }

You can run tests with ``--d[0-4]`` log option, and this option must be put before ``run`` command.

.. code-block:: bash

   $ baut --d1 run test_log.sh
   1 file, 1 test
   #1 /Users/guest/workspace/baut/test_log.sh
   o test_log
   2017-10-01 00:30:10 [INFO] test_log.sh:4 - status code is ok.
   1 test, 1 ok, 0 failed, 0 skipped

   1 file, 1 test, 1 ok, 0 failed, 0 skipped
   Time: 0 hour, 0 minute, 0 second



trap
----

**add_trap_callback <signame> <command>**

Adds a command to a callback chain of signame. The function added later is executed first. In this example, ``rm flagfile`` is executed, and then ``echo "done"``.

.. code-block:: bash

   add_trap_callback "EXIT" echo "done"
   add_trap_callback "EXIT" rm flagfile

**reset_trap_callback [<signame> ...]**

Removes existing commands from callback chains of the specified signals. This function removes commands. but does not remove the already registered trap entries.

.. code-block:: bash

   reset_trap_callback "EXIT" "ERR"

**register_trap_ballback [<signame> ...]**

Registers traps of the specified signals. This function is usually used with ``add_trap_callback`` function.

.. code-block:: bash

   add_trap_callback "EXIT" rm "flagfile"
   register_trap_callback "EXIT"

**unregister_trap_ballback [<signame> ...]**

Unregisters traps of the specified signals.

.. code-block:: bash

   unregister_trap_callback "EXIT"

**enable_trap [<signame> ...]**

Enables traps of the specified signals. This function just switches on/off of trap, the existing trap commands remain.

**disable_trap [<signame> ...]**

Disables traps of the specified signals. This function just switches on/off of trap, the existing trap commands remain.

.. code-block:: bash

   disable_trap "ERR"
   {
     echo "do something"
   }
   enable_trap "ERR"


Others
------

**hash_get <key> [<key> ...]**

Returns the value with the specified keys.

**hash_set <key> [<key> ...] <value>**

Sets the value with the specified keys.

**hash_delete <key> [<key> ...]**

Deletes the entry with the specified keys.

.. code-block:: bash

   hash_set "namespace" "key" "value"
   hash_get "namespace" "key" #=> value
   hash_delete "namespace" "key"

**get_comment_block <file> <ident>**

Extracts the comment block with the specified ident from the file.

.. code-block:: bash

   # test_my.sh
   get_comment_block "$(__FILE__)" "HELP"  #=> This is a help comment.

   #=begin HELP
   #
   # This is a help comment.
   #
   #=end HELP

**self_comment_block <ident>**

Extracts the comment block with the specified ident from the written file.

.. code-block:: bash

   # test_my.sh
   self_comment_block "HELP"  #=> This is a help comment.

   #=begin HELP
   #
   # This is a help comment.
   #
   #=end HELP
