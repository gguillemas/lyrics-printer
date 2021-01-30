#!/bin/bash

if [ $# -ne 2 ]; then
  echo "Usage: $0 input_file output_dir"
  exit 1
fi

input="$1"
output="$2"

echo $input
echo $output

for file in $input/*.json; do
  title=$(cat $file | jq -r '.title' | perl -CSD -pe "s/[^\p{ASCII}]//gu")
  artist=$(cat $file | jq -r '.artist' | perl -CSD -pe "s/[^\p{ASCII}]//gu")

  cat << EOF > "$output/$title - $artist.md"
---
papersize: a4
documentclass: article 
fontsize: 12pt
fontfamily: charter
linestretch: 0.5
header-includes:
    - \usepackage{multicol}
    - \usepackage[utf8]{inputenc}
    - \usepackage[a4paper, margin=3.5cm, headsep=0cm]{geometry}
    - \setlength{\columnsep}{20pt}
    - \setlength{\parskip}{0.5em}
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

###

\Begin{multicols}{2}

$(cat $file | jq -r '.lyrics' | sed -z 's/\n\n/\n#### \n/g' | sed -z 's/\n/\n\n/g' | perl -CSD -pe "s/[^\p{ASCII}]//gu")

\End{multicols}
EOF

  echo "Wrote lyrics to: $output/$title - $artist.md"

  pandoc "$output/$title - $artist.md" -o "$output/$title - $artist.pdf"
  
  echo "Printed lyrics to: $output/$title - $artist.pdf"
done
