#!/usr/bin/env bash
# ينسخ قاعدة بيانات منصة واحدة : نسخة كاملة ← ضغط ← تشفير ← حفظ في data/<المنصة>/
# يحتاج : PLATFORM و DATABASE_URL و BACKUP_PASSPHRASE
set -euo pipefail
: "${PLATFORM:?}" "${DATABASE_URL:?}" "${BACKUP_PASSPHRASE:?}"
day="$(date -u +%F)"
out="data/${PLATFORM}"
mkdir -p "$out"
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
# نسخة نصية كاملة حتى يمكن استرجاعها على أي قاعدة بيانات لاحقاً
pg_dump --no-owner --no-privileges --dbname "$DATABASE_URL" | gzip -9 > "$tmp"
# نسخة فارغة أو صغيرة جداً تعني أن النسخ فشل بصمت ، فنوقف العملية
size="$(stat -c %s "$tmp")"
if [ "$size" -lt 200 ]; then echo "النسخة فارغة ($size بايت)" >&2; exit 1; fi
gpg --batch --yes --pinentry-mode loopback --passphrase "$BACKUP_PASSPHRASE" \
    --symmetric --cipher-algo AES256 --output "${out}/db-${day}.sql.gz.gpg" "$tmp"
echo "تم : ${out}/db-${day}.sql.gz.gpg ($size بايت قبل التشفير)"
