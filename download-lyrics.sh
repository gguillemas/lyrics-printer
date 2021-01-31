#!/bin/bash

set -e

usage() {
  echo "Usage: $0 [-h] [-d] [-s NUMBER] input_file [output_dir]"
  echo "  -s NUMBER  Skip downloading the first NUMBER songs"
  echo "  -d         Run in dry run mode to verify songs before download"
  echo "  -h         Show this usage message"
}

skip=2
while getopts 'hds:' flag; do 
  case ${flag} in
    d) dry=1 ;;
    s) skip=${OPTARG}; echo "Skipping first $skip songs." ;;
    h) usage; exit 0 ;;
    ?) usage; exit 1 ;;
  esac
done

shift $(($OPTIND - 1))
remaining_args="$@"

input="$1"
output="$2"

echo "Reading from \"$input\" and writing to \"$output\"."

tail -n +$(($skip + 2)) "$input" | {
while IFS= read -r line; do
  song="$(echo $line | cut -f1 -d ';')"
  artist="$(echo $line | cut -f2 -d ';')"
  transp="$(echo $line | cut -f3 -d ';')"
  capo="$(echo $line | cut -f4 -d ';')"
  chords="$(echo $line | cut -f5 -d ';')"
  if [[ $dry -eq 1 ]]; then
    python3 -m lyricsgenius song "$song" "$artist"
  else
    echo "Downloading \"$song\" by $artist..."
    lyrics=$(python3 -m lyricsgenius song "$song" "$artist" --save | grep -oP '\S*.json')
    cat $lyrics | jq \
	    --arg capo "$capo" \
	    --arg transp "$transp" \
	    --arg chords "$chords" \
	    '. + {capo: $capo, transp: $transp, chords: $chords}' > $output/$lyrics
    rm $lyrics
  fi
done || echo "Error downloading \"$song\" by $artist!" 
}
