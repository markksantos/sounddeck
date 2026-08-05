import type { Metadata } from "next";
import Link from "next/link";
import JsonLd from "@/components/JsonLd";
import PublicPage from "@/components/PublicPage";
import { appGuides, compatibilityDetails } from "@/lib/content";
import { absoluteUrl, siteConfig, supportMailtoLink } from "@/lib/site";

const pageDescription =
  "SoundDeck compatibility notes for Zoom, Discord, Google Meet, Microsoft Teams, FaceTime, Slack Huddles, OBS, Riverside, browsers, and apps with a microphone picker.";

export const metadata: Metadata = {
  title: "Compatibility",
  description: pageDescription,
  alternates: { canonical: "/compatibility" },
};

const compatibilitySchema = [
  {
    "@context": "https://schema.org",
    "@type": "CollectionPage",
    name: "SoundDeck Compatibility",
    url: absoluteUrl("/compatibility"),
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
        name: "Compatibility",
        item: absoluteUrl("/compatibility"),
      },
    ],
  },
  {
    "@context": "https://schema.org",
    "@type": "ItemList",
    name: "SoundDeck compatible apps",
    itemListElement: compatibilityDetails.map((app, index) => ({
      "@type": "ListItem",
      position: index + 1,
      name: app.name,
      description: `${app.setup} ${app.note}`,
    })),
  },
];

export default function CompatibilityPage() {
  const guideByName = new Map(appGuides.map((guide) => [guide.name, guide]));

  return (
    <PublicPage
      eyebrow="Compatibility"
      title="Use SoundDeck anywhere you can choose a microphone"
      description="SoundDeck appears as a macOS microphone input. Select SoundDeck Virtual Mic in your call, stream, recording, or browser app, then keep your real mic managed inside SoundDeck."
    >
      <JsonLd data={compatibilitySchema} />

      <div className="two-column">
        <div className="info-panel">
          <h2>How The Route Works</h2>
          <p>
            SoundDeck mixes your real microphone, triggered sounds, voice effects,
            and monitor controls locally, then sends that mix through SoundDeck
            Virtual Mic.
          </p>
        </div>

        <div className="info-panel">
          <h2>Setup Rule</h2>
          <p>
            If the target app exposes a microphone selector, choose SoundDeck
            Virtual Mic there. If the app keeps using another mic, restart that
            app after driver installation or reload the browser tab.
          </p>
        </div>
      </div>

      <div className="stack-list">
        {compatibilityDetails.map((app) => {
          const guide = guideByName.get(app.name);

          return (
            <article className="info-panel" key={app.name}>
              <p className="eyebrow">{app.category}</p>
              <h2>{app.name}</h2>
              <h3>Setup</h3>
              <p>{app.setup}</p>
              <h3>Best Fit</h3>
              <p>{app.note}</p>
              {guide ? (
                <Link className="button button-ghost" href={`/guides/${guide.slug}`}>
                  {`Open ${app.name} guide`}
                </Link>
              ) : null}
            </article>
          );
        })}
      </div>

      <div className="two-column">
        <div className="info-panel">
          <h2>Troubleshooting</h2>
          <ul>
            <li>Install or reinstall the audio driver from SoundDeck Settings.</li>
            <li>Grant microphone permission to SoundDeck in macOS System Settings.</li>
            <li>Restart the target app if SoundDeck Virtual Mic does not appear.</li>
            <li>Use Stop All before switching rooms, meetings, or OBS scenes.</li>
          </ul>
        </div>

        <div className="info-panel">
          <h2>Need Direct Help?</h2>
          <p>
            Include your macOS version, SoundDeck version, target app, selected
            input device, and whether SoundDeck Virtual Mic appears in the app.
          </p>
          <a className="button button-primary" href={supportMailtoLink()}>
            Email compatibility support
          </a>
          <Link className="button button-ghost" href="/guides">
            Open app setup guides
          </Link>
          <Link className="button button-ghost" href="/docs/virtual-microphone">
            Open virtual mic guide
          </Link>
          <Link className="button button-ghost" href="/docs/getting-started">
            Open setup guide
          </Link>
        </div>
      </div>
    </PublicPage>
  );
}
