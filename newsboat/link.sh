#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./link.sh

Symlink the newsboat urls to this github repository

'
    exit
fi

main() {
  if [[ ! -d "$HOME/.newsboat" ]]
    then
      mkdir "$HOME/.newsboat"
      ln -s "$PWD/newsboat/urls" "$HOME/.newsboat/urls"
  fi

  if [[ ! -f "$HOME/.newsboat/urls" ]]
    then
      ln -s "$PWD/newsboat/urls" "$HOME/.newsboat/urls"
    else
      rm "$HOME/.newsboat/urls"
      ln -s "$PWD/newsboat/urls" "$HOME/.newsboat/urls"
  fi
  if [[ ! -f "$HOME/.newsboat/config" ]]
    then
      ln -s "$PWD/newsboat/config" "$HOME/.newsboat/config"
    else
      rm "$HOME/.newsboat/config"
      ln -s "$PWD/newsboat/config" "$HOME/.newsboat/config"
  fi
}

main "$@"