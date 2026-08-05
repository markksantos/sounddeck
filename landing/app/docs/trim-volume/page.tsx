import type { Metadata } from "next";
import Link from "next/link";
import JsonLd from "@/components/JsonLd";
import PublicPage from "@/components/PublicPage";
import { trimVolumeChecks, trimVolumeFaqs, trimVolumeSteps } from "@/lib/content";
import { absoluteUrl, siteConfig, supportMailtoLink } from "@/lib/site";

const pageDescription =
  "Adjust SoundDeck per-sound volume, use the Pro trim editor, preview waveform start and end points, and verify clips before live calls, streams, and recordings.";

const pageUrl = "/docs/trim-volume";

export const metadata: Metadata = {
  title: "Trim And Volume Guide",
  description: pageDescription,
  alternates: { canonical: pageUrl },
};

const trimVolumeSchema = [
  {
    "@context": "https://schema.org",
    "@type": "CollectionPage",
    name: "SoundDeck Trim And Volume Guide",
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
        name: "Trim And Volume",
        item: absoluteUrl(pageUrl),
      },
    ],
  },
  {
    "@context": "https://schema.org",
    "@type": "ItemList",
    name: "SoundDeck trim and volume checks",
    itemListElement: trimVolumeChecks.map((check, index) => ({
      "@type": "ListItem",
      position: index + 1,
      name: check,
    })),
  },
  {
    "@context": "https://schema.org",
    "@type": "HowTo",
    name: "Trim and balance a SoundDeck sound pad",
    description: pageDescription,
    url: absoluteUrl(pageUrl),
    step: trimVolumeSteps.map((step, index) => ({
      "@type": "HowToStep",
      position: index + 1,
      name: step.title,
      text: step.body,
    })),
  },
  {
    "@context": "https://schema.org",
    "@type": "FAQPage",
    mainEntity: trimVolumeFaqs.map((faq) => ({
      "@type": "Question",
      name: faq.q,
      acceptedAnswer: {
        "@type": "Answer",
        text: faq.a,
      },
    })),
  },
];

export default function TrimVolumePage() {
  return (
    <PublicPage
      eyebrow="Docs"
      title="Trim and balance SoundDeck sounds"
      description="Polish imported clips before they reach a live microphone path: set per-sound volume, remove silence, preview the result, and test the adjusted pad."
    >
      <JsonLd data={trimVolumeSchema} />

      <div className="two-column">
        <div className="info-panel">
          <h2>Volume Is Per Sound</h2>
          <p>
            Sound Volume is available from each pad menu. Use it to make one
            clip quieter or louder without changing the rest of the board.
          </p>
        </div>

        <div className="info-panel">
          <h2>Trim Is Pro</h2>
          <p>
            Trim Audio is a SoundDeck Pro control with waveform handles,
            Preview, Save, and Cancel so imported clips can start and end cleanly.
          </p>
          <Link className="button button-ghost" href="/pricing">
            Compare Free and Pro
          </Link>
          <Link className="button button-ghost" href="/docs/free-plan">
            Open Free plan guide
          </Link>
        </div>
      </div>

      <div className="stack-list numbered">
        {trimVolumeSteps.map((step, index) => (
          <article className="info-panel" key={step.title}>
            <span className="step-number">{index + 1}</span>
            <h2>{step.title}</h2>
            <p>{step.body}</p>
          </article>
        ))}
      </div>

      <div className="two-column">
        <div className="info-panel">
          <h2>Trim And Volume Verification Checks</h2>
          <ol className="check-list">
            {trimVolumeChecks.map((check) => (
              <li key={check}>{check}</li>
            ))}
          </ol>
        </div>

        <div className="info-panel">
          <h2>Trim And Volume FAQ</h2>
          {trimVolumeFaqs.map((faq) => (
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
            Preview the edited clip locally, send one short SoundDeck Virtual
            Mic test to the target app, then keep Stop All ready before the real
            session starts.
          </p>
          <Link className="button button-ghost" href="/docs/import-sounds">
            Open import sounds guide
          </Link>
          <Link className="button button-ghost" href="/docs/monitoring-preview">
            Open monitoring guide
          </Link>
        </div>

        <div className="info-panel">
          <h2>Trim Or Volume Still Off?</h2>
          <p>
            Include the file format, pad volume, trim start/end, whether Preview
            worked locally, target app, SoundDeck plan, macOS version, and
            SoundDeck version.
          </p>
          <a className="button button-primary" href={supportMailtoLink()}>
            Email trim support
          </a>
          <Link className="button button-ghost" href="/support">
            Search support
          </Link>
        </div>
      </div>
    </PublicPage>
  );
}
