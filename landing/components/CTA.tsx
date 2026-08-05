import { siteConfig, supportMailtoLink } from "@/lib/site";

export default function CTA({
  title = "Put SoundDeck in your mic menu.",
  body = "Download the Mac app, install the virtual audio driver, and route sound pads into your next call or recording session.",
}: {
  title?: string;
  body?: string;
}) {
  return (
    <section className="cta-band" aria-label="Download SoundDeck">
      <div>
        <p className="eyebrow">Free plan available</p>
        <h2>{title}</h2>
        <p>{body}</p>
      </div>
      <div className="cta-actions">
        <a className="button button-primary" href={siteConfig.downloadUrl}>
          Download SoundDeck
        </a>
        <a className="button button-ghost" href={supportMailtoLink()}>
          Ask support
        </a>
      </div>
    </section>
  );
}
