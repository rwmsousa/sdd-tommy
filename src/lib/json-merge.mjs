const SCALAR_KEYS = ["effortLevel", "theme", "language"];
// One marker per hook event Tommy manages — used to detect whether the Tommy
// hook entry is already present without clobbering user-defined hooks.
const HOOK_MARKERS = {
  PostToolUse: "tommy-format-on-edit.sh",
  Stop: "tommy-quality-sentinel.sh",
};

export function mergeSettings(existing, incoming) {
  const merged = structuredClone(existing);
  let changed = false;

  for (const key of SCALAR_KEYS) {
    if (!(key in merged) && key in incoming) {
      merged[key] = incoming[key];
      changed = true;
    }
  }

  if (!("attribution" in merged) && "attribution" in incoming) {
    merged.attribution = incoming.attribution;
    changed = true;
  }

  merged.permissions ??= { allow: [], deny: [] };
  for (const bucket of ["allow", "deny"]) {
    const before = merged.permissions[bucket] ?? [];
    const union = Array.from(new Set([...before, ...(incoming.permissions?.[bucket] ?? [])]));
    if (union.length !== before.length) changed = true;
    merged.permissions[bucket] = union;
  }

  merged.hooks ??= {};
  for (const [event, marker] of Object.entries(HOOK_MARKERS)) {
    merged.hooks[event] ??= [];
    for (const incomingHook of incoming.hooks?.[event] ?? []) {
      const alreadyPresent = merged.hooks[event].some(
        (entry) =>
          entry.matcher === incomingHook.matcher &&
          entry.hooks?.some((h) => h.command?.includes(marker))
      );
      if (!alreadyPresent) {
        merged.hooks[event].push(incomingHook);
        changed = true;
      }
    }
  }

  return { merged, changed };
}

export function mergeMcp(existing, incoming) {
  const merged = structuredClone(existing);
  merged.mcpServers ??= {};
  let changed = false;

  for (const [name, config] of Object.entries(incoming.mcpServers ?? {})) {
    if (!(name in merged.mcpServers)) {
      merged.mcpServers[name] = config;
      changed = true;
    }
  }

  return { merged, changed };
}

// VS Code / GitHub Copilot use `.vscode/mcp.json` with a `servers` key instead
// of `mcpServers` (and per-entry `type`), so it needs its own merge.
export function mergeVscodeMcp(existing, incoming) {
  const merged = structuredClone(existing);
  merged.servers ??= {};
  let changed = false;

  for (const [name, config] of Object.entries(incoming.servers ?? {})) {
    if (!(name in merged.servers)) {
      merged.servers[name] = config;
      changed = true;
    }
  }

  return { merged, changed };
}
