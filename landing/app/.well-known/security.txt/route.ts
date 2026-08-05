import { absoluteUrl, siteConfig } from "@/lib/site";

export const dynamic = "force-static";

export function GET() {
  const body = [
    `Contact: mailto:${siteConfig.supportEmail}`,
    `Expires: 2027-05-06T00:00:00.000Z`,
    "Preferred-Languages: en",
    `Canonical: ${absoluteUrl("/.well-known/security.txt")}`,
    `Policy: ${absoluteUrl("/security")}`,
    "",
  ].join("\n");

  return new Response(body, {
    headers: {
      "Content-Type": "text/plain; charset=utf-8",
      "Cache-Control": "public, max-age=3600",
    },
  });
}
