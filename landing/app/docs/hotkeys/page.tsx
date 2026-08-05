import type { Metadata } from "next";
import Link from "next/link";
import JsonLd from "@/components/JsonLd";
import PublicPage from "@/components/PublicPage";
import { hotkeyActions, hotkeyConflictChecks } from "@/lib/content";
import { absoluteUrl, siteConfig, supportMailtoLink } from "@/lib/site";

const pageDescription =
  "Configure SoundDeck global hotkeys, Stop All, Pro voice changer shortcuts, and per-sound hotkeys for macOS calls, streams, recordings, and workshops.";

export const metadata: Metadata = {
  title: "Hotkeys",
  description: pageDescription,
  alternates: { canonical: "/docs/hotkeys" },
};

function actionId(title: string) {
  return title
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-|-$/g, "");
}

const hotkeysSchema = [
  {
    "@context": "https://schema.org",
    "@type": "CollectionPage",
    name: "SoundDeck Hotkeys Guide",
    url: absoluteUrl("/docs/hotkeys"),
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
        name: "Hotkeys",
        item: absoluteUrl("/docs/hotkeys"),
      },
    ],
  },
  {
    "@context": "https://schema.org",
    "@type": "ItemList",
    name: "SoundDeck hotkey actions",
    itemListElement: hotkeyActions.map((action, index) => ({
      "@type": "ListItem",
      position: index + 1,
      name: action.title,
      url: absoluteUrl(`/docs/hotkeys#${actionId(action.title)}`),
      description: `${action.availability}. ${action.behavior}`,
    })),
  },
  ...hotkeyActions.map((action) => ({
    "@context": "https://schema.org",
    "@type": "HowTo",
    name: `Configure ${action.title} in SoundDeck`,
    description: action.behavior,
    url: absoluteUrl(`/docs/hotkeys#${actionId(action.title)}`),
    step: [
      {
        "@type": "HowToStep",
        position: 1,
        text: action.setup,
      },
      {
        "@type": "HowToStep",
        position: 2,
        text: action.behavior,
      },
    ],
  })),
];

export default function HotkeysPage() {
  return (
    <PublicPage
      eyebrow="Docs"
      title="SoundDeck hotkeys guide"
      description="Assign shortcuts for mute, Stop All, Pro voice changer, and individual sound pads so live audio controls work while Zoom, Discord, OBS, Riverside, or a browser stays focused."
    >
      <JsonLd data={hotkeysSchema} />

      <div className="two-column">
        <div className="info-panel">
          <h2>Free Hotkeys</h2>
          <p>
            Mute microphone and Stop All are available on the free plan. They
            are the safest shortcuts to set before testing SoundDeck in a call.
          </p>
        </div>

        <div className="info-panel">
          <h2>Pro Hotkeys</h2>
          <p>
            SoundDeck Pro unlocks voice changer toggling and per-sound hotkeys
            for larger boards, live shows, and repeated production workflows.
          </p>
          <Link className="button button-ghost" href="/pricing">
            Compare Free and Pro
          </Link>
          <Link className="button button-ghost" href="/docs/free-plan">
            Open Free plan guide
          </Link>
          <Link className="button button-ghost" href="/docs/voice-effects">
            Open voice effects guide
          </Link>
        </div>
      </div>

      <div className="stack-list">
        {hotkeyActions.map((action) => (
          <article className="info-panel" id={actionId(action.title)} key={action.title}>
            <p className="eyebrow">{action.availability}</p>
            <h2>{action.title}</h2>
            <p>{action.behavior}</p>
            <h3>Setup</h3>
            <p>{action.setup}</p>
            <p className="card-kicker">Shortcut name: {action.shortcutName}</p>
          </article>
        ))}
      </div>

      <div className="two-column">
        <div className="info-panel">
          <h2>Conflict Checks</h2>
          <ul>
            {hotkeyConflictChecks.map((check) => (
              <li key={check}>{check}</li>
            ))}
          </ul>
        </div>

        <div className="info-panel">
          <h2>Still Not Triggering?</h2>
          <p>
            Include the shortcut combination, target app, SoundDeck version, Pro
            status, and whether the pad badge shows the shortcut.
          </p>
          <a className="button button-primary" href={supportMailtoLink()}>
            Email hotkey support
          </a>
          <Link className="button button-ghost" href="/docs/troubleshooting">
            Open troubleshooting guide
          </Link>
        </div>
      </div>
    </PublicPage>
  );
}
