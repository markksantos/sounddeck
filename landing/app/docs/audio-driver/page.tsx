import type { Metadata } from "next";
import Link from "next/link";
import JsonLd from "@/components/JsonLd";
import PublicPage from "@/components/PublicPage";
import { audioDriverChecks, audioDriverFaqs, audioDriverSteps } from "@/lib/content";
import { absoluteUrl, siteConfig, supportMailtoLink } from "@/lib/site";

const pageDescription =
  "Install, approve, reinstall, and verify the SoundDeck CoreAudio driver so SoundDeck Virtual Mic appears in macOS target apps.";

const pageUrl = "/docs/audio-driver";

export const metadata: Metadata = {
  title: "Audio Driver Guide",
  description: pageDescription,
  alternates: { canonical: pageUrl },
};

const audioDriverSchema = [
  {
    "@context": "https://schema.org",
    "@type": "CollectionPage",
    name: "SoundDeck Audio Driver Guide",
    url: absoluteUrl(pageUrl),
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
      {
        "@type": "ListItem",
        position: 3,
        name: "Audio Driver",
        item: absoluteUrl(pageUrl),
      },
    ],
  },
  {
    "@context": "https://schema.org",
    "@type": "ItemList",
    name: "SoundDeck audio driver verification checks",
    itemListElement: audioDriverChecks.map((check, index) => ({
      "@type": "ListItem",
      position: index + 1,
      name: check,
    })),
  },
  {
    "@context": "https://schema.org",
    "@type": "HowTo",
    name: "Install and verify SoundDeck Virtual Mic",
    description: pageDescription,
    url: absoluteUrl(pageUrl),
    step: audioDriverSteps.map((step, index) => ({
      "@type": "HowToStep",
      position: index + 1,
      name: step.title,
      text: step.body,
    })),
  },
  {
    "@context": "https://schema.org",
    "@type": "FAQPage",
    mainEntity: audioDriverFaqs.map((faq) => ({
      "@type": "Question",
      name: faq.q,
      acceptedAnswer: {
        "@type": "Answer",
        text: faq.a,
      },
    })),
  },
];

export default function AudioDriverPage() {
  return (
    <PublicPage
      eyebrow="Docs"
      title="Install the SoundDeck audio driver"
      description="Use this guide when SoundDeck Virtual Mic is missing, driver approval is blocked, or a target app needs to see the virtual microphone after setup."
    >
      <JsonLd data={audioDriverSchema} />

      <div className="two-column">
        <div className="info-panel">
          <h2>Driver Role</h2>
          <p>
            SoundDeck Virtual Mic is the CoreAudio route that lets Zoom,
            Discord, Google Meet, Teams, OBS, Riverside, browsers, and other
            apps receive SoundDeck as a microphone input.
          </p>
        </div>

        <div className="info-panel">
          <h2>Approval Path</h2>
          <p>
            Driver installation needs administrator approval. Some macOS builds
            may also ask you to allow the system audio plugin in System
            Settings before target apps can see it.
          </p>
        </div>
      </div>

      <div className="stack-list numbered">
        {audioDriverSteps.map((step, index) => (
          <article className="info-panel" key={step.title}>
            <span className="step-number">{index + 1}</span>
            <h2>{step.title}</h2>
            <p>{step.body}</p>
          </article>
        ))}
      </div>

      <div className="two-column">
        <div className="info-panel">
          <h2>Driver Verification Checks</h2>
          <ol className="check-list">
            {audioDriverChecks.map((check) => (
              <li key={check}>{check}</li>
            ))}
          </ol>
        </div>

        <div className="info-panel">
          <h2>Audio Driver FAQ</h2>
          {audioDriverFaqs.map((faq) => (
            <section key={faq.q}>
              <h3>{faq.q}</h3>
              <p>{faq.a}</p>
            </section>
          ))}
        </div>
      </div>

      <div className="two-column">
        <div className="info-panel">
          <h2>After The Driver Appears</h2>
          <p>
            Continue with the route check: hardware microphone inside SoundDeck,
            SoundDeck Virtual Mic inside the target app, then one short test pad
            before a live call or recording.
          </p>
          <Link className="button button-ghost" href="/docs/virtual-microphone">
            Open virtual mic guide
          </Link>
          <Link className="button button-ghost" href="/docs/microphone-permission">
            Open microphone permission guide
          </Link>
        </div>

        <div className="info-panel">
          <h2>Still Missing?</h2>
          <p>
            Include your macOS version, SoundDeck version, driver status,
            target app, whether administrator approval appeared, and whether the
            target app was restarted after installation.
          </p>
          <a className="button button-primary" href={supportMailtoLink()}>
            Email driver support
          </a>
          <Link className="button button-ghost" href="/docs/troubleshooting">
            Open troubleshooting
          </Link>
        </div>
      </div>
    </PublicPage>
  );
}
