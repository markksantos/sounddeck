"use client";

import AnimateIn from "./AnimateIn";
import { CheckCircle, Cpu, LockKey, SpeakerHigh } from "@phosphor-icons/react";

export default function SocialProof() {
  return (
    <section className="proof-strip" aria-label="SoundDeck trust signals">
      <AnimateIn className="proof-inner">
        <span>
          <CheckCircle weight="fill" /> Free plan available
        </span>
        <span>
          <Cpu weight="fill" /> Native CoreAudio route
        </span>
        <span>
          <LockKey weight="fill" /> Local-first audio
        </span>
        <span>
          <SpeakerHigh weight="fill" /> Private monitoring
        </span>
      </AnimateIn>
    </section>
  );
}
