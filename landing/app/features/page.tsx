import type { Metadata } from "next";
import Link from "next/link";
import JsonLd from "@/components/JsonLd";
import PublicPage from "@/components/PublicPage";
import { productFeatures, trustItems } from "@/lib/content";
import { absoluteUrl, siteConfig } from "@/lib/site";

const pageDescription =
  "SoundDeck features for macOS virtual microphone routing, sound pads, voice changer, hotkeys, monitoring, trimming, privacy, and driver setup.";

export const metadata: Metadata = {
  title: "Features",
  description: pageDescription,
  alternates: { canonical: "/features" },
};

const featuresSchema = [
  {
    "@context": "https://schema.org",
    "@type": "CollectionPage",
    name: "SoundDeck Features",
    url: absoluteUrl("/features"),
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
        name: "Features",
        item: absoluteUrl("/features"),
      },
    ],
  },
  {
    "@context": "https://schema.org",
    "@type": "ItemList",
    name: "SoundDeck feature set",
    itemListElement: productFeatures.map((feature, index) => ({
      "@type": "ListItem",
      position: index + 1,
      name: feature.title,
      description: `${feature.description} ${feature.proof}`,
    })),
  },
];

export default function FeaturesPage() {
  return (
    <PublicPage
      eyebrow="Features"
      title="A native Mac soundboard built around the microphone path"
      description="SoundDeck combines virtual microphone routing, a fast sound grid, monitoring, hotkeys, voice effects, and local-first audio controls in one menu bar app."
    >
      <JsonLd data={featuresSchema} />

      <div className="stack-list">
        {productFeatures.map((feature) => (
          <article className="info-panel" key={feature.title}>
            <h2>{feature.title}</h2>
            <p>{feature.description}</p>
            <p className="card-kicker">{feature.proof}</p>
          </article>
        ))}
      </div>

      <div className="two-column">
        <div className="info-panel">
          <h2>Trust Details</h2>
          <ul>
            {trustItems.map((item) => (
              <li key={item.title}>
                <span>{item.title}: </span>
                <span>{item.description}</span>
              </li>
            ))}
          </ul>
        </div>

        <div className="info-panel">
          <h2>Next Steps</h2>
          <p>
            Install SoundDeck, grant microphone permission, choose SoundDeck
            Virtual Mic in your target app, then test your first sound pad.
          </p>
          <Link className="button button-primary" href="/download">
            Download SoundDeck
          </Link>
          <Link className="button button-ghost" href="/docs/getting-started">
            Read setup guide
          </Link>
          <Link className="button button-ghost" href="/docs/virtual-microphone">
            Read virtual mic guide
          </Link>
          <Link className="button button-ghost" href="/docs/folders">
            Read folders guide
          </Link>
          <Link className="button button-ghost" href="/docs/pro-library">
            Read Pro library guide
          </Link>
          <Link className="button button-ghost" href="/docs/voice-effects">
            Read voice effects guide
          </Link>
          <Link className="button button-ghost" href="/docs/trim-volume">
            Read trim and volume guide
          </Link>
          <Link className="button button-ghost" href="/docs/monitoring-preview">
            Read monitoring guide
          </Link>
          <Link className="button button-ghost" href="/docs/hotkeys">
            Read hotkeys guide
          </Link>
        </div>
      </div>
    </PublicPage>
  );
}
