import * as esbuild from "esbuild";
import { spawn } from "node:child_process";
import { mkdir, readFile } from "node:fs/promises";

const watch = process.argv.includes("--watch");
await mkdir("app/assets/builds", { recursive: true });
const options = {
  entryPoints: ["app/frontend/agents/index.tsx"], outfile: "app/assets/builds/agent-prism.js",
  tsconfig: "tsconfig.agents.json",
  banner: { js: `/*! AgentPrism\n${await readFile("vendor/agent-prism/LICENSE", "utf8")}*/` },
  bundle: true, minify: !watch, jsx: "automatic", target: "es2022", legalComments: "linked",
  define: { "process.env.NODE_ENV": JSON.stringify("production") },
};
const context = watch ? await esbuild.context(options) : null;
if (context) await context.watch();
else await esbuild.build(options);
const css = spawn("node_modules/.bin/tailwindcss", ["-i", "app/frontend/agents/application.css",
  "-o", "app/assets/builds/agent-prism.css", ...(watch ? ["--watch=always"] : ["--minify"])], { stdio: "inherit" });
let stopping = false;
css.on("exit", async code => {
  await context?.dispose();
  process.exit(stopping ? 0 : (code ?? 1));
});
for (const signal of ["SIGINT", "SIGTERM"]) process.on(signal, () => {
  stopping = true;
  css.kill(signal);
});
