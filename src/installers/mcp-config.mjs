import fs from "node:fs";
import path from "node:path";

import { writeFileAtomic } from "../lib/fs-utils.mjs";
import { installJsonWithMerge } from "../lib/json-install.mjs";
import { mergeMcp, mergeVscodeMcp } from "../lib/json-merge.mjs";

// Baseline servers every project gets in .tommy/mcp.json (the "always" group of
// common/templates/mcp/mcp-reference.json). Stack-conditional servers (e.g.
// playwright for frontend projects) are proposed later by /tommy-start, which
// can actually detect the stack.
const DEFAULT_SERVERS = {
  context7: {
    command: "npx",
    args: ["-y", "@upstash/context7-mcp@latest"],
  },
};

export const MCP_WIRINGS = ["root-file", "tommy-only"];

export function readTommyConfig(targetDir) {
  const configPath = path.join(targetDir, ".tommy", "config.json");
  if (!fs.existsSync(configPath)) return {};
  try {
    return JSON.parse(fs.readFileSync(configPath, "utf8"));
  } catch {
    return {};
  }
}

function persistWiring(targetDir, wiring, report) {
  const configPath = path.join(targetDir, ".tommy", "config.json");
  const config = readTommyConfig(targetDir);
  if (config.mcp?.wiring === wiring) {
    report.upToDate.push(configPath);
    return;
  }
  config.mcp = { ...(config.mcp ?? {}), wiring };
  writeFileAtomic(configPath, `${JSON.stringify(config, null, 2)}\n`);
  report.written.push(configPath);
}

function toVscodeFormat(canonical) {
  const servers = {};
  for (const [name, config] of Object.entries(canonical.mcpServers ?? {})) {
    servers[name] = { type: "stdio", ...config };
  }
  return { servers };
}

// Materializes the project's MCP configuration:
//   .tommy/mcp.json (canonical) → .cursor/mcp.json, .vscode/mcp.json,
//   and .mcp.json at the root only when wiring === "root-file".
// All writes are non-destructive merges; existing entries are never replaced.
export function configureMcp(targetDir, wiring, report) {
  if (!MCP_WIRINGS.includes(wiring)) {
    throw new Error(`Unknown MCP wiring "${wiring}" (expected: ${MCP_WIRINGS.join(", ")})`);
  }

  const tommyDir = path.join(targetDir, ".tommy");
  fs.mkdirSync(tommyDir, { recursive: true });

  const canonicalPath = path.join(tommyDir, "mcp.json");
  installJsonWithMerge(canonicalPath, { mcpServers: DEFAULT_SERVERS }, mergeMcp, report);
  const canonical = JSON.parse(fs.readFileSync(canonicalPath, "utf8"));

  persistWiring(targetDir, wiring, report);

  installJsonWithMerge(path.join(targetDir, ".cursor", "mcp.json"), canonical, mergeMcp, report);
  installJsonWithMerge(
    path.join(targetDir, ".vscode", "mcp.json"),
    toVscodeFormat(canonical),
    mergeVscodeMcp,
    report
  );

  if (wiring === "root-file") {
    installJsonWithMerge(path.join(targetDir, ".mcp.json"), canonical, mergeMcp, report);
  } else {
    report.notes.push(
      'MCP wiring "tommy-only": sem .mcp.json na raiz — inicie o Claude Code neste projeto com: claude --mcp-config .tommy/mcp.json'
    );
  }
}
