import { CSV } from "https://js.sabae.cc/CSV.js";
import HTMLParser from "https://dev.jspm.io/node-html-parser";

const url = "https://www.yatex.org/gitbucket/touhoku_procon/touhoku_procon/pages/m_m_game_download.html";
const html = await (await fetch(url)).text();
const root = HTMLParser.parse(html);

const data = [];
const links = root.querySelectorAll("a");
for (const link of links) {
  const href = link.attributes.href;
  const title = link.text.trim();
  console.log(href, title);
  data.push({ href, title })
}
await Deno.writeTextFile("links.csv", CSV.stringify(data));
