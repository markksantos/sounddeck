# SoundDeck Landing Site

Next.js 16 public site for SoundDeck, the native macOS soundboard and virtual microphone.

## Requirements

- Node.js 20.9.0 or newer. This repo has been verified with Node 22.22.2.
- npm 10 or newer.

If your shell defaults to the older `/usr/local/bin/node`, use the Homebrew Node 22 binary:

```bash
PATH=/opt/homebrew/Cellar/node@22/22.22.2_1/bin:$PATH npm run build
```

## Environment

The site works without env vars, but production should set:

```bash
NEXT_PUBLIC_SITE_URL=https://sounddeck.app
NEXT_PUBLIC_DOWNLOAD_URL=https://sounddeck.app/downloads/SoundDeck-1.0.0-1.zip
NEXT_PUBLIC_CHECKOUT_URL=https://apps.apple.com/account/subscriptions
```

`NEXT_PUBLIC_DOWNLOAD_URL` and `NEXT_PUBLIC_CHECKOUT_URL` are used by CTAs, metadata, and SoftwareApplication schema.

## Commands

```bash
npm ci
npm run dev
npm run lint
npm run build
npm run verify
```

## Launch Assets

- `app/robots.ts` emits `robots.txt`.
- `app/sitemap.ts` emits `sitemap.xml`.
- `app/manifest.ts` emits `manifest.webmanifest`.
- `public/llms.txt` gives AI answer engines concise product facts and key pages.
- `next.config.ts` applies launch security headers for CSP, HSTS, referrer policy, clickjacking protection, content sniffing protection, and feature permissions.
- `app/opengraph-image.tsx` generates the Open Graph image.
- `app/page.tsx` includes Organization, WebSite, SoftwareApplication, and FAQPage JSON-LD.

## Public Pages

- `/`
- `/download`
- `/features`
- `/use-cases`
- `/compatibility`
- `/guides`
- `/guides/zoom`
- `/guides/discord`
- `/guides/google-meet`
- `/guides/microsoft-teams`
- `/guides/obs`
- `/guides/riverside`
- `/compare`
- `/pricing`
- `/system-requirements`
- `/docs`
- `/docs/getting-started`
- `/docs/audio-driver`
- `/docs/microphone-permission`
- `/docs/virtual-microphone`
- `/docs/import-sounds`
- `/docs/free-plan`
- `/docs/folders`
- `/docs/pro-library`
- `/docs/trim-volume`
- `/docs/monitoring-preview`
- `/docs/voice-effects`
- `/docs/troubleshooting`
- `/docs/uninstall`
- `/docs/hotkeys`
- `/faq`
- `/support`
- `/contact`
- `/privacy`
- `/terms`
- `/changelog`
- `/security`
- `/press`

## Verification

Use Node 22+:

```bash
npm run verify
```

`npm run verify` runs `npm audit`, lint, production build, starts `next start`,
checks every public route, validates crawl assets, validates homepage metadata
and JSON-LD, and scans for placeholder regressions.
