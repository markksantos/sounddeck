import Link from "next/link";
import SiteHeader from "@/components/SiteHeader";
import Footer from "@/components/Footer";

export default function NotFound() {
  return (
    <>
      <SiteHeader />
      <main id="main-content" className="public-page">
        <section className="page-hero">
          <p className="eyebrow">404</p>
          <h1>This SoundDeck page is not here.</h1>
          <p>
            The route may have changed. Start at the homepage, download page, or
            setup guide.
          </p>
          <div className="hero-actions">
            <Link className="button button-primary" href="/">
              Go home
            </Link>
            <Link className="button button-ghost" href="/docs/getting-started">
              Read setup guide
            </Link>
          </div>
        </section>
      </main>
      <Footer />
    </>
  );
}
