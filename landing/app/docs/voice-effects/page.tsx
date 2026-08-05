import type { Metadata } from "next";
import Link from "next/link";
import JsonLd from "@/components/JsonLd";
import PublicPage from "@/components/PublicPage";
import { voiceEffectsChecks, voiceEffectsFaqs, voiceEffectsSteps } from "@/lib/content";
import { absoluteUrl, siteConfig, supportMailtoLink } from "@/lib/site";

const pageDescription =
  "Use SoundDeck Pro voice effects safely with pitch presets, Voice Monitor, virtual microphone routing, toggle hotkeys, and live-room checks.";

const pageUrl = "/docs/voice-effects";

export const metadata: Metadata = {
  title: "Voice Effects Guide",
  description: pageDescription,
  alternates: { canonical: pageUrl },
};

const voiceEffectsSchema = [
  {
    "@context": "https://schema.org",
    "@type": "CollectionPage",
    name: "SoundDeck Voice Effects Guide",
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
        name: "Voice Effects",
        item: absoluteUrl(pageUrl),
      },
    ],
  },
  {
    "@context": "https://schema.org",
    "@type": "ItemList",
    name: "SoundDeck voice effects verification checks",
    itemListElement: voiceEffectsChecks.map((check, index) => ({
      "@type": "ListItem",
      position: index + 1,
      name: check,
    })),
  },
  {
    "@context": "https://schema.org",
    "@type": "HowTo",
    name: "Use SoundDeck voice effects safely",
    description: pageDescription,
    url: absoluteUrl(pageUrl),
    step: voiceEffectsSteps.map((step, index) => ({
      "@type": "HowToStep",
      position: index + 1,
      name: step.title,
      text: step.body,
    })),
  },
  {
    "@context": "https://schema.org",
    "@type": "FAQPage",
    mainEntity: voiceEffectsFaqs.map((faq) => ({
      "@type": "Question",
      name: faq.q,
      acceptedAnswer: {
        "@type": "Answer",
        text: faq.a,
      },
    })),
  },
];

export default function VoiceEffectsPage() {
  return (
    <PublicPage
      eyebrow="Docs"
      title="Use voice effects in SoundDeck"
      description="Shift your voice locally, monitor the result privately, and send the final mix through SoundDeck Virtual Mic only when the route is ready."
    >
      <JsonLd data={voiceEffectsSchema} />

      <div className="two-column">
        <div className="info-panel">
          <h2>Pro Feature</h2>
          <p>
            Voice Changer is included with SoundDeck Pro. Use the free plan to
            confirm the virtual microphone route, then upgrade when voice
            effects need to be part of the live workflow.
          </p>
          <Link className="button button-ghost" href="/pricing">
            Compare Free and Pro
          </Link>
          <Link className="button button-ghost" href="/docs/free-plan">
            Open Free plan guide
          </Link>
        </div>

        <div className="info-panel">
          <h2>Local Voice Processing</h2>
          <p>
            SoundDeck applies pitch changes on your Mac before sending the mixed
            microphone and soundboard output through SoundDeck Virtual Mic.
          </p>
          <Link className="button button-ghost" href="/privacy">
            Read privacy notes
          </Link>
        </div>
      </div>

      <div className="stack-list numbered">
        {voiceEffectsSteps.map((step, index) => (
          <article className="info-panel" key={step.title}>
            <span className="step-number">{index + 1}</span>
            <h2>{step.title}</h2>
            <p>{step.body}</p>
          </article>
        ))}
      </div>

      <div className="two-column">
        <div className="info-panel">
          <h2>Voice Effects Verification Checks</h2>
          <ol className="check-list">
            {voiceEffectsChecks.map((check) => (
              <li key={check}>{check}</li>
            ))}
          </ol>
        </div>

        <div className="info-panel">
          <h2>Voice Effects FAQ</h2>
          {voiceEffectsFaqs.map((faq) => (
            <section key={faq.q}>
              <h3>{faq.q}</h3>
              <p>{faq.a}</p>
            </section>
          ))}
        </div>
      </div>

      <div className="two-column">
        <div className="info-panel">
          <h2>Before Going Live</h2>
          <p>
            Confirm the route with a normal voice first, enable the effect,
            monitor through headphones, then keep Toggle voice changer and Stop
            All hotkeys ready.
          </p>
          <Link className="button button-ghost" href="/docs/virtual-microphone">
            Open virtual mic guide
          </Link>
          <Link className="button button-ghost" href="/docs/monitoring-preview">
            Open monitoring guide
          </Link>
          <Link className="button button-ghost" href="/docs/free-plan">
            Open Free plan guide
          </Link>
          <Link className="button button-ghost" href="/docs/hotkeys">
            Open hotkeys guide
          </Link>
        </div>

        <div className="info-panel">
          <h2>Voice Effects Still Failing?</h2>
          <p>
            Include SoundDeck plan, pitch setting, target app, microphone
            selection, Voice Monitor state, hotkey setup, macOS version, and
            SoundDeck version.
          </p>
          <a className="button button-primary" href={supportMailtoLink()}>
            Email voice effects support
          </a>
          <Link className="button button-ghost" href="/support">
            Search support
          </Link>
        </div>
      </div>
    </PublicPage>
  );
}
