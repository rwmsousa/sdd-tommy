import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

export const PKG_ROOT = path.resolve(__dirname, "..");

export const SRC = {
  claudeCode: path.join(PKG_ROOT, "claude-code"),
  cursor: path.join(PKG_ROOT, "cursor"),
  githubCopilot: path.join(PKG_ROOT, "github-copilot"),
  common: path.join(PKG_ROOT, "common"),
};

export const TOMMY_COPILOT_MARKER =
  "<!-- ===== Tommy (sdd-tommy) managed section below — do not edit; re-run `npx sdd-tommy@latest` to update ===== -->";
