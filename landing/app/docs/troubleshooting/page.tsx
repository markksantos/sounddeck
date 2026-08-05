import type { Metadata } from "next";
import Link from "next/link";
import JsonLd from "@/components/JsonLd";
import PublicPage from "@/components/PublicPage";
import { supportTopics } from "@/lib/content";
import { absoluteUrl, siteConfig, supportMailtoLink } from "@/lib/site";

const pageDescription =
  "Troubleshoot SoundDeck driver installation, SoundDeck Virtual Mic routing, macOS microphone permission, sound playback, and driver uninstall steps.";

export const metadata: Metadata = {
  title: "Troubleshooting",
  description: pageDescription,
  alternates: { canonical: "/docs/troubleshooting" },
};

function topicId(title: string) {
  return title
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-|-$/g, "");
}

const troubleshootingSchema = [
  {
    "@context": "https://schema.org",
    "@type": "CollectionPage",
    name: "SoundDeck Troubleshooting Guide",
    url: absoluteUrl("/docs/troubleshooting"),
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
        name: "Getting Started",
        item: absoluteUrl("/docs/getting-started"),
      },
      {
        "@type": "ListItem",
        position: 3,
        name: "Troubleshooting",
        item: absoluteUrl("/docs/troubleshooting"),
      },
    ],
  },
  {
    "@context": "https://schema.org",
    "@type": "ItemList",
    name: "SoundDeck troubleshooting topics",
    itemListElement: supportTopics.map((topic, index) => ({
      "@type": "ListItem",
      position: index + 1,
      name: topic.title,
      url: absoluteUrl(`/docs/troubleshooting#${topicId(topic.title)}`),
      description: topic.body,
    })),
  },
  ...supportTopics.map((topic) => ({
    "@context": "https://schema.org",
    "@type": "HowTo",
    name: `SoundDeck: ${topic.title}`,
    description: topic.body,
    url: absoluteUrl(`/docs/troubleshooting#${topicId(topic.title)}`),
    step: topic.steps.map((step, index) => ({
      "@type": "HowToStep",
      position: index + 1,
      text: step,
    })),
  })),
];

export default function TroubleshootingPage() {
  return (
    <PublicPage
      eyebrow="Docs"
      title="Troubleshooting SoundDeck setup"
      description="Use these checks when the driver, SoundDeck Virtual Mic, microphone permission, routing, or uninstall flow does not behave as expected."
    >
      <JsonLd data={troubleshootingSchema} />

      <div className="two-column">
        <div className="info-panel">
          <h2>Before You Debug</h2>
          <p>
            Confirm SoundDeck is open, the audio engine indicator is green, and
            your target app is using SoundDeck Virtual Mic instead of your
            hardware microphone.
          </p>
        </div>

        <div className="info-panel">
          <h2>Support Details To Include</h2>
          <p>
            Send your macOS version, SoundDeck version, target app, selected
            microphone, driver status, and a screenshot of SoundDeck Settings.
          </p>
          <a className="button button-primary" href={supportMailtoLink()}>
            Email troubleshooting support
          </a>
        </div>
      </div>

      <div className="stack-list">
        {supportTopics.map((topic) => (
          <article className="info-panel" id={topicId(topic.title)} key={topic.title}>
            <h2>{topic.title}</h2>
            <p>{topic.body}</p>
            <h3>Checks</h3>
            <ul>
              {topic.steps.map((step) => (
                <li key={step}>{step}</li>
              ))}
            </ul>
          </article>
        ))}
      </div>

      <div className="two-column">
        <div className="info-panel">
          <h2>Recheck The Setup Path</h2>
          <p>
            A clean setup is driver installed, microphone permission granted,
            SoundDeck Virtual Mic selected in the target app, and your real mic
            selected inside SoundDeck.
          </p>
          <Link className="button button-ghost" href="/docs/getting-started">
            Open getting started
          </Link>
          <Link className="button button-ghost" href="/docs/audio-driver">
            Open audio driver guide
          </Link>
          <Link className="button button-ghost" href="/docs/microphone-permission">
            Open microphone permission guide
          </Link>
          <Link className="button button-ghost" href="/docs/monitoring-preview">
            Open monitoring guide
          </Link>
        </div>

        <div className="info-panel">
          <h2>Still Blocked?</h2>
          <p>
            Email support before a live call or recording session if SoundDeck
            Virtual Mic still does not appear after reinstalling the driver and
            restarting the target app.
          </p>
          <Link className="button button-ghost" href="/docs/uninstall">
            Open uninstall guide
          </Link>
          <Link className="button button-ghost" href="/support">
            Search support
          </Link>
        </div>
      </div>
    </PublicPage>
  );
}
