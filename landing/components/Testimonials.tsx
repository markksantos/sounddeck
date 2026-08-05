"use client";

import Link from "next/link";
import AnimateIn from "./AnimateIn";
import { trustItems, useCases } from "@/lib/content";
import {
  Airplay,
  Article,
  Broadcast,
  ChatsCircle,
  Circuitry,
  Crown,
  LockKey,
  SlidersHorizontal,
} from "@phosphor-icons/react";

const useCaseIcons = [ChatsCircle, Broadcast, Article, Airplay];
const trustIcons = [LockKey, Circuitry, SlidersHorizontal, Crown];

export default function Testimonials() {
  return (
    <section id="use-cases" className="section">
      <div className="section-inner">
        <AnimateIn className="section-heading">
          <p className="eyebrow">Use cases</p>
          <h2>Purpose-built for live audio moments.</h2>
          <p>
            These are the workflows SoundDeck is designed around, without
            unverified testimonials or inflated review claims.
          </p>
        </AnimateIn>

        <div className="use-case-grid">
          {useCases.map((item, i) => {
            const Icon = useCaseIcons[i] ?? ChatsCircle;
            return (
              <AnimateIn key={item.title} delay={i * 0.08} className="use-case-card">
                <Icon weight="duotone" className="feature-icon" />
                <p className="card-kicker">{item.audience}</p>
                <h3>{item.title}</h3>
                <p>{item.description}</p>
              </AnimateIn>
            );
          })}
        </div>
        <div className="section-actions">
          <Link className="button button-ghost" href="/use-cases">
            Explore use cases
          </Link>
        </div>

        <div className="trust-grid" aria-label="SoundDeck trust and safety details">
          {trustItems.map((item, i) => {
            const Icon = trustIcons[i] ?? LockKey;
            return (
              <AnimateIn key={item.title} delay={i * 0.08} className="trust-card">
                <Icon weight="duotone" />
                <div>
                  <h3>{item.title}</h3>
                  <p>{item.description}</p>
                </div>
              </AnimateIn>
            );
          })}
        </div>
      </div>
    </section>
  );
}
