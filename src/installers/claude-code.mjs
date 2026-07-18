import fs from "node:fs";
import path from "node:path";

import { copyTreeSmart, walkFiles } from "../lib/fs-utils.mjs";
import { installJsonWithMerge } from "../lib/json-install.mjs";
import { mergeMcp, mergeSettings } from "../lib/json-merge.mjs";

const COPY_SUBDIRS = ["agents", "commands", "skills", "hooks"];

export function installClaudeCode(srcDir, homeDir, report) {
  const claudeDir = path.join(homeDir, ".claude");
  fs.mkdirSync(claudeDir, { recursive: true });

  for (const sub of COPY_SUBDIRS) {
    copyTreeSmart(path.join(srcDir, sub), path.join(claudeDir, sub), report);
  }

  for (const file of walkFiles(path.join(claudeDir, "hooks"))) {
    if (file.endsWith(".sh")) fs.chmodSync(file, 0o755);
  }

  installJsonWithMerge(
    path.join(claudeDir, "settings.json"),
    JSON.parse(fs.readFileSync(path.join(srcDir, "settings.json"), "utf8")),
    mergeSettings,
    report
  );

  installJsonWithMerge(
    path.join(claudeDir, "mcp.json"),
    JSON.parse(fs.readFileSync(path.join(srcDir, "mcp.json"), "utf8")),
    mergeMcp,
    report
  );
}
