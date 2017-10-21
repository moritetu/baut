#!/usr/bin/env bash


#: @BeforeAll
setup_all() {
  log_warn "==> boot redis"
  redis-server &>/dev/null &
  #redis-server --port 7777
  #redis-server --port 7777 --slaveof localhost 8888
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
