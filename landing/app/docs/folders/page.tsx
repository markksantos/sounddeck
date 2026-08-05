import type { Metadata } from "next";
import Link from "next/link";
import JsonLd from "@/components/JsonLd";
import PublicPage from "@/components/PublicPage";
import {
  folderOrganizationChecks,
  folderOrganizationFaqs,
  folderOrganizationSteps,
} from "@/lib/content";
import { absoluteUrl, siteConfig, supportMailtoLink } from "@/lib/site";

const pageDescription =
  "Organize SoundDeck sounds with folders, selected-folder imports, Move to Folder, safe folder deletion, preview checks, and live-route verification.";

const pageUrl = "/docs/folders";

export const metadata: Metadata = {
  title: "Folders Guide",
  description: pageDescription,
  alternates: { canonical: pageUrl },
};

const foldersSchema = [
  {
    "@context": "https://schema.org",
    "@type": "CollectionPage",
    name: "SoundDeck Folders Guide",
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
        name: "Folders",
        item: absoluteUrl(pageUrl),
      },
    ],
  },
  {
    "@context": "https://schema.org",
    "@type": "ItemList",
    name: "SoundDeck folder organization checks",
    itemListElement: folderOrganizationChecks.map((check, index) => ({
      "@type": "ListItem",
      position: index + 1,
      name: check,
    })),
  },
  {
    "@context": "https://schema.org",
    "@type": "HowTo",
    name: "Organize SoundDeck sounds with folders",
    description: pageDescription,
    url: absoluteUrl(pageUrl),
    step: folderOrganizationSteps.map((step, index) => ({
      "@type": "HowToStep",
      position: index + 1,
      name: step.title,
      text: step.body,
    })),
  },
  {
    "@context": "https://schema.org",
    "@type": "FAQPage",
    mainEntity: folderOrganizationFaqs.map((faq) => ({
      "@type": "Question",
      name: faq.q,
      acceptedAnswer: {
        "@type": "Answer",
        text: faq.a,
      },
    })),
  },
];

export default function FoldersPage() {
  return (
    <PublicPage
      eyebrow="Docs"
      title="Organize SoundDeck sounds with folders"
      description="Keep busy soundboards usable under pressure: create folders, import directly into the selected folder, move existing pads, and verify the exact board before going live."
    >
      <JsonLd data={foldersSchema} />

      <div className="two-column">
        <div className="info-panel">
          <h2>Focused Boards</h2>
          <p>
            Folders filter the grid without changing the audio route. Use them
            for meetings, stream scenes, podcast sections, classes, workshops,
            or recurring show segments.
          </p>
        </div>

        <div className="info-panel">
          <h2>Safe Cleanup</h2>
          <p>
            Folder deletion is organizational. Sounds return to All Sounds, and
            copied audio files stay in SoundDeck storage unless you delete the
            sound itself.
          </p>
          <Link className="button button-ghost" href="/privacy">
            Read storage notes
          </Link>
        </div>
      </div>

      <div className="stack-list numbered">
        {folderOrganizationSteps.map((step, index) => (
          <article className="info-panel" key={step.title}>
            <span className="step-number">{index + 1}</span>
            <h2>{step.title}</h2>
            <p>{step.body}</p>
          </article>
        ))}
      </div>

      <div className="two-column">
        <div className="info-panel">
          <h2>Folder Verification Checks</h2>
          <ol className="check-list">
            {folderOrganizationChecks.map((check) => (
              <li key={check}>{check}</li>
            ))}
          </ol>
        </div>

        <div className="info-panel">
          <h2>Folder FAQ</h2>
          {folderOrganizationFaqs.map((faq) => (
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
            Open the folder for the session, search or sort if needed, preview
            critical clips, test one short SoundDeck Virtual Mic trigger, and
            keep Stop All ready.
          </p>
          <Link className="button button-ghost" href="/docs/import-sounds">
            Open import sounds guide
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
        </div>

        <div className="info-panel">
          <h2>Folders Still Wrong?</h2>
          <p>
            Include the folder name, selected sidebar row, visible sound count,
            whether All shows the sound, whether Move to Folder was used,
            macOS version, and SoundDeck version.
          </p>
          <a className="button button-primary" href={supportMailtoLink()}>
            Email folder support
          </a>
          <Link className="button button-ghost" href="/support">
            Search support
          </Link>
        </div>
      </div>
    </PublicPage>
  );
}
