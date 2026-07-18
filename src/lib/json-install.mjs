import fs from "node:fs";

import { writeFileAtomic } from "./fs-utils.mjs";

export function installJsonWithMerge(destPath, incoming, mergeFn, report) {
  let existing = null;

  if (fs.existsSync(destPath)) {
    try {
      existing = JSON.parse(fs.readFileSync(destPath, "utf8"));
    } catch {
      const backup = `${destPath}.tommy-backup-${report.timestamp}`;
      fs.copyFileSync(destPath, backup);
      report.backedUp.push({ file: destPath, backup, reason: "invalid JSON, treated as absent" });
      existing = null;
    }
  }

  if (existing === null) {
    writeFileAtomic(destPath, `${JSON.stringify(incoming, null, 2)}\n`);
    report.written.push(destPath);
    return;
  }

  const { merged, changed } = mergeFn(existing, incoming);
  if (!changed) {
    report.upToDate.push(destPath);
    return;
  }

  const backup = `${destPath}.tommy-backup-${report.timestamp}`;
  fs.copyFileSync(destPath, backup);
  writeFileAtomic(destPath, `${JSON.stringify(merged, null, 2)}\n`);
  report.backedUp.push({ file: destPath, backup });
  report.written.push(destPath);
}
