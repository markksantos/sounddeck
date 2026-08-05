"use client";

import { useState } from "react";
import { motion, useReducedMotion } from "framer-motion";
import {
  Microphone,
  MusicNote,
  SpeakerHigh,
  StopCircle,
  Waveform,
} from "@phosphor-icons/react";

const pads = [
  { label: "Intro", tone: "coral", key: "⌘1" },
  { label: "Applause", tone: "mint", key: "⌘2" },
  { label: "Rimshot", tone: "amber", key: "⌘3" },
  { label: "Hold", tone: "sky", key: "⌘4" },
  { label: "Laugh", tone: "violet", key: "⌘5" },
  { label: "Cue", tone: "slate", key: "⌘6" },
];

const folders = ["All", "Effects", "Music", "Voice", "Custom"];

export default function ProductMockup({ compact = false }: { compact?: boolean }) {
  const [active, setActive] = useState("Applause");
  const [selectedFolder, setSelectedFolder] = useState("Effects");
  const shouldReduceMotion = useReducedMotion();

  return (
    <div className={compact ? "product-mockup compact-mockup" : "product-mockup"}>
      <div className="menu-bar">
        <span className="traffic red" />
        <span className="traffic yellow" />
        <span className="traffic green" />
        <span className="menu-title">SoundDeck</span>
        <span className="menu-status">SoundDeck Virtual Mic</span>
      </div>

      <div className="mockup-body">
        <aside className="mockup-sidebar">
          {folders.map((item) => (
            <button
              key={item}
              type="button"
              className={item === selectedFolder ? "folder active" : "folder"}
              aria-pressed={item === selectedFolder}
              onClick={() => setSelectedFolder(item)}
            >
              {item}
            </button>
          ))}
        </aside>

        <section className="mockup-panel" aria-label="SoundDeck app preview">
          <div className="meter-row">
            <div className="wave-strip" aria-hidden="true">
              {Array.from({ length: 22 }, (_, index) => (
                <motion.span
                  key={index}
                  animate={
                    shouldReduceMotion
                      ? undefined
                      : { height: active ? 8 + ((index * 7) % 24) : 8 }
                  }
                  transition={{ duration: 0.7, repeat: Infinity, repeatType: "reverse", delay: index * 0.03 }}
                />
              ))}
            </div>
            <div className="monitor-pills">
              <span>
                <SpeakerHigh weight="fill" /> SFX
              </span>
              <span>
                <Microphone weight="fill" /> Mic
              </span>
            </div>
          </div>

          <div className="pad-grid">
            {pads.map((pad) => (
              <button
                key={pad.label}
                type="button"
                className={`sound-pad ${pad.tone} ${active === pad.label ? "active" : ""}`}
                aria-pressed={active === pad.label}
                onClick={() => setActive(pad.label)}
              >
                <MusicNote weight="fill" />
                <span>{pad.label}</span>
                <kbd>{pad.key}</kbd>
              </button>
            ))}
          </div>

          <div className="route-strip" aria-label="Virtual microphone routing preview">
            <span>Your mic</span>
            <span>+</span>
            <span>{active ? `${active} SFX` : "No SFX armed"}</span>
            <span>→</span>
            <strong>SoundDeck Virtual Mic</strong>
          </div>

          <div className="mockup-footer">
            <span className="engine-live">
              <Waveform weight="bold" /> Engine running
            </span>
            <button
              type="button"
              className="stop-button"
              aria-label="Stop all active sound previews"
              onClick={() => setActive("")}
            >
              <StopCircle weight="fill" /> Stop All
            </button>
          </div>
        </section>
      </div>
    </div>
  );
}
