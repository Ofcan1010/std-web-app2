#!/bin/bash
DATE=$(date +%Y-%m-%d_%H-%M)
FILENAME="/app/backups/backup_$DATE.sql"
mysqldump -h db -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" > "$FILENAME"
find /app/backups -type f -name "*.sql" -mtime +180 -delete