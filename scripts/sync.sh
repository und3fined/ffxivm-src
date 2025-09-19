#!/bin/bash

echo "Syncing files from FFXIV extract..."

FGAME_BUNDLE="com.tencent.tmgp.fmgame"
EXPORTED_DIR="$HOME/Library/Containers/$FGAME_BUNDLE/Data/Documents/FF_U2PM/extract"

RAW_FOLDER="Encrypted"
SRC_FOLDER="Source"

# Ensure the exported directory exists
if [ ! -d "$EXPORTED_DIR" ]; then
		echo "Error: Exported directory $EXPORTED_DIR does not exist."
		exit 1
fi

EXCLUDE_LIST=(".DS_Store" ".gitignore" ".gitkeep" "U2pm/" "*.u3patch.lua" "*_patch.lua")

# Generate ignore parameters for rsync
RSYNC_EXCLUDES=()
for EXCLUDE in "${EXCLUDE_LIST[@]}"; do
		RSYNC_EXCLUDES+=("--exclude=$EXCLUDE")
done

# Use rsync to copy files from RAW_FOLDER, overriding existing files. Use RSYNC_EXCLUDES to exclude files
rsync -a --delete "${RSYNC_EXCLUDES[@]}" "$EXPORTED_DIR/$RAW_FOLDER/" raw/
if [ $? -ne 0 ]; then
		echo "Warning: rsync from $EXPORTED_DIR/$RAW_FOLDER to raw/ failed."
fi

# Use rsync to copy files from SRC_FOLDER, excluding .DS_Store, .gitignore files, overriding existing files
rsync -a --delete "${RSYNC_EXCLUDES[@]}" "$EXPORTED_DIR/$SRC_FOLDER/" src/
if [ $? -ne 0 ]; then
		echo "Warning: rsync from $EXPORTED_DIR/$SRC_FOLDER to src/ failed."
fi

echo "Sync completed."
