import fs from "node:fs/promises";
import path from "node:path";
import { chromium } from "/Users/chenzhuo/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright/index.mjs";

const root = "/Users/chenzhuo/Library/Mobile Documents/com~apple~CloudDocs/Documents/Manuscript/在研项目/大语言模型发布行为对金融市场的影响 - 来自美股市场的证据";
const refsPath = path.join(root, "agent_tasks/ref_audit_20260625-233637/audit_refs.json");
const evidenceDir = path.join(root, "Literature/证据");
const outputPath = path.join(root, "agent_tasks/ref_audit_20260625-233637/playwright_results.json");

const wantedKeys = new Set(process.argv.slice(2));
const refs = JSON.parse(await fs.readFile(refsPath, "utf8"));
const targets = wantedKeys.size ? refs.filter((ref) => wantedKeys.has(ref.key)) : refs;

const browser = await chromium.launch({
  headless: true,
  executablePath: "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
});
const page = await browser.newPage({ viewport: { width: 1440, height: 1100 } });
const results = [];

for (const ref of targets) {
  const query = `"${ref.title}" ${ref.first_author} ${ref.year}`;
  const url = `https://www.bing.com/search?q=${encodeURIComponent(query)}`;
  const record = { key: ref.key, query, url, status: "pending", finalUrl: "", title: "", error: "" };

  try {
    await page.goto(url, { waitUntil: "domcontentloaded", timeout: 30000 });
    await page.screenshot({ path: path.join(evidenceDir, `${ref.key}.png`), fullPage: false });
    record.finalUrl = page.url();
    record.title = await page.title();
    record.status = "saved";
  } catch (error) {
    record.status = "error";
    record.error = error instanceof Error ? error.message : String(error);
  }

  results.push(record);
}

await browser.close();
await fs.writeFile(outputPath, JSON.stringify(results, null, 2));
console.log(JSON.stringify({
  attempted: results.length,
  saved: results.filter((r) => r.status === "saved").length,
  error: results.filter((r) => r.status === "error").length,
}, null, 2));
