#!/usr/bin/env bash

# This definition overwrites existing definition of the function that has same name,
# we need this for test...
endpoint_is_terminal() {
  return 0
}

test_text_color_on() {
  run text_color_on 2 ""
  [ "$result" = "$(printf "\033[32m")" ]
  run text_color_off
}

test_text_color_off() {
  run text_color_off
  [ "$result" = "$(printf "\033[m")" ]
}

test_text_color() {
  run text_color "hoge" 2 ""
  [ "$result" = "$(printf "\033[32mhoge\033[m")" ]
  run text_color_off
}
