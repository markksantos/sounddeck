"use client";

import AnimateIn from "./AnimateIn";

export default function Screenshots() {
  return (
    <section className="py-[120px] px-6 bg-foreground/[0.02]">
      <div className="max-w-4xl mx-auto">
        <AnimateIn>
          <div className="glass rounded-3xl p-8 shadow-xl shadow-black/5">
            <div className="bg-foreground/5 rounded-2xl aspect-[16/10] flex items-center justify-center">
              <div className="text-center text-foreground/30">
                <div className="text-5xl mb-3">🖥️</div>
                <p className="text-base font-medium">
                  SoundDeck Popover — Full App View
                </p>
                <p className="text-sm mt-1">Placeholder for app screenshot</p>
              </div>
            </div>
          </div>
        </AnimateIn>

        <AnimateIn delay={0.15} className="mt-8 max-w-sm mx-auto">
          <div className="glass rounded-2xl p-4 shadow-lg shadow-black/5">
            <div className="bg-foreground/5 rounded-xl aspect-[4/1] flex items-center justify-center">
              <p className="text-sm text-foreground/30 font-medium">
                Menu bar context
              </p>
            </div>
          </div>
        </AnimateIn>
      </div>
    </section>
  );
}
