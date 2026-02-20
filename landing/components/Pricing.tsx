"use client";

import AnimateIn from "./AnimateIn";
import { Check } from "@phosphor-icons/react";

const features = [
  "Virtual microphone device",
  "Unlimited sound effects",
  "Voice changer & effects",
  "Global hotkey support",
  "All future updates included",
  "macOS Ventura & later",
];

export default function Pricing() {
  return (
    <section id="pricing" className="py-[120px] px-6">
      <div className="max-w-md mx-auto">
        <AnimateIn>
          <div className="glass rounded-3xl p-10 text-center shadow-xl shadow-black/5">
            <p className="text-sm font-semibold text-accent uppercase tracking-wider mb-4">
              One-Time Purchase
            </p>
            <div className="mb-2">
              <span className="text-6xl font-bold tracking-tight">$29</span>
            </div>
            <p className="text-foreground/50 mb-8">
              No subscription. No recurring fees. Ever.
            </p>

            <ul className="text-left space-y-3 mb-10">
              {features.map((f) => (
                <li key={f} className="flex items-center gap-3">
                  <Check
                    weight="bold"
                    className="w-5 h-5 text-accent flex-shrink-0"
                  />
                  <span className="text-[15px]">{f}</span>
                </li>
              ))}
            </ul>

            <a
              href="https://lemonsqueezy.com"
              target="_blank"
              rel="noopener noreferrer"
              className="block w-full py-4 rounded-full bg-accent text-white font-semibold text-base hover:bg-accent/90 transition-colors"
            >
              Buy SoundDeck — $29
            </a>
          </div>
        </AnimateIn>
      </div>
    </section>
  );
}
