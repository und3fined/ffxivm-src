#!/bin/bash

RAW_DIR="./raw"
SRC_DIR="./src"
REPORT_FILE="./stats.md"

# Create or clear the report file
echo "# File Comparison Report" > "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Last updated at use ETC time
echo "Generated on: $(date -u +"%Y-%m-%d %H:%M:%S UTC")" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Count total files in raw and src directories
TOTAL_RAW_FILES=$(find "$RAW_DIR" -type f | wc -l)
TOTAL_SRC_FILES=$(find "$SRC_DIR" -type f | wc -l)

# calculator space for alignment
RAW_WIDTH=${#TOTAL_RAW_FILES}
SRC_WIDTH=${#TOTAL_SRC_FILES}
MAX_WIDTH=$(( RAW_WIDTH > SRC_WIDTH ? RAW_WIDTH : SRC_WIDTH ))

# echo Raw files to REPORT_FILE with MAX_WIDTH
echo "## Summary" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
printf " - Raw   : %${MAX_WIDTH}d files\n" "$TOTAL_RAW_FILES" >> "$REPORT_FILE"
printf " - Src   : %${MAX_WIDTH}d files\n" "$TOTAL_SRC_FILES" >> "$REPORT_FILE"
printf " - Diff  : %${MAX_WIDTH}d files\n" "$((TOTAL_RAW_FILES - TOTAL_SRC_FILES))" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Find files that are in raw but not in src
echo "## Files in raw but not in src" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

MISSING_FILES=$(comm -13 <(find "$SRC_DIR" -type f | sed "s|^$SRC_DIR/||" | sort) <(find "$RAW_DIR" -type f | sed "s|^$RAW_DIR/||" | sort))
if [ -z "$MISSING_FILES" ]; then
		echo "No files are missing in src." >> "$REPORT_FILE"
else
		echo "$MISSING_FILES" | while read -r file; do
				echo "- $file" >> "$REPORT_FILE"
		done
fi
echo "" >> "$REPORT_FILE"

# Find files that are in src but not in raw
echo "## Files in src but not in raw" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
EXTRA_FILES=$(comm -23 <(find "$SRC_DIR" -type f | sed "s|^$SRC_DIR/||" | sort) <(find "$RAW_DIR" -type f | sed "s|^$RAW_DIR/||" | sort))
if [ -z "$EXTRA_FILES" ]; then
		echo "No extra files in src." >> "$REPORT_FILE"
else
		echo "$EXTRA_FILES" | while read -r file; do
				echo "- $file" >> "$REPORT_FILE"
		done
fi

echo "" >> "$REPORT_FILE"
echo "Report generated at $REPORT_FILE"
echo "Done."
