Welcome to Baut's documentation!
================================

.. image:: _static/logo.png

Baut (Bash Unit test Tool) is a unit testing tool runs on Bash and helps you to verify that the programs on Unix/Linux
behave as expected.

Here is a example.

**test_sample.sh**

.. code-block:: bash

   #: @BeforeAll
   function setup_all() {
     echo "==> Called once at first"
   }

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
     echo "# Clean up a test."
   }

   #: @AfterAll
   function teardown_all() {
     echo "==> Called once at last"
   }

OK, we run tests.

.. code-block:: bash

   $ baut run test_sample.sh
   1 file, 1 test
   [1] /Users/guest/workspace/baut/test_sample.sh
   ==> Called once at first
   o The usage should be displayed when command line options are invalid
     # Clean up a test.
   ==> Called once at last
   1 test, 1 ok, 0 failed, 0 skipped

   1 file, 1 test, 1 ok, 0 failed, 0 skipped
   Time: 0 hour, 0 minute, 0 second

.. toctree::
   :caption: Table Of Contents
   :numbered:
   :maxdepth: 2

   Introduction
   Installation
   Writing Tests <WritingTests>
   Running Tests <RunningTests>
   Customization
