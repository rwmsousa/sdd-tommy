import fs from "node:fs";
import os from "node:os";
import path from "node:path";

import prompts from "prompts";

import { SRC } from "./constants.mjs";
import { installClaudeCode } from "./installers/claude-code.mjs";
import { installCursor } from "./installers/cursor.mjs";
import { installGithubCopilot } from "./installers/github-copilot.mjs";
import { syncTommyRuntime } from "./installers/tommy-runtime.mjs";
import { createReport, printSummary } from "./lib/report.mjs";

function onCancel() {
  console.log("\n[Tommy] Installation cancelled.");
  process.exit(0);
}

function resolveTargetDir(rawDir) {
  const targetDir = path.resolve(rawDir);

  if (fs.existsSync(targetDir)) {
    const stat = fs.statSync(targetDir);
    if (!stat.isDirectory()) {
      throw new Error(`${targetDir} exists and is not a directory.`);
    }
  } else {
    fs.mkdirSync(targetDir, { recursive: true });
    console.log(`[Tommy] Created directory ${targetDir}`);
  }

  if (!fs.existsSync(path.join(targetDir, ".git"))) {
    console.log(`[Tommy] Note: ${targetDir} is not a git repository — Tommy still works, but branch-based workflows won't apply.`);
  }

  return targetDir;
}

export async function runInstall() {
  const { tools } = await prompts(
    {
      type: "multiselect",
      name: "tools",
      message: "Which tools do you want to install Tommy for?",
      choices: [
        { title: "Claude Code (global, ~/.claude)", value: "claude-code", selected: false },
        { title: "Cursor (this project)", value: "cursor", selected: false },
        { title: "GitHub Copilot (this project)", value: "github-copilot", selected: false },
      ],
      min: 1,
      hint: "Space to select, Enter to confirm",
    },
    { onCancel }
  );

  const needsProjectDir = tools.includes("cursor") || tools.includes("github-copilot");
  let targetDir = null;

  if (needsProjectDir) {
    const { targetDir: rawDir } = await prompts(
      { type: "text", name: "targetDir", message: "Project directory to install into", initial: process.cwd() },
      { onCancel }
    );
    targetDir = resolveTargetDir(rawDir);
  } else {
    const { scaffoldTommy } = await prompts(
      {
        type: "confirm",
        name: "scaffoldTommy",
        message: "Also set up the shared .tommy/ runtime (scripts + templates) in a project now?",
        initial: true,
      },
      { onCancel }
    );
    if (scaffoldTommy) {
      const { targetDir: rawDir } = await prompts(
        { type: "text", name: "targetDir", message: "Project directory", initial: process.cwd() },
        { onCancel }
      );
      targetDir = resolveTargetDir(rawDir);
    }
  }

  console.log("");
  console.log("[Tommy] About to install:");
  for (const tool of tools) {
    if (tool === "claude-code") {
      console.log(`  - Claude Code -> ${path.join(os.homedir(), ".claude")} (global)`);
    } else if (tool === "cursor") {
      console.log(`  - Cursor -> ${path.join(targetDir, ".cursor")}`);
    } else if (tool === "github-copilot") {
      console.log(`  - GitHub Copilot -> ${path.join(targetDir, ".github")}`);
    }
  }
  if (targetDir) {
    console.log(`  - Shared .tommy/ runtime (scripts + templates) -> ${path.join(targetDir, ".tommy")}`);
  }
  console.log("  Existing settings.json/mcp.json (Claude Code) are merged, never blindly overwritten; any changed file is backed up first.");
  console.log("");

  const { proceed } = await prompts(
    { type: "confirm", name: "proceed", message: "Proceed?", initial: true },
    { onCancel }
  );
  if (!proceed) onCancel();

  const report = createReport();

  if (tools.includes("claude-code")) {
    installClaudeCode(SRC.claudeCode, os.homedir(), report);
  }
  if (tools.includes("cursor")) {
    installCursor(SRC.cursor, targetDir, report);
  }
  if (tools.includes("github-copilot")) {
    installGithubCopilot(SRC.githubCopilot, targetDir, report);
  }
  if (targetDir) {
    syncTommyRuntime(SRC.common, targetDir, report);
  }

  printSummary(report);
  console.log("[Tommy] Installation complete.");
}
