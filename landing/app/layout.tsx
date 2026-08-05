import type { Metadata, Viewport } from "next";
import { DM_Sans, Cormorant_Garamond } from "next/font/google";
import { absoluteUrl, siteConfig } from "@/lib/site";
import "./globals.css";

const dmSans = DM_Sans({
  variable: "--font-dm-sans",
  subsets: ["latin"],
  weight: ["400", "500", "600", "700"],
});

const cormorant = Cormorant_Garamond({
  variable: "--font-cormorant",
  subsets: ["latin"],
  weight: ["400", "500", "600"],
  style: ["normal", "italic"],
});

export const metadata: Metadata = {
  metadataBase: new URL(siteConfig.url),
  applicationName: siteConfig.name,
  manifest: "/manifest.webmanifest",
  title: {
    default: "SoundDeck | macOS Soundboard and Virtual Microphone",
    template: "%s | SoundDeck",
  },
  description: siteConfig.description,
  keywords: [
    "SoundDeck",
    "macOS soundboard",
    "virtual microphone Mac",
    "Discord soundboard Mac",
    "Zoom sound effects",
    "Google Meet soundboard",
    "OBS virtual microphone",
    "voice changer Mac",
    "menu bar soundboard",
    "CoreAudio soundboard",
    "stream deck alternative Mac",
    "podcast soundboard Mac",
  ],
  authors: [{ name: "SoundDeck" }],
  creator: "SoundDeck",
  publisher: "SoundDeck",
  category: "software",
  alternates: {
    canonical: "/",
    types: {
      "application/rss+xml": "/feed.xml",
    },
  },
  icons: {
    icon: "/favicon.ico",
    apple: "/apple-touch-icon.png",
  },
  openGraph: {
    type: "website",
    locale: "en_US",
    url: siteConfig.url,
    siteName: siteConfig.name,
    title: "SoundDeck | macOS Soundboard and Virtual Microphone",
    description: siteConfig.shortDescription,
    images: [
      {
        url: absoluteUrl("/opengraph-image"),
        width: 1200,
        height: 630,
        alt: "SoundDeck macOS soundboard product preview",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "SoundDeck | macOS Soundboard and Virtual Microphone",
    description: siteConfig.shortDescription,
    images: [absoluteUrl("/opengraph-image")],
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      "max-image-preview": "large",
      "max-snippet": -1,
      "max-video-preview": -1,
    },
  },
};

export const viewport: Viewport = {
  themeColor: "#f6f1e8",
  colorScheme: "light",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <head>
        <link
          rel="search"
          type="application/opensearchdescription+xml"
          title={`${siteConfig.name} Support`}
          href="/opensearch.xml"
        />
      </head>
      <body className={`${dmSans.variable} ${cormorant.variable} antialiased`}>
        <a href="#main-content" className="skip-link">
          Skip to content
        </a>
        {children}
      </body>
    </html>
  );
}
