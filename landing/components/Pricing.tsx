"use client";

import AnimateIn from "./AnimateIn";
import { Check } from "@phosphor-icons/react";
import { freePlanFeatures, proPlanFeatures } from "@/lib/content";
import { siteConfig } from "@/lib/site";

export default function Pricing() {
  return (
    <section id="pricing" className="section section-paper">
      <div className="section-inner pricing-inner">
        <AnimateIn className="section-heading">
          <p className="eyebrow">Pricing</p>
          <h2>Start free. Upgrade when SoundDeck becomes part of your show.</h2>
          <p>
            The app includes a free plan for setup and core use. Pro unlocks the
            faster production controls inside the Mac app.
          </p>
        </AnimateIn>

        <div className="pricing-grid">
          <AnimateIn className="pricing-card">
            <p className="price-label">Free</p>
            <div className="price-row">$0</div>
            <p className="price-note">Try the virtual mic and starter library.</p>
            <ul>
              {freePlanFeatures.map((feature) => (
                <li key={feature}>
                  <Check weight="bold" />
                  <span>{feature}</span>
                </li>
              ))}
            </ul>
            <a className="button button-ghost full" href={siteConfig.downloadUrl}>
              Download free
            </a>
          </AnimateIn>

          <AnimateIn delay={0.1} className="pricing-card featured">
            <p className="price-label">SoundDeck Pro</p>
            <div className="price-row">{siteConfig.priceYearly}</div>
            <p className="price-note">
              Annual plan. Monthly option from {siteConfig.priceMonthly}/mo in app.
            </p>
            <ul>
              {proPlanFeatures.map((feature) => (
                <li key={feature}>
                  <Check weight="bold" />
                  <span>{feature}</span>
                </li>
              ))}
            </ul>
            <a className="button button-primary full" href={siteConfig.checkoutUrl}>
              Upgrade to Pro
            </a>
            <a className="button button-ghost full" href="/pricing">
              Compare plans
            </a>
            <p className="refund-note">
              Need help before subscribing? Email support for setup guidance and
              refund handling details.
            </p>
          </AnimateIn>
        </div>
      </div>
    </section>
  );
}
