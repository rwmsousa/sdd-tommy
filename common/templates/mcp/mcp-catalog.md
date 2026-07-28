# Tommy MCP Catalog & Wiring

How Tommy manages MCP servers per project. Used by `/tommy-start` (capabilities step) and by the `sdd-tommy` installer.

## Canonical source: `.tommy/mcp.json`

`.tommy/mcp.json` is the single source of truth for the project's MCP servers, in the standard `{"mcpServers": {...}}` format — created whenever the project is bootstrapped, regardless of which tool(s) are in use. Tools do **not** read it natively — it is projected into each tool's native location, but **only for the tools actually in use in this project** (selected in the `sdd-tommy` installer, or already installed by a previous `/tommy-start` run):

| Tool | Native file | Format | Projected when |
|---|---|---|---|
| Claude Code | `.mcp.json` (project root) — only in `root-file` wiring | `{"mcpServers": {...}}` | Claude Code is one of the selected/installed tools |
| Cursor | `.cursor/mcp.json` | `{"mcpServers": {...}}` | Cursor is one of the selected/installed tools |
| VS Code / GitHub Copilot | `.vscode/mcp.json` | `{"servers": {...}}` — each entry gains `"type": "stdio"` | GitHub Copilot is one of the selected/installed tools |

Never project into a tool's native file just because the project has one — a Claude-Code-only project must not end up with a `.cursor/` or `.vscode/` folder it never asked for. Generation is always a **non-destructive merge**: existing servers in a native file are never overwritten or removed; only missing entries are added, and any changed file is backed up first.

## Wiring modes (persisted in `.tommy/config.json`)

Claude Code only auto-loads project MCP servers from `.mcp.json` at the project root. This choice — and the question that asks for it — only exists when Claude Code is one of the tools in use. It's asked **once per project** at bootstrap and stored as `{"mcp": {"wiring": ...}}`:

- **`root-file`** (recommended): generate `.mcp.json` at the project root — native auto-load in Claude Code. This is the only file Tommy creates at the root besides `AGENTS.md`.
- **`tommy-only`**: no file at the root. Claude Code must be launched with `claude --mcp-config .tommy/mcp.json`.

Never re-ask when `.tommy/config.json` already records the choice — change it by editing that file and re-running the bootstrap.

## Catalog (`mcp-reference.json`)

The curated catalog next to this file maps stack → suggested servers:

- **`always`**: proposed for every project (context7 — required by the Tommy knowledge chain).
- **`frontend`**: proposed when `.tommy/codebase/stack.md` indicates a frontend UI (playwright — used by the quality gate's Frontend Audit).

Rules for whoever applies the catalog (`/tommy-start`):

1. Read `.tommy/codebase/stack.md` to decide which groups apply.
2. **Always confirm with the user before adding a server** — never install silently. Show the `why` of each proposed entry.
3. Add confirmed servers to `.tommy/mcp.json`, then regenerate the native files per the wiring mode.
4. When a server needs a permission entry (e.g. `mcp__playwright` in the **project's** `.claude/settings.json` allow list), add it per project — never globally.
5. Servers outside the catalog may be suggested by the user; record them the same way. Treat any third-party MCP server as code you are choosing to run — prefer well-known, pinned packages.
