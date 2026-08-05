import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import JsonLd from "@/components/JsonLd";
import PublicPage from "@/components/PublicPage";
import { appGuides } from "@/lib/content";
import { absoluteUrl, siteConfig, supportMailtoLink } from "@/lib/site";

type GuidePageProps = {
  params: Promise<{
    slug: string;
  }>;
};

export const dynamicParams = false;

function guideForSlug(slug: string) {
  return appGuides.find((guide) => guide.slug === slug);
}

export function generateStaticParams() {
  return appGuides.map((guide) => ({ slug: guide.slug }));
}

export async function generateMetadata({ params }: GuidePageProps): Promise<Metadata> {
  const { slug } = await params;
  const guide = guideForSlug(slug);

  if (!guide) {
    return {};
  }

  return {
    title: guide.title,
    description: guide.summary,
    alternates: { canonical: `/guides/${guide.slug}` },
  };
}

export default async function AppGuidePage({ params }: GuidePageProps) {
  const { slug } = await params;
  const guide = guideForSlug(slug);

  if (!guide) {
    notFound();
  }

  const guideUrl = `/guides/${guide.slug}`;
  const helpCopy = `Include ${guide.name}, your macOS version, SoundDeck version, selected input device, and whether SoundDeck Virtual Mic appears in the app.`;
  const routingRule = `Select SoundDeck Virtual Mic inside ${guide.name}, then keep your hardware microphone selected inside SoundDeck.`;
  const supportLabel = `Email ${guide.name} setup support`;
  const guideSchema = [
    {
      "@context": "https://schema.org",
      "@type": "Article",
      headline: guide.title,
      name: guide.title,
      url: absoluteUrl(guideUrl),
      description: guide.summary,
      about: [
        {
          "@type": "SoftwareApplication",
          name: siteConfig.name,
          applicationCategory: siteConfig.appStoreCategory,
          operatingSystem: "macOS",
          softwareVersion: siteConfig.currentVersion,
          url: siteConfig.url,
        },
        {
          "@type": "SoftwareApplication",
          name: guide.name,
          applicationCategory: guide.category,
        },
      ],
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
          name: "App Setup Guides",
          item: absoluteUrl("/guides"),
        },
        {
          "@type": "ListItem",
          position: 3,
          name: guide.name,
          item: absoluteUrl(guideUrl),
        },
      ],
    },
    {
      "@context": "https://schema.org",
      "@type": "HowTo",
      name: guide.title,
      description: guide.summary,
      url: absoluteUrl(guideUrl),
      step: guide.setupSteps.map((step, index) => ({
        "@type": "HowToStep",
        position: index + 1,
        text: step,
      })),
    },
  ];

  return (
    <PublicPage
      eyebrow={guide.category}
      title={guide.title}
      description={guide.summary}
    >
      <JsonLd data={guideSchema} />

      <div className="two-column">
        <div className="info-panel">
          <h2>Best Fit</h2>
          <p>{guide.bestFor}</p>
        </div>

        <div className="info-panel">
          <h2>Routing Rule</h2>
          <p>{routingRule}</p>
        </div>
      </div>

      <div className="info-panel">
        <h2>Setup Checklist</h2>
        <ol>
          {guide.setupSteps.map((step) => (
            <li key={step}>{step}</li>
          ))}
        </ol>
      </div>

      <div className="info-panel">
        <h2>Troubleshooting Checks</h2>
        <ul>
          {guide.troubleshooting.map((check) => (
            <li key={check}>{check}</li>
          ))}
        </ul>
      </div>

      <div className="two-column">
        <div className="info-panel">
          <h2>Related Guides</h2>
          <p>
            Check the universal setup, troubleshooting, and hotkey guides if the
            microphone picker works but routing still feels wrong.
          </p>
          <Link className="button button-ghost" href="/docs/getting-started">
            Open setup guide
          </Link>
          <Link className="button button-ghost" href="/docs/troubleshooting">
            Open troubleshooting
          </Link>
        </div>

        <div className="info-panel">
          <h2>Need Direct Help?</h2>
          <p>{helpCopy}</p>
          <a className="button button-primary" href={supportMailtoLink()}>
            {supportLabel}
          </a>
          <Link className="button button-ghost" href="/guides">
            View all app guides
          </Link>
        </div>
      </div>
    </PublicPage>
  );
}
