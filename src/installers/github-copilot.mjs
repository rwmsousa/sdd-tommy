import fs from "node:fs";
import path from "node:path";

import { TOMMY_COPILOT_MARKER } from "../constants.mjs";
import { copyTreeSmart, writeFileAtomic } from "../lib/fs-utils.mjs";

function installCopilotInstructions(srcFile, destFile, report) {
  const incoming = fs.readFileSync(srcFile, "utf8");

  if (!fs.existsSync(destFile)) {
    writeFileAtomic(destFile, incoming);
    report.written.push(destFile);
    return;
  }

  const existing = fs.readFileSync(destFile, "utf8");
  const markerIdx = existing.indexOf(TOMMY_COPILOT_MARKER);
  const prefix = markerIdx === -1 ? existing.trimEnd() : existing.slice(0, markerIdx).trimEnd();
  const combined = prefix
    ? `${prefix}\n\n${TOMMY_COPILOT_MARKER}\n\n${incoming}`
    : `${TOMMY_COPILOT_MARKER}\n\n${incoming}`;

  if (combined === existing) {
    report.upToDate.push(destFile);
    return;
  }

  if (markerIdx === -1 && existing.trim().length > 0) {
    const backup = `${destFile}.tommy-backup-${report.timestamp}`;
    fs.copyFileSync(destFile, backup);
    report.backedUp.push({ file: destFile, backup, reason: "pre-existing non-Tommy instructions preserved above the marker" });
  }

  writeFileAtomic(destFile, combined);
  report.written.push(destFile);
}

export function installGithubCopilot(srcDir, targetProjectDir, report) {
  const githubDir = path.join(targetProjectDir, ".github");
  installCopilotInstructions(
    path.join(srcDir, "copilot-instructions.md"),
    path.join(githubDir, "copilot-instructions.md"),
    report
  );
  copyTreeSmart(path.join(srcDir, "prompts"), path.join(githubDir, "prompts"), report);
}
