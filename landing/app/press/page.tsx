import type { Metadata } from "next";
import PublicPage from "@/components/PublicPage";
import { pressFacts } from "@/lib/content";
import { pressMailtoLink, siteConfig } from "@/lib/site";

export const metadata: Metadata = {
  title: "Press",
  description:
    "SoundDeck press information, product facts, launch positioning, and contact details.",
  alternates: { canonical: "/press" },
};

export default function PressPage() {
  return (
    <PublicPage
      eyebrow="Press"
      title="SoundDeck press kit"
      description="A concise product brief for coverage, launch listings, and partnership conversations."
    >
      <div className="two-column">
        <div className="info-panel">
          <h2>Facts</h2>
          <ul>
            {pressFacts.map((fact) => (
              <li key={fact}>{fact}</li>
            ))}
          </ul>
        </div>
        <div className="info-panel">
          <h2>Short description</h2>
          <p>{siteConfig.shortDescription}</p>
          <h2>Press contact</h2>
          <p>
            <a href={pressMailtoLink()}>{siteConfig.pressEmail}</a>
          </p>
        </div>
      </div>
    </PublicPage>
  );
}
