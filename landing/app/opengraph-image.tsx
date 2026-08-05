import { ImageResponse } from "next/og";
import { siteConfig } from "@/lib/site";

export const alt = "SoundDeck macOS soundboard and virtual microphone preview";
export const size = {
  width: 1200,
  height: 630,
};
export const contentType = "image/png";

export default function Image() {
  return new ImageResponse(
    (
      <div
        style={{
          width: "100%",
          height: "100%",
          display: "flex",
          background: "#f4f1ea",
          color: "#191714",
          fontFamily: "Arial",
          padding: 64,
        }}
      >
        <div
          style={{
            display: "flex",
            flexDirection: "column",
            justifyContent: "space-between",
            width: "48%",
          }}
        >
          <div style={{ display: "flex", alignItems: "center", gap: 18 }}>
            <div
              style={{
                width: 72,
                height: 72,
                borderRadius: 18,
                background: "#151515",
                color: "#f6f2ea",
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                fontSize: 30,
                fontWeight: 800,
              }}
            >
              SD
            </div>
            <div style={{ fontSize: 34, fontWeight: 800 }}>{siteConfig.name}</div>
          </div>
          <div style={{ display: "flex", flexDirection: "column" }}>
            <div style={{ fontSize: 76, lineHeight: 0.95, fontWeight: 800 }}>
              macOS soundboard + virtual mic
            </div>
            <div style={{ marginTop: 28, fontSize: 28, color: "#5f5a50", lineHeight: 1.25 }}>
              Play SFX and voice-changed audio into Zoom, Discord, OBS, and any app with a mic input.
            </div>
          </div>
          <div style={{ fontSize: 24, color: "#7b5632" }}>
            Free plan available · macOS 13+
          </div>
        </div>

        <div
          style={{
            marginLeft: 56,
            flex: 1,
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
          }}
        >
          <div
            style={{
              width: 470,
              height: 390,
              borderRadius: 34,
              background: "#22201d",
              boxShadow: "0 28px 80px rgba(0,0,0,0.24)",
              padding: 28,
              display: "flex",
              flexDirection: "column",
              gap: 18,
            }}
          >
            <div style={{ display: "flex", gap: 12 }}>
              {["#ee6b5f", "#e6ba4e", "#71bd6a"].map((color) => (
                <div key={color} style={{ width: 14, height: 14, borderRadius: 999, background: color }} />
              ))}
            </div>
            <div style={{ display: "flex", flexWrap: "wrap", gap: 16 }}>
              {["Intro", "Applause", "Rimshot", "Hold", "Laugh", "Cue"].map((pad, index) => (
                <div
                  key={pad}
                  style={{
                    width: 124,
                    height: 92,
                    borderRadius: 18,
                    background: ["#e76545", "#3eb489", "#e3a12d", "#4c97b8", "#7d63c8", "#4a4741"][index],
                    color: "white",
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                    fontSize: 22,
                    fontWeight: 800,
                  }}
                >
                  {pad}
                </div>
              ))}
            </div>
            <div
              style={{
                marginTop: "auto",
                borderRadius: 18,
                background: "#f4f1ea",
                color: "#191714",
                padding: "18px 22px",
                fontSize: 24,
                fontWeight: 800,
              }}
            >
              Mic + SFX → SoundDeck Virtual Mic
            </div>
          </div>
        </div>
      </div>
    ),
    size
  );
}
