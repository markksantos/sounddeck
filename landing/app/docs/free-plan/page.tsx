import type { Metadata } from "next";
import Link from "next/link";
import JsonLd from "@/components/JsonLd";
import PublicPage from "@/components/PublicPage";
import { freePlanChecks, freePlanFaqs, freePlanSteps } from "@/lib/content";
import { absoluteUrl, siteConfig, supportMailtoLink } from "@/lib/site";

const pageDescription =
  "Understand SoundDeck Free and Pro: starter sounds, 8 custom import slots, the Free watermark, Pro unlocks, Restore Purchases, and subscription management.";

const pageUrl = "/docs/free-plan";

export const metadata: Metadata = {
  title: "Free Plan And Pro Guide",
  description: pageDescription,
  alternates: { canonical: pageUrl },
};

const freePlanSchema = [
  {
    "@context": "https://schema.org",
    "@type": "CollectionPage",
    name: "SoundDeck Free Plan And Pro Guide",
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
        name: "Free Plan And Pro",
        item: absoluteUrl(pageUrl),
      },
    ],
  },
  {
    "@context": "https://schema.org",
    "@type": "ItemList",
    name: "SoundDeck Free and Pro checks",
    itemListElement: freePlanChecks.map((check, index) => ({
      "@type": "ListItem",
      position: index + 1,
      name: check,
    })),
  },
  {
    "@context": "https://schema.org",
    "@type": "HowTo",
    name: "Decide when to use SoundDeck Free or Pro",
    description: pageDescription,
    url: absoluteUrl(pageUrl),
    step: freePlanSteps.map((step, index) => ({
      "@type": "HowToStep",
      position: index + 1,
      name: step.title,
      text: step.body,
    })),
  },
  {
    "@context": "https://schema.org",
    "@type": "FAQPage",
    mainEntity: freePlanFaqs.map((faq) => ({
      "@type": "Question",
      name: faq.q,
      acceptedAnswer: {
        "@type": "Answer",
        text: faq.a,
      },
    })),
  },
];

export default function FreePlanPage() {
  return (
    <PublicPage
      eyebrow="Docs"
      title="Understand SoundDeck Free and Pro"
      description="Use Free to prove the virtual microphone route, then upgrade only when the live workflow needs larger boards, faster controls, voice effects, trimming, library access, or no watermark."
    >
      <JsonLd data={freePlanSchema} />

      <div className="two-column">
        <div className="info-panel">
          <h2>Free Is For Setup</h2>
          <p>
            Free includes starter sounds, the virtual microphone route, Preview,
            SFX Monitor, Mute microphone, Stop All, and up to 8 custom imported
            sounds.
          </p>
          <Link className="button button-ghost" href="/download">
            Download Free
          </Link>
          <Link className="button button-ghost" href="/docs/getting-started">
            Open setup guide
          </Link>
        </div>

        <div className="info-panel">
          <h2>Pro Is For Live Production</h2>
          <p>
            Pro removes the Free-plan watermark and unlocks unlimited custom
            sounds, per-sound hotkeys, voice changer controls, Trim Audio, and
            the Pro Sound Library.
          </p>
          <Link className="button button-ghost" href="/pricing">
            Compare plans
          </Link>
          <Link className="button button-ghost" href="/docs/pro-library">
            Open Pro library guide
          </Link>
        </div>
      </div>

      <div className="stack-list numbered">
        {freePlanSteps.map((step, index) => (
          <article className="info-panel" key={step.title}>
            <span className="step-number">{index + 1}</span>
            <h2>{step.title}</h2>
            <p>{step.body}</p>
          </article>
        ))}
      </div>

      <div className="two-column">
        <div className="info-panel">
          <h2>Free And Pro Verification Checks</h2>
          <ol className="check-list">
            {freePlanChecks.map((check) => (
              <li key={check}>{check}</li>
            ))}
          </ol>
        </div>

        <div className="info-panel">
          <h2>Free And Pro FAQ</h2>
          {freePlanFaqs.map((faq) => (
            <section key={faq.q}>
              <h3>{faq.q}</h3>
              <p>{faq.a}</p>
            </section>
          ))}
        </div>
      </div>

      <div className="two-column">
        <div className="info-panel">
          <h2>Related Guides</h2>
          <p>
            Pro is most useful after the route works. Check imports, folders,
            hotkeys, voice effects, trim, and privacy before relying on the app
            in a live room.
          </p>
          <Link className="button button-ghost" href="/docs/import-sounds">
            Open import sounds guide
          </Link>
          <Link className="button button-ghost" href="/docs/folders">
            Open folders guide
          </Link>
          <Link className="button button-ghost" href="/docs/hotkeys">
            Open hotkeys guide
          </Link>
          <Link className="button button-ghost" href="/docs/voice-effects">
            Open voice effects guide
          </Link>
          <Link className="button button-ghost" href="/docs/trim-volume">
            Open trim and volume guide
          </Link>
          <Link className="button button-ghost" href="/privacy">
            Read privacy notes
          </Link>
        </div>

        <div className="info-panel">
          <h2>Plan Still Looks Wrong?</h2>
          <p>
            Include whether Settings shows Free Plan or SoundDeck Pro Active,
            custom sound count, Restore Purchases result, target app, macOS
            version, and SoundDeck version.
          </p>
          <a
            className="button button-primary"
            href={supportMailtoLink("SoundDeck Plan Support")}
          >
            Email plan support
          </a>
          <Link className="button button-ghost" href="/support?q=free">
            Search support
          </Link>
        </div>
      </div>
    </PublicPage>
  );
}
