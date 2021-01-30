#!/bin/bash

[ $# -ne 2 ]; then
  echo "Usage: $0 input_file output_dir"
  exit 1
fi

input="$1"
output="$2"
while IFS= read -r line; do
  song=$(echo $line | cut -f1 -d ';')
  artist=$(echo $line | cut -f2 -d ';')
  python3 -m lyricsgenius song "$song" "$artist" --save
done < "$input"
