import type { Metadata } from "next";
import Link from "next/link";
import JsonLd from "@/components/JsonLd";
import PublicPage from "@/components/PublicPage";
import { proLibraryChecks, proLibraryFaqs, proLibrarySteps } from "@/lib/content";
import { absoluteUrl, siteConfig, supportMailtoLink } from "@/lib/site";

const pageDescription =
  "Use the SoundDeck Pro Library to browse Trending, Popular, Recent, and Search results, preview sounds locally, add clips to your library, and verify them before live routing.";

const pageUrl = "/docs/pro-library";

export const metadata: Metadata = {
  title: "Pro Library Guide",
  description: pageDescription,
  alternates: { canonical: pageUrl },
};

const proLibrarySchema = [
  {
    "@context": "https://schema.org",
    "@type": "CollectionPage",
    name: "SoundDeck Pro Library Guide",
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
        name: "Pro Library",
        item: absoluteUrl(pageUrl),
      },
    ],
  },
  {
    "@context": "https://schema.org",
    "@type": "ItemList",
    name: "SoundDeck Pro library checks",
    itemListElement: proLibraryChecks.map((check, index) => ({
      "@type": "ListItem",
      position: index + 1,
      name: check,
    })),
  },
  {
    "@context": "https://schema.org",
    "@type": "HowTo",
    name: "Use the SoundDeck Pro Library",
    description: pageDescription,
    url: absoluteUrl(pageUrl),
    step: proLibrarySteps.map((step, index) => ({
      "@type": "HowToStep",
      position: index + 1,
      name: step.title,
      text: step.body,
    })),
  },
  {
    "@context": "https://schema.org",
    "@type": "FAQPage",
    mainEntity: proLibraryFaqs.map((faq) => ({
      "@type": "Question",
      name: faq.q,
      acceptedAnswer: {
        "@type": "Answer",
        text: faq.a,
      },
    })),
  },
];

export default function ProLibraryPage() {
  return (
    <PublicPage
      eyebrow="Docs"
      title="Use the SoundDeck Pro Library"
      description="Browse downloadable sounds, preview them locally, add only the clips you want, and verify imported pads before a meeting, stream, recording, or workshop hears them."
    >
      <JsonLd data={proLibrarySchema} />

      <div className="two-column">
        <div className="info-panel">
          <h2>Pro Access</h2>
          <p>
            Pro Library is available when SoundDeck Pro is active. Locked users
            can still import local files and test the core virtual microphone
            route before upgrading.
          </p>
          <Link className="button button-ghost" href="/pricing">
            Compare Free and Pro
          </Link>
          <Link className="button button-ghost" href="/docs/free-plan">
            Open Free plan guide
          </Link>
        </div>

        <div className="info-panel">
          <h2>Optional Network Library</h2>
          <p>
            Browsing, searching, previewing, and downloading library results use
            network requests to the provider. SoundDeck does not upload
            microphone audio to browse the Pro Library.
          </p>
          <Link className="button button-ghost" href="/privacy">
            Read privacy notes
          </Link>
        </div>
      </div>

      <div className="stack-list numbered">
        {proLibrarySteps.map((step, index) => (
          <article className="info-panel" key={step.title}>
            <span className="step-number">{index + 1}</span>
            <h2>{step.title}</h2>
            <p>{step.body}</p>
          </article>
        ))}
      </div>

      <div className="two-column">
        <div className="info-panel">
          <h2>Pro Library Verification Checks</h2>
          <ol className="check-list">
            {proLibraryChecks.map((check) => (
              <li key={check}>{check}</li>
            ))}
          </ol>
        </div>

        <div className="info-panel">
          <h2>Pro Library FAQ</h2>
          {proLibraryFaqs.map((faq) => (
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
            Treat imported library sounds like any custom sound: preview first,
            trim rough edges, balance volume, then send one short SoundDeck
            Virtual Mic test before the real session starts.
          </p>
          <Link className="button button-ghost" href="/docs/import-sounds">
            Open import sounds guide
          </Link>
          <Link className="button button-ghost" href="/docs/free-plan">
            Open Free plan guide
          </Link>
          <Link className="button button-ghost" href="/docs/folders">
            Open folders guide
          </Link>
          <Link className="button button-ghost" href="/docs/monitoring-preview">
            Open monitoring guide
          </Link>
          <Link className="button button-ghost" href="/docs/trim-volume">
            Open trim and volume guide
          </Link>
        </div>

        <div className="info-panel">
          <h2>Pro Library Still Failing?</h2>
          <p>
            Include SoundDeck plan, selected tab, search term, whether preview
            worked, whether Add to Library completed, target app, macOS version,
            and SoundDeck version.
          </p>
          <a className="button button-primary" href={supportMailtoLink()}>
            Email Pro library support
          </a>
          <Link className="button button-ghost" href="/support">
            Search support
          </Link>
        </div>
      </div>
    </PublicPage>
  );
}
