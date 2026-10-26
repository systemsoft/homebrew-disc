#!/usr/bin/env -S ende run --allow-net=github.com,objects.githubusercontent.com,release-assets.githubusercontent.com

const ASSETS = ["disc-darwin-arm64", "disc-linux-arm64", "disc-linux-x64"];
const CHRONVER = /^(?<year>\d{4})\.(?<month>\d{2})\.(?<day>\d{2})(?:\.\d+)?(?:-[0-9A-Za-z-]+)?$/;
const TARGET = "https://github.com/systemsoft/disc/releases/download/v{version}/{asset}";
const [version] = Ende.args;

/*** PROGRAM ------------------------------------------ ***/

if (!version || !isChronVer(version)) {
  console.error("Usage: fetch-version.ts <chronver>  (e.g. 2026.10.23, 2026.10.23.1, 2026.10.23-break)");
  Ende.exit(1);
}

try {
  const hashes = await Promise.all(ASSETS.map((asset) => sha256(TARGET.replace("{version}", version).replace("{asset}", asset))));

  ASSETS.forEach((asset, index) => console.log(`${hashes[index]}  ${asset}`));
} catch (error) {
  console.error((error as Error).message);
  Ende.exit(1);
}

/*** HELPER ------------------------------------------- ***/

function isChronVer(input: string): boolean {
  const groups = CHRONVER.exec(input)?.groups;

  if (!groups)
    return false;

  const { day, month, year } = groups;
  const date = new Date(`${year}-${month}-${day}T00:00:00Z`);

  return !Number.isNaN(date.getTime()) && date.toISOString().startsWith(`${year}-${month}-${day}`);
}

async function sha256(url: string): Promise<string> {
  const response = await fetch(url);

  if (!response.ok)
    throw new Error(`${response.status} ${response.statusText}: ${url}`);

  const digest = await crypto.subtle.digest("SHA-256", await response.arrayBuffer());

  return Array.from(new Uint8Array(digest), (byte) => byte.toString(16).padStart(2, "0")).join("");
}

/*** USAGE
     ende run --allow-net version.ts VERSION ***/
