import type { Metadata } from "next";
import PublicPage from "@/components/PublicPage";
import { securityPoints } from "@/lib/content";
import { securityDisclosureMailtoLink, siteConfig } from "@/lib/site";

export const metadata: Metadata = {
  title: "Security",
  description:
    "SoundDeck security and privacy posture for local audio processing, driver removal, network requests, and responsible disclosure.",
  alternates: { canonical: "/security" },
};

export default function SecurityPage() {
  return (
    <PublicPage
      eyebrow="Security"
      title="A local-first audio path with clear controls"
      description="SoundDeck uses macOS audio APIs and makes setup, monitoring, update, and removal paths visible to users."
    >
      <div className="two-column">
        <div className="info-panel">
          <h2>Security posture</h2>
          <ul>
            {securityPoints.map((point) => (
              <li key={point}>{point}</li>
            ))}
          </ul>
        </div>
        <div className="info-panel">
          <h2>Responsible disclosure</h2>
          <p>
            Send security reports to{" "}
            <a href={securityDisclosureMailtoLink()}>{siteConfig.supportEmail}</a>.
            Include reproduction steps, macOS version, app version, and whether
            the report involves the app, updater, or audio driver.
          </p>
        </div>
      </div>
    </PublicPage>
  );
}
