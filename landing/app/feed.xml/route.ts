import { changelog, releaseAnchor } from "@/lib/content";
import { absoluteUrl, siteConfig } from "@/lib/site";

export const dynamic = "force-static";

function escapeXml(value: string) {
  return value
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&apos;");
}

function pubDate(date: string) {
  return new Date(date).toUTCString();
}

export function GET() {
  const latest = changelog[0];
  const lastBuildDate = latest ? pubDate(latest.date) : new Date().toUTCString();
  const items = changelog
    .map((release) => {
      const link = absoluteUrl(`/changelog#${releaseAnchor(release.version)}`);
      const description = release.items.join(" ");

      return [
        "    <item>",
        `      <title>${escapeXml(`${siteConfig.name} ${release.version}`)}</title>`,
        `      <link>${escapeXml(link)}</link>`,
        `      <guid isPermaLink="false">${escapeXml(`sounddeck-${release.version}`)}</guid>`,
        `      <pubDate>${escapeXml(pubDate(release.date))}</pubDate>`,
        `      <description>${escapeXml(description)}</description>`,
        "    </item>",
      ].join("\n");
    })
    .join("\n");

  const xml = [
    '<?xml version="1.0" encoding="UTF-8"?>',
    '<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">',
    "  <channel>",
    `    <title>${escapeXml(`${siteConfig.name} Changelog`)}</title>`,
    `    <link>${escapeXml(absoluteUrl("/changelog"))}</link>`,
    `    <description>${escapeXml(`${siteConfig.name} release notes for the macOS soundboard and virtual microphone app.`)}</description>`,
    "    <language>en-us</language>",
    `    <lastBuildDate>${escapeXml(lastBuildDate)}</lastBuildDate>`,
    `    <atom:link href="${escapeXml(absoluteUrl("/feed.xml"))}" rel="self" type="application/rss+xml" />`,
    items,
    "  </channel>",
    "</rss>",
  ].join("\n");

  return new Response(xml, {
    headers: {
      "Content-Type": "application/rss+xml; charset=utf-8",
      "Cache-Control": "public, max-age=3600",
    },
  });
}
