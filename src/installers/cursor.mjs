import path from "node:path";

import { copyTreeSmart } from "../lib/fs-utils.mjs";

export function installCursor(srcDir, targetProjectDir, report) {
  copyTreeSmart(path.join(srcDir, "rules"), path.join(targetProjectDir, ".cursor", "rules"), report);
}
