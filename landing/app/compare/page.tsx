import type { Metadata } from "next";
import Link from "next/link";
import JsonLd from "@/components/JsonLd";
import PublicPage from "@/components/PublicPage";
import { comparisonDetails, comparisonRows } from "@/lib/content";
import { absoluteUrl, siteConfig, supportMailtoLink } from "@/lib/site";

const pageDescription =
  "Compare SoundDeck with web soundboards, hardware-only setups, and manual audio routing for macOS calls, streams, podcasts, and workshops.";

export const metadata: Metadata = {
  title: "Compare",
  description: pageDescription,
  alternates: { canonical: "/compare" },
};

const compareSchema = [
  {
    "@context": "https://schema.org",
    "@type": "CollectionPage",
    name: "SoundDeck Comparison",
    url: absoluteUrl("/compare"),
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
        name: "Compare",
        item: absoluteUrl("/compare"),
      },
    ],
  },
  {
    "@context": "https://schema.org",
    "@type": "ItemList",
    name: "SoundDeck workflow comparison",
    itemListElement: comparisonDetails.map((item, index) => ({
      "@type": "ListItem",
      position: index + 1,
      name: item.option,
      description: `${item.summary} Best for: ${item.bestFor} Tradeoff: ${item.tradeoff}`,
    })),
  },
];

export default function ComparePage() {
  return (
    <PublicPage
      eyebrow="Compare"
      title="Choose the soundboard workflow that actually reaches the call"
      description="SoundDeck is built for the microphone path. This comparison focuses on live routing, preview, hotkeys, and reset behavior rather than generic playback."
    >
      <JsonLd data={compareSchema} />

      <div className="comparison-table-wrap">
        <table className="comparison-table">
          <caption>SoundDeck compared with common soundboard workflows</caption>
          <thead>
            <tr>
              <th>Workflow need</th>
              <th>SoundDeck</th>
              <th>Web soundboards</th>
              <th>Hardware-only setups</th>
            </tr>
          </thead>
          <tbody>
            {comparisonRows.map((row) => (
              <tr key={row[0]}>
                {row.map((cell) => (
                  <td key={cell}>{cell}</td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      <div className="stack-list">
        {comparisonDetails.map((item) => (
          <article className="info-panel" key={item.option}>
            <h2>{item.option}</h2>
            <p>{item.summary}</p>
            <h3>Best Fit</h3>
            <p>{item.bestFor}</p>
            <h3>Tradeoff</h3>
            <p>{item.tradeoff}</p>
          </article>
        ))}
      </div>

      <div className="two-column">
        <div className="info-panel">
          <h2>When SoundDeck Wins</h2>
          <p>
            Use SoundDeck when the audience needs to hear sound effects through
            the same microphone route as your voice, and you need a fast Stop All
            path before the next meeting, scene, or recording take.
          </p>
          <Link className="button button-primary" href="/download">
            Download SoundDeck
          </Link>
        </div>

        <div className="info-panel">
          <h2>Unsure About Routing?</h2>
          <p>
            Send your target app, current audio setup, and whether you use a
            web soundboard, hardware controller, or manual loopback chain.
          </p>
          <a className="button button-ghost" href={supportMailtoLink()}>
            Ask setup support
          </a>
        </div>
      </div>
    </PublicPage>
  );
}
