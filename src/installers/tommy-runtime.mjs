import fs from "node:fs";
import path from "node:path";

import { walkFiles, writeFileAtomic } from "../lib/fs-utils.mjs";

export function syncTommyRuntime(commonSrcDir, targetProjectDir, report) {
  const tommyDir = path.join(targetProjectDir, ".tommy");
  const scriptsSrc = path.join(commonSrcDir, "scripts");
  const templatesSrc = path.join(commonSrcDir, "templates");

  for (const src of walkFiles(scriptsSrc)) {
    const dest = path.join(tommyDir, "scripts", path.relative(scriptsSrc, src));
    writeFileAtomic(dest, fs.readFileSync(src));
    if (dest.endsWith(".sh")) fs.chmodSync(dest, 0o755);
    report.written.push(dest);
  }

  for (const src of walkFiles(templatesSrc)) {
    const dest = path.join(tommyDir, "templates", path.relative(templatesSrc, src));
    writeFileAtomic(dest, fs.readFileSync(src));
    report.written.push(dest);
  }

  fs.mkdirSync(path.join(tommyDir, "resources"), { recursive: true });
}
