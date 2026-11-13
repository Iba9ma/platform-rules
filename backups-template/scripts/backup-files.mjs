// ينسخ الملفات المرفوعة (صور ، إيصالات) من تخزين Supabase لمنصة واحدة إلى مجلد محلي.
// يحتاج : SUPABASE_URL و SUPABASE_SERVICE_ROLE_KEY و OUT_DIR
import { createClient } from "@supabase/supabase-js";
import fs from "node:fs/promises";
import path from "node:path";

const { SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, OUT_DIR } = process.env;
if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY || !OUT_DIR) throw new Error("متغيرات ناقصة");
const db = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, { auth: { persistSession: false } });

async function walk(bucket, prefix = "") {
  const files = [];
  for (let offset = 0; ; offset += 1000) {
    const { data, error } = await db.storage.from(bucket).list(prefix, { limit: 1000, offset });
    if (error) throw error;
    for (const it of data) {
      const p = prefix ? `${prefix}/${it.name}` : it.name;
      // المجلد ليس له معرّف ، والملف له معرّف
      if (it.id === null) files.push(...(await walk(bucket, p)));
      else files.push(p);
    }
    if (data.length < 1000) break;
  }
  return files;
}

const { data: buckets, error } = await db.storage.listBuckets();
if (error) throw error;
let count = 0;
for (const b of buckets) {
  for (const f of await walk(b.name)) {
    const { data, error: e } = await db.storage.from(b.name).download(f);
    if (e) throw e;
    const dest = path.join(OUT_DIR, b.name, f);
    await fs.mkdir(path.dirname(dest), { recursive: true });
    await fs.writeFile(dest, Buffer.from(await data.arrayBuffer()));
    count++;
  }
}
console.log(`ملفات منسوخة : ${count} من ${buckets.length} حاوية`);
