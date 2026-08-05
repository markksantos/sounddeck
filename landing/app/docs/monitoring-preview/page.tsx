import type { Metadata } from "next";
import Link from "next/link";
import JsonLd from "@/components/JsonLd";
import PublicPage from "@/components/PublicPage";
import {
  monitoringPreviewChecks,
  monitoringPreviewFaqs,
  monitoringPreviewSteps,
} from "@/lib/content";
import { absoluteUrl, siteConfig, supportMailtoLink } from "@/lib/site";

const pageDescription =
  "Use SoundDeck Preview, SFX Monitor, Voice Monitor, and Preview / Monitor Output safely without leaking feedback into calls, streams, or recordings.";

const pageUrl = "/docs/monitoring-preview";

export const metadata: Metadata = {
  title: "Monitoring And Preview Guide",
  description: pageDescription,
  alternates: { canonical: pageUrl },
};

const monitoringPreviewSchema = [
  {
    "@context": "https://schema.org",
    "@type": "CollectionPage",
    name: "SoundDeck Monitoring And Preview Guide",
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
        name: "Monitoring And Preview",
        item: absoluteUrl(pageUrl),
      },
    ],
  },
  {
    "@context": "https://schema.org",
    "@type": "ItemList",
    name: "SoundDeck monitoring and preview checks",
    itemListElement: monitoringPreviewChecks.map((check, index) => ({
      "@type": "ListItem",
      position: index + 1,
      name: check,
    })),
  },
  {
    "@context": "https://schema.org",
    "@type": "HowTo",
    name: "Use SoundDeck monitoring and preview safely",
    description: pageDescription,
    url: absoluteUrl(pageUrl),
    step: monitoringPreviewSteps.map((step, index) => ({
      "@type": "HowToStep",
      position: index + 1,
      name: step.title,
      text: step.body,
    })),
  },
  {
    "@context": "https://schema.org",
    "@type": "FAQPage",
    mainEntity: monitoringPreviewFaqs.map((faq) => ({
      "@type": "Question",
      name: faq.q,
      acceptedAnswer: {
        "@type": "Answer",
        text: faq.a,
      },
    })),
  },
];

export default function MonitoringPreviewPage() {
  return (
    <PublicPage
      eyebrow="Docs"
      title="Monitor and preview SoundDeck safely"
      description="Hear clips and microphone changes locally without creating feedback, echo, or confusion about what the live app receives."
    >
      <JsonLd data={monitoringPreviewSchema} />

      <div className="two-column">
        <div className="info-panel">
          <h2>Private Preview</h2>
          <p>
            Preview is for checking a clip locally before it reaches SoundDeck
            Virtual Mic. Use it to catch silence, bad trims, and volume spikes.
          </p>
        </div>

        <div className="info-panel">
          <h2>Live Monitoring</h2>
          <p>
            SFX Monitor and Voice Monitor are local output tools. They help you
            hear what you are doing while the target app still receives
            SoundDeck Virtual Mic as its input.
          </p>
        </div>
      </div>

      <div className="stack-list numbered">
        {monitoringPreviewSteps.map((step, index) => (
          <article className="info-panel" key={step.title}>
            <span className="step-number">{index + 1}</span>
            <h2>{step.title}</h2>
            <p>{step.body}</p>
          </article>
        ))}
      </div>

      <div className="two-column">
        <div className="info-panel">
          <h2>Monitoring Verification Checks</h2>
          <ol className="check-list">
            {monitoringPreviewChecks.map((check) => (
              <li key={check}>{check}</li>
            ))}
          </ol>
        </div>

        <div className="info-panel">
          <h2>Monitoring FAQ</h2>
          {monitoringPreviewFaqs.map((faq) => (
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
            Set the output to headphones, preview one clip, test the target app
            route, then keep Stop All ready before switching meetings, scenes,
            or recordings.
          </p>
          <Link className="button button-ghost" href="/docs/virtual-microphone">
            Open virtual mic guide
          </Link>
          <Link className="button button-ghost" href="/docs/import-sounds">
            Open import sounds guide
          </Link>
          <Link className="button button-ghost" href="/docs/trim-volume">
            Open trim and volume guide
          </Link>
        </div>

        <div className="info-panel">
          <h2>Monitoring Still Failing?</h2>
          <p>
            Include the output device, SFX Monitor state, Voice Monitor state,
            target app, microphone route, SoundDeck version, and macOS version.
          </p>
          <a className="button button-primary" href={supportMailtoLink()}>
            Email monitoring support
          </a>
          <Link className="button button-ghost" href="/support">
            Search support
          </Link>
        </div>
      </div>
    </PublicPage>
  );
}
