export function createReport() {
  return {
    timestamp: new Date().toISOString().replace(/[:.]/g, "-"),
    written: [],
    upToDate: [],
    backedUp: [],
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
  console.log("");
}
