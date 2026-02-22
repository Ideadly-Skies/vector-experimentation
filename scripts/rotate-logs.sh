#!/bin/bash
# Log Rotation Script - Simulated Log Rotation for Vector
# This script zips the current log file and clears it without stopping Vector

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# Change to project root (parent directory)
cd "$SCRIPT_DIR/.."

# Configuration
LOG_FILE="${LOG_FILE_PATH:-./data/examples/SSBAdapter.log}"
ARCHIVE_DIR="./data/logs-archive"
BACKUP_DIR="./data/backup-original"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}         Vector Log Rotation Script${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Check if log file exists
if [ ! -f "$LOG_FILE" ]; then
    echo -e "${RED}Error: Log file not found: $LOG_FILE${NC}"
    exit 1
fi

# Create archive directory if it doesn't exist
mkdir -p "$ARCHIVE_DIR"

# Get current date in dd-mm-yy format
DATE_STAMP=$(date +"%d-%m-%y")

# Extract just the filename from the path
LOG_FILENAME=$(basename "$LOG_FILE")
ZIP_FILENAME="${DATE_STAMP}.${LOG_FILENAME}.zip"
ZIP_PATH="$ARCHIVE_DIR/$ZIP_FILENAME"

# Check if archive for today already exists
COUNTER=1
while [ -f "$ZIP_PATH" ]; do
    ZIP_FILENAME="${DATE_STAMP}.${LOG_FILENAME}.${COUNTER}.zip"
    ZIP_PATH="$ARCHIVE_DIR/$ZIP_FILENAME"
    COUNTER=$((COUNTER + 1))
done

# Get log file size
LOG_SIZE=$(du -h "$LOG_FILE" | cut -f1)

echo -e "${YELLOW}Current log:${NC} $LOG_FILE"
echo -e "${YELLOW}Log size:${NC} $LOG_SIZE"
echo -e "${YELLOW}Archive to:${NC} $ZIP_PATH"
echo ""

# Ask for confirmation
echo -e -n "${YELLOW}Proceed with log rotation? (y/N): ${NC}"
read -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}Log rotation cancelled.${NC}"
    exit 0
fi

echo ""
echo -e "${BLUE}Step 1: Creating temporary copy...${NC}"
TEMP_FILE="$ARCHIVE_DIR/$LOG_FILENAME"
cp "$LOG_FILE" "$TEMP_FILE"
echo -e "${GREEN}✓ Temporary copy created${NC}"

echo -e "${BLUE}Step 2: Zipping log file...${NC}"
# Zip the file from within the archive directory
cd "$ARCHIVE_DIR"
zip -q "$ZIP_FILENAME" "$LOG_FILENAME"
rm "$LOG_FILENAME"
cd "$SCRIPT_DIR"
echo -e "${GREEN}✓ Log file zipped: $ZIP_FILENAME${NC}"

echo -e "${BLUE}Step 3: Clearing original log file...${NC}"
# Truncate the file (empties it while keeping the same inode)
# This ensures Vector continues reading from the same file handle
> "$LOG_FILE"
echo -e "${GREEN}✓ Log file cleared (Vector can continue reading)${NC}"

echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}         Log Rotation Complete! 🎉${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
echo "Summary:"
echo -e "  📦 Archived: ${BLUE}$ZIP_PATH${NC}"
echo -e "  📊 Original size: ${BLUE}$LOG_SIZE${NC}"

# Get zip size
ZIP_SIZE=$(du -h "$ZIP_PATH" | cut -f1)
echo -e "  📦 Compressed size: ${BLUE}$ZIP_SIZE${NC}"
echo -e "  🧹 Current log: ${BLUE}Empty (ready for new logs)${NC}"
echo ""

# List all archives
echo "All archived logs:"
ls -lh "$ARCHIVE_DIR" | grep ".zip" | awk '{print "  " $9 " (" $5 ")"}'
echo ""

# Restore instructions
echo -e "${YELLOW}💡 To restore original data:${NC}"
echo -e "   cp $BACKUP_DIR/$(basename "$LOG_FILE") $LOG_FILE"
echo ""
