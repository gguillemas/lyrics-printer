# Lyrics Printer

Lyrics Printer is a set of scripts to download and format song lyrics for printing.

## Usage

Here is an example of a typical usage:

```
# Installs required dependencies.
./setup.sh

# Example songlist in the required CSV format.
echo << EOF > songlist.csv
You Give Me Something;James Morrisson
You Know My Name;Chris Cornell
You Were Meant For Me;Jewel
Youth;Daughter
EOF

mkdir output

# Downloads the song lyrics and metadata from Genius.
export GENIUS_ACCESS_TOKEN="<YOUR GENIUS CLIENT ACCESS TOKEN>"
./download-lyrics.sh songlist.csv output/

# Generates intermediate Markdown and PDF files for printing.
./format-lyrics.sh output/ output/

# Optionally, merge all PDF files into one.
pdftk output/*.pdf cat output songbook.pdf
````

## Acknowledgements

These scripts rely on [LyricsGenius](https://github.com/johnwmillr/LyricsGenius) to download the lyrics from the [Genius API](https://genius.com/api-clients) and [Pandoc](https://pandoc.org/) to print them.
