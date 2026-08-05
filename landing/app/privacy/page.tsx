import type { Metadata } from "next";
import Link from "next/link";
import PublicPage from "@/components/PublicPage";
import { securityPoints } from "@/lib/content";
import { privacyMailtoLink, siteConfig } from "@/lib/site";

export const metadata: Metadata = {
  title: "Privacy Policy",
  description:
    "SoundDeck privacy policy covering local audio processing, local library storage, subscriptions, updates, and optional Pro Sound Library requests.",
  alternates: { canonical: "/privacy" },
};

export default function PrivacyPage() {
  return (
    <PublicPage
      eyebrow="Privacy"
      title="SoundDeck keeps audio work on your Mac"
      description="Last updated May 6, 2026. This plain-language policy describes what SoundDeck processes locally and when a network request may happen."
    >
      <div className="info-panel legal-copy">
        <h2>Audio data</h2>
        <p>
          SoundDeck processes microphone audio, imported sound files, monitoring,
          and voice effects locally on your Mac. SoundDeck does not record,
          upload, sell, or use your audio for advertising.
        </p>

        <h2>Local storage</h2>
        <p>
          SoundDeck stores sound library metadata, folders, imported clips,
          hotkey preferences, and audio settings in local macOS application
          support and preferences storage.
        </p>

        <h2>Payments and subscriptions</h2>
        <p>
          Pro access is handled through in-app purchase infrastructure. SoundDeck
          does not store your full payment card details.
        </p>

        <h2>Network requests</h2>
        <ul>
          {securityPoints.map((point) => (
            <li key={point}>{point}</li>
          ))}
        </ul>
        <Link className="button button-ghost" href="/docs/pro-library">
          Read Pro library guide
        </Link>

        <h2>Contact</h2>
        <p>
          Privacy questions can be sent to{" "}
          <a href={privacyMailtoLink()}>{siteConfig.supportEmail}</a>.
        </p>
      </div>
    </PublicPage>
  );
}
