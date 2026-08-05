import type { Metadata } from "next";
import Link from "next/link";
import JsonLd from "@/components/JsonLd";
import PublicPage from "@/components/PublicPage";
import {
  uninstallFaqs,
  uninstallSteps,
  uninstallVerificationChecks,
} from "@/lib/content";
import { absoluteUrl, siteConfig, supportMailtoLink } from "@/lib/site";

const pageDescription =
  "Uninstall SoundDeck on macOS by removing SoundDeck Virtual Mic first, quitting the app, moving SoundDeck.app to Trash, restarting target apps, and verifying microphone pickers.";

const pageUrl = "/docs/uninstall";

export const metadata: Metadata = {
  title: "Uninstall Guide",
  description: pageDescription,
  alternates: { canonical: pageUrl },
};

const uninstallSchema = [
  {
    "@context": "https://schema.org",
    "@type": "CollectionPage",
    name: "SoundDeck Uninstall Guide",
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
        name: "Uninstall",
        item: absoluteUrl(pageUrl),
      },
    ],
  },
  {
    "@context": "https://schema.org",
    "@type": "ItemList",
    name: "SoundDeck uninstall verification checks",
    itemListElement: uninstallVerificationChecks.map((check, index) => ({
      "@type": "ListItem",
      position: index + 1,
      name: check,
    })),
  },
  {
    "@context": "https://schema.org",
    "@type": "HowTo",
    name: "Uninstall SoundDeck Virtual Mic and SoundDeck.app",
    description: pageDescription,
    url: absoluteUrl(pageUrl),
    step: uninstallSteps.map((step, index) => ({
      "@type": "HowToStep",
      position: index + 1,
      name: step.title,
      text: step.body,
    })),
  },
  {
    "@context": "https://schema.org",
    "@type": "FAQPage",
    mainEntity: uninstallFaqs.map((faq) => ({
      "@type": "Question",
      name: faq.q,
      acceptedAnswer: {
        "@type": "Answer",
        text: faq.a,
      },
    })),
  },
];

export default function UninstallPage() {
  return (
    <PublicPage
      eyebrow="Docs"
      title="Remove SoundDeck safely"
      description="Use this uninstall path when removing SoundDeck, cleaning up a Mac for IT review, preparing for a reinstall, or clearing a stale virtual microphone listing."
    >
      <JsonLd data={uninstallSchema} />

      <div className="two-column">
        <div className="info-panel">
          <h2>Driver First</h2>
          <p>
            Remove SoundDeck Virtual Mic from SoundDeck Settings before moving
            the app to Trash. That keeps the CoreAudio driver cleanup inside the
            app flow that has administrator approval and status checks.
          </p>
        </div>

        <div className="info-panel">
          <h2>Target Apps Cache Devices</h2>
          <p>
            Meeting, streaming, recording, and browser apps may keep an old
            microphone list until they restart. Reopen those apps after driver
            removal before deciding the uninstall failed.
          </p>
        </div>
      </div>

      <div className="stack-list numbered">
        {uninstallSteps.map((step, index) => (
          <article className="info-panel" key={step.title}>
            <span className="step-number">{index + 1}</span>
            <h2>{step.title}</h2>
            <p>{step.body}</p>
          </article>
        ))}
      </div>

      <div className="two-column">
        <div className="info-panel">
          <h2>Verification Checks</h2>
          <ol className="check-list">
            {uninstallVerificationChecks.map((check) => (
              <li key={check}>{check}</li>
            ))}
          </ol>
        </div>

        <div className="info-panel">
          <h2>Uninstall FAQ</h2>
          {uninstallFaqs.map((faq) => (
            <section key={faq.q}>
              <h3>{faq.q}</h3>
              <p>{faq.a}</p>
            </section>
          ))}
        </div>
      </div>

      <div className="two-column">
        <div className="info-panel">
          <h2>Before Reinstalling</h2>
          <p>
            If you are reinstalling to fix a missing or stale microphone input,
            confirm the Mac still meets the driver requirements and restart the
            target app after the new driver install.
          </p>
          <Link className="button button-ghost" href="/system-requirements">
            Check system requirements
          </Link>
          <Link className="button button-ghost" href="/download">
            Download SoundDeck
          </Link>
        </div>

        <div className="info-panel">
          <h2>Still Seeing SoundDeck Virtual Mic?</h2>
          <p>
            Include your macOS version, SoundDeck version, driver status,
            whether SoundDeck.app is still installed, and the target app that
            still lists SoundDeck Virtual Mic.
          </p>
          <a className="button button-primary" href={supportMailtoLink()}>
            Email uninstall support
          </a>
          <Link className="button button-ghost" href="/docs/troubleshooting">
            Open troubleshooting
          </Link>
        </div>
      </div>
    </PublicPage>
  );
}
