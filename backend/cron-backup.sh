#!/usr/bin/env bash
# MySQL -> /app/backups/*.sql
set -euo pipefail
umask 077

MYSQL_HOST="${MYSQL_HOST:-db}"
MYSQL_PORT="${MYSQL_PORT:-3306}"
MYSQL_USER="${MYSQL_USER:?MYSQL_USER boş}"
MYSQL_PASSWORD="${MYSQL_PASSWORD:?MYSQL_PASSWORD boş}"
MYSQL_DATABASE="${MYSQL_DATABASE:?MYSQL_DATABASE boş}"
MYSQL_SSL_MODE="${MYSQL_SSL_MODE:-REQUIRED}"   # CA yoksa doğrulamasız TLS
MYSQL_SSL_CA="${MYSQL_SSL_CA:-}"               # varsa: /app/ca/ca.pem
KEEP_DAYS="${KEEP_DAYS:-180}"

BACKUP_DIR="/app/backups"
mkdir -p "$BACKUP_DIR"
TS="$(date -u +%Y-%m-%d_%H-%M)"
F="$BACKUP_DIR/backup_${TS}.sql"
TMP="${F}.tmp"

cleanup(){ [[ -f "$TMP" ]] && rm -f "$TMP"; }
trap cleanup EXIT

# SSL bayrakları (MySQL vs MariaDB)
C=$(mysqldump --version 2>&1 | tr 'A-Z' 'a-z')
SSLFLAGS=()
COLSTATS=()
if echo "$C" | grep -q mariadb; then
  SSLFLAGS+=(--ssl)
  if [[ -n "$MYSQL_SSL_CA" ]]; then
    SSLFLAGS+=(--ssl-ca="$MYSQL_SSL_CA" --ssl-verify-server-cert=ON)
  else
    SSLFLAGS+=(--ssl-verify-server-cert=OFF)
  fi
else
  if [[ -n "$MYSQL_SSL_CA" ]]; then
    SSLFLAGS+=(--ssl-mode=VERIFY_CA --ssl-ca="$MYSQL_SSL_CA")
  else
    SSLFLAGS+=(--ssl-mode="$MYSQL_SSL_MODE")
  fi
  COLSTATS=(--column-statistics=0)
fi

# Dump (my.cnf etkisini kapatmak için --no-defaults)
mysqldump --no-defaults \
  --protocol=TCP \
  --host="$MYSQL_HOST" --port="$MYSQL_PORT" \
  --user="$MYSQL_USER" --password="$MYSQL_PASSWORD" \
  --single-transaction --quick --skip-lock-tables \
  --no-tablespaces "${COLSTATS[@]}" "${SSLFLAGS[@]}" \
  "$MYSQL_DATABASE" > "$TMP"

[[ -s "$TMP" ]] || { echo "ERR: boş dump"; exit 1; }
mv "$TMP" "$F"
find "$BACKUP_DIR" -type f -name "*.sql" -mtime +"$KEEP_DAYS" -delete
echo "OK: $F"