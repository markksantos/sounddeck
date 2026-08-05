"use client";

import { motion, useScroll, useTransform } from "framer-motion";
import { useRef } from "react";
import ProductMockup from "./ProductMockup";
import { siteConfig } from "@/lib/site";

export default function Hero() {
  const ref = useRef(null);
  const { scrollYProgress } = useScroll({
    target: ref,
    offset: ["start start", "end start"],
  });
  const screenshotY = useTransform(scrollYProgress, [0, 1], [0, -60]);

  return (
    <section
      ref={ref}
      className="hero-section"
    >
      <motion.div
        initial={false}
        className="hero-copy"
      >
        <p className="eyebrow">Native macOS soundboard + virtual microphone</p>
        <h1>
          SoundDeck puts a polished soundboard inside your Mac microphone.
        </h1>
        <p>
          Play SFX, voice-changed audio, and hotkey-triggered clips into Zoom,
          Discord, Google Meet, OBS, Riverside, and any app with a mic picker.
        </p>
        <div className="hero-actions">
          <a href={siteConfig.downloadUrl} className="button button-primary">
            Download SoundDeck
          </a>
          <a href="/pricing" className="button button-ghost">
            See Free vs Pro
          </a>
        </div>
        <div className="hero-facts" aria-label="SoundDeck launch facts">
          <span>{siteConfig.supportedMacOS}</span>
          <span>Apple Silicon + Intel</span>
          <span>Local audio processing</span>
        </div>
      </motion.div>

      <motion.div
        style={{ y: screenshotY }}
        initial={false}
        className="hero-product"
      >
        <ProductMockup />
      </motion.div>
    </section>
  );
}
