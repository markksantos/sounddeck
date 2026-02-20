"use client";

import AnimateIn from "./AnimateIn";
import {
  Microphone,
  MusicNote,
  WaveformSlash,
  Keyboard,
  SpeakerHigh,
  Sidebar,
} from "@phosphor-icons/react";
import { ReactNode } from "react";

interface Feature {
  icon: ReactNode;
  title: string;
  description: string;
  large?: boolean;
}

const features: Feature[] = [
  {
    icon: <Microphone weight="duotone" className="w-8 h-8 text-accent" />,
    title: "Virtual Microphone",
    description:
      "Creates a system-level audio device that works natively in Zoom, Discord, Google Meet, and every app on macOS.",
    large: true,
  },
  {
    icon: <MusicNote weight="duotone" className="w-8 h-8 text-accent" />,
    title: "Instant Sound Effects",
    description:
      "One-click SFX pads for rimshots, applause, airhorns, and anything you drag in.",
  },
  {
    icon: <WaveformSlash weight="duotone" className="w-8 h-8 text-accent" />,
    title: "Voice Changer",
    description:
      "Real-time pitch shifting and voice effects with zero perceptible latency.",
  },
  {
    icon: <Keyboard weight="duotone" className="w-8 h-8 text-accent" />,
    title: "Hotkey Support",
    description:
      "Assign global keyboard shortcuts to trigger any sound instantly.",
  },
  {
    icon: <SpeakerHigh weight="duotone" className="w-8 h-8 text-accent" />,
    title: "SFX Monitor",
    description:
      "Preview what you're sending so you always know what others hear.",
  },
  {
    icon: <Sidebar weight="duotone" className="w-8 h-8 text-accent" />,
    title: "Menu Bar Native",
    description:
      "Lives in your menu bar and is always one click away. No dock icon, no clutter.",
    large: true,
  },
];

export default function Features() {
  return (
    <section className="py-[120px] px-6">
      <div className="max-w-5xl mx-auto">
        <AnimateIn className="text-center mb-16">
          <h2 className="text-3xl md:text-5xl font-bold tracking-tight">
            Everything you need,{" "}
            <em className="font-serif font-medium italic text-accent">
              nothing you don&apos;t
            </em>
          </h2>
        </AnimateIn>

        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          {features.map((feature, i) => (
            <AnimateIn
              key={feature.title}
              delay={i * 0.08}
              className={feature.large ? "md:col-span-2" : "md:col-span-2"}
            >
              <div className="glass rounded-2xl p-8 h-full hover:shadow-lg hover:shadow-black/5 transition-shadow">
                <div className="mb-4">{feature.icon}</div>
                <h3 className="text-lg font-semibold mb-2">{feature.title}</h3>
                <p className="text-foreground/50 leading-relaxed text-[15px]">
                  {feature.description}
                </p>
              </div>
            </AnimateIn>
          ))}
        </div>
      </div>
    </section>
  );
}
