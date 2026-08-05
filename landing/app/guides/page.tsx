import type { Metadata } from "next";
import Link from "next/link";
import JsonLd from "@/components/JsonLd";
import PublicPage from "@/components/PublicPage";
import { appGuides } from "@/lib/content";
import { absoluteUrl, siteConfig, supportMailtoLink } from "@/lib/site";

const pageDescription =
  "SoundDeck app setup guides for Zoom, Discord, Google Meet, Microsoft Teams, OBS, Riverside, and other tools with microphone pickers.";

export const metadata: Metadata = {
  title: "App Setup Guides",
  description: pageDescription,
  alternates: { canonical: "/guides" },
};

const guidesSchema = [
  {
    "@context": "https://schema.org",
    "@type": "CollectionPage",
    name: "SoundDeck App Setup Guides",
    url: absoluteUrl("/guides"),
    description: pageDescription,
    about: {
      "@type": "SoftwareApplication",
      name: siteConfig.name,
      applicationCategory: siteConfig.appStoreCategory,
      operatingSystem: "macOS",
      softwareVersion: siteConfig.currentVersion,
      url: siteConfig.url,
    },
  },
  {
    "@context": "https://schema.org",
    "@type": "BreadcrumbList",
    itemListElement: [
      {
        "@type": "ListItem",
        position: 1,
        name: "Home",
        item: siteConfig.url,
      },
      {
        "@type": "ListItem",
        position: 2,
        name: "App Setup Guides",
        item: absoluteUrl("/guides"),
      },
    ],
  },
  {
    "@context": "https://schema.org",
    "@type": "ItemList",
    name: "SoundDeck app setup guides",
    itemListElement: appGuides.map((guide, index) => ({
      "@type": "ListItem",
      position: index + 1,
      name: guide.title,
      url: absoluteUrl(`/guides/${guide.slug}`),
      description: `${guide.summary} ${guide.bestFor}`,
    })),
  },
];

export default function GuidesPage() {
  return (
    <PublicPage
      eyebrow="Guides"
      title="App-specific SoundDeck setup guides"
      description="Choose your target app, select SoundDeck Virtual Mic there, and keep your real microphone managed inside SoundDeck."
    >
      <JsonLd data={guidesSchema} />

      <div className="stack-list">
        {appGuides.map((guide) => (
          <article className="info-panel" key={guide.slug}>
            <p className="eyebrow">{guide.category}</p>
            <h2>{guide.name}</h2>
            <p>{guide.summary}</p>
            <p className="card-kicker">{guide.bestFor}</p>
            <Link className="button button-ghost" href={`/guides/${guide.slug}`}>
              {`Open ${guide.name} guide`}
            </Link>
          </article>
        ))}
      </div>

      <div className="two-column">
        <div className="info-panel">
          <h2>Universal Routing Rule</h2>
          <p>
            If the app can choose a microphone, choose SoundDeck Virtual Mic
            there. SoundDeck handles your hardware microphone, sound pads, voice
            changer, monitoring, and Stop All controls locally.
          </p>
          <Link className="button button-ghost" href="/compatibility">
            View compatibility
          </Link>
        </div>

        <div className="info-panel">
          <h2>Need A Missing App?</h2>
          <p>
            Email support with the target app name, macOS version, SoundDeck
            version, and whether the app exposes a microphone picker.
          </p>
          <a className="button button-primary" href={supportMailtoLink()}>
            Email app setup support
          </a>
        </div>
      </div>
    </PublicPage>
  );
}
