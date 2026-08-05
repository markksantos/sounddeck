import type { Metadata } from "next";
import Link from "next/link";
import JsonLd from "@/components/JsonLd";
import PublicPage from "@/components/PublicPage";
import {
  microphonePermissionChecks,
  microphonePermissionFaqs,
  microphonePermissionSteps,
} from "@/lib/content";
import { absoluteUrl, siteConfig, supportMailtoLink } from "@/lib/site";

const pageDescription =
  "Grant macOS microphone permission to SoundDeck, restart the app, recheck the hardware microphone route, and recover missing permission prompts.";

const pageUrl = "/docs/microphone-permission";

export const metadata: Metadata = {
  title: "Microphone Permission Guide",
  description: pageDescription,
  alternates: { canonical: pageUrl },
};

const microphonePermissionSchema = [
  {
    "@context": "https://schema.org",
    "@type": "CollectionPage",
    name: "SoundDeck Microphone Permission Guide",
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
        name: "Microphone Permission",
        item: absoluteUrl(pageUrl),
      },
    ],
  },
  {
    "@context": "https://schema.org",
    "@type": "ItemList",
    name: "SoundDeck microphone permission checks",
    itemListElement: microphonePermissionChecks.map((check, index) => ({
      "@type": "ListItem",
      position: index + 1,
      name: check,
    })),
  },
  {
    "@context": "https://schema.org",
    "@type": "HowTo",
    name: "Grant microphone permission to SoundDeck",
    description: pageDescription,
    url: absoluteUrl(pageUrl),
    step: microphonePermissionSteps.map((step, index) => ({
      "@type": "HowToStep",
      position: index + 1,
      name: step.title,
      text: step.body,
    })),
  },
  {
    "@context": "https://schema.org",
    "@type": "FAQPage",
    mainEntity: microphonePermissionFaqs.map((faq) => ({
      "@type": "Question",
      name: faq.q,
      acceptedAnswer: {
        "@type": "Answer",
        text: faq.a,
      },
    })),
  },
];

export default function MicrophonePermissionPage() {
  return (
    <PublicPage
      eyebrow="Docs"
      title="Grant microphone access to SoundDeck"
      description="Use this guide when SoundDeck cannot hear your hardware microphone or macOS Privacy & Security has blocked the app."
    >
      <JsonLd data={microphonePermissionSchema} />

      <div className="two-column">
        <div className="info-panel">
          <h2>Permission Path</h2>
          <p>
            Open System Settings, choose Privacy & Security, then Microphone.
            SoundDeck must be enabled there before it can receive your hardware
            microphone.
          </p>
        </div>

        <div className="info-panel">
          <h2>Why Permission Matters</h2>
          <p>
            SoundDeck processes audio locally, but macOS still requires
            microphone permission before the app can mix your voice with sound
            pads and send it through SoundDeck Virtual Mic.
          </p>
        </div>
      </div>

      <div className="stack-list numbered">
        {microphonePermissionSteps.map((step, index) => (
          <article className="info-panel" key={step.title}>
            <span className="step-number">{index + 1}</span>
            <h2>{step.title}</h2>
            <p>{step.body}</p>
          </article>
        ))}
      </div>

      <div className="two-column">
        <div className="info-panel">
          <h2>Recovery Checks</h2>
          <ol className="check-list">
            {microphonePermissionChecks.map((check) => (
              <li key={check}>{check}</li>
            ))}
          </ol>
        </div>

        <div className="info-panel">
          <h2>Permission FAQ</h2>
          {microphonePermissionFaqs.map((faq) => (
            <section key={faq.q}>
              <h3>{faq.q}</h3>
              <p>{faq.a}</p>
            </section>
          ))}
        </div>
      </div>

      <div className="two-column">
        <div className="info-panel">
          <h2>After Permission Works</h2>
          <p>
            Continue with the virtual microphone route: hardware mic inside
            SoundDeck, SoundDeck Virtual Mic inside the target app, then a short
            sound pad test before going live.
          </p>
          <Link className="button button-ghost" href="/docs/virtual-microphone">
            Open virtual mic guide
          </Link>
          <Link className="button button-ghost" href="/system-requirements">
            Check system requirements
          </Link>
        </div>

        <div className="info-panel">
          <h2>Still Blocked?</h2>
          <p>
            Include your macOS version, SoundDeck version, target app, selected
            microphone, whether SoundDeck appears in Microphone settings, and
            whether the app was restarted after permission changed.
          </p>
          <a className="button button-primary" href={supportMailtoLink()}>
            Email microphone support
          </a>
          <Link className="button button-ghost" href="/docs/troubleshooting">
            Open troubleshooting
          </Link>
        </div>
      </div>
    </PublicPage>
  );
}
