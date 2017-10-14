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

run
---

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


compile
-------

``compile`` converts a test script into the baut test file. This command is called in ``run`` command process, so you will not call explicitly ``compile`` command.
