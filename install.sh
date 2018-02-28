#!/usr/bin/env bash
#
# source install.sh or sh install.sh
#

function __install_baut() {
  local HERE="$(cd -P -- "$(dirname -- "${BASH_SOURCE:-$0}")" && pwd -P)"
  local BASH_PROFILE=~/.bash_profile
  sed -i -e '/### start baut/,/### end baut/d' "$BASH_PROFILE"

  cat <<EOS >> "$BASH_PROFILE"
### start baut
export PATH="$HERE/bin":"\$PATH"
### end baut
EOS
  source "$BASH_PROFILE"
}

__install_baut
unset -f __install_baut
