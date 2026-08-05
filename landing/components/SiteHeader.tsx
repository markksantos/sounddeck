"use client";

import Link from "next/link";
import { useState } from "react";
import { List, X } from "@phosphor-icons/react";
import { siteConfig } from "@/lib/site";

const navItems = [
  { href: "/features", label: "Features" },
  { href: "/use-cases", label: "Use Cases" },
  { href: "/compatibility", label: "Compatibility" },
  { href: "/compare", label: "Compare" },
  { href: "/pricing", label: "Pricing" },
  { href: "/docs", label: "Docs" },
  { href: "/changelog", label: "Changelog" },
  { href: "/support", label: "Support" },
  { href: "/contact", label: "Contact" },
];

export default function SiteHeader() {
  const [open, setOpen] = useState(false);

  return (
    <header className="site-header" aria-label="Primary navigation">
      <nav className="nav-shell">
        <Link className="brand-lockup" href="/" aria-label="SoundDeck home">
          <span className="brand-mark" aria-hidden="true">
            SD
          </span>
          <span>SoundDeck</span>
        </Link>

        <div className="desktop-nav">
          {navItems.map((item) => (
            <Link key={item.href} href={item.href}>
              {item.label}
            </Link>
          ))}
        </div>

        <div className="nav-actions">
          <a className="button button-ghost compact" href={siteConfig.downloadUrl}>
            Download
          </a>
          <a className="button button-primary compact" href={siteConfig.checkoutUrl}>
            Upgrade
          </a>
          <button
            type="button"
            className="mobile-menu-button"
            aria-label={open ? "Close navigation menu" : "Open navigation menu"}
            aria-expanded={open}
            onClick={() => setOpen((value) => !value)}
          >
            {open ? <X weight="bold" /> : <List weight="bold" />}
          </button>
        </div>
      </nav>

      {open && (
        <div className="mobile-nav">
          {navItems.map((item) => (
            <Link key={item.href} href={item.href} onClick={() => setOpen(false)}>
              {item.label}
            </Link>
          ))}
          <a className="button button-primary" href={siteConfig.downloadUrl} onClick={() => setOpen(false)}>
            Download SoundDeck
          </a>
          <a className="button button-ghost" href={siteConfig.checkoutUrl} onClick={() => setOpen(false)}>
            Upgrade to Pro
          </a>
        </div>
      )}
    </header>
  );
}
