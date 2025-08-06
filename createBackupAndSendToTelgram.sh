#!/bin/bash

# === Configuration ===
DB_CONTAINER="vijay_db_1"
DB_NAME="ajay_db"
DB_USER="root"
DB_PASSWORD="654321"
SQL_FILE="ajay_db.sql"
ZIP_FILE="ajay_db.zip"
CHUNK_SIZE="100k"

# === Telegram Configuration ===
BOT_TOKEN="8096341529:AAFt4mMWlDLk1gPIa2Mu2awqpNBSqMTOvvQ"
CHAT_ID="7918533956"
TG_API="https://api.telegram.org/bot${BOT_TOKEN}/sendDocument"

echo "📦 Starting database backup for '$DB_NAME'..."

# 1. Dump the database
echo "📤 Exporting MySQL database from container..."
docker exec -i "$DB_CONTAINER" mysqldump -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" > "$SQL_FILE"

if [ $? -ne 0 ]; then
    echo "❌ Failed to dump database. Please check credentials or container status."
    exit 1
fi

# 2. Compress and split
echo "🗜️ Compressing and splitting into $CHUNK_SIZE chunks..."
zip -s "$CHUNK_SIZE" "$ZIP_FILE" "$SQL_FILE"

# 3. Remove uncompressed SQL
echo "🧹 Removing uncompressed SQL file..."
rm -f "$SQL_FILE"

# 4. Send parts to Telegram
echo "📤 Sending split files to Telegram..."
for part in ajay_db.z* ajay_db.zip; do
    if [ -f "$part" ]; then
        echo "📨 Sending $part..."
        curl -s -F document=@"$part" "$TG_API?chat_id=$CHAT_ID" > /dev/null
        if [ $? -eq 0 ]; then
            echo "✅ Sent $part"
        else
            echo "❌ Failed to send $part"
        fi
    fi
done

echo "✅ Backup and upload completed."
