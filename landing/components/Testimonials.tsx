"use client";

import AnimateIn from "./AnimateIn";

const testimonials = [
  {
    name: "Alex Rivera",
    role: "Podcast Host",
    quote:
      "SoundDeck completely changed my remote recording workflow. Drop in a sting, a laugh track — guests love it, and it just works in Riverside.",
  },
  {
    name: "Sam Chen",
    role: "Twitch Streamer",
    quote:
      "I used to juggle three apps to get soundboard audio into Discord. Now it's one click from the menu bar. The latency is genuinely zero.",
  },
  {
    name: "Jordan Park",
    role: "Remote Team Lead",
    quote:
      "Our standup meetings went from painful to actually fun. The hotkey support means I can drop a rimshot without anyone seeing me fumble.",
  },
];

export default function Testimonials() {
  return (
    <section className="py-[120px] px-6">
      <div className="max-w-5xl mx-auto">
        <AnimateIn className="text-center mb-16">
          <h2 className="text-3xl md:text-5xl font-bold tracking-tight">
            Loved by{" "}
            <em className="font-serif font-medium italic text-accent">
              real people
            </em>
          </h2>
        </AnimateIn>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {testimonials.map((t, i) => (
            <AnimateIn key={t.name} delay={i * 0.1}>
              <div className="glass rounded-2xl p-8 h-full">
                <p className="text-foreground/70 leading-relaxed mb-6">
                  &ldquo;{t.quote}&rdquo;
                </p>
                <div>
                  <p className="font-semibold text-sm">{t.name}</p>
                  <p className="text-foreground/40 text-sm">{t.role}</p>
                </div>
              </div>
            </AnimateIn>
          ))}
        </div>
      </div>
    </section>
  );
}
