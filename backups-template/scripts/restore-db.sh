#!/usr/bin/env bash
# يسترجع نسخة إلى قاعدة بيانات تُحدَّد بالاسم. لا يُشغَّل على القاعدة المنشورة إلا بقرار صريح.
# الاستخدام : BACKUP_PASSPHRASE=... scripts/restore-db.sh data/takaful/db-2026-11-13.sql.gz.gpg "رابط القاعدة الهدف"
set -euo pipefail
file="${1:?ملف النسخة}"; target="${2:?رابط القاعدة الهدف}"
: "${BACKUP_PASSPHRASE:?}"
gpg --batch --quiet --pinentry-mode loopback --passphrase "$BACKUP_PASSPHRASE" --decrypt "$file" \
  | gunzip | psql --set ON_ERROR_STOP=1 --quiet --dbname "$target"
echo "تم الاسترجاع من $file"
