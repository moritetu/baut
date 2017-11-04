================
Sample Templates
================

By default, Baut source tree includes some templates.


PostgreSQL
==========

This template shows a test case like PostgresSQL regression test.

.. code-block:: bash

   $ baut init -t postgresql postgresql
   $ cd postgresql
   $ tree
   .
   ├── expected
   │   ├── test_count.out
   │   ├── test_from_file.out
   │   ├── test_limit.out
   │   ├── test_offset.out
   │   └── test_where.out
   ├── run-test.sh
   ├── sql
   │   └── test.sql
   └── test_sample.sh


There are expected results under ``expected`` directory, and actual results are written under ``results`` directory.

.. code-block:: bash

   $ cat test_sample.sh
   #!/usr/bin/env bash

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


``load 'diff-helper.sh'`` loads the helper which enables the execution of ``run_diff`` or ``run_diffx`` commands. The execution result is as follows.

.. code-block:: bash

   $ ./run-test.sh
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


MongoDB
=======

.. code-block:: bash

   $ baut init -t mongo mongo
   $ cd mongo
   $ tree
   .
   ├── expected
   │   └── test_query.out
   ├── run-test.sh
   └── test_sample.sh

.. code-block:: bash

   $ cat test_sample.sh
   #!/usr/bin/env bash

   load "diff-helper.sh"

   DBPATH="$(__DIR__)/data"
   LOGPATH="$(__DIR__)/logs"

   mkdir -p "$LOGPATH" "$DBPATH"

   #: @BeforeAll
   setup_all() {
     log_warn "==> start mongod"
     mongod --fork --dbpath="$DBPATH" --logpath="$LOGPATH/mongod.log"
   }


   #: @AfterAll
   after_all() {
     log_warn "==> shutdown mongod"
     mongo --quiet <<EOF
   use admin;
   db.shutdownServer();
   EOF
     rm -rf "$DBPATH"
   }

   #: @BeforeEach
   setup() {
     mongo --quiet <<EOF
   use test;
   for (var i = 0; i < 100; ++i) {
     db.users.insert({userid: i, username: "name-" + i});
   }
   EOF
   }

   #: @AfterEach
   teardown() {
     mongo --quiet <<EOF
   use test;
   db.users.remove({});
   EOF
   }

   test_query() {
     run_diffx mongo --quiet <<EOF
   use test;
   db.users.count();
   EOF
   }

.. code-block:: bash

   $ ./run-test.sh
   1 file, 1 test
   #1 /Users/guest/workspace/baut/mongo/test_sample.sh
   2017-11-04 10:32:43 [WARN] test_sample.sh:12 - ==> start mongod
   about to fork child process, waiting until server is ready for connections.
   forked process: 44517
   child process started successfully, parent exiting
   o test_query
     switched to db test
     WriteResult({ "nInserted" : 1 })
     switched to db test
     WriteResult({ "nRemoved" : 100 })
   2017-11-04 10:32:47 [WARN] test_sample.sh:19 - ==> shutdown mongod
   switched to db admin
   server should be down...
   2017-11-04T10:32:47.976+0900 I NETWORK  [thread1] trying reconnect to 127.0.0.1:27017 (127.0.0.1) failed
   2017-11-04T10:32:47.976+0900 W NETWORK  [thread1] Failed to connect to 127.0.0.1:27017, in(checking socket for error after poll), reason: Connection refused
   2017-11-04T10:32:47.976+0900 I NETWORK  [thread1] reconnect 127.0.0.1:27017 (127.0.0.1) failed failed
   #$ 1 test, 1 ok, 0 failed, 0 skipped

   🎉  1 file, 1 test, 1 ok, 0 failed, 0 skipped
   Time: 0 hour, 0 minute, 4 seconds



Redis
=====


.. code-block:: bash

   $ baut init -t redis redis
   $ cd redis
   $ cat test_sample.sh
   #!/usr/bin/env bash


   #: @BeforeAll
   setup_all() {
     log_warn "==> boot redis"
     redis-server &>/dev/null &
     REDISPID="$!"
     sleep 1
   }

   test_set_get() {
     run redis-cli SET key value
     [ "$result" = "OK" ]
     [ $status -eq 0 ]

     run redis-cli GET key
     [ "${lines[0]}" = "value" ]
     [ $status -eq 0 ]
   }

   #: @AfterAll
   after_all() {
     log_warn "==> shutdown redis"
     kill $REDISPID
   }


.. code-block:: bash

   $ ./run-test.sh
   1 file, 1 test
   #1 /Users/guest/workspace/baut/redis/test_sample.sh
   2017-11-04 22:35:26 [WARN] test_sample.sh:6 - ==> boot redis
   o test_set_get
   2017-11-04 22:35:27 [WARN] test_sample.sh:26 - ==> shutdown redis
   #$ 1 test, 1 ok, 0 failed, 0 skipped

   🎉  1 file, 1 test, 1 ok, 0 failed, 0 skipped
   Time: 0 hour, 0 minute, 1 second
