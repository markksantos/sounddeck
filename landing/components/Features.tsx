"use client";

import Link from "next/link";
import AnimateIn from "./AnimateIn";
import { productFeatures } from "@/lib/content";
import {
  DownloadSimple,
  Headphones,
  Keyboard,
  Microphone,
  MusicNote,
  Scissors,
  ShieldCheck,
  Waveform,
} from "@phosphor-icons/react";

const featureIcons = [
  Microphone,
  MusicNote,
  Waveform,
  Keyboard,
  Headphones,
  Scissors,
  ShieldCheck,
  DownloadSimple,
];

export default function Features() {
  return (
    <section id="features" className="section">
      <div className="section-inner">
        <AnimateIn className="section-heading">
          <p className="eyebrow">Feature set</p>
          <h2>Built for the moment someone says “can everyone hear that?”</h2>
          <p>
            SoundDeck handles the audio route, the local preview, and the fast
            trigger surface in one native Mac app.
          </p>
        </AnimateIn>

        <div className="feature-grid">
          {productFeatures.map((feature, i) => {
            const Icon = featureIcons[i] ?? MusicNote;
            return (
              <AnimateIn
                key={feature.title}
                delay={i * 0.08}
                className="feature-card"
              >
                <Icon weight="duotone" className="feature-icon" />
                <h3>{feature.title}</h3>
                <p>{feature.description}</p>
                <span>{feature.proof}</span>
              </AnimateIn>
            );
          })}
        </div>
        <div className="section-actions">
          <Link className="button button-ghost" href="/features">
            Explore features
          </Link>
        </div>
      </div>
    </section>
  );
}
