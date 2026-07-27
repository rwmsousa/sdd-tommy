export function createReport() {
  return {
    timestamp: new Date().toISOString().replace(/[:.]/g, "-"),
    written: [],
    upToDate: [],
    backedUp: [],
    removed: [],
    notes: [],
  };
}

export function printSummary(report) {
  console.log("");
  console.log(`Files written or updated: ${report.written.length}`);
  console.log(`Files already up to date: ${report.upToDate.length}`);
  if (report.backedUp.length > 0) {
    console.log(`Files backed up before overwrite: ${report.backedUp.length}`);
    for (const { file, backup, reason } of report.backedUp) {
      console.log(`  - ${file}`);
      console.log(`    backup: ${backup}${reason ? ` (${reason})` : ""}`);
    }
  }
  if (report.removed.length > 0) {
    console.log(`Obsolete files removed: ${report.removed.length}`);
    for (const file of report.removed) {
      console.log(`  - ${file}`);
    }
  }
  if (report.notes.length > 0) {
    console.log("Notes:");
    for (const note of report.notes) {
      console.log(`  - ${note}`);
    }
  }
  console.log("");
}
