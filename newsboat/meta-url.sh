#!/usr/bin/env zsh

set -o errexit
set -o nounset
set -e
# set -x
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./feed-meta.sh

Add feed metadata to the end of the RSS link in urls file for newsboat

'
    exit
fi

main() {
  # Ensure that file is linked
  $PWD/newsboat/link.sh

  # Create backup of URLS directory
  rm -f "$PWD/newsboat/urls.bak" && cp "$PWD/newsboat/urls" "$PWD/newsboat/urls.bak"

  # Create temp file for url writing
  rm -f "$PWD/newsboat/urls_tmp" && touch "$PWD/newsboat/urls_tmp"

  echo "Writing metadata to url files\r"

  for i in $(cat "$PWD/newsboat/urls" | cut -f1 -d"#") # strip away comments
  do
    # TODO: handling for when the curl request fails
    # TODO: Output new URL if redirected due to 301 HTTP status
    rss_yt=$(curl -sSL $i | xmlstarlet sel -t -v "//*[local-name()='feed']/*[local-name()='title']/text()" -n)
    rss_2=$(curl -sSL $i | xmlstarlet sel -t -v "//*[local-name()='channel']/*[local-name()='title']/text()" -n)
    atom_2=$(curl -sSL $i | xmlstarlet sel -t -v "//*[local-name()='rss']/*[local-name()='channel']/*[local-name()='title']/text()" -n)

    default=""
    rss_title=${rss_yt:-${rss_2:-atom_2:-default}} # if feed/title is not available, use channel/title, or rss/channel/title

    # Add url and title to file
    if [[ ! -z "${rss_title}" ]]
      then
        echo "$i # $rss_title" >> "$PWD/newsboat/urls_tmp"
        echo -ne ""
        echo -ne "Added metadata for $i\r"
      else
        echo -ne "No RSS title for $i\r"
    fi

  done

  echo -ne "Done adding metadata.                                                                    \r"
  echo -ne "\n"

  # Check if number of parse-able URLs is the same
  if [[ $(cat $PWD/newsboat/urls_tmp | wc -l) == $(cat $PWD/newsboat/urls.bak | wc -l) ]]
    then
      echo "No broken URLs, deleting backup"
      rm "$PWD/newsboat/urls.bak"
    else
      old=$(cat "$PWD/newsboat/urls.bak" | wc -l)
      new=$(cat "$PWD/newsboat/urls_tmp" | wc -l)
      difference=$(($old-$new))
      echo "There are $difference broken URLs, keeping backup"
  fi
  # Write to urls file
  if [[ -s "$PWD/newsboat/urls_tmp" ]]
    then
      echo "File is non-empty, writing to urls"
      rm "$PWD/newsboat/urls"
      cp "$PWD/newsboat/urls_tmp" "$PWD/newsboat/urls"
      rm "$PWD/newsboat/urls_tmp"
    else
      echo "File is empty, skipping"
  fi

}

main "$@"