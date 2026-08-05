import type { Metadata } from "next";
import Link from "next/link";
import JsonLd from "@/components/JsonLd";
import PublicPage from "@/components/PublicPage";
import { importSoundChecks, importSoundFaqs, importSoundSteps } from "@/lib/content";
import { absoluteUrl, siteConfig, supportMailtoLink } from "@/lib/site";

const pageDescription =
  "Import custom sounds into SoundDeck, organize folders, check supported audio formats, respect Free plan limits, trim clips, balance volume, and preview safely.";

const pageUrl = "/docs/import-sounds";

export const metadata: Metadata = {
  title: "Import Sounds Guide",
  description: pageDescription,
  alternates: { canonical: pageUrl },
};

const importSoundsSchema = [
  {
    "@context": "https://schema.org",
    "@type": "CollectionPage",
    name: "SoundDeck Import Sounds Guide",
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
        name: "Import Sounds",
        item: absoluteUrl(pageUrl),
      },
    ],
  },
  {
    "@context": "https://schema.org",
    "@type": "ItemList",
    name: "SoundDeck import verification checks",
    itemListElement: importSoundChecks.map((check, index) => ({
      "@type": "ListItem",
      position: index + 1,
      name: check,
    })),
  },
  {
    "@context": "https://schema.org",
    "@type": "HowTo",
    name: "Import custom sounds into SoundDeck",
    description: pageDescription,
    url: absoluteUrl(pageUrl),
    step: importSoundSteps.map((step, index) => ({
      "@type": "HowToStep",
      position: index + 1,
      name: step.title,
      text: step.body,
    })),
  },
  {
    "@context": "https://schema.org",
    "@type": "FAQPage",
    mainEntity: importSoundFaqs.map((faq) => ({
      "@type": "Question",
      name: faq.q,
      acceptedAnswer: {
        "@type": "Answer",
        text: faq.a,
      },
    })),
  },
];

export default function ImportSoundsPage() {
  return (
    <PublicPage
      eyebrow="Docs"
      title="Import sounds into SoundDeck"
      description="Build a clean soundboard library with supported audio files, organized folders, balanced volumes, private preview, and a safe live test."
    >
      <JsonLd data={importSoundsSchema} />

      <div className="two-column">
        <div className="info-panel">
          <h2>Supported Formats</h2>
          <p>
            SoundDeck imports MP3, WAV, M4A, AAC, AIFF, and CAF files. Use
            readable filenames before import so pads start with clear labels.
          </p>
        </div>

        <div className="info-panel">
          <h2>Library Shape</h2>
          <p>
            Organize folders around the live workflow: meeting reactions,
            stream stingers, podcast cues, class prompts, workshop timers, or
            show segments.
          </p>
        </div>
      </div>

      <div className="stack-list numbered">
        {importSoundSteps.map((step, index) => (
          <article className="info-panel" key={step.title}>
            <span className="step-number">{index + 1}</span>
            <h2>{step.title}</h2>
            <p>{step.body}</p>
          </article>
        ))}
      </div>

      <div className="two-column">
        <div className="info-panel">
          <h2>Import Verification Checks</h2>
          <ol className="check-list">
            {importSoundChecks.map((check) => (
              <li key={check}>{check}</li>
            ))}
          </ol>
        </div>

        <div className="info-panel">
          <h2>Import FAQ</h2>
          {importSoundFaqs.map((faq) => (
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
            Test one imported clip privately, confirm the virtual microphone
            route, and keep Stop All available before sending new sounds into a
            live room or recording.
          </p>
          <Link className="button button-ghost" href="/docs/virtual-microphone">
            Open virtual mic guide
          </Link>
          <Link className="button button-ghost" href="/docs/folders">
            Open folders guide
          </Link>
          <Link className="button button-ghost" href="/docs/free-plan">
            Open Free plan guide
          </Link>
          <Link className="button button-ghost" href="/docs/pro-library">
            Open Pro library guide
          </Link>
          <Link className="button button-ghost" href="/docs/trim-volume">
            Open trim and volume guide
          </Link>
          <Link className="button button-ghost" href="/docs/monitoring-preview">
            Open monitoring guide
          </Link>
          <Link className="button button-ghost" href="/docs/hotkeys">
            Open hotkeys guide
          </Link>
        </div>

        <div className="info-panel">
          <h2>Import Still Failing?</h2>
          <p>
            Include the file format, file size, import method, folder name,
            SoundDeck plan, macOS version, and whether the same file plays in
            QuickTime or Music.
          </p>
          <a className="button button-primary" href={supportMailtoLink()}>
            Email import support
          </a>
          <Link className="button button-ghost" href="/support">
            Search support
          </Link>
        </div>
      </div>
    </PublicPage>
  );
}
