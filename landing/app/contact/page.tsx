import type { Metadata } from "next";
import JsonLd from "@/components/JsonLd";
import PublicPage from "@/components/PublicPage";
import {
  absoluteUrl,
  pressMailtoLink,
  privacyMailtoLink,
  securityDisclosureMailtoLink,
  siteConfig,
  supportMailtoLink,
  termsMailtoLink,
} from "@/lib/site";

export const metadata: Metadata = {
  title: "Contact",
  description:
    "Contact SoundDeck for setup support, security reports, privacy questions, terms questions, and press inquiries.",
  alternates: { canonical: "/contact" },
};

const contactOptions = [
  {
    title: "Setup Support",
    body: "Driver installation, virtual microphone routing, microphone permission, sound import, hotkeys, and Pro access.",
    href: supportMailtoLink(),
    action: "Email support",
  },
  {
    title: "Security Reports",
    body: "Responsible disclosure for app, updater, driver, or website issues with reproduction details and affected versions.",
    href: securityDisclosureMailtoLink(),
    action: "Report security issue",
  },
  {
    title: "Privacy Questions",
    body: "Questions about local audio processing, stored settings, subscriptions, updates, or data handling.",
    href: privacyMailtoLink(),
    action: "Ask privacy question",
  },
  {
    title: "Terms Questions",
    body: "Questions about subscriptions, refunds, acceptable use, driver installation, or account context.",
    href: termsMailtoLink(),
    action: "Ask terms question",
  },
  {
    title: "Press",
    body: "Launch coverage, product facts, screenshots, founder context, partnership notes, and review timelines.",
    href: pressMailtoLink(),
    action: "Email press",
  },
];

const contactSchema = {
  "@context": "https://schema.org",
  "@type": "ContactPage",
  name: "Contact SoundDeck",
  url: absoluteUrl("/contact"),
  about: {
    "@type": "SoftwareApplication",
    name: siteConfig.name,
    applicationCategory: siteConfig.appStoreCategory,
    operatingSystem: "macOS",
    softwareVersion: siteConfig.currentVersion,
    url: siteConfig.url,
  },
  mainEntity: {
    "@type": "Organization",
    name: siteConfig.name,
    url: siteConfig.url,
    email: siteConfig.supportEmail,
    contactPoint: [
      {
        "@type": "ContactPoint",
        contactType: "customer support",
        email: siteConfig.supportEmail,
        availableLanguage: "en",
      },
      {
        "@type": "ContactPoint",
        contactType: "security",
        email: siteConfig.supportEmail,
        availableLanguage: "en",
      },
      {
        "@type": "ContactPoint",
        contactType: "press",
        email: siteConfig.pressEmail,
        availableLanguage: "en",
      },
    ],
  },
};

export default function ContactPage() {
  return (
    <PublicPage
      eyebrow="Contact"
      title="Route the request to the right inbox"
      description="Choose the closest path below. Each email opens with the details SoundDeck needs to answer quickly."
    >
      <JsonLd data={contactSchema} />

      <div className="stack-list">
        {contactOptions.map((option) => (
          <article className="info-panel" key={option.title}>
            <h2>{option.title}</h2>
            <p>{option.body}</p>
            <a className="button button-primary" href={option.href}>
              {option.action}
            </a>
          </article>
        ))}
      </div>

      <div className="info-panel">
        <h2>Response Context</h2>
        <ul>
          <li>For setup support, include the target app and selected microphone input.</li>
          <li>For security reports, include reproduction steps and affected SoundDeck version.</li>
          <li>For press requests, include publication, deadline, and requested assets.</li>
        </ul>
      </div>
    </PublicPage>
  );
}
