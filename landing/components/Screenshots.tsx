"use client";

import Link from "next/link";
import AnimateIn from "./AnimateIn";
import ProductMockup from "./ProductMockup";
import { compatibility, comparisonRows } from "@/lib/content";

export default function Screenshots() {
  return (
    <section id="compatibility" className="section section-ink">
      <div className="section-inner">
        <AnimateIn className="section-heading">
          <p className="eyebrow">Compatibility</p>
          <h2>One virtual mic for the apps you already use.</h2>
          <p>
            Select SoundDeck Virtual Mic once in your call, stream, or recording
            app. Your real mic and triggered sounds travel through the same route.
          </p>
        </AnimateIn>

        <div className="compat-layout">
          <AnimateIn className="compat-visual">
            <ProductMockup compact />
          </AnimateIn>

          <AnimateIn delay={0.12} className="compat-panel">
            <h3>Known target apps</h3>
            <div className="compat-list" aria-label="Compatible app list">
              {compatibility.map((app) => (
                <span key={app}>{app}</span>
              ))}
            </div>
            <div className="routing-card">
              <span>Microphone Input</span>
              <strong>SoundDeck Virtual Mic</strong>
              <p>
                Works with meeting apps, browsers, streaming software, and
                recording tools that expose a microphone selector.
              </p>
            </div>
            <Link className="button button-ghost" href="/compatibility">
              See app setup notes
            </Link>
          </AnimateIn>
        </div>

        <AnimateIn delay={0.16} className="comparison-table-wrap">
          <table className="comparison-table">
            <caption>SoundDeck compared with common soundboard workflows</caption>
            <thead>
              <tr>
                <th>Workflow need</th>
                <th>SoundDeck</th>
                <th>Web soundboards</th>
                <th>Hardware-only setups</th>
              </tr>
            </thead>
            <tbody>
              {comparisonRows.map((row) => (
                <tr key={row[0]}>
                  {row.map((cell) => (
                    <td key={cell}>{cell}</td>
                  ))}
                </tr>
              ))}
            </tbody>
          </table>
          <Link className="button button-ghost" href="/compare">
            Compare workflows
          </Link>
        </AnimateIn>
      </div>
    </section>
  );
}
