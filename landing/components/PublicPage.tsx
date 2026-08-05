import SiteHeader from "./SiteHeader";
import Footer from "./Footer";

export default function PublicPage({
  eyebrow,
  title,
  description,
  children,
}: {
  eyebrow: string;
  title: string;
  description: string;
  children: React.ReactNode;
}) {
  return (
    <>
      <SiteHeader />
      <main id="main-content" className="public-page">
        <section className="page-hero">
          <p className="eyebrow">{eyebrow}</p>
          <h1>{title}</h1>
          <p>{description}</p>
        </section>
        <section className="page-content">{children}</section>
      </main>
      <Footer />
    </>
  );
}
