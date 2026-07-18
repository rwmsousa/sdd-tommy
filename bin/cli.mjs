#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";

import { PKG_ROOT } from "../src/constants.mjs";

const HELP = `sdd-tommy — interactive installer for Tommy

Usage:
  npx sdd-tommy@latest              Interactive install (choose tools, target dir)
  npx sdd-tommy@latest --sync-runtime [--dir <path>]
                                     Non-interactive: (re)populate .tommy/scripts
                                     and .tommy/templates in <path> (default: cwd)
  npx sdd-tommy@latest --help       Show this help
  npx sdd-tommy@latest --version    Show the installed sdd-tommy version
`;

function getArgValue(args, flag) {
  const idx = args.indexOf(flag);
  if (idx === -1) return undefined;
  return args[idx + 1];
}

async function main() {
  const args = process.argv.slice(2);

  if (args.includes("--help") || args.includes("-h")) {
    console.log(HELP);
    return;
  }

  if (args.includes("--version") || args.includes("-v")) {
    const pkg = JSON.parse(fs.readFileSync(path.join(PKG_ROOT, "package.json"), "utf8"));
    console.log(pkg.version);
    return;
  }

  if (args.includes("--sync-runtime")) {
    const { runSyncRuntime } = await import("../src/sync-runtime-cli.mjs");
    const dir = getArgValue(args, "--dir");
    runSyncRuntime({ targetDir: dir ? path.resolve(dir) : process.cwd() });
    return;
  }

  const { runInstall } = await import("../src/index.mjs");
  await runInstall();
}

main().catch((err) => {
  console.error(`[Tommy] ${err.message}`);
  process.exit(1);
});
