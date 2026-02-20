"use client";

import { motion, useScroll, useTransform } from "framer-motion";
import { useRef } from "react";
import dynamic from "next/dynamic";

const HeroBackground = dynamic(() => import("./HeroBackground"), {
  ssr: false,
});

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
      className="relative min-h-screen flex flex-col items-center justify-center px-6 overflow-hidden"
    >
      <HeroBackground />

      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.7, ease: [0.25, 0.1, 0.25, 1] }}
        className="text-center max-w-3xl mx-auto"
      >
        <h1 className="text-5xl md:text-7xl font-bold tracking-tight leading-[1.1]">
          The{" "}
          <em className="font-serif font-medium italic text-accent">
            soundboard
          </em>{" "}
          built for your Mac
        </h1>
        <p className="mt-6 text-lg md:text-xl text-foreground/60 max-w-xl mx-auto leading-relaxed">
          A virtual microphone that injects sound effects and voice changes
          directly into Zoom, Discord, and any app on macOS.
        </p>
        <div className="mt-10 flex flex-col sm:flex-row gap-4 justify-center">
          <a
            href="#pricing"
            className="inline-flex items-center justify-center px-8 py-3.5 rounded-full bg-accent text-white font-semibold text-base hover:bg-accent/90 transition-colors"
          >
            Download Free
          </a>
          <a
            href="#pricing"
            className="inline-flex items-center justify-center px-8 py-3.5 rounded-full border-2 border-foreground/15 font-semibold text-base hover:border-foreground/30 transition-colors"
          >
            See Pricing
          </a>
        </div>
      </motion.div>

      <motion.div
        style={{ y: screenshotY }}
        initial={{ opacity: 0, y: 40 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.8, delay: 0.3, ease: [0.25, 0.1, 0.25, 1] }}
        className="mt-16 w-full max-w-2xl mx-auto"
      >
        <div className="glass rounded-2xl p-6 shadow-xl shadow-black/5">
          <div className="bg-foreground/5 rounded-xl aspect-[16/10] flex items-center justify-center">
            <div className="text-center text-foreground/30">
              <div className="text-4xl mb-2">🎙️</div>
              <p className="text-sm font-medium">App Screenshot</p>
            </div>
          </div>
        </div>
      </motion.div>
    </section>
  );
}
