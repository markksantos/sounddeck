import type { Metadata } from "next";
import Link from "next/link";
import PublicPage from "@/components/PublicPage";
import JsonLd from "@/components/JsonLd";
import { releaseChecklist } from "@/lib/content";
import { absoluteUrl, siteConfig } from "@/lib/site";

export const metadata: Metadata = {
  title: "Download",
  description:
    "Download SoundDeck for macOS and follow the setup checklist for the virtual microphone driver, microphone permission, and first soundboard.",
  alternates: { canonical: "/download" },
};

export default function DownloadPage() {
  const realDownload = siteConfig.downloadUrl !== "/download";

  return (
    <>
      <JsonLd
        data={{
          "@context": "https://schema.org",
          "@type": "BreadcrumbList",
          itemListElement: [
            { "@type": "ListItem", position: 1, name: "Home", item: siteConfig.url },
            { "@type": "ListItem", position: 2, name: "Download", item: absoluteUrl("/download") },
          ],
        }}
      />
      <PublicPage
        eyebrow="Download"
        title="Install SoundDeck for macOS"
        description="Use the public download link when a signed build is attached. Until then, this page gives testers and launch reviewers the exact setup path."
      >
        <div className="two-column">
          <div className="info-panel">
            <h2>Download status</h2>
            {realDownload ? (
              <a className="button button-primary full" href={siteConfig.downloadUrl}>
                Download SoundDeck
              </a>
            ) : (
              <div className="notice">
                Set <code>NEXT_PUBLIC_DOWNLOAD_URL</code> to the signed app artifact
                before launch. The page, metadata, and CTAs are already wired to
                that variable.
              </div>
            )}
            <p>
              Supported platform: {siteConfig.supportedMacOS} on Apple Silicon
              and Intel Macs.
            </p>
            <Link className="button button-ghost full" href="/docs/getting-started">
              Read setup guide
            </Link>
            <Link className="button button-ghost full" href="/system-requirements">
              Check system requirements
            </Link>
          </div>

          <div className="info-panel">
            <h2>Setup checklist</h2>
            <ol className="check-list">
              {releaseChecklist.map((item) => (
                <li key={item}>{item}</li>
              ))}
            </ol>
          </div>
        </div>
      </PublicPage>
    </>
  );
}
