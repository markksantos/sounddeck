"use client";

import AnimateIn from "./AnimateIn";
import { Star } from "@phosphor-icons/react";

export default function SocialProof() {
  return (
    <section className="py-12 bg-foreground/[0.02] border-y border-foreground/5">
      <AnimateIn className="max-w-5xl mx-auto px-6 flex flex-col sm:flex-row items-center justify-center gap-6 sm:gap-12">
        <div className="flex items-center gap-2">
          <div className="flex -space-x-2">
            {[...Array(4)].map((_, i) => (
              <div
                key={i}
                className="w-8 h-8 rounded-full bg-accent/20 border-2 border-background"
              />
            ))}
          </div>
          <span className="text-sm font-medium text-foreground/50">
            500+ creators
          </span>
        </div>

        <div className="flex items-center gap-1.5">
          {[...Array(5)].map((_, i) => (
            <Star key={i} weight="fill" className="w-4 h-4 text-amber-400" />
          ))}
          <span className="ml-1 text-sm font-medium text-foreground/50">
            4.9 average rating
          </span>
        </div>
      </AnimateIn>
    </section>
  );
}
