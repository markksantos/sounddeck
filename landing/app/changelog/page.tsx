import type { Metadata } from "next";
import PublicPage from "@/components/PublicPage";
import { changelog, releaseAnchor } from "@/lib/content";

export const metadata: Metadata = {
  title: "Changelog",
  description:
    "SoundDeck release notes and public changelog for the macOS soundboard and virtual microphone app.",
  alternates: { canonical: "/changelog" },
};

export default function ChangelogPage() {
  return (
    <PublicPage
      eyebrow="Release notes"
      title="SoundDeck changelog"
      description="Track public app changes, launch notes, and release-readiness updates."
    >
      <div className="stack-list">
        {changelog.map((release) => (
          <article
            key={release.version}
            id={releaseAnchor(release.version)}
            className="info-panel"
          >
            <p className="eyebrow">{release.date}</p>
            <h2>Version {release.version}</h2>
            <ul>
              {release.items.map((item) => (
                <li key={item}>{item}</li>
              ))}
            </ul>
          </article>
        ))}
      </div>
    </PublicPage>
  );
}
