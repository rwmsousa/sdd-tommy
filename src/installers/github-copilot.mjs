import fs from "node:fs";
import path from "node:path";

import { TOMMY_COPILOT_END_MARKER, TOMMY_COPILOT_MARKER } from "../constants.mjs";
import { copyTreeSmart, writeFileAtomic } from "../lib/fs-utils.mjs";

const TOMMY_HEADING = "# Tommy — Repository Instructions";

// Splits an existing copilot-instructions.md into what sits before and after
// Tommy's managed section, so other tools' sections (e.g. Graphify's, appended
// below ours) survive a re-install. Files written before the end marker existed
// are handled too: a bare Tommy file (no markers at all) is Tommy's alone.
function splitAroundTommySection(existing) {
  const startIdx = existing.indexOf(TOMMY_COPILOT_MARKER);
  if (startIdx === -1) {
    if (existing.trimStart().startsWith(TOMMY_HEADING)) return { prefix: "", suffix: "", legacy: true };
    return { prefix: existing.trimEnd(), suffix: "", legacy: false };
  }
  const endIdx = existing.indexOf(TOMMY_COPILOT_END_MARKER, startIdx);
  return {
    prefix: existing.slice(0, startIdx).trimEnd(),
    suffix: endIdx === -1 ? "" : existing.slice(endIdx + TOMMY_COPILOT_END_MARKER.length).trim(),
    legacy: false,
  };
}

function installCopilotInstructions(srcFile, destFile, report) {
  const section = `${TOMMY_COPILOT_MARKER}\n\n${fs.readFileSync(srcFile, "utf8").trimEnd()}\n\n${TOMMY_COPILOT_END_MARKER}`;

  if (!fs.existsSync(destFile)) {
    writeFileAtomic(destFile, `${section}\n`);
    report.written.push(destFile);
    return;
  }

  const existing = fs.readFileSync(destFile, "utf8");
  const { prefix, suffix, legacy } = splitAroundTommySection(existing);
  const combined = `${[prefix, section, suffix].filter(Boolean).join("\n\n")}\n`;

  if (combined === existing) {
    report.upToDate.push(destFile);
    return;
  }

  if (legacy || (!existing.includes(TOMMY_COPILOT_MARKER) && existing.trim().length > 0)) {
    const backup = `${destFile}.tommy-backup-${report.timestamp}`;
    fs.copyFileSync(destFile, backup);
    report.backedUp.push({
      file: destFile,
      backup,
      reason: legacy ? "pre-marker Tommy file replaced by the managed section" : "pre-existing non-Tommy instructions preserved above the marker",
    });
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
