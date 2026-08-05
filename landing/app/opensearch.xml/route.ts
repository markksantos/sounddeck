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

export function GET() {
  const xml = [
    '<?xml version="1.0" encoding="UTF-8"?>',
    '<OpenSearchDescription xmlns="http://a9.com/-/spec/opensearch/1.1/">',
    `  <ShortName>${escapeXml(siteConfig.name)}</ShortName>`,
    `  <LongName>${escapeXml(`${siteConfig.name} Support Search`)}</LongName>`,
    `  <Description>${escapeXml(`Search ${siteConfig.name} setup help, common fixes, and launch FAQ.`)}</Description>`,
    `  <Contact>${escapeXml(siteConfig.supportEmail)}</Contact>`,
    "  <InputEncoding>UTF-8</InputEncoding>",
    `  <Image width="16" height="16" type="image/x-icon">${escapeXml(absoluteUrl("/favicon.ico"))}</Image>`,
    `  <Url type="text/html" method="get" template="${escapeXml(`${absoluteUrl("/support")}?q={searchTerms}`)}" />`,
    "</OpenSearchDescription>",
    "",
  ].join("\n");

  return new Response(xml, {
    headers: {
      "Content-Type": "application/opensearchdescription+xml; charset=utf-8",
      "Cache-Control": "public, max-age=3600",
    },
  });
}
