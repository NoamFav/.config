#!/bin/bash

COLORSCRIPTS_DIR="/usr/local/bin/colorscripts"
OUTPUT_FILE="colorscripts_output.txt"

echo "Checking all colorscripts in $COLORSCRIPTS_DIR..." | tee "$OUTPUT_FILE"

for script in "$COLORSCRIPTS_DIR"/*; do
    if [ -x "$script" ]; then
        echo "Running: $(basename "$script")" | tee -a "$OUTPUT_FILE"
        bash "$script" | tee -a "$OUTPUT_FILE"
        echo -e "\n---\n" | tee -a "$OUTPUT_FILE"
    else
        echo "Skipping: $(basename "$script") (not executable)" | tee -a "$OUTPUT_FILE"
    fi
done

echo "Finished checking all colorscripts." | tee -a "$OUTPUT_FILE"
