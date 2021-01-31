#!/bin/bash

set -e

sudo apt install python3 python3-pip pdftk konwert \
  pandoc texlive-latex-base texlive-fonts-recommended texlive-extra-utils texlive-latex-extra
pip install git+https://github.com/johnwmillr/LyricsGenius.git
