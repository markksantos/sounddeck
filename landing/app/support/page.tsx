import type { Metadata } from "next";
import Link from "next/link";
import PublicPage from "@/components/PublicPage";
import { faqs, supportTopics } from "@/lib/content";
import { siteConfig, supportMailtoLink } from "@/lib/site";

export const metadata: Metadata = {
  title: "Support",
  description:
    "Get SoundDeck setup help for macOS microphone permission, driver installation, virtual mic routing, voice effects, Pro access, and uninstall steps.",
  alternates: { canonical: "/support" },
};

type SupportPageProps = {
  searchParams?: Promise<{
    q?: string | string[];
  }>;
};

function firstSearchParam(value: string | string[] | undefined) {
  return Array.isArray(value) ? value[0] : value;
}

function normalizeQuery(value: string | undefined) {
  return (value ?? "").trim().replace(/\s+/g, " ").slice(0, 80);
}

function matchesQuery(query: string, ...values: string[]) {
  const normalizedQuery = query.toLowerCase();
  return values.some((value) => value.toLowerCase().includes(normalizedQuery));
}

export default async function SupportPage({ searchParams }: SupportPageProps) {
  const params = await searchParams;
  const query = normalizeQuery(firstSearchParam(params?.q));
  const hasQuery = query.length > 0;
  const filteredTopics = hasQuery
    ? supportTopics.filter((topic) =>
        matchesQuery(query, topic.title, topic.body, ...topic.steps),
      )
    : supportTopics;
  const filteredFaqs = hasQuery
    ? faqs.filter((faq) => matchesQuery(query, faq.q, faq.a))
    : faqs;
  const resultCount = filteredTopics.length + filteredFaqs.length;

  return (
    <PublicPage
      eyebrow="Support"
      title="Setup help without the runaround"
      description="Start with the common fixes below. For direct help, include your macOS version, SoundDeck version, target app, and whether the driver is installed."
    >
      <form className="support-search" action="/support" role="search">
        <label htmlFor="support-query">Search setup help</label>
        <div className="support-search-row">
          <input
            id="support-query"
            name="q"
            type="search"
            defaultValue={query}
            aria-describedby="support-query-hint"
          />
          <button className="button button-primary" type="submit">
            Search
          </button>
        </div>
        <p id="support-query-hint">
          Try driver, microphone permission, import, duplicate, folders, free plan, Pro library, trim, monitoring, voice effects, uninstall, or Pro.
        </p>
        {hasQuery ? (
          <p>
            Showing {resultCount} result{resultCount === 1 ? "" : "s"} for <strong>{query}</strong>.
            <a href="/support">Clear search</a>
          </p>
        ) : (
          <p>Search the setup guide, common fixes, and launch FAQ.</p>
        )}
      </form>

      <div className="two-column">
        <div className="info-panel">
          <h2>Contact</h2>
          <p>
            Email <a href={supportMailtoLink()}>{siteConfig.supportEmail}</a>.
            Support is best when you include your target app, input device, and a
            screenshot of SoundDeck Settings.
          </p>
          <a className="button button-primary full" href={supportMailtoLink()}>
            Email support
          </a>
          <Link className="button button-ghost full" href="/docs/troubleshooting">
            Open troubleshooting guide
          </Link>
          <Link className="button button-ghost full" href="/docs/audio-driver">
            Open audio driver guide
          </Link>
          <Link className="button button-ghost full" href="/docs/microphone-permission">
            Open microphone permission guide
          </Link>
          <Link className="button button-ghost full" href="/docs/import-sounds">
            Open import sounds guide
          </Link>
          <Link className="button button-ghost full" href="/docs/free-plan">
            Open Free plan guide
          </Link>
          <Link className="button button-ghost full" href="/docs/folders">
            Open folders guide
          </Link>
          <Link className="button button-ghost full" href="/docs/pro-library">
            Open Pro library guide
          </Link>
          <Link className="button button-ghost full" href="/docs/trim-volume">
            Open trim and volume guide
          </Link>
          <Link className="button button-ghost full" href="/docs/monitoring-preview">
            Open monitoring guide
          </Link>
          <Link className="button button-ghost full" href="/docs/voice-effects">
            Open voice effects guide
          </Link>
        </div>

        <div className="info-panel">
          <h2>Common fixes</h2>
          <div className="stack-list">
            {filteredTopics.map((topic) => (
              <article key={topic.title}>
                <h3>{topic.title}</h3>
                <p>{topic.body}</p>
              </article>
            ))}
            {filteredTopics.length === 0 && (
              <article>
                <h3>No matching fixes</h3>
                <p>Email support with your target app, input device, and SoundDeck Settings screenshot.</p>
              </article>
            )}
          </div>
        </div>
      </div>

      <div className="info-panel">
        <h2>FAQ</h2>
        <div className="stack-list">
          {filteredFaqs.map((faq) => (
            <article key={faq.q}>
              <h3>{faq.q}</h3>
              <p>{faq.a}</p>
            </article>
          ))}
          {filteredFaqs.length === 0 && (
            <article>
              <h3>No matching FAQ entries</h3>
              <p>Try a broader query or email support for direct setup help.</p>
            </article>
          )}
        </div>
      </div>
    </PublicPage>
  );
}
