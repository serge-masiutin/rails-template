import { createHash } from "node:crypto";
import { readFile } from "node:fs/promises";

const root = new URL("../vendor/agent-prism/", import.meta.url);
const source = JSON.parse(await readFile(new URL("source.json", root), "utf8"));
for (const [path, expected] of Object.entries(source.files)) {
  const actual = createHash("sha256").update(await readFile(new URL(path, root))).digest("hex");
  if (actual !== expected) throw new Error(`Upstream AgentPrism changed: ${path}. Review the source and update the manifest.`);
}
console.log(`AgentPrism: ${Object.keys(source.files).length} files, commit ${source.commit}`);
