#!/usr/bin/env bash
#
# Run test suite for baut.
#
set -eu
BAUT_ROOT="$(cd -P -- "$(dirname -- "${BASH_SOURCE:-$0}")" && pwd -P)"
BAUT_LIBEXEC="$BAUT_ROOT/libexec"

print_label() {
  text_color_on 3 "" 1
  log_info "$@"
  text_color_off
}

source "$BAUT_LIBEXEC/baut--load"

# Target plagforms to do test.
# We assume that virtual machines are running on vagrant.
# So, at first, tap 'vagrant up'.
TARGET_PLATFORMS=(centos7 ubuntu)

# Do test on current platform.
print_label "==> Run test suite on current platform"
"$BAUT_ROOT"/bin/baut r --no-debug test

# Do test on target machines.
for pf in ${TARGET_PLATFORMS[@]}; do
  print_label "==> Run test suite on $pf"
  vagrant ssh -c "cd /vagrant && ./bin/baut run --no-debug test" $pf
done
