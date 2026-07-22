#!/bin/bash

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

# Define the header template
header_template="//
//  %s
//  %s
//
//  Created by %s.
//  Copyright © %s %s.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the \"Software\"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//"

# Fallback copyright year for this fork's upstream author, used only when a file's own
# header carries no parseable year. Plot/Ink originated in 2019; Files in 2017.
if [ "$package" = "Files" ]; then
  fork_year="2017-2019"
else
  fork_year="2019"
fi

# Upstream header for JohnSundell/Plot and JohnSundell/Ink — the compact /** block,
# reproduced verbatim from upstream. Args: %s = package name, %s = copyright year.
fork_header_template="/**
*  %s
*  Copyright (c) John Sundell %s
*  MIT license, see LICENSE file for details
*/"

# Upstream header for JohnSundell/Files — a /** block with the full MIT license text
# inline (leading-space prefix), reproduced verbatim from upstream. Arg: %s = year range.
files_header_template="/**
 *  Files
 *
 *  Copyright (c) %s John Sundell. Licensed under the MIT license, as follows:
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the \"Software\"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in all
 *  copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 *  SOFTWARE.
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

  # This is a fork of John Sundell's package. The MIT license requires the original
  # author's copyright notice to be preserved, so files carrying a Sundell copyright are
  # given the package's ORIGINAL upstream header (not the BrightDigit template). BrightDigit
  # fork credit lives in the NOTICE and README instead. This emit is idempotent: an
  # already-correct header re-renders byte-identically.
  if head -n 25 "$file" | grep -qi "Sundell"; then
    # Preserve the file's existing copyright year (Sundell's headers vary per file); fall
    # back to the package's original year only if none can be parsed.
    file_year=$(head -n 25 "$file" | grep -iE "Copyright .*John Sundell" \
      | grep -oE "[0-9]{4}(-[0-9]{4})?" | head -n 1)
    [ -n "$file_year" ] || file_year="$fork_year"

    if [ "$package" = "Files" ]; then
      # Upstream JohnSundell/Files uses a /** block with the full MIT license text inline.
      printf "$files_header_template" "$file_year" > temp_header
    else
      # Upstream JohnSundell/Plot and /Ink use a compact /** block.
      printf "$fork_header_template" "$package" "$file_year" > temp_header
    fi

    # Strip a leading comment block — either consecutive "//" lines or a single "/* ... */"
    # block — plus following blank lines, so re-emitting never stacks headers.
    awk '
    BEGIN { skip = 1; inblock = 0 }
    {
      if (skip && NR == 1 && $0 ~ /^\/\*/) { inblock = 1 }
      if (skip && inblock) {
        if ($0 ~ /\*\//) { inblock = 0 }
        next
      }
      if (skip && ($0 ~ /^\/\/ / || $0 ~ /^\/\/$/ || $0 ~ /^$/)) { next }
      skip = 0
      print
    }' "$file" > temp_file

    # temp_header has no trailing newline (printf), so the first echo terminates the
    # closing "*/" line and the second echo emits the single blank line before the code,
    # matching the upstream header/body separation.
    (cat temp_header; echo; echo; cat temp_file) > "$file"
    rm -f temp_header temp_file
    echo "Applied upstream Sundell header to $file (year ${file_year})."
    continue
  fi

  # Create the header with the current filename
  filename=$(basename "$file")
  header=$(printf "$header_template" "$filename" "$package" "$creator" "$year" "$company")

  # Remove all consecutive lines at the beginning which start with "// ", contain only whitespace, or only "//"
  awk '
  BEGIN { skip = 1 }
  {
    if (skip && ($0 ~ /^\/\/ / || $0 ~ /^\/\/$/ || $0 ~ /^$/)) {
      next
    }
    skip = 0
    print
  }' "$file" > temp_file

  # Add the header to the cleaned file
  (echo "$header"; echo; cat temp_file) > "$file"

  # Remove the temporary file
  rm temp_file
done

echo "Headers added or files skipped appropriately across all Swift files in the directory and subdirectories."
