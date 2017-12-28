=============
Running Tests
=============

To run tests, you need to execute ``run`` command with files or directories.

.. code-block:: bash

   $ baut run <file or directory> [<file or directory> ...]

``run`` takes files or directories and executes them in order. If directories are passed, Baut will find test files under the directories. With ``-r`` option, Baut finds test target files recursively under the directories.

.. code-block:: bash

   $ baut run -r directory

Commands
========

run(r)
------

You can run tests with ``run`` command, and its command takes some options.

``-r, --recursively``

Baut finds test target files recursively under the specified directories.

``-s, --stop-on-error``

Baut stops test process when a test fails.

``--no-color``

A test report will not be colored.

``--no-checksum``

Baut does not verify checksum of compiled test files.

``-f, --format [oneline|default|tap|cat]``

You can get a test report with various formats with this option. Default is ``default``. ``tap`` is Test Anything Protocol. (For more detail, see https://testanything.org)

``-m, --match <regex>``

Executes only functions that match the specified value.

.. code-block:: bash

   $ baut run -m "option" test_command.sh

``-i, --interactive``

Run tests in interactive mode.


compile(c)
----------

``compile`` converts a test script into the baut test file. This command is called in ``run`` command process, so you will not need to call explicitly ``compile`` command.

.. code-block:: bash

   $ baut compile test_sample.sh > test_sample.baut
   $ baut test test_sample.baut | baut report


report(R)
---------

``report`` command receives data from the starndard input, formats the result of test.

.. code-block:: bash

   $ baut compile test_sample.sh > test_sample.baut
   $ baut test test_sample.baut | baut report

``report`` command can interpret the following messages as a special message.

``#:RDY;<file_num>\t<test_num>``

This message is sent at the begin of all tests.

``#:STR;<baut_file>\t<test_file>\t<test_num>``

This message is sent at the begin of a test set.

``#:END;<baut_file>\t<test_file>``

This message is sent at the end of a test set.

``#:STRT;<test_function>[\t<alias_name>]``

This message is sent at the begin of a test.

``#:STRTDT;<todo>\t<test_function>[\t<alias_name>]``

This message is sent at the begin of a todo test.

``#:ENDT;<test_function>\t<exit_status>``

This message is sent at the end of a test.

``#:OK;<test_function>``

This message is sent when a test has ended successfully.

``#:ERR;<test_function>``

This message is sent when a test failed.

``#:SKP;<test_function>[\t<message>]``

This message is sent when a test has been skipped.

``#:DPR;<test_function>[\t<message>]``

This message is sent before a deprecated test begins.

``#:ERR0;<test_function>``

This message is sent when a critical error occurred.

``#:STP;<baut_fuke>\t<test_file>[\t<test_function>]``

This message is sent when test process is stopped.


This example shows a cycle of running test.

.. code-block:: bash

   $ cat report.txt
   #:RDY;1	1
   #:STR;hoge.baut	hoge.sh	1
   #:STRT;test_foo	alias_name
   #:OK;test_foo
   #:ENDT;test_foo	0
   #:END;hoge.baut	hoge.sh
   #:TIME;total test time
   $ cat report.txt | baut report
   1 file, 1 test
   #1 hoge.sh
   o alias_name
   #$ 1 test, 1 ok, 0 failed, 0 skipped

   🎉  1 file, 1 test, 1 ok, 0 failed, 0 skipped
   Time: total test time
