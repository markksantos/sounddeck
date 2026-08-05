import type { Metadata } from "next";
import Link from "next/link";
import JsonLd from "@/components/JsonLd";
import PublicPage from "@/components/PublicPage";
import {
  systemReadinessChecks,
  systemRequirementFaqs,
  systemRequirements,
} from "@/lib/content";
import { absoluteUrl, siteConfig, supportMailtoLink } from "@/lib/site";

const pageDescription =
  "SoundDeck system requirements for macOS version, Apple Silicon and Intel Macs, virtual audio driver approval, microphone permission, imports, network access, and Free or Pro plans.";

export const metadata: Metadata = {
  title: "System Requirements",
  description: pageDescription,
  alternates: { canonical: "/system-requirements" },
};

const requirementsSchema = [
  {
    "@context": "https://schema.org",
    "@type": "CollectionPage",
    name: "SoundDeck System Requirements",
    url: absoluteUrl("/system-requirements"),
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
        name: "System Requirements",
        item: absoluteUrl("/system-requirements"),
      },
    ],
  },
  {
    "@context": "https://schema.org",
    "@type": "ItemList",
    name: "SoundDeck system requirements",
    itemListElement: systemRequirements.map((item, index) => ({
      "@type": "ListItem",
      position: index + 1,
      name: item.title,
      description: `${item.requirement} ${item.detail}`,
    })),
  },
  {
    "@context": "https://schema.org",
    "@type": "FAQPage",
    mainEntity: systemRequirementFaqs.map((faq) => ({
      "@type": "Question",
      name: faq.q,
      acceptedAnswer: {
        "@type": "Answer",
        text: faq.a,
      },
    })),
  },
];

export default function SystemRequirementsPage() {
  return (
    <PublicPage
      eyebrow="Requirements"
      title="SoundDeck system requirements for macOS"
      description="Check the Mac, driver, permission, app routing, file import, network, and plan requirements before installing SoundDeck."
    >
      <JsonLd data={requirementsSchema} />

      <div className="two-column">
        <div className="info-panel">
          <h2>Supported Macs</h2>
          <p>
            SoundDeck supports {siteConfig.supportedMacOS} on Apple Silicon and
            Intel Macs. The app uses native macOS audio APIs and a CoreAudio
            virtual microphone driver.
          </p>
          <Link className="button button-primary" href="/download">
            Download SoundDeck
          </Link>
        </div>

        <div className="info-panel">
          <h2>Install Contract</h2>
          <p>
            Install the driver, grant microphone permission, select SoundDeck
            Virtual Mic in the target app, and keep your hardware microphone
            selected inside SoundDeck.
          </p>
          <Link className="button button-ghost" href="/docs/getting-started">
            Read setup guide
          </Link>
        </div>
      </div>

      <div className="stack-list">
        {systemRequirements.map((item) => (
          <article className="info-panel" key={item.title}>
            <p className="eyebrow">{item.title}</p>
            <h2>{item.requirement}</h2>
            <p>{item.detail}</p>
          </article>
        ))}
      </div>

      <div className="two-column">
        <div className="info-panel">
          <h2>Readiness Checks</h2>
          <ol className="check-list">
            {systemReadinessChecks.map((check) => (
              <li key={check}>{check}</li>
            ))}
          </ol>
        </div>

        <div className="info-panel">
          <h2>Requirements FAQ</h2>
          {systemRequirementFaqs.map((faq) => (
            <section key={faq.q}>
              <h3>{faq.q}</h3>
              <p>{faq.a}</p>
            </section>
          ))}
        </div>
      </div>

      <div className="info-panel">
        <h2>Need An IT Or Setup Review?</h2>
        <p>
          Include your macOS version, Mac hardware, target app, driver status,
          microphone permission status, and whether SoundDeck Virtual Mic appears
          in the target app.
        </p>
        <a className="button button-primary" href={supportMailtoLink()}>
          Email requirements support
        </a>
        <Link className="button button-ghost" href="/compatibility">
          View compatibility
        </Link>
      </div>
    </PublicPage>
  );
}
