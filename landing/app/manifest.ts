import type { MetadataRoute } from "next";
import { absoluteUrl, siteConfig } from "@/lib/site";

export default function manifest(): MetadataRoute.Manifest {
  return {
    name: `${siteConfig.name} - macOS Soundboard and Virtual Microphone`,
    short_name: siteConfig.name,
    description: siteConfig.shortDescription,
    start_url: absoluteUrl("/"),
    scope: absoluteUrl("/"),
    display: "standalone",
    background_color: "#f6f1e8",
    theme_color: "#f6f1e8",
    categories: ["music", "productivity", "utilities"],
    lang: "en-US",
    icons: [
      {
        src: absoluteUrl("/icon-192.png"),
        sizes: "192x192",
        type: "image/png",
        purpose: "any",
      },
      {
        src: absoluteUrl("/icon-512.png"),
        sizes: "512x512",
        type: "image/png",
        purpose: "any",
      },
    ],
  };
}
