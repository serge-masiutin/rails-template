import { createHash } from "node:crypto";
import { readFile } from "node:fs/promises";

const root = new URL("../vendor/agent-prism/", import.meta.url);
const source = JSON.parse(await readFile(new URL("source.json", root), "utf8"));
for (const [path, expected] of Object.entries(source.files)) {
  const actual = createHash("sha256").update(await readFile(new URL(path, root))).digest("hex");
  if (actual !== expected) throw new Error(`Изменён upstream AgentPrism: ${path}. Проверьте источник и обновите manifest.`);
}
console.log(`AgentPrism: ${Object.keys(source.files).length} файлов, commit ${source.commit}`);
