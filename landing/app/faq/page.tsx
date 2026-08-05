import type { Metadata } from "next";
import Link from "next/link";
import JsonLd from "@/components/JsonLd";
import PublicPage from "@/components/PublicPage";
import { faqs } from "@/lib/content";
import { absoluteUrl, siteConfig, supportMailtoLink } from "@/lib/site";

const pageDescription =
  "SoundDeck FAQ for virtual microphone setup, compatible apps, macOS support, privacy, Free vs Pro, uninstalling, and support.";

export const metadata: Metadata = {
  title: "FAQ",
  description: pageDescription,
  alternates: { canonical: "/faq" },
};

const faqSchema = [
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
        name: "FAQ",
        item: absoluteUrl("/faq"),
      },
    ],
  },
  {
    "@context": "https://schema.org",
    "@type": "FAQPage",
    mainEntity: faqs.map((faq) => ({
      "@type": "Question",
      name: faq.q,
      acceptedAnswer: {
        "@type": "Answer",
        text: faq.a,
      },
    })),
  },
];

export default function FAQPage() {
  return (
    <PublicPage
      eyebrow="FAQ"
      title="SoundDeck answers before you install"
      description="Start here for the common setup, compatibility, privacy, pricing, and uninstall questions people ask before routing audio through SoundDeck."
    >
      <JsonLd data={faqSchema} />

      <div className="stack-list">
        {faqs.map((faq) => (
          <article className="info-panel" key={faq.q}>
            <h2>{faq.q}</h2>
            <p>{faq.a}</p>
          </article>
        ))}
      </div>

      <div className="two-column">
        <div className="info-panel">
          <h2>Need Setup Steps?</h2>
          <p>
            The getting started guide covers install, microphone permission,
            driver setup, target-app routing, sound import, monitoring, and Stop
            All behavior.
          </p>
          <Link className="button button-ghost" href="/docs/getting-started">
            Open setup guide
          </Link>
        </div>

        <div className="info-panel">
          <h2>Still Stuck?</h2>
          <p>
            Send your macOS version, SoundDeck version, target app, driver
            status, and whether SoundDeck Virtual Mic appears in the app.
          </p>
          <a className="button button-primary" href={supportMailtoLink()}>
            Ask FAQ support
          </a>
        </div>
      </div>
    </PublicPage>
  );
}
