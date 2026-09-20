const { readFileSync } = require("node:fs");
const { join } = require("node:path");

// Reuse the upstream palette to keep color names aligned.
const theme = readFileSync(join(__dirname, "../vendor/agent-prism/components/theme/index.ts"), "utf8");
const tokens = theme.split("AGENT_PRISM_TOKENS = [")[1].split("] as const")[0].matchAll(/"([a-z-]+)"/g);
module.exports = {
  theme: { extend: { colors: Object.fromEntries([...tokens].map(([, token]) =>
    [`agentprism-${token}`, `oklch(var(--agentprism-${token}) / <alpha-value>)`])) } },
};
