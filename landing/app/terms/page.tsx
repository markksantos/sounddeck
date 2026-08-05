import type { Metadata } from "next";
import PublicPage from "@/components/PublicPage";
import { siteConfig, termsMailtoLink } from "@/lib/site";

export const metadata: Metadata = {
  title: "Terms",
  description:
    "SoundDeck terms for macOS app usage, virtual audio driver installation, Pro access, refunds, support, and acceptable use.",
  alternates: { canonical: "/terms" },
};

export default function TermsPage() {
  return (
    <PublicPage
      eyebrow="Terms"
      title="Terms for using SoundDeck"
      description="Last updated May 6, 2026. These public terms give customers launch-ready expectations before installing the app."
    >
      <div className="info-panel legal-copy">
        <h2>License</h2>
        <p>
          SoundDeck is licensed for personal or professional use on Macs you own
          or control. Do not redistribute modified copies or attempt to bypass Pro
          access controls.
        </p>

        <h2>Driver installation</h2>
        <p>
          SoundDeck may install a virtual audio driver with administrator
          approval. You are responsible for choosing whether to install, reinstall,
          or remove that driver from Settings.
        </p>

        <h2>Subscriptions and refunds</h2>
        <p>
          The free plan is available for setup and evaluation. Pro pricing and
          billing are shown in the app before purchase. Refund requests should be
          sent through the platform purchase flow or to support for guidance.
        </p>

        <h2>Acceptable use</h2>
        <p>
          You are responsible for the sounds you import and play. Do not use
          SoundDeck to violate laws, platform rules, copyrights, or call consent
          requirements.
        </p>

        <h2>Contact</h2>
        <p>
          Questions about these terms can be sent to{" "}
          <a href={termsMailtoLink()}>{siteConfig.supportEmail}</a>.
        </p>
      </div>
    </PublicPage>
  );
}
