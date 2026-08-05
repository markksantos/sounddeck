"use client";

import Link from "next/link";
import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { CaretDown } from "@phosphor-icons/react";
import AnimateIn from "./AnimateIn";
import { faqs } from "@/lib/content";

function FAQItem({ q, a, index }: { q: string; a: string; index: number }) {
  const [open, setOpen] = useState(false);
  const panelId = `faq-panel-${index}`;
  const buttonId = `faq-button-${index}`;

  return (
    <div className="faq-item">
      <button
        id={buttonId}
        onClick={() => setOpen(!open)}
        className="faq-trigger"
        aria-expanded={open}
        aria-controls={panelId}
      >
        <span>{q}</span>
        <motion.div
          animate={{ rotate: open ? 180 : 0 }}
          transition={{ duration: 0.2 }}
        >
          <CaretDown weight="bold" />
        </motion.div>
      </button>
      <AnimatePresence>
        {open && (
          <motion.div
            id={panelId}
            role="region"
            aria-labelledby={buttonId}
            initial={{ height: 0, opacity: 0 }}
            animate={{ height: "auto", opacity: 1 }}
            exit={{ height: 0, opacity: 0 }}
            transition={{ duration: 0.25, ease: [0.25, 0.1, 0.25, 1] }}
            className="faq-panel"
          >
            <p>{a}</p>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}

export default function FAQ() {
  return (
    <section id="faq" className="section section-ink">
      <div className="section-inner narrow">
        <AnimateIn className="section-heading">
          <p className="eyebrow">Answers</p>
          <h2>Frequently asked questions</h2>
        </AnimateIn>

        <AnimateIn delay={0.1}>
          <div className="faq-list">
            {faqs.map((faq, index) => (
              <FAQItem key={faq.q} {...faq} index={index} />
            ))}
          </div>
          <div className="section-actions">
            <Link className="button button-ghost" href="/faq">
              Read all FAQs
            </Link>
          </div>
        </AnimateIn>
      </div>
    </section>
  );
}
