import SiteHeader from "@/components/SiteHeader";
import Hero from "@/components/Hero";
import SocialProof from "@/components/SocialProof";
import Features from "@/components/Features";
import Screenshots from "@/components/Screenshots";
import Testimonials from "@/components/Testimonials";
import Pricing from "@/components/Pricing";
import FAQ from "@/components/FAQ";
import CTA from "@/components/CTA";
import Footer from "@/components/Footer";
import JsonLd from "@/components/JsonLd";
import { compatibility, faqs } from "@/lib/content";
import { absoluteUrl, siteConfig } from "@/lib/site";

const jsonLd = [
  {
    "@context": "https://schema.org",
    "@type": "Organization",
    name: siteConfig.name,
    url: siteConfig.url,
    email: siteConfig.supportEmail,
    sameAs: [siteConfig.url],
  },
  {
    "@context": "https://schema.org",
    "@type": "WebSite",
    name: siteConfig.name,
    url: siteConfig.url,
    potentialAction: {
      "@type": "SearchAction",
      target: `${absoluteUrl("/support")}?q={search_term_string}`,
      "query-input": "required name=search_term_string",
    },
  },
  {
    "@context": "https://schema.org",
    "@type": "SoftwareApplication",
    name: siteConfig.name,
    applicationCategory: "MultimediaApplication",
    operatingSystem: "macOS 13 or later",
    url: siteConfig.url,
    downloadUrl: absoluteUrl(siteConfig.downloadUrl),
    softwareVersion: siteConfig.currentVersion,
    description: siteConfig.description,
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
        url: siteConfig.checkoutUrl.startsWith("http")
          ? siteConfig.checkoutUrl
          : absoluteUrl(siteConfig.checkoutUrl),
      },
    ],
    featureList: [
      "Virtual microphone for macOS",
      "Sound effect pads",
      "Voice changer",
      "Global hotkeys",
      "Private monitor output",
      ...compatibility.map((app) => `Works with ${app}`),
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

export default function Home() {
  return (
    <>
      <JsonLd data={jsonLd} />
      <SiteHeader />
      <main id="main-content">
        <Hero />
        <SocialProof />
        <Features />
        <Screenshots />
        <Testimonials />
        <Pricing />
        <FAQ />
        <CTA />
      </main>
      <Footer />
    </>
  );
}
