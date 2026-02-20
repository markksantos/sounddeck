"use client";

import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { CaretDown } from "@phosphor-icons/react";
import AnimateIn from "./AnimateIn";

const faqs = [
  {
    q: "How does SoundDeck work?",
    a: "SoundDeck installs a lightweight audio driver that creates a virtual microphone on your Mac. When you select 'SoundDeck Mic' as your input device in any app, it receives your real microphone audio mixed with any sound effects you trigger.",
  },
  {
    q: "Is the audio driver safe?",
    a: "Yes. The driver is a standard macOS AudioServerPlugin — the same mechanism used by professional audio software. It's sandboxed, signed, and notarized by Apple. It does not modify your system or other audio devices.",
  },
  {
    q: "Which apps does it work with?",
    a: "Any app that accepts a microphone input — Zoom, Google Meet, Discord, Slack, Microsoft Teams, FaceTime, OBS, and more. If it shows up in the app's microphone picker, it works.",
  },
  {
    q: "What macOS versions are supported?",
    a: "SoundDeck supports macOS Ventura (13.0) and later, on both Apple Silicon and Intel Macs.",
  },
  {
    q: "Is there a free trial?",
    a: "Yes — you can download and try SoundDeck with a limited set of built-in sounds. The full version unlocks unlimited custom sounds, voice changer, and hotkey support.",
  },
  {
    q: "What's the refund policy?",
    a: "We offer a 14-day no-questions-asked refund policy. If SoundDeck isn't for you, just email us and we'll process the refund immediately.",
  },
];

function FAQItem({ q, a }: { q: string; a: string }) {
  const [open, setOpen] = useState(false);

  return (
    <div className="border-b border-foreground/5">
      <button
        onClick={() => setOpen(!open)}
        className="w-full flex items-center justify-between py-5 text-left cursor-pointer"
      >
        <span className="font-semibold text-[15px] pr-4">{q}</span>
        <motion.div
          animate={{ rotate: open ? 180 : 0 }}
          transition={{ duration: 0.2 }}
        >
          <CaretDown weight="bold" className="w-4 h-4 text-foreground/30" />
        </motion.div>
      </button>
      <AnimatePresence>
        {open && (
          <motion.div
            initial={{ height: 0, opacity: 0 }}
            animate={{ height: "auto", opacity: 1 }}
            exit={{ height: 0, opacity: 0 }}
            transition={{ duration: 0.25, ease: [0.25, 0.1, 0.25, 1] }}
            className="overflow-hidden"
          >
            <p className="pb-5 text-foreground/50 leading-relaxed text-[15px]">
              {a}
            </p>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}

export default function FAQ() {
  return (
    <section className="py-[120px] px-6 bg-foreground/[0.02]">
      <div className="max-w-2xl mx-auto">
        <AnimateIn className="text-center mb-12">
          <h2 className="text-3xl md:text-5xl font-bold tracking-tight">
            Questions?{" "}
            <em className="font-serif font-medium italic text-accent">
              Answers
            </em>
          </h2>
        </AnimateIn>

        <AnimateIn delay={0.1}>
          <div>
            {faqs.map((faq) => (
              <FAQItem key={faq.q} {...faq} />
            ))}
          </div>
        </AnimateIn>
      </div>
    </section>
  );
}
