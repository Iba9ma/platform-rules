#!/usr/bin/env bash
# ينسخ ملفات التخزين لمنصة واحدة ثم يضغطها ويشفّرها في data/<المنصة>/
set -euo pipefail
: "${PLATFORM:?}" "${SUPABASE_URL:?}" "${SUPABASE_SERVICE_ROLE_KEY:?}" "${BACKUP_PASSPHRASE:?}"
day="$(date -u +%F)"
out="data/${PLATFORM}"
mkdir -p "$out"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
OUT_DIR="$work/files" node scripts/backup-files.mjs
mkdir -p "$work/files"
tar -C "$work" -czf "$work/files.tar.gz" files
gpg --batch --yes --pinentry-mode loopback --passphrase "$BACKUP_PASSPHRASE" \
    --symmetric --cipher-algo AES256 --output "${out}/files-${day}.tar.gz.gpg" "$work/files.tar.gz"
echo "تم : ${out}/files-${day}.tar.gz.gpg"
