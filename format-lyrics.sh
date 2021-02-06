#!/bin/bash

set -e

utf8_to_ascii() {
  perl -CSD -pe "s/[^\p{Word}\p{Punct}\p{Symbol}\p{Mark}\p{PerlSpace}]//gu" | konwert utf8-ascii
}

if [ $# -ne 2 ]; then
  echo "Usage: $0 input_dir output_dir"
  exit 1
fi

input="$1"
output="$2"

echo "Reading from \"$input\" and writing to \"$output\"."

for file in $input/*.json; do
  title=$(cat $file | jq -r '.title' | utf8_to_ascii )
  artist=$(cat $file | jq -r '.artist' | utf8_to_ascii )
  transp=$(cat $file | jq -r '.transp' | utf8_to_ascii )
  capo=$(cat $file | jq -r '.capo' | utf8_to_ascii )
  chords=$(cat $file | jq -r '.chords' | utf8_to_ascii )

  cat << EOF > "$output/$title - $artist.md"
---
papersize: a4
documentclass: article 
fontsize: 12pt
fontfamily: libertine 
linestretch: 1.0
header-includes:
    - \usepackage{multicol}
    - \usepackage[utf8]{inputenc}
    - \usepackage[a4paper, margin=2.0cm, headsep=1pt]{geometry}
    - \setlength{\columnsep}{24pt}
    - \setlength{\parskip}{0.2em}
    - \newcommand{\hideFromPandoc}[1]{#1}
    - \hideFromPandoc{
        \let\Begin\begin
        \let\End\end
      }

...

$title
==============

$artist
--------------

\Begin{multicols}{2}

**Transposed:** $transp | **Capo:** $capo

**Chords:**

$(echo $chords | sed -z 's/ \/ /\n\n/g')

\ 

$(cat $file | jq -r '.lyrics' | sed -z 's/\n\n/\n\\ \n/g' | sed -z 's/\n/\n\n/g' | utf8_to_ascii )

\End{multicols}
EOF

  echo "Wrote lyrics to: $output/$title - $artist.md"

  pandoc --wrap=preserve "$output/$title - $artist.md" -o "$output/$title - $artist.pdf"
  
  echo "Printed lyrics to: $output/$title - $artist.pdf"
done
