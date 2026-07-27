import { execFileSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";

import { copyTreeSmart, walkFiles } from "../lib/fs-utils.mjs";
import { installJsonWithMerge } from "../lib/json-install.mjs";
import { mergeSettings } from "../lib/json-merge.mjs";

const COPY_SUBDIRS = ["agents", "commands", "skills", "hooks"];

// Files a previous sdd-tommy version installed that no longer exist upstream.
// tommy-specify/tommy-prompt became commands and tommy-business-analyst became
// a skill in 0.2.0 — leaving the old agent files behind would register two
// competing entry points for the same phase.
const OBSOLETE_PATHS = [
  "agents/tommy-specify.md",
  "agents/tommy-prompt.md",
  "agents/tommy-business-analyst.md",
];

function removeObsoleteFiles(claudeDir, report) {
  for (const rel of OBSOLETE_PATHS) {
    const full = path.join(claudeDir, rel);
    if (fs.existsSync(full)) {
      fs.rmSync(full);
      report.removed.push(full);
    }
  }
}

export function installClaudeCode(srcDir, homeDir, report) {
  const claudeDir = path.join(homeDir, ".claude");
  fs.mkdirSync(claudeDir, { recursive: true });

  for (const sub of COPY_SUBDIRS) {
    copyTreeSmart(path.join(srcDir, sub), path.join(claudeDir, sub), report);
  }

  removeObsoleteFiles(claudeDir, report);

  for (const file of walkFiles(path.join(claudeDir, "hooks"))) {
    if (file.endsWith(".sh")) fs.chmodSync(file, 0o755);
  }

  installJsonWithMerge(
    path.join(claudeDir, "settings.json"),
    JSON.parse(fs.readFileSync(path.join(srcDir, "settings.json"), "utf8")),
    mergeSettings,
    report
  );

  registerUserScopeMcpServers(srcDir, claudeDir, report);
}

// Claude Code does not read ~/.claude/mcp.json — user-scope servers live in
// Claude Code's own config, managed via `claude mcp add --scope user`. Earlier
// sdd-tommy versions wrote ~/.claude/mcp.json, which was dead configuration.
function registerUserScopeMcpServers(srcDir, claudeDir, report) {
  const mcp = JSON.parse(fs.readFileSync(path.join(srcDir, "mcp.json"), "utf8"));

  for (const [name, config] of Object.entries(mcp.mcpServers ?? {})) {
    const manualCmd = `claude mcp add --scope user ${name} -- ${config.command} ${(config.args ?? []).join(" ")}`;
    try {
      execFileSync("claude", ["mcp", "get", name], { stdio: "ignore" });
      report.upToDate.push(`MCP server "${name}" (user scope, claude CLI)`);
      continue;
    } catch {
      // Not registered yet, or the claude CLI is unavailable — try to add below.
    }
    try {
      execFileSync(
        "claude",
        ["mcp", "add", "--scope", "user", name, "--", config.command, ...(config.args ?? [])],
        { stdio: "ignore" }
      );
      report.written.push(`MCP server "${name}" (user scope, claude CLI)`);
    } catch {
      report.notes.push(`Não foi possível registrar o MCP "${name}" automaticamente. Rode: ${manualCmd}`);
    }
  }

  const legacyMcp = path.join(claudeDir, "mcp.json");
  if (fs.existsSync(legacyMcp)) {
    report.notes.push(
      `${legacyMcp} não é lido pelo Claude Code (config morta de versões anteriores do sdd-tommy). Confira \`claude mcp list\` e remova o arquivo se não usá-lo para outra finalidade.`
    );
  }
}
