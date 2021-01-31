# Lyrics Printer

Lyrics Printer is a set of scripts to download and format song lyrics for printing. These scripts are for my personal use and have very little validation and error handling. Feel free to use them at your own expense.

The expected input is a semicolon-separated CSV file containing song title, artist, transposition, capo position and chords, which will be included with the printable lyrics. A sample `songlist.csv` file is supplied for convenience.

## Usage

Here is a typical usage example:

```
# Installs required dependencies.
./setup.sh

mkdir output

# Downloads the song lyrics and metadata from Genius.
export GENIUS_ACCESS_TOKEN="<YOUR GENIUS CLIENT ACCESS TOKEN>"
./download-lyrics.sh songlist.csv output/

# Generates intermediate Markdown and PDF files for printing.
./format-lyrics.sh output/ output/

# Optionally, merge all PDF files into one.
pdftk output/*.pdf cat output songbook.pdf
```

If the download exits prematurely because of an error (usually because the song is not found in Genius by the supplied title and artist strings) the download can be resumed from the offending song after the pertinent modifications by using the `-s` flag with the line number of the song in the CSV file minus two. More information:

```
Usage: ./download-lyrics.sh [-h] [-d] [-s NUMBER] input_file [output_dir]
  -s NUMBER  Skip downloading the first NUMBER songs
  -d         Run in dry run mode to verify songs before download
  -h         Show this usage message
```

## Acknowledgements

These scripts rely on [LyricsGenius](https://github.com/johnwmillr/LyricsGenius) to download the lyrics from the [Genius API](https://genius.com/api-clients) and [Pandoc](https://pandoc.org/) to print them.
