#!/bin/bash

# Sundell-fork variant of Scripts/header.sh.
#
# Same skeleton as the standard BrightDigit header.sh (arg parsing, find loop,
# Generated/ + swift-format-ignore skips, idempotent prepend) — the only
# difference is the header TEXT: this emits John Sundell's compact `/** */`
# block instead of the BrightDigit MIT block, so his attribution is preserved.
#
# Used ONLY by the three Sundell forks (Plot / Files / Ink). Invoke with the
# original author as creator and each repo's latest copyright year, e.g.:
#   ./Scripts/header.sh -d Sources -c "John Sundell" -o "John Sundell" -p "Plot"  -y 2021
#   ./Scripts/header.sh -d Sources -c "John Sundell" -o "John Sundell" -p "Ink"   -y 2020
#   ./Scripts/header.sh -d Sources -c "John Sundell" -o "John Sundell" -p "Files" -y 2019

# Function to print usage
usage() {
  echo "Usage: $0 -d directory -c creator -o company -p package [-y year]"
  echo "  -d directory  Directory to read from (including subdirectories)"
  echo "  -c creator    Name of the creator"
  echo "  -o company    Name of the company with the copyright"
  echo "  -p package    Package or library name"
  echo "  -y year       Copyright year (optional, defaults to current year)"
  exit 1
}

# Get the current year if not provided
current_year=$(date +"%Y")

# Default values
year="$current_year"

# Parse arguments
while getopts ":d:c:o:p:y:" opt; do
  case $opt in
    d) directory="$OPTARG" ;;
    c) creator="$OPTARG" ;;
    o) company="$OPTARG" ;;
    p) package="$OPTARG" ;;
    y) year="$OPTARG" ;;
    *) usage ;;
  esac
done

# Check for mandatory arguments
if [ -z "$directory" ] || [ -z "$creator" ] || [ -z "$company" ] || [ -z "$package" ]; then
  usage
fi

# Define the header template — John Sundell's compact block.
# (company/-o is parsed for arg parity with the standard script but unused here.)
header_template="/**
*  %s
*  Copyright (c) %s %s
*  MIT license, see LICENSE file for details
*/"

# Loop through each Swift file in the specified directory and subdirectories
find "$directory" -type f -name "*.swift" | while read -r file; do
  # Skip files in the Generated directory
  if [[ "$file" == *"/Generated/"* ]]; then
    echo "Skipping $file (generated file)"
    continue
  fi

  # Check if the first line is the swift-format-ignore indicator
  first_line=$(head -n 1 "$file")
  if [[ "$first_line" == "// swift-format-ignore-file" ]]; then
    echo "Skipping $file due to swift-format-ignore directive."
    continue
  fi

  # Create the header (package, creator, year)
  header=$(printf "$header_template" "$package" "$creator" "$year")

  # Remove the leading license comment, then prepend the fresh one. Strips the
  # FIRST leading `/* ... */` block (the license — covers Plot/Ink `/**`,
  # including inner "#40:" annotation lines) plus leading "// " / "//" line
  # comments (Files' "//" license) and blank lines, up to the first real line.
  # It deliberately does NOT strip "///" doc comments or a SECOND comment block
  # (a `/**`-style doc): a `block_done` guard limits block stripping to the
  # license only, and the "//" patterns exclude "///". This preserves the API
  # doc comments that sit between the header and the first declaration —
  # otherwise swift-format's AllPublicDeclarationsHaveDocumentation rule fails.
  # Idempotent (running twice produces no diff).
  awk '
  BEGIN { skip = 1; in_block = 0; block_done = 0 }
  {
    if (in_block) {
      if ($0 ~ /\*\//) { in_block = 0 }
      next
    }
    if (skip) {
      if (block_done == 0 && $0 ~ /^[[:space:]]*\/\*/) {
        block_done = 1
        if ($0 !~ /\*\//) { in_block = 1 }
        next
      }
      if ($0 ~ /^\/\/ / || $0 ~ /^\/\/$/ || $0 ~ /^$/) { next }
    }
    skip = 0
    print
  }' "$file" > temp_file

  # Add the header to the cleaned file
  (echo "$header"; echo; cat temp_file) > "$file"

  # Remove the temporary file
  rm temp_file
done

echo "Sundell headers added or files skipped appropriately across all Swift files in the directory and subdirectories."
