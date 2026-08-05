import type { Metadata } from "next";
import Link from "next/link";
import JsonLd from "@/components/JsonLd";
import PublicPage from "@/components/PublicPage";
import {
  virtualMicrophoneChecks,
  virtualMicrophoneFaqs,
  virtualMicrophoneFlow,
} from "@/lib/content";
import { absoluteUrl, siteConfig, supportMailtoLink } from "@/lib/site";

const pageDescription =
  "SoundDeck Virtual Mic routing guide for installing the driver, selecting the hardware microphone in SoundDeck, choosing SoundDeck Virtual Mic in target apps, monitoring audio, and fixing missing inputs.";

export const metadata: Metadata = {
  title: "Virtual Microphone Guide",
  description: pageDescription,
  alternates: { canonical: "/docs/virtual-microphone" },
};

const pageUrl = "/docs/virtual-microphone";

const virtualMicSchema = [
  {
    "@context": "https://schema.org",
    "@type": "CollectionPage",
    name: "SoundDeck Virtual Microphone Guide",
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
        name: "Virtual Microphone",
        item: absoluteUrl(pageUrl),
      },
    ],
  },
  {
    "@context": "https://schema.org",
    "@type": "ItemList",
    name: "SoundDeck Virtual Mic routing checks",
    itemListElement: virtualMicrophoneChecks.map((check, index) => ({
      "@type": "ListItem",
      position: index + 1,
      name: check,
    })),
  },
  {
    "@context": "https://schema.org",
    "@type": "HowTo",
    name: "Route audio through SoundDeck Virtual Mic",
    description: pageDescription,
    url: absoluteUrl(pageUrl),
    step: virtualMicrophoneFlow.map((step, index) => ({
      "@type": "HowToStep",
      position: index + 1,
      name: step.title,
      text: step.body,
    })),
  },
  {
    "@context": "https://schema.org",
    "@type": "FAQPage",
    mainEntity: virtualMicrophoneFaqs.map((faq) => ({
      "@type": "Question",
      name: faq.q,
      acceptedAnswer: {
        "@type": "Answer",
        text: faq.a,
      },
    })),
  },
];

export default function VirtualMicrophonePage() {
  return (
    <PublicPage
      eyebrow="Docs"
      title="SoundDeck Virtual Microphone routing guide"
      description="Route your hardware microphone, sound pads, and voice effects through SoundDeck Virtual Mic so calls, streams, and recordings receive one clean microphone input."
    >
      <JsonLd data={virtualMicSchema} />

      <div className="two-column">
        <div className="info-panel">
          <h2>The Route</h2>
          <p>
            SoundDeck listens to your hardware microphone, mixes in triggered
            sound pads and voice effects locally, then sends that combined audio
            through SoundDeck Virtual Mic.
          </p>
        </div>

        <div className="info-panel">
          <h2>Selection Rule</h2>
          <p>
            Select your hardware microphone inside SoundDeck. Select SoundDeck
            Virtual Mic inside Zoom, Discord, Google Meet, Teams, OBS,
            Riverside, browsers, or another target app.
          </p>
        </div>
      </div>

      <div className="stack-list numbered">
        {virtualMicrophoneFlow.map((step, index) => (
          <article className="info-panel" key={step.title}>
            <span className="step-number">{index + 1}</span>
            <h2>{step.title}</h2>
            <p>{step.body}</p>
          </article>
        ))}
      </div>

      <div className="two-column">
        <div className="info-panel">
          <h2>Clean Route Checklist</h2>
          <ol className="check-list">
            {virtualMicrophoneChecks.map((check) => (
              <li key={check}>{check}</li>
            ))}
          </ol>
        </div>

        <div className="info-panel">
          <h2>Virtual Mic FAQ</h2>
          {virtualMicrophoneFaqs.map((faq) => (
            <section key={faq.q}>
              <h3>{faq.q}</h3>
              <p>{faq.a}</p>
            </section>
          ))}
        </div>
      </div>

      <div className="two-column">
        <div className="info-panel">
          <h2>Related Setup Paths</h2>
          <p>
            Use the app-specific guides when the virtual mic route is correct in
            SoundDeck but a target app still needs its own microphone picker
            changed.
          </p>
          <Link className="button button-ghost" href="/guides">
            Open app setup guides
          </Link>
          <Link className="button button-ghost" href="/docs/troubleshooting">
            Open troubleshooting
          </Link>
        </div>

        <div className="info-panel">
          <h2>Need Routing Help?</h2>
          <p>
            Include your macOS version, target app, driver status, SoundDeck
            input device, target app microphone, and whether browser tabs were
            reloaded after changing devices.
          </p>
          <a className="button button-primary" href={supportMailtoLink()}>
            Email virtual mic support
          </a>
          <Link className="button button-ghost" href="/system-requirements">
            Check system requirements
          </Link>
        </div>
      </div>
    </PublicPage>
  );
}
