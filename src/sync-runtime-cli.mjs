import { SRC } from "./constants.mjs";
import { createReport, printSummary } from "./lib/report.mjs";
import { syncTommyRuntime } from "./installers/tommy-runtime.mjs";

export function runSyncRuntime({ targetDir = process.cwd() } = {}) {
  console.log(`[Tommy] Syncing .tommy/scripts and .tommy/templates into ${targetDir}`);

  const report = createReport();
  syncTommyRuntime(SRC.common, targetDir, report);
  printSummary(report);

  console.log("[Tommy] Runtime sync complete.");
}
