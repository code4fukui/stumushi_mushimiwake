import { CSV } from "https://js.sabae.cc/CSV.js";
import { sleep } from "https://js.sabae.cc/sleep.js";

const fn = "links.csv";
const data = await CSV.fetchJSON(fn);
const pre = "https://www.yatex.org/gitbucket/touhoku_procon/touhoku_procon/raw/main/";
for (const d of data) {
  const url = d.href;
  if (!url.startsWith(pre)) continue;
  const bin = new Uint8Array(await (await fetch(url)).arrayBuffer());
  const fn = url.substring(url.lastIndexOf("/") + 1);
  console.log(fn);
  await Deno.writeFile(fn, bin);
  await sleep(500);
}
