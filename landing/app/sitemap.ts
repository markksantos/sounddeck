import type { MetadataRoute } from "next";
import { appGuides } from "@/lib/content";
import { absoluteUrl } from "@/lib/site";

const routes = [
  "/",
  "/download",
  "/features",
  "/use-cases",
  "/compatibility",
  "/guides",
  "/compare",
  "/pricing",
  "/system-requirements",
  "/docs",
  "/docs/getting-started",
  "/docs/audio-driver",
  "/docs/microphone-permission",
  "/docs/virtual-microphone",
  "/docs/import-sounds",
  "/docs/free-plan",
  "/docs/folders",
  "/docs/pro-library",
  "/docs/trim-volume",
  "/docs/monitoring-preview",
  "/docs/voice-effects",
  "/docs/troubleshooting",
  "/docs/uninstall",
  "/docs/hotkeys",
  "/faq",
  "/support",
  "/contact",
  "/privacy",
  "/terms",
  "/changelog",
  "/security",
  "/press",
  ...appGuides.map((guide) => `/guides/${guide.slug}`),
];

export default function sitemap(): MetadataRoute.Sitemap {
  return routes.map((route) => ({
    url: absoluteUrl(route),
    lastModified: new Date("2026-05-06"),
    changeFrequency: route === "/" ? "weekly" : "monthly",
    priority: route === "/" ? 1 : route === "/download" ? 0.9 : 0.7,
  }));
}
