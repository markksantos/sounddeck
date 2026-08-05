import type { MetadataRoute } from "next";
import { absoluteUrl, siteHost } from "@/lib/site";

export default function robots(): MetadataRoute.Robots {
  return {
    rules: [
      {
        userAgent: "*",
        allow: "/",
      },
      {
        userAgent: [
          "GPTBot",
          "ChatGPT-User",
          "OAI-SearchBot",
          "PerplexityBot",
          "ClaudeBot",
          "Google-Extended",
          "Googlebot",
          "Bingbot",
        ],
        allow: "/",
      },
    ],
    sitemap: absoluteUrl("/sitemap.xml"),
    host: siteHost,
  };
}
