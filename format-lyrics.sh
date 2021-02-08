#!/bin/bash

set -e

usage() {
  echo "Usage: $0 [-h] [-i] [-a author] [-k output_dir] input_dir"
  echo "  -k OUTPUT_DIR  Keep temporary files in directory"
  echo "  -a AUTHOR      Name of author to put on the cover"
  echo "  -h             Show this usage message"
}

while getopts 'hka:' flag; do
  case ${flag} in
    k) output_dir=${OPTARG}; echo "Keeping temporary files." ;;
    a) author=${OPTARG};;
    h) usage; exit 0 ;;
    ?) usage; exit 1 ;;
  esac
done

shift $(($OPTIND - 1))
remaining_args="$@"

if [ $# -ne 1 ]; then
  usage
  exit 1
fi

input_dir="$1"
index_name="000Index"
songbook_name="Songbook"

if [[ -z "$output_dir" ]]; then
  output_dir=$(mktemp -d)
  echo "Reading from \"$input_dir\"."
else
  echo "Reading from \"$input_dir\" and writing to \"$output_dir\"."
fi

header=$(cat <<-EOF
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
    - \pagenumbering{gobble}
    - \setlength{\columnsep}{24pt}
    - \setlength{\parskip}{0.2em}
    - \newcommand{\hideFromPandoc}[1]{#1}
    - \hideFromPandoc{
        \let\Begin\begin
        \let\End\end
      }

...
EOF
)

utf8_to_ascii() {
  perl -CSD -pe "s/[^\p{Word}\p{Punct}\p{Symbol}\p{Mark}\p{PerlSpace}]//gu" | konwert utf8-ascii
}

i=1
for file in $input_dir/*.json; do
  title=$(cat $file | jq -r '.title' | utf8_to_ascii)
  artist=$(cat $file | jq -r '.artist' | utf8_to_ascii)
  transp=$(cat $file | jq -r '.transp' | utf8_to_ascii)
  capo=$(cat $file | jq -r '.capo' | utf8_to_ascii)
  chords=$(cat $file | jq -r '.chords' | utf8_to_ascii)

  echo "Processing \"$title\" by $artist."

  fileprefix="$output_dir/$artist - $title"

  cat << EOF > "$fileprefix.md"
$header

$title
==============

$artist
--------------

\Begin{multicols}{2}

**Transposed:** $transp | **Capo:** $capo

**Chords:**

$(echo $chords | sed -z 's/ \/ /\n\n/g')

\ 

$(cat $file | jq -r '.lyrics' | sed -z 's/\n\n/\n\\ \n/g' | sed -z 's/\n/\n\n/g' | utf8_to_ascii)

\End{multicols}
EOF

  pandoc --wrap=preserve "$fileprefix.md" -o "$fileprefix.pdf"
  
  i=$((i+1))
done

cat << EOF > "$output_dir/$index_name.md"
$header

\Begin{center}

Songbook
==============

$author
--------------

\End{center}
\clearpage

Index
==============

\Begin{multicols}{2}

$(LC_COLLATE=en_US.utf8 ls $output_dir/*.pdf | grep -Po '[^/]*?(?=\.pdf)' | sed -z 's/\n/\n\n/g')

\End{multicols}
EOF

pandoc --wrap=preserve "$output_dir/$index_name.md" -o "$output_dir/$index_name.pdf"

ls -v "$output_dir"/*.pdf | bash -c 'IFS=$'"'"'\n'"'"' read -d "" -ra x;pdfunite "${x[@]}" '$songbook_name'.pdf'

echo "Songbook saved as \"$songbook_name.pdf\"."
