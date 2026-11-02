import { execFileSync, execSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";

const IS_WINDOWS = process.platform === "win32";
const MIN_NODE = [18, 20];
const USER_BIN_DIRS = [path.join(os.homedir(), ".local", "bin"), path.join(os.homedir(), ".cargo", "bin")];

// "system" tools come from the OS package manager and usually need admin
// rights, so Tommy only checks them and prints how to install. "managed" tools
// install into the user's home (~/.local/bin, no sudo) and Tommy installs them
// itself — always after an explicit confirmation, since the official installers
// are downloaded scripts.
export const PREREQUISITES = [
  {
    name: "node",
    kind: "system",
    why: "runs the sdd-tommy installer (npx) and MCP servers",
    hint: "https://nodejs.org (LTS) or nvm — Node >= 18.20",
  },
  {
    name: "git",
    kind: "system",
    why: "feature branches, diff analysis, commits",
    hint: IS_WINDOWS ? "winget install Git.Git" : "apt install git | brew install git",
  },
  {
    name: "bash",
    kind: "system",
    why: "runs the .tommy/scripts (specs, plans, quality gate, graph)",
    hint: IS_WINDOWS ? "Git Bash (bundled with Git for Windows) or WSL" : "preinstalled on Linux/macOS",
  },
  {
    name: "jq",
    kind: "system",
    why: "quality-gate sentinel hook and JSON output of the .tommy scripts",
    hint: IS_WINDOWS ? "winget install jqlang.jq" : "sudo apt install jq | brew install jq",
  },
  {
    name: "uv",
    kind: "managed",
    why: "isolated Python tool installer used to install Graphify",
    install: "curl -LsSf https://astral.sh/uv/install.sh | sh",
    hint: IS_WINDOWS
      ? 'powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"'
      : "curl -LsSf https://astral.sh/uv/install.sh | sh",
  },
  {
    name: "graphify",
    kind: "managed",
    why: "code knowledge graph queried before grepping the codebase (PyPI package: graphifyy)",
    dependsOn: "uv",
    install: (bins) => `"${bins.uv}" tool install graphifyy`,
    hint: "uv tool install graphifyy",
  },
  {
    name: "rtk",
    kind: "managed",
    why: "compresses command output before it reaches the agent's context",
    install: "curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh",
    hint: IS_WINDOWS
      ? "winget install rtk-ai.rtk"
      : "curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh",
  },
];

function resolveBin(name) {
  try {
    const out = execFileSync(IS_WINDOWS ? "where" : "which", [name], { encoding: "utf8", stdio: ["ignore", "pipe", "ignore"] });
    const first = out.split(/\r?\n/).find(Boolean);
    if (first) return first.trim();
  } catch {
    // Not on PATH — fall through to the user bin dirs below.
  }
  for (const dir of USER_BIN_DIRS) {
    const candidate = path.join(dir, IS_WINDOWS ? `${name}.exe` : name);
    if (fs.existsSync(candidate)) return candidate;
  }
  return null;
}

function readVersion(bin) {
  try {
    const out = execFileSync(bin, ["--version"], { encoding: "utf8", stdio: ["ignore", "pipe", "pipe"], timeout: 10000 });
    return out.split(/\r?\n/).find(Boolean)?.trim() ?? "";
  } catch {
    return "";
  }
}

function nodeIsSupported() {
  const [major, minor] = process.versions.node.split(".").map(Number);
  return major > MIN_NODE[0] || (major === MIN_NODE[0] && minor >= MIN_NODE[1]);
}

export function detectPrerequisites() {
  return PREREQUISITES.map((tool) => {
    if (tool.name === "node") {
      return { ...tool, path: process.execPath, version: `v${process.versions.node}`, ok: nodeIsSupported() };
    }
    const bin = resolveBin(tool.name);
    return { ...tool, path: bin, version: bin ? readVersion(bin) : "", ok: Boolean(bin) };
  });
}

function userBinOnPath() {
  const entries = (process.env.PATH ?? "").split(path.delimiter);
  return USER_BIN_DIRS.some((dir) => entries.includes(dir));
}

export function printDoctor(results) {
  console.log("[Tommy] Prerequisites");
  for (const r of results) {
    const mark = r.ok ? "✓" : "✗";
    const detail = r.ok ? r.version || r.path : `missing — ${r.hint}`;
    console.log(`  ${mark} ${r.name.padEnd(9)} ${r.kind === "system" ? "(required)   " : "(auto-install)"} ${detail}`);
  }
  const missing = results.filter((r) => !r.ok);
  if (missing.length === 0) {
    console.log("  All prerequisites present.");
  } else {
    console.log("  Tommy keeps working without the missing tools (no code graph / uncompressed output),");
    console.log("  but they are part of the supported setup. Run `npx sdd-tommy@latest` to install uv, graphify and rtk.");
  }
  const livesInUserBin = results.some(
    (r) => r.kind === "managed" && (!r.ok || USER_BIN_DIRS.some((dir) => r.path?.startsWith(dir)))
  );
  if (!IS_WINDOWS && livesInUserBin && !userBinOnPath()) {
    console.log(`  Note: ${USER_BIN_DIRS[0]} is not on your PATH — add it to your shell profile so graphify/rtk are found.`);
  }
}

export function missingManagedTools(results) {
  return results.filter((r) => r.kind === "managed" && !r.ok);
}

// Installs uv, graphify and rtk in user space. Never throws: a failure (no
// network, no permission, Windows) becomes a report note and the install goes on.
export function installManagedTools(results, report) {
  const missing = missingManagedTools(results);
  if (missing.length === 0) return;

  if (IS_WINDOWS) {
    for (const tool of missing) {
      report.notes.push(`Windows: instale ${tool.name} manualmente — ${tool.hint}`);
    }
    return;
  }

  const bins = Object.fromEntries(results.filter((r) => r.ok).map((r) => [r.name, r.path]));
  for (const tool of missing) {
    if (tool.dependsOn && !bins[tool.dependsOn]) {
      report.notes.push(`${tool.name} não instalado: depende de ${tool.dependsOn}, que não está disponível. Depois de instalá-lo: ${tool.hint}`);
      continue;
    }
    const command = typeof tool.install === "function" ? tool.install(bins) : tool.install;
    console.log(`[Tommy] Installing ${tool.name}: ${command}`);
    try {
      execSync(command, { stdio: "inherit", shell: "/bin/sh" });
      const bin = resolveBin(tool.name);
      if (!bin) throw new Error("binary not found after install");
      bins[tool.name] = bin;
      report.written.push(`${tool.name} (${bin})`);
    } catch (err) {
      report.notes.push(`Falha ao instalar ${tool.name} (${err.message}). Tommy segue sem ele; instale depois com: ${tool.hint}`);
    }
  }
}

function runIntegration(label, bin, args, cwd, report) {
  try {
    // stdin is not a TTY on purpose: rtk then skips its optional prompts
    // (telemetry stays off, proxy onboarding is not offered).
    execFileSync(bin, args, { cwd, stdio: ["ignore", "pipe", "pipe"], timeout: 120000 });
    report.written.push(label);
  } catch (err) {
    const stderr = err.stderr?.toString().trim().split(/\r?\n/).pop() ?? err.message;
    report.notes.push(`Não foi possível configurar ${label}: ${stderr}. Rode manualmente: ${path.basename(bin)} ${args.join(" ")}`);
  }
}

// Wires RTK (command-output compression) and Graphify (code graph skill/rules)
// into each selected tool. RTK and Graphify own their own config writes and
// merge into existing files; Tommy only invokes their official CLIs.
export function configureIntegrations(tools, targetDir, report) {
  const results = detectPrerequisites();
  const rtk = results.find((r) => r.name === "rtk");
  const graphify = results.find((r) => r.name === "graphify");

  if (rtk.ok) {
    if (tools.includes("claude-code")) runIntegration("RTK hook — Claude Code (global)", rtk.path, ["init", "-g", "--auto-patch"], undefined, report);
    if (tools.includes("cursor")) runIntegration("RTK hook — Cursor (global)", rtk.path, ["init", "-g", "--agent", "cursor", "--auto-patch"], undefined, report);
    if (tools.includes("github-copilot")) runIntegration("RTK hook — GitHub Copilot (global)", rtk.path, ["init", "-g", "--copilot", "--auto-patch"], undefined, report);
  } else {
    report.notes.push("RTK ausente: a saída dos comandos não será comprimida. Instale com `npx sdd-tommy@latest` (ou veja `--doctor`).");
  }

  if (graphify.ok) {
    if (tools.includes("claude-code")) runIntegration("Graphify skill — Claude Code (global)", graphify.path, ["install"], undefined, report);
    if (targetDir && tools.includes("cursor")) runIntegration("Graphify rule — Cursor (.cursor/rules/graphify.mdc)", graphify.path, ["cursor", "install"], targetDir, report);
    if (targetDir && tools.includes("github-copilot")) runIntegration("Graphify — GitHub Copilot (.github/copilot-instructions.md)", graphify.path, ["vscode", "install"], targetDir, report);
  } else {
    report.notes.push("Graphify ausente: os agentes usam busca comum em vez do grafo de código. Instale com `npx sdd-tommy@latest` (ou veja `--doctor`).");
  }
}
