import type { Metadata } from "next";
import Link from "next/link";
import PublicPage from "@/components/PublicPage";
import CTA from "@/components/CTA";
import { docsSteps } from "@/lib/content";

export const metadata: Metadata = {
  title: "Getting Started",
  description:
    "Get started with SoundDeck on macOS: install the driver, grant microphone permission, select SoundDeck Virtual Mic, import sounds, and monitor playback.",
  alternates: { canonical: "/docs/getting-started" },
};

export default function GettingStartedPage() {
  return (
    <PublicPage
      eyebrow="Docs"
      title="Getting started with SoundDeck"
      description="Follow this setup path when using SoundDeck with Zoom, Discord, Google Meet, OBS, Riverside, or another app with a microphone picker."
    >
      <div className="stack-list numbered">
        {docsSteps.map((step, index) => (
          <article key={step.title} className="info-panel">
            <span className="step-number">{index + 1}</span>
            <h2>{step.title}</h2>
            <p>{step.body}</p>
          </article>
        ))}
      </div>
      <div className="two-column">
        <div className="info-panel">
          <h2>Something Not Appearing?</h2>
          <p>
            Use the troubleshooting guide for driver approval, SoundDeck Virtual
            Mic visibility, macOS microphone permission, routing, and uninstall
            checks.
          </p>
          <Link className="button button-ghost" href="/docs/troubleshooting">
            Open troubleshooting guide
          </Link>
          <Link className="button button-ghost" href="/docs/audio-driver">
            Open audio driver guide
          </Link>
          <Link className="button button-ghost" href="/docs/microphone-permission">
            Open microphone permission guide
          </Link>
          <Link className="button button-ghost" href="/docs/virtual-microphone">
            Open virtual mic guide
          </Link>
          <Link className="button button-ghost" href="/docs/import-sounds">
            Open import sounds guide
          </Link>
          <Link className="button button-ghost" href="/docs/free-plan">
            Open Free plan guide
          </Link>
          <Link className="button button-ghost" href="/docs/folders">
            Open folders guide
          </Link>
          <Link className="button button-ghost" href="/docs/pro-library">
            Open Pro library guide
          </Link>
          <Link className="button button-ghost" href="/docs/trim-volume">
            Open trim and volume guide
          </Link>
          <Link className="button button-ghost" href="/docs/monitoring-preview">
            Open monitoring guide
          </Link>
          <Link className="button button-ghost" href="/docs/voice-effects">
            Open voice effects guide
          </Link>
          <Link className="button button-ghost" href="/docs/hotkeys">
            Open hotkeys guide
          </Link>
        </div>
        <div className="info-panel">
          <h2>Clean Route Check</h2>
          <p>
            SoundDeck should be open, your real mic should be selected inside
            SoundDeck, and the target app should use SoundDeck Virtual Mic.
          </p>
          <Link className="button button-ghost" href="/docs/virtual-microphone">
            Check the route
          </Link>
        </div>
      </div>
      <CTA
        title="Ready to test the route?"
        body="Download SoundDeck, choose the virtual mic in your target app, and trigger your first pad."
      />
    </PublicPage>
  );
}
