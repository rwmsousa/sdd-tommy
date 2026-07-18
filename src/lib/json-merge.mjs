const SCALAR_KEYS = ["effortLevel", "theme", "language"];
const HOOK_MARKER = "tommy-format-on-edit.sh";

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
  merged.hooks.PostToolUse ??= [];
  const incomingHook = incoming.hooks?.PostToolUse?.[0];
  if (incomingHook) {
    const alreadyPresent = merged.hooks.PostToolUse.some(
      (entry) =>
        entry.matcher === incomingHook.matcher &&
        entry.hooks?.some((h) => h.command?.includes(HOOK_MARKER))
    );
    if (!alreadyPresent) {
      merged.hooks.PostToolUse.push(incomingHook);
      changed = true;
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
