import type { Metadata } from "next";
import Link from "next/link";
import JsonLd from "@/components/JsonLd";
import PublicPage from "@/components/PublicPage";
import { appGuides, docsGuides } from "@/lib/content";
import { absoluteUrl, siteConfig, supportMailtoLink } from "@/lib/site";

const pageDescription =
  "SoundDeck documentation for setup, troubleshooting, hotkeys, virtual microphone routing, driver checks, and live audio workflows.";

export const metadata: Metadata = {
  title: "Docs",
  description: pageDescription,
  alternates: { canonical: "/docs" },
};

const docsSchema = [
  {
    "@context": "https://schema.org",
    "@type": "CollectionPage",
    name: "SoundDeck Docs",
    url: absoluteUrl("/docs"),
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
        name: "Docs",
        item: absoluteUrl("/docs"),
      },
    ],
  },
  {
    "@context": "https://schema.org",
    "@type": "ItemList",
    name: "SoundDeck documentation guides",
    itemListElement: docsGuides.map((guide, index) => ({
      "@type": "ListItem",
      position: index + 1,
      name: guide.title,
      url: absoluteUrl(guide.href),
      description: `${guide.summary} ${guide.bestFor}`,
    })),
  },
];

export default function DocsPage() {
  const appGuideNames = appGuides.map((guide) => guide.name).join(", ");

  return (
    <PublicPage
      eyebrow="Docs"
      title="SoundDeck setup, routing, and live-control guides"
      description="Start with the setup path, then use the focused guides for driver issues, SoundDeck Virtual Mic routing, shortcut conflicts, and live workflow checks."
    >
      <JsonLd data={docsSchema} />

      <div className="stack-list">
        {docsGuides.map((guide) => (
          <article className="info-panel" key={guide.href}>
            <h2>{guide.title}</h2>
            <p>{guide.summary}</p>
            <p className="card-kicker">{guide.bestFor}</p>
            <Link className="button button-ghost" href={guide.href}>
              Open {guide.title.toLowerCase()}
            </Link>
          </article>
        ))}
      </div>

      <div className="two-column">
        <div className="info-panel">
          <h2>Clean Setup Pattern</h2>
          <p>
            SoundDeck should be open, the driver installed, microphone permission
            granted, your real mic selected inside SoundDeck, and SoundDeck
            Virtual Mic selected inside the target app.
          </p>
        </div>

        <div className="info-panel">
          <h2>App Setup Guides</h2>
          <p>
            {`Open focused routing instructions for ${appGuideNames}, and other microphone-picker workflows.`}
          </p>
          <Link className="button button-ghost" href="/guides">
            Open app guides
          </Link>
        </div>
      </div>

      <div className="info-panel">
        <h2>Need Direct Help?</h2>
        <p>
          Include your macOS version, SoundDeck version, target app, driver
          status, selected microphone, and whether the issue affects setup,
          playback, hotkeys, or Pro access.
        </p>
        <a className="button button-primary" href={supportMailtoLink()}>
          Email docs support
        </a>
        <Link className="button button-ghost" href="/support">
          Search support
        </Link>
      </div>
    </PublicPage>
  );
}
