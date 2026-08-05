import type { Metadata } from "next";
import Link from "next/link";
import JsonLd from "@/components/JsonLd";
import PublicPage from "@/components/PublicPage";
import { useCases } from "@/lib/content";
import { absoluteUrl, siteConfig, supportMailtoLink } from "@/lib/site";

const pageDescription =
  "SoundDeck use cases for remote meetings, streams, podcasts, interviews, classes, and workshops.";

export const metadata: Metadata = {
  title: "Use Cases",
  description: pageDescription,
  alternates: { canonical: "/use-cases" },
};

const useCasesSchema = [
  {
    "@context": "https://schema.org",
    "@type": "CollectionPage",
    name: "SoundDeck Use Cases",
    url: absoluteUrl("/use-cases"),
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
        name: "Use Cases",
        item: absoluteUrl("/use-cases"),
      },
    ],
  },
  {
    "@context": "https://schema.org",
    "@type": "ItemList",
    name: "SoundDeck live audio use cases",
    itemListElement: useCases.map((useCase, index) => ({
      "@type": "ListItem",
      position: index + 1,
      name: useCase.title,
      description: `${useCase.description} ${useCase.workflow}`,
    })),
  },
];

export default function UseCasesPage() {
  return (
    <PublicPage
      eyebrow="Use Cases"
      title="Live audio workflows that need fast, local control"
      description="SoundDeck is built for moments where the sound cue has to land inside the same microphone path as your voice."
    >
      <JsonLd data={useCasesSchema} />

      <div className="stack-list">
        {useCases.map((useCase) => (
          <article className="info-panel" key={useCase.title}>
            <p className="eyebrow">{useCase.audience}</p>
            <h2>{useCase.title}</h2>
            <p>{useCase.description}</p>
            <h3>Workflow</h3>
            <p>{useCase.workflow}</p>
            <h3>Best Fit</h3>
            <p>{useCase.bestFor}</p>
            <h3>Setup Notes</h3>
            <p>{useCase.setup}</p>
          </article>
        ))}
      </div>

      <div className="two-column">
        <div className="info-panel">
          <h2>Route First</h2>
          <p>
            The core setup is the same for every use case: install the driver,
            choose SoundDeck Virtual Mic in the target app, then keep your real
            microphone selected inside SoundDeck.
          </p>
          <Link className="button button-ghost" href="/compatibility">
            Check app setup notes
          </Link>
        </div>

        <div className="info-panel">
          <h2>Need A Workflow Check?</h2>
          <p>
            Send the target app, macOS version, SoundDeck version, and whether
            you need meeting, stream, podcast, or workshop routing.
          </p>
          <a className="button button-primary" href={supportMailtoLink()}>
            Email workflow support
          </a>
        </div>
      </div>
    </PublicPage>
  );
}
