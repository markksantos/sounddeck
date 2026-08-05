import type { Metadata } from "next";
import Link from "next/link";
import JsonLd from "@/components/JsonLd";
import PublicPage from "@/components/PublicPage";
import { freePlanFeatures, pricingFaqs, proPlanFeatures } from "@/lib/content";
import { absoluteUrl, siteConfig, supportMailtoLink } from "@/lib/site";

const pageDescription =
  "Compare SoundDeck Free and SoundDeck Pro pricing for the macOS soundboard and virtual microphone app.";

const checkoutUrl = siteConfig.checkoutUrl.startsWith("http")
  ? siteConfig.checkoutUrl
  : absoluteUrl(siteConfig.checkoutUrl);

export const metadata: Metadata = {
  title: "Pricing",
  description: pageDescription,
  alternates: { canonical: "/pricing" },
};

const pricingSchema = [
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
        name: "Pricing",
        item: absoluteUrl("/pricing"),
      },
    ],
  },
  {
    "@context": "https://schema.org",
    "@type": "Product",
    name: siteConfig.name,
    description: siteConfig.description,
    brand: {
      "@type": "Brand",
      name: siteConfig.name,
    },
    category: siteConfig.appStoreCategory,
    url: absoluteUrl("/pricing"),
    offers: [
      {
        "@type": "Offer",
        name: "SoundDeck Free",
        price: "0",
        priceCurrency: "USD",
        availability: "https://schema.org/InStock",
        url: absoluteUrl(siteConfig.downloadUrl),
      },
      {
        "@type": "Offer",
        name: "SoundDeck Pro Annual",
        price: "29.99",
        priceCurrency: "USD",
        availability: "https://schema.org/InStock",
        url: checkoutUrl,
      },
    ],
  },
  {
    "@context": "https://schema.org",
    "@type": "FAQPage",
    mainEntity: pricingFaqs.map((faq) => ({
      "@type": "Question",
      name: faq.q,
      acceptedAnswer: {
        "@type": "Answer",
        text: faq.a,
      },
    })),
  },
];

export default function PricingPage() {
  return (
    <PublicPage
      eyebrow="Pricing"
      title="Start free, upgrade when SoundDeck joins the show"
      description="The free plan is built for setup and evaluation. Pro unlocks the faster production controls for larger boards, hotkeys, trimming, voice effects, and library access."
    >
      <JsonLd data={pricingSchema} />

      <div className="pricing-grid">
        <article className="pricing-card">
          <p className="price-label">Free</p>
          <div className="price-row">$0</div>
          <p className="price-note">Try SoundDeck with the virtual mic route and starter library.</p>
          <ul>
            {freePlanFeatures.map((feature) => (
              <li key={feature}>{feature}</li>
            ))}
          </ul>
          <a className="button button-ghost full" href={siteConfig.downloadUrl}>
            Download free
          </a>
        </article>

        <article className="pricing-card featured">
          <p className="price-label">SoundDeck Pro</p>
          <div className="price-row">{siteConfig.priceYearly}</div>
          <p className="price-note">
            Annual plan. Monthly option from {siteConfig.priceMonthly}/mo in app.
          </p>
          <ul>
            {proPlanFeatures.map((feature) => (
              <li key={feature}>{feature}</li>
            ))}
          </ul>
          <a className="button button-primary full" href={siteConfig.checkoutUrl}>
            Upgrade to Pro
          </a>
        </article>
      </div>

      <div className="two-column">
        <div className="info-panel">
          <h2>Before You Upgrade</h2>
          <p>
            Install the app, grant microphone permission, and confirm SoundDeck
            Virtual Mic appears in the app you plan to use. Pro is most useful
            once you need unlimited sounds, hotkeys, voice effects, or trimming.
          </p>
          <Link className="button button-ghost" href="/docs/getting-started">
            Open setup guide
          </Link>
          <Link className="button button-ghost" href="/docs/free-plan">
            Read Free plan guide
          </Link>
          <Link className="button button-ghost" href="/docs/hotkeys">
            Compare hotkeys
          </Link>
          <Link className="button button-ghost" href="/docs/pro-library">
            Review Pro Library
          </Link>
          <Link className="button button-ghost" href="/docs/trim-volume">
            Review trim controls
          </Link>
          <Link className="button button-ghost" href="/docs/voice-effects">
            Review voice effects
          </Link>
        </div>

        <div className="info-panel">
          <h2>Billing And Refund Help</h2>
          <p>
            Pro pricing and purchase confirmation are shown before checkout.
            Refund handling follows the platform purchase flow, and support can
            help route setup questions before you subscribe.
          </p>
          <a className="button button-ghost" href={supportMailtoLink()}>
            Ask billing support
          </a>
        </div>
      </div>

      <div className="info-panel">
        <h2>Pricing FAQ</h2>
        <div className="stack-list">
          {pricingFaqs.map((faq) => (
            <article key={faq.q}>
              <h3>{faq.q}</h3>
              <p>{faq.a}</p>
            </article>
          ))}
        </div>
      </div>
    </PublicPage>
  );
}
