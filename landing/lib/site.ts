function normalizeSiteUrl(value: string) {
  const url = new URL(value);
  url.pathname = "";
  url.search = "";
  url.hash = "";
  return url.toString().replace(/\/$/, "");
}

const siteUrl = normalizeSiteUrl(
  process.env.NEXT_PUBLIC_SITE_URL ?? "https://sounddeck.app",
);

export const siteHost = new URL(siteUrl).host;

export const siteConfig = {
  name: "SoundDeck",
  url: siteUrl,
  description:
    "SoundDeck is a native macOS soundboard and virtual microphone for playing sound effects, voice-changed audio, and hotkey-triggered clips into Zoom, Discord, Google Meet, OBS, and any app that accepts a mic input.",
  shortDescription:
    "Native macOS soundboard and virtual microphone for calls, streams, podcasts, and workshops.",
  supportEmail: "support@sounddeck.app",
  downloadUrl: process.env.NEXT_PUBLIC_DOWNLOAD_URL ?? "/download",
  checkoutUrl: process.env.NEXT_PUBLIC_CHECKOUT_URL ?? "/download",
  pressEmail: "press@sounddeck.app",
  appStoreCategory: "MusicApplication",
  priceMonthly: "$4.99",
  priceYearly: "$29.99",
  supportedMacOS: "macOS Ventura 13.0 or later",
  currentVersion: "1.0.0",
  launchDate: "2026-05-06",
};

export function absoluteUrl(path = "/") {
  return new URL(path, `${siteConfig.url}/`).toString();
}

export function mailtoLink(email: string, subject: string, body?: string) {
  const params = new URLSearchParams({ subject });

  if (body) {
    params.set("body", body);
  }

  return `mailto:${email}?${params.toString()}`;
}

const supportEmailBody = [
  "Describe what happened:",
  "",
  "App or workflow (Zoom, Discord, Google Meet, OBS, etc.):",
  "",
  "macOS version:",
  "SoundDeck version:",
  "Driver status:",
  "Microphone permission:",
  "Input device:",
  "Output device:",
].join("\n");

export function supportMailtoLink(subject = "SoundDeck Support Request") {
  return mailtoLink(siteConfig.supportEmail, subject, supportEmailBody);
}

export function privacyMailtoLink() {
  return mailtoLink(
    siteConfig.supportEmail,
    "SoundDeck Privacy Question",
    ["Privacy question:", "", "SoundDeck version:", "macOS version:"].join("\n"),
  );
}

export function termsMailtoLink() {
  return mailtoLink(
    siteConfig.supportEmail,
    "SoundDeck Terms Question",
    ["Terms question:", "", "Purchase or subscription context:", ""].join("\n"),
  );
}

export function securityDisclosureMailtoLink() {
  return mailtoLink(
    siteConfig.supportEmail,
    "SoundDeck Security Report",
    [
      "Summary:",
      "",
      "Reproduction steps:",
      "",
      "Affected component:",
      "macOS version:",
      "SoundDeck version:",
    ].join("\n"),
  );
}

export function pressMailtoLink() {
  return mailtoLink(
    siteConfig.pressEmail,
    "SoundDeck Press Inquiry",
    ["Publication or channel:", "", "Deadline:", "", "Requested assets or questions:"].join(
      "\n",
    ),
  );
}
