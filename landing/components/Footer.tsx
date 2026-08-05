import Link from "next/link";
import { siteConfig, supportMailtoLink } from "@/lib/site";

export default function Footer() {
  return (
    <footer className="site-footer">
      <div className="footer-grid">
        <div>
          <Link className="brand-lockup" href="/">
            <span className="brand-mark" aria-hidden="true">
              SD
            </span>
            <span>SoundDeck</span>
          </Link>
          <p>
            Native macOS soundboard and virtual microphone for calls, streams,
            podcasts, and workshops.
          </p>
          <a href={supportMailtoLink()}>{siteConfig.supportEmail}</a>
        </div>

        <div>
          <h2>Product</h2>
          <Link href="/download">Download</Link>
          <Link href="/features">Features</Link>
          <Link href="/use-cases">Use Cases</Link>
          <Link href="/compatibility">Compatibility</Link>
          <Link href="/guides">App Guides</Link>
          <Link href="/compare">Compare</Link>
          <Link href="/pricing">Pricing</Link>
          <Link href="/system-requirements">System Requirements</Link>
          <Link href="/docs">Docs</Link>
          <Link href="/docs/getting-started">Getting Started</Link>
          <Link href="/docs/audio-driver">Audio Driver</Link>
          <Link href="/docs/microphone-permission">Microphone Permission</Link>
          <Link href="/docs/virtual-microphone">Virtual Microphone</Link>
          <Link href="/docs/import-sounds">Import Sounds</Link>
          <Link href="/docs/free-plan">Free Plan And Pro</Link>
          <Link href="/docs/folders">Folders</Link>
          <Link href="/docs/pro-library">Pro Library</Link>
          <Link href="/docs/trim-volume">Trim And Volume</Link>
          <Link href="/docs/monitoring-preview">Monitoring And Preview</Link>
          <Link href="/docs/voice-effects">Voice Effects</Link>
          <Link href="/docs/troubleshooting">Troubleshooting</Link>
          <Link href="/docs/uninstall">Uninstall</Link>
          <Link href="/docs/hotkeys">Hotkeys</Link>
          <Link href="/changelog">Changelog</Link>
          <Link href="/security">Security</Link>
        </div>

        <div>
          <h2>Company</h2>
          <Link href="/support">Support</Link>
          <Link href="/contact">Contact</Link>
          <Link href="/press">Press</Link>
          <Link href="/faq">FAQ</Link>
          <Link href="/privacy">Privacy</Link>
          <Link href="/terms">Terms</Link>
        </div>

        <div>
          <h2>Search Assets</h2>
          <Link href="/sitemap.xml">Sitemap</Link>
          <Link href="/robots.txt">Robots</Link>
          <Link href="/llms.txt">llms.txt</Link>
          <Link href="/feed.xml">RSS feed</Link>
          <Link href="/.well-known/security.txt">security.txt</Link>
        </div>
      </div>

      <div className="footer-bottom">
        <span>&copy; {new Date().getFullYear()} SoundDeck.</span>
        <span>Free plan with optional Pro subscription.</span>
        <span>Not affiliated with Zoom, Discord, Google, Microsoft, OBS, or Riverside.</span>
      </div>
    </footer>
  );
}
