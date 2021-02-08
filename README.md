# Lyrics Printer

Lyrics Printer is a set of scripts to download and format song lyrics with chords in print for practice and performance.

The expected input is a semicolon-separated CSV file containing song title, artist, transposition, capo position and chords. A sample `songlist.csv` file is supplied for convenience. Running the scripts as shown below will result in a **single PDF file containing lyrics for each song along with the supplied chords** and performance information.

These scripts were developed for my own use and have very little validation and error handling.

## Usage

Here is a typical usage example:

```
# Installs required dependencies.
./setup.sh

mkdir output

# Downloads the song lyrics and metadata from Genius.
export GENIUS_ACCESS_TOKEN="<YOUR GENIUS CLIENT ACCESS TOKEN>"
./download-lyrics.sh songlist.csv output/

# Generates the songbook with your name in the cover.
./format-lyrics.sh -a "John Doe" output/

# Preview songbook with your preferred application.
xdg-open Songbook.pdf
```

If the download exits prematurely because of an error (usually because the song is not found in Genius by the supplied title and artist strings) the download can be resumed from the offending song after the pertinent modifications by using the `-s` flag with the line number of the song in the CSV file minus two. More detailed usage information below.

Usage information for `download-lyrics.sh`:

```
Usage: ./download-lyrics.sh [-h] [-d] [-s NUMBER] input_file [output_dir]
  -s NUMBER  Skip downloading the first NUMBER songs
  -d         Run in dry run mode to verify songs before download
  -h         Show this usage message
```

Usage information for `format-lyrics.sh`:

```
Usage: format-lyrics.sh [-h] [-i] [-a author] [-k output_dir] input_dir
  -k OUTPUT_DIR  Keep temporary files in directory
  -a AUTHOR      Name of author to put on the cover
  -h             Show this usage message
```

## Acknowledgements

These scripts rely on [LyricsGenius](https://github.com/johnwmillr/LyricsGenius) to download the lyrics from the [Genius API](https://genius.com/api-clients) and [Pandoc](https://pandoc.org/) to print them.
