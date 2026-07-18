import crypto from "node:crypto";
import fs from "node:fs";
import path from "node:path";

export function* walkFiles(dir) {
  if (!fs.existsSync(dir)) return;
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      yield* walkFiles(full);
    } else if (entry.isFile()) {
      yield full;
    }
  }
}

function sha256(filePath) {
  return crypto.createHash("sha256").update(fs.readFileSync(filePath)).digest("hex");
}

export function writeFileAtomic(destPath, content) {
  fs.mkdirSync(path.dirname(destPath), { recursive: true });
  const tmp = `${destPath}.tmp-${process.pid}-${Date.now()}`;
  fs.writeFileSync(tmp, content);
  fs.renameSync(tmp, destPath);
}

export function smartCopyFile(srcFile, destFile, report) {
  const content = fs.readFileSync(srcFile);
  if (!fs.existsSync(destFile)) {
    writeFileAtomic(destFile, content);
    report.written.push(destFile);
    return;
  }
  if (sha256(srcFile) === sha256(destFile)) {
    report.upToDate.push(destFile);
    return;
  }
  const backup = `${destFile}.tommy-backup-${report.timestamp}`;
  fs.copyFileSync(destFile, backup);
  writeFileAtomic(destFile, content);
  report.backedUp.push({ file: destFile, backup });
  report.written.push(destFile);
}

export function copyTreeSmart(srcDir, destDir, report) {
  for (const src of walkFiles(srcDir)) {
    const dest = path.join(destDir, path.relative(srcDir, src));
    smartCopyFile(src, dest, report);
  }
}
