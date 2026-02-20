export default function Footer() {
  return (
    <footer className="py-12 px-6 border-t border-foreground/5">
      <div className="max-w-5xl mx-auto flex flex-col sm:flex-row items-center justify-between gap-4">
        <div className="flex items-center gap-2">
          <span className="font-semibold">SoundDeck</span>
        </div>
        <div className="flex items-center gap-6 text-sm text-foreground/40">
          <a
            href="mailto:support@sounddeck.app"
            className="hover:text-foreground/60 transition-colors"
          >
            Support
          </a>
          <span>&copy; {new Date().getFullYear()} SoundDeck</span>
        </div>
      </div>
    </footer>
  );
}
