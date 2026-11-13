#!/usr/bin/env bash
# يبقي آخر 6 أشهر من النسخ ويحذف الأقدم
set -euo pipefail
keep_days="${KEEP_DAYS:-180}"
cutoff="$(date -u -d "-${keep_days} days" +%F)"
find data -type f -name '*.gpg' | while read -r f; do
  d="$(basename "$f" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' || true)"
  if [ -n "$d" ] && [[ "$d" < "$cutoff" ]]; then rm -f "$f"; echo "حُذفت نسخة قديمة : $f"; fi
done
