export const productFeatures: {
  title: string;
  description: string;
  proof: string;
}[] = [
  {
    title: "Virtual microphone",
    description:
      "SoundDeck creates a system audio input, then mixes your real mic with any sound pad you trigger.",
    proof: "Works anywhere a mic picker exists.",
  },
  {
    title: "Instant sound pads",
    description:
      "Drag in MP3, WAV, M4A, AAC, AIFF, or CAF files and launch them from a compact menu bar grid.",
    proof: "Built for fast calls, streams, and recordings.",
  },
  {
    title: "Voice changer",
    description:
      "Shift pitch in real time for character voices, call energy, and quick production effects.",
    proof: "Pro feature with on/off control.",
  },
  {
    title: "Global hotkeys",
    description:
      "Trigger mute, stop-all, voice changer, and individual Pro sound pads while another app is focused.",
    proof: "No window switching required.",
  },
  {
    title: "Private monitoring",
    description:
      "Preview sounds through headphones before sending them, or monitor the final SFX mix locally.",
    proof: "Separate preview output selection.",
  },
  {
    title: "Trim and polish",
    description:
      "Set trim points, pad colors, icons, and folders so your board stays production-ready.",
    proof: "No external editor needed for quick clips.",
  },
  {
    title: "Local-first audio",
    description:
      "Microphone audio and imported files stay on your Mac. SoundDeck does not record or upload your audio.",
    proof: "Privacy posture is visible before purchase.",
  },
  {
    title: "Driver setup flow",
    description:
      "The app guides you through microphone permission and one-time virtual audio driver installation.",
    proof: "Includes support and uninstall paths.",
  },
];

export const useCases = [
  {
    title: "Remote meetings",
    audience: "Team leads, facilitators, and presenters",
    description:
      "Add a tasteful cue, timer sting, or celebratory sound without sharing a tab or routing desktop audio.",
    workflow:
      "Use SoundDeck Virtual Mic in Zoom, Google Meet, Microsoft Teams, FaceTime, or Slack Huddles so cues and your real voice travel through one microphone input.",
    bestFor: "Agenda transitions, timers, retros, celebrations, and attention resets.",
    setup:
      "Install the driver, choose SoundDeck Virtual Mic in the meeting app, keep your real mic selected inside SoundDeck, and use Stop All before switching calls.",
  },
  {
    title: "Streams and live shows",
    audience: "Streamers, moderators, and live producers",
    description:
      "Keep Discord, OBS, and stream calls fed by the same virtual mic while monitoring sound effects locally.",
    workflow:
      "Route SoundDeck Virtual Mic into OBS or a guest-call app, then trigger sounds from the menu bar or Pro hotkeys while monitoring locally.",
    bestFor: "Scene stingers, guest cues, moderation signals, audience reactions, and live-show pacing.",
    setup:
      "Add SoundDeck Virtual Mic as a Mic/Aux source, enable SFX monitoring if needed, and confirm active pads are stopped before changing scenes.",
  },
  {
    title: "Podcasts and interviews",
    audience: "Hosts, editors, and remote production teams",
    description:
      "Drop intros, transitions, reactions, and hold music into Riverside, Zoom, or browser recording rooms.",
    workflow:
      "Select SoundDeck Virtual Mic in Riverside, Zoom, or a browser studio so intros and transitions are captured in the same track as your mic.",
    bestFor: "Show intros, segment transitions, sponsor cues, remote guest prompts, and post-production markers.",
    setup:
      "Choose the virtual mic before recording, preview clips through headphones, and keep a clean Stop All hotkey ready for retakes.",
  },
  {
    title: "Classes and workshops",
    audience: "Educators, trainers, and community hosts",
    description:
      "Use hotkeys for attention cues, breaks, games, and segment transitions while slides stay in focus.",
    workflow:
      "Keep slides or curriculum apps focused while SoundDeck handles audio cues through the selected meeting microphone.",
    bestFor: "Break timers, quiz cues, classroom games, workshop segments, and facilitation rituals.",
    setup:
      "Prepare a small folder of class cues, select SoundDeck Virtual Mic in the classroom app, and use local preview before sending new sounds.",
  },
];

export const compatibility = [
  "Zoom",
  "Discord",
  "Google Meet",
  "Microsoft Teams",
  "FaceTime",
  "Slack Huddles",
  "OBS",
  "Riverside",
  "Chrome",
  "Safari",
  "Firefox",
  "Any app with a microphone picker",
];

export const compatibilityDetails = [
  {
    name: "Zoom",
    category: "Meetings",
    setup:
      "Open Zoom audio settings and choose SoundDeck Virtual Mic as the microphone. Keep your normal microphone selected inside SoundDeck.",
    note: "Useful for meeting cues, workshops, timed breaks, and lightweight reactions without sharing computer audio.",
  },
  {
    name: "Discord",
    category: "Voice chat",
    setup:
      "Open Voice & Video settings, set Input Device to SoundDeck Virtual Mic, and keep automatic input sensitivity adjusted for your room.",
    note: "Works well for community calls, gaming sessions, moderation cues, and stream guest audio.",
  },
  {
    name: "Google Meet",
    category: "Browser meetings",
    setup:
      "Open Meet settings in Chrome, Safari, or Firefox and choose SoundDeck Virtual Mic as the microphone input.",
    note: "Browser permission prompts may need to be refreshed after changing the microphone source.",
  },
  {
    name: "Microsoft Teams",
    category: "Meetings",
    setup:
      "Open Devices settings and select SoundDeck Virtual Mic under Microphone before joining or from the active meeting menu.",
    note: "Use Stop All before switching meetings so stale sound effects never carry into the next call.",
  },
  {
    name: "FaceTime",
    category: "macOS calls",
    setup:
      "Use the macOS microphone selector or FaceTime video menu to choose SoundDeck Virtual Mic for the call.",
    note: "Best for simple local routing because FaceTime uses the same system audio controls as other Mac apps.",
  },
  {
    name: "Slack Huddles",
    category: "Team calls",
    setup:
      "Open Slack audio preferences and set Microphone to SoundDeck Virtual Mic before starting or joining a huddle.",
    note: "Useful for standups, facilitation, and quick team rituals where screen sharing is overkill.",
  },
  {
    name: "OBS",
    category: "Streaming",
    setup:
      "Add or update a Mic/Auxiliary Audio source and choose SoundDeck Virtual Mic for scene audio.",
    note: "Pairs with SFX monitoring so you can hear cues locally while the stream receives the mixed mic feed.",
  },
  {
    name: "Riverside",
    category: "Recording",
    setup:
      "Open Riverside studio settings and choose SoundDeck Virtual Mic as the microphone before recording.",
    note: "Good for podcast intros, transitions, remote interviews, and producer-driven call segments.",
  },
  {
    name: "Chrome, Safari, and Firefox",
    category: "Browsers",
    setup:
      "Choose SoundDeck Virtual Mic in the site's device picker or browser permission dialog, then reload the page if the site cached another input.",
    note: "Applies to browser-based call tools, webinars, classrooms, and recording rooms.",
  },
  {
    name: "Any app with a microphone picker",
    category: "General routing",
    setup:
      "If an app can choose a microphone input, select SoundDeck Virtual Mic there and manage the real mic inside SoundDeck.",
    note: "SoundDeck routes audio through CoreAudio, so app compatibility depends on microphone input selection rather than app-specific plugins.",
  },
];

export const appGuides = [
  {
    slug: "zoom",
    name: "Zoom",
    category: "Meetings",
    title: "Use SoundDeck with Zoom",
    summary:
      "Route SoundDeck sound pads, voice effects, and your real microphone into Zoom through SoundDeck Virtual Mic.",
    bestFor: "Meeting cues, workshops, webinars, timers, retros, and lightweight reactions.",
    setupSteps: [
      "Install or reinstall the SoundDeck audio driver from SoundDeck Settings.",
      "Grant microphone permission to SoundDeck in macOS System Settings.",
      "Open Zoom audio settings and choose SoundDeck Virtual Mic as the microphone.",
      "Keep your hardware microphone selected inside SoundDeck.",
      "Trigger a short pad, confirm Zoom receives it, then assign a Stop All hotkey before the meeting.",
    ],
    troubleshooting: [
      "If SoundDeck Virtual Mic is missing, quit and reopen Zoom after driver installation.",
      "If Zoom keeps another mic selected, choose SoundDeck Virtual Mic before joining the meeting.",
      "If participants cannot hear sounds, confirm the SoundDeck engine indicator is green and Stop All is not active.",
    ],
  },
  {
    slug: "discord",
    name: "Discord",
    category: "Voice chat",
    title: "Use SoundDeck with Discord",
    summary:
      "Send sound effects and voice-changed audio into Discord voice channels through the normal input device picker.",
    bestFor: "Community calls, gaming sessions, moderation cues, live guests, and stream side channels.",
    setupSteps: [
      "Install the SoundDeck driver and open Discord Voice & Video settings.",
      "Set Input Device to SoundDeck Virtual Mic.",
      "Keep your real microphone selected inside SoundDeck.",
      "Adjust Discord input sensitivity if quiet sounds are being gated.",
      "Use SFX Monitor in SoundDeck if you need to hear cues locally while the channel receives them.",
    ],
    troubleshooting: [
      "If Discord noise suppression cuts sounds, adjust input sensitivity or disable aggressive processing for the test.",
      "If the virtual mic is missing, restart Discord after reinstalling the driver.",
      "If only your voice is heard, confirm Discord is not still using the hardware mic directly.",
    ],
  },
  {
    slug: "google-meet",
    name: "Google Meet",
    category: "Browser meetings",
    title: "Use SoundDeck with Google Meet",
    summary:
      "Select SoundDeck Virtual Mic in Google Meet so browser meetings receive your microphone plus triggered sound pads.",
    bestFor: "Remote meetings, browser-based classrooms, standups, lightweight webinars, and facilitation cues.",
    setupSteps: [
      "Install the SoundDeck driver and grant microphone permission to SoundDeck.",
      "Open Google Meet in Chrome, Safari, or Firefox.",
      "Open Meet audio settings and choose SoundDeck Virtual Mic as the microphone.",
      "Keep your real microphone selected inside SoundDeck.",
      "Reload the Meet tab if the browser cached a previous microphone choice.",
    ],
    troubleshooting: [
      "If the browser permission prompt appears, allow microphone access for the Meet site.",
      "If SoundDeck Virtual Mic does not appear, restart the browser after driver installation.",
      "If Meet switches back to another input, open the meeting device menu and reselect SoundDeck Virtual Mic.",
    ],
  },
  {
    slug: "microsoft-teams",
    name: "Microsoft Teams",
    category: "Meetings",
    title: "Use SoundDeck with Microsoft Teams",
    summary:
      "Route SoundDeck through Teams device settings so your soundboard arrives as the selected microphone input.",
    bestFor: "Team meetings, workshops, training calls, standups, and recurring production cues.",
    setupSteps: [
      "Install the SoundDeck audio driver and confirm SoundDeck Virtual Mic is available on macOS.",
      "Open Teams Devices settings before joining, or open device settings inside the active meeting.",
      "Select SoundDeck Virtual Mic under Microphone.",
      "Keep your hardware microphone selected inside SoundDeck.",
      "Use Stop All before switching meetings so no stale sound carries into the next room.",
    ],
    troubleshooting: [
      "If Teams does not list SoundDeck Virtual Mic, restart Teams after reinstalling the driver.",
      "If sounds are too quiet, test a short pad before the meeting and adjust the pad volume inside SoundDeck.",
      "If Teams changes devices between calls, recheck the active meeting device menu.",
    ],
  },
  {
    slug: "obs",
    name: "OBS",
    category: "Streaming",
    title: "Use SoundDeck with OBS",
    summary:
      "Add SoundDeck Virtual Mic as an OBS microphone source so streams receive voice, sound pads, and voice effects together.",
    bestFor: "Streams, live shows, scene stingers, guest cues, moderation signals, and producer-driven broadcasts.",
    setupSteps: [
      "Install the SoundDeck driver and confirm the SoundDeck engine indicator is green.",
      "Open OBS audio settings or add a Mic/Auxiliary Audio source.",
      "Choose SoundDeck Virtual Mic as the microphone source.",
      "Keep your real microphone selected inside SoundDeck.",
      "Enable SFX Monitor if you need local cue monitoring, then test levels before going live.",
    ],
    troubleshooting: [
      "If OBS captures the wrong mic, update the Mic/Aux source to SoundDeck Virtual Mic.",
      "If sounds appear in monitoring but not stream audio, check the OBS mixer source and scene audio routing.",
      "If a scene change leaves stale audio, use Stop All before switching scenes.",
    ],
  },
  {
    slug: "riverside",
    name: "Riverside",
    category: "Recording",
    title: "Use SoundDeck with Riverside",
    summary:
      "Choose SoundDeck Virtual Mic in Riverside so intros, transitions, and live cues are captured with your microphone.",
    bestFor: "Podcasts, interviews, remote recording rooms, producer cues, sponsor reads, and retake markers.",
    setupSteps: [
      "Install the SoundDeck driver and grant microphone permission to SoundDeck.",
      "Open Riverside studio settings before recording.",
      "Choose SoundDeck Virtual Mic as the microphone.",
      "Keep your hardware microphone selected inside SoundDeck.",
      "Preview clips locally and keep Stop All ready for retakes.",
    ],
    troubleshooting: [
      "If Riverside cached another microphone, reload the studio after selecting SoundDeck Virtual Mic.",
      "If browser permission blocks input, allow microphone access for Riverside.",
      "If the recording room still receives only your voice, confirm Riverside is not using the hardware mic directly.",
    ],
  },
];

export const trustItems = [
  {
    title: "No cloud audio processing",
    description: "Your microphone audio, voice changer output, and imported clips are processed locally.",
  },
  {
    title: "Native macOS audio path",
    description: "Built with CoreAudio and AVFoundation instead of browser tab capture or screen-share workarounds.",
  },
  {
    title: "Clear setup and removal",
    description: "Driver install, reinstall, and uninstall controls are available in onboarding and settings.",
  },
  {
    title: "Free plan, Pro upgrade",
    description: "Try the core app first. Pro unlocks unlimited sounds, voice changer, hotkeys, trimming, and library access.",
  },
];

export const faqs = [
  {
    q: "What is SoundDeck?",
    a: "SoundDeck is a native macOS menu bar app that works as a soundboard and virtual microphone. It lets you play sound effects and voice-changed audio into meeting, streaming, and recording apps.",
  },
  {
    q: "How does the virtual microphone work?",
    a: "SoundDeck installs a lightweight CoreAudio driver that appears as a microphone input. Select the SoundDeck mic in Zoom, Discord, Google Meet, OBS, or another app, and SoundDeck sends your mixed microphone and sound effects to that input.",
  },
  {
    q: "Which apps does SoundDeck work with?",
    a: "SoundDeck works with apps that accept a microphone input, including Zoom, Discord, Google Meet, Microsoft Teams, FaceTime, Slack Huddles, OBS, Riverside, and browser-based call tools.",
  },
  {
    q: "What macOS versions are supported?",
    a: "SoundDeck supports macOS Ventura 13.0 or later on Apple Silicon and Intel Macs.",
  },
  {
    q: "Does SoundDeck upload or record my audio?",
    a: "No. Audio processing happens locally on your Mac. SoundDeck does not record your microphone, upload your voice, or sell audio data.",
  },
  {
    q: "Is there a free plan?",
    a: "Yes. The free plan lets you try SoundDeck with a limited sound library. SoundDeck Pro unlocks unlimited sounds, per-sound hotkeys, voice changer controls, trimming, Pro library access, and removes the free-plan watermark.",
  },
  {
    q: "How do I uninstall the audio driver?",
    a: "Open SoundDeck settings, go to Audio Driver, and choose Uninstall. You can then move SoundDeck.app to Trash.",
  },
  {
    q: "Can I get help if setup does not work?",
    a: "Yes. Email support@sounddeck.app with your macOS version, SoundDeck version, target app, and whether the driver and audio engine show as installed and running.",
  },
];

export const freePlanFeatures = [
  "Starter sound library",
  "8 custom sound slots",
  "Virtual microphone route",
  "Mute and Stop All hotkeys",
  "SFX monitor and preview",
];

export const proPlanFeatures = [
  "Unlimited custom sounds",
  "Per-sound global hotkeys",
  "Voice changer controls",
  "Trim editor and Pro library",
  "No free-plan watermark",
  "Priority setup support",
];

export const pricingFaqs = [
  {
    q: "Can I use SoundDeck for free?",
    a: "Yes. The free plan includes the virtual microphone route, starter library, monitoring, preview, mute, Stop All, and a limited number of custom sound slots.",
  },
  {
    q: "What does SoundDeck Pro unlock?",
    a: "SoundDeck Pro unlocks unlimited custom sounds, per-sound global hotkeys, voice changer controls, trimming, Pro library access, and removes the free-plan watermark.",
  },
  {
    q: "Is the Pro price monthly or yearly?",
    a: "The launch site highlights the annual Pro plan. A monthly option is available in the Mac app before purchase.",
  },
  {
    q: "Can I get help before upgrading?",
    a: "Yes. Email support with your macOS version, target app, and driver status before subscribing if setup is not working.",
  },
];

export const freePlanSteps = [
  {
    title: "Start with the Free plan",
    body: "Use the included starter sounds, basic soundboard controls, virtual microphone route, Preview, SFX Monitor, Mute microphone, and Stop All before subscribing.",
  },
  {
    title: "Test the route before upgrading",
    body: "Install SoundDeck Virtual Mic, grant microphone permission, keep your hardware microphone selected inside SoundDeck, choose SoundDeck Virtual Mic in the target app, and trigger one short pad.",
  },
  {
    title: "Use the 8 custom import slots carefully",
    body: "Free plan custom slots count imported sounds, not the bundled defaults. Remove unused custom sounds or upgrade to SoundDeck Pro when the board needs more clips.",
  },
  {
    title: "Expect the Free watermark",
    body: "The Free plan includes a short periodic watermark beep. SoundDeck Pro removes the watermark from the virtual microphone path.",
  },
  {
    title: "Upgrade when live controls matter",
    body: "SoundDeck Pro unlocks unlimited custom sounds, per-sound hotkeys, voice changer controls, Trim Audio, the Pro Sound Library, and no Free-plan watermark.",
  },
  {
    title: "Restore or manage Pro",
    body: "Use Restore Purchases in the upgrade sheet or Settings if Pro does not appear. When Pro is active, Settings also includes Manage Subscription for Apple subscription management.",
  },
];

export const freePlanChecks = [
  "Settings shows Free Plan when SoundDeck Pro is not active.",
  "Bundled default sounds remain available without consuming custom import slots.",
  "Free custom imports stop at 8 slots.",
  "Mute microphone and Stop All hotkeys are available on Free and Pro.",
  "Voice changer, per-sound hotkeys, Trim Audio, and Pro Library stay locked until SoundDeck Pro is active.",
  "The Free-plan watermark is expected while Pro is inactive and removed when Pro is active.",
  "Restore Purchases is available from the upgrade sheet and Settings.",
  "Manage Subscription opens Apple subscription management when SoundDeck Pro is active.",
  "The virtual microphone route is tested before paying for Pro.",
];

export const freePlanFaqs = [
  {
    q: "Can I use SoundDeck for free?",
    a: "Yes. Free includes starter sounds, the virtual microphone route, monitoring, Preview, Mute microphone, Stop All, and up to 8 custom imported sounds.",
  },
  {
    q: "What counts toward the 8 custom imports?",
    a: "Imported sounds count toward the Free limit. Bundled starter sounds do not count against the 8 custom import slots.",
  },
  {
    q: "What does the Free watermark do?",
    a: "The Free plan plays a short periodic watermark beep. SoundDeck Pro removes that watermark.",
  },
  {
    q: "What unlocks with SoundDeck Pro?",
    a: "Pro unlocks unlimited custom sounds, per-sound global hotkeys, voice changer controls, Trim Audio, the Pro Sound Library, and no Free-plan watermark.",
  },
  {
    q: "How do I restore Pro access?",
    a: "Open Restore Purchases in the upgrade sheet or Settings. If Pro is active, Settings shows SoundDeck Pro Active and includes Manage Subscription.",
  },
];

export const changelog = [
  {
    version: "1.0.0",
    date: "May 6, 2026",
    items: [
      "Native menu bar sound grid with folders and custom imports.",
      "Virtual microphone driver for routing SFX into calls and streams.",
      "Voice changer, monitoring controls, waveform meter, and global hotkeys.",
      "Onboarding, support, privacy, terms, update checks, and Pro upgrade flow.",
    ],
  },
];

export function releaseAnchor(version: string) {
  return `v${version
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-|-$/g, "")}`;
}

export const releaseChecklist = [
  "Download SoundDeck and open the app.",
  "Install the SoundDeck audio driver when prompted.",
  "Grant microphone permission in macOS.",
  "Select SoundDeck Virtual Mic inside your meeting or recording app.",
  "Drag in sounds or use the included defaults.",
  "Use Stop All before switching meetings or scenes.",
];

export const systemRequirements = [
  {
    title: "macOS version",
    requirement: "macOS Ventura 13.0 or later",
    detail:
      "SoundDeck is built for modern macOS audio permissions and CoreAudio driver installation flows.",
  },
  {
    title: "Mac hardware",
    requirement: "Apple Silicon and Intel Macs",
    detail:
      "The app and installer build for Mac hardware directly, without requiring iOS Simulator support.",
  },
  {
    title: "Virtual audio driver",
    requirement: "Administrator approval for the SoundDeck CoreAudio driver",
    detail:
      "SoundDeck Virtual Mic appears as a microphone input after the driver is installed and the target app is restarted.",
  },
  {
    title: "Microphone permission",
    requirement: "macOS microphone access for SoundDeck",
    detail:
      "Permission is required so SoundDeck can pass your real microphone through the virtual mic and apply voice effects locally.",
  },
  {
    title: "Target app support",
    requirement: "Any app that can choose a microphone input",
    detail:
      "Zoom, Discord, Google Meet, Microsoft Teams, FaceTime, Slack Huddles, OBS, Riverside, browsers, and similar tools can use SoundDeck Virtual Mic.",
  },
  {
    title: "Audio imports",
    requirement: "MP3, WAV, M4A, AAC, AIFF, and CAF files",
    detail:
      "Imported clips are copied into SoundDeck storage and can be organized into folders, trimmed, colored, and launched from the sound grid.",
  },
  {
    title: "Local storage",
    requirement: "Local app data for sounds, folders, preferences, and license state",
    detail:
      "SoundDeck does not upload or record microphone audio. Imported clips and app settings stay on the Mac.",
  },
  {
    title: "Network access",
    requirement: "Only for download, update, subscription, support, and optional Pro library requests",
    detail:
      "Core soundboard, virtual mic, monitoring, and voice processing run locally after installation.",
  },
  {
    title: "Plan requirements",
    requirement: "Free plan for core routing; Pro for advanced live controls",
    detail:
      "Pro unlocks unlimited custom sounds, per-sound hotkeys, voice changer controls, trimming, Pro library access, and removes the free-plan watermark.",
  },
];

export const systemReadinessChecks = [
  "Confirm the Mac is running macOS Ventura 13.0 or later.",
  "Install the SoundDeck driver from onboarding or Settings with administrator approval.",
  "Grant SoundDeck microphone permission in macOS System Settings.",
  "Restart the target app after driver installation so SoundDeck Virtual Mic appears.",
  "Select SoundDeck Virtual Mic in the call, stream, recorder, or browser app.",
  "Keep the real hardware microphone selected inside SoundDeck.",
  "Test one short sound pad and Stop All before going live.",
];

export const systemRequirementFaqs = [
  {
    q: "Does SoundDeck work on Intel Macs?",
    a: "Yes. SoundDeck supports Apple Silicon and Intel Macs running macOS Ventura 13.0 or later.",
  },
  {
    q: "Why does SoundDeck need a driver?",
    a: "The driver creates SoundDeck Virtual Mic, a CoreAudio microphone input that meeting, streaming, and recording apps can select.",
  },
  {
    q: "Does SoundDeck need internet access to play sounds?",
    a: "No. Core sound pads, virtual microphone routing, monitoring, and voice processing run locally after installation.",
  },
  {
    q: "Which apps can receive SoundDeck audio?",
    a: "Any app with a microphone picker can receive SoundDeck audio by selecting SoundDeck Virtual Mic.",
  },
];

export const docsSteps = [
  {
    title: "Install",
    body: "Open SoundDeck from the Applications folder, then follow onboarding to install the virtual audio driver. Administrator approval is required because macOS protects system audio plugins.",
  },
  {
    title: "Grant microphone access",
    body: "SoundDeck needs microphone permission to pass your voice through the virtual mic and apply voice effects. You can change this later in System Settings.",
  },
  {
    title: "Choose SoundDeck as your mic",
    body: "Open Zoom, Discord, Google Meet, OBS, or another target app and pick SoundDeck Virtual Mic as the microphone input.",
  },
  {
    title: "Add and trigger sounds",
    body: "Drag audio files onto the grid or use Add Sound. Click a pad to play, long-press to preview locally, or configure Pro hotkeys in settings.",
  },
  {
    title: "Monitor and stop safely",
    body: "Use SFX Monitor to hear what you send locally. Use Stop All from the app, menu, or hotkey to clear active playback.",
  },
];

export const virtualMicrophoneFlow = [
  {
    title: "Install SoundDeck Virtual Mic",
    body: "Install the SoundDeck CoreAudio driver from onboarding or Settings. Restart the target app after installation so the new microphone input appears.",
  },
  {
    title: "Grant microphone permission",
    body: "Allow SoundDeck in macOS System Settings so your real hardware microphone can pass through the virtual mic path.",
  },
  {
    title: "Choose the real mic in SoundDeck",
    body: "Keep your hardware microphone selected inside SoundDeck. This is the input SoundDeck mixes with sound pads and voice effects.",
  },
  {
    title: "Choose SoundDeck Virtual Mic in the target app",
    body: "Open Zoom, Discord, Google Meet, Teams, OBS, Riverside, or another tool and select SoundDeck Virtual Mic as that app's microphone.",
  },
  {
    title: "Test and monitor the route",
    body: "Trigger one short pad, watch the SoundDeck engine indicator, use SFX Monitor if you need local cue monitoring, and keep Stop All ready before going live.",
  },
];

export const virtualMicrophoneChecks = [
  "SoundDeck is open and the audio engine indicator is green.",
  "The target app microphone picker is set to SoundDeck Virtual Mic, not the hardware mic.",
  "The hardware mic is selected inside SoundDeck.",
  "macOS microphone permission is enabled for SoundDeck.",
  "The target app was restarted after driver installation.",
  "Browser-based apps were reloaded after changing microphone devices.",
  "Stop All is available before switching rooms, meetings, scenes, or recordings.",
];

export const virtualMicrophoneFaqs = [
  {
    q: "Why choose the hardware mic inside SoundDeck?",
    a: "SoundDeck needs the hardware microphone as its input so it can mix your voice with sound pads and voice effects before sending the result through SoundDeck Virtual Mic.",
  },
  {
    q: "Why choose SoundDeck Virtual Mic inside Zoom or OBS?",
    a: "The target app only receives the mixed audio path when its microphone input is set to SoundDeck Virtual Mic.",
  },
  {
    q: "What if SoundDeck Virtual Mic is missing?",
    a: "Reinstall the driver from SoundDeck Settings, grant administrator approval, then quit and reopen the target app or reload the browser tab.",
  },
  {
    q: "Can I hear sounds locally without sending them?",
    a: "Yes. Use preview or SFX Monitor depending on whether you want to hear a clip privately or monitor the final sound effect mix.",
  },
];

export const audioDriverSteps = [
  {
    title: "Open Audio Driver settings",
    body: "Open SoundDeck Settings, choose Audio Driver, and confirm whether SoundDeck Virtual Mic is installed.",
  },
  {
    title: "Install SoundDeck Virtual Mic",
    body: "Choose Install and approve the SoundDeck CoreAudio driver with an administrator password when macOS asks.",
  },
  {
    title: "Approve macOS security prompts",
    body: "If macOS asks for system audio plugin approval, follow the prompt in System Settings and allow the SoundDeck driver.",
  },
  {
    title: "Restart target apps",
    body: "Quit and reopen Zoom, Discord, Google Meet, Microsoft Teams, OBS, Riverside, browsers, or any app that needs the new microphone input.",
  },
  {
    title: "Verify SoundDeck Virtual Mic",
    body: "Open the target app microphone picker and choose SoundDeck Virtual Mic, then trigger a short test pad before going live.",
  },
];

export const audioDriverChecks = [
  "SoundDeck Settings shows the audio driver as installed.",
  "macOS administrator approval completed during installation.",
  "Any macOS system audio plugin approval prompt has been allowed.",
  "SoundDeck has microphone permission in Privacy & Security.",
  "Target apps were quit and reopened after the driver install or reinstall.",
  "Browser-based call tabs were reloaded after the driver install or reinstall.",
  "SoundDeck Virtual Mic appears in the target app microphone picker.",
  "A support email includes macOS version, SoundDeck version, driver status, target app, and whether administrator approval appeared.",
];

export const audioDriverFaqs = [
  {
    q: "Why does SoundDeck need an audio driver?",
    a: "SoundDeck Virtual Mic is a CoreAudio driver that lets meeting, streaming, recording, and browser apps receive SoundDeck as a normal microphone input.",
  },
  {
    q: "What if installation needs administrator approval?",
    a: "That is expected. macOS requires administrator approval before installing a system audio driver.",
  },
  {
    q: "Why is SoundDeck Virtual Mic still missing after installation?",
    a: "Target apps often cache microphone devices. Quit and reopen the app, reload browser tabs, and reinstall the driver from SoundDeck Settings if the input is still missing.",
  },
  {
    q: "When should I reinstall the driver?",
    a: "Reinstall from SoundDeck Settings if SoundDeck Virtual Mic disappears, macOS was upgraded, or a target app never sees the input after restarting.",
  },
];

export const importSoundSteps = [
  {
    title: "Prepare supported audio files",
    body: "Use MP3, WAV, M4A, AAC, AIFF, or CAF files. Keep filenames readable because SoundDeck uses them as the initial pad names.",
  },
  {
    title: "Import with Add Sound or drag and drop",
    body: "Choose Add Sound from the sound grid or drag audio files onto SoundDeck. Drop onto an empty folder to import directly there.",
  },
  {
    title: "Organize folders before a live session",
    body: "Move sounds into folders for meetings, streams, podcasts, classes, or workshops so the right pads stay visible under pressure.",
  },
  {
    title: "Duplicate a safe variant",
    body: "Right-click a pad and choose Duplicate Sound before trying a different trim, volume, icon, color, or folder placement. The duplicate copies the audio file and editable settings, but starts without a hotkey assignment.",
  },
  {
    title: "Trim and set pad volume",
    body: "Use trimming and per-sound volume controls to remove silence, balance loud clips, and keep effects comfortable for the audience.",
  },
  {
    title: "Preview, monitor, and test",
    body: "Preview a clip privately, use SFX Monitor when you need local monitoring, then trigger one short test through SoundDeck Virtual Mic.",
  },
];

export const importSoundChecks = [
  "Imported files use MP3, WAV, M4A, AAC, AIFF, or CAF format.",
  "File names are readable before importing.",
  "Free plan custom sound slots are still within the available limit.",
  "Dropped files appeared in the intended folder.",
  "Duplicate Sound creates a separate stored copy before risky edits.",
  "Duplicated sounds stay in the same folder but do not copy hotkey assignments.",
  "Trim start and end points remove unwanted silence.",
  "Per-sound volume is balanced against the hardware microphone.",
  "Preview works locally before sending the clip through SoundDeck Virtual Mic.",
  "Stop All is ready before testing imports in a live call, stream, recording, or workshop.",
];

export const importSoundFaqs = [
  {
    q: "Which audio formats can I import?",
    a: "SoundDeck supports MP3, WAV, M4A, AAC, AIFF, and CAF files for custom sound pads.",
  },
  {
    q: "Can I drag files into SoundDeck?",
    a: "Yes. Drag audio files onto the sound grid or onto an empty folder to import them into that folder.",
  },
  {
    q: "What happens if I hit the Free plan limit?",
    a: "The Free plan keeps custom sound slots limited. Remove unused custom sounds or upgrade to SoundDeck Pro for unlimited custom sounds.",
  },
  {
    q: "Can I duplicate a sound before editing it?",
    a: "Yes. Right-click a pad and choose Duplicate Sound. The duplicate copies the stored audio, folder, trim, volume, icon, and color, but does not copy the hotkey assignment.",
  },
  {
    q: "How do I avoid sending a loud clip into a call?",
    a: "Preview the clip first, trim silence or rough edges, lower the per-sound volume, and keep Stop All available before testing live.",
  },
];

export const proLibrarySteps = [
  {
    title: "Confirm SoundDeck Pro",
    body: "The Pro Sound Library is available only when SoundDeck Pro is active. If the library row shows a lock, compare plans or restore Pro access before browsing.",
  },
  {
    title: "Open Pro Library",
    body: "Use the Pro Library row in the SoundDeck sidebar. The library sheet opens with Trending, Popular, Recent, and Search tabs.",
  },
  {
    title: "Browse or search",
    body: "Start with Trending, Popular, or Recent for quick ideas. Use Search for a specific cue; SoundDeck sends only that library request to the provider.",
  },
  {
    title: "Preview before adding",
    body: "Use the play button to preview a result locally before adding it. Stop preview playback or close the sheet before switching live rooms.",
  },
  {
    title: "Add to Library",
    body: "Choose Add to Library on the result you want. SoundDeck downloads the clip, imports it with the sound title, and stores the imported sound locally on your Mac.",
  },
  {
    title: "Polish and verify",
    body: "After import, organize the pad, trim or balance volume if needed, preview locally, and test one short SoundDeck Virtual Mic trigger before going live.",
  },
];

export const proLibraryChecks = [
  "SoundDeck Pro is active before browsing the Pro Sound Library.",
  "The Pro Library sheet opens from the sidebar without showing a locked state.",
  "Trending, Popular, or Recent loads when network access is available.",
  "Search uses a clear query and returns expected library results.",
  "Preview plays locally before the sound is added to the board.",
  "Add to Library changes to the added state after import completes.",
  "The imported sound appears in the local sound grid with a readable name.",
  "The imported clip is previewed, trimmed or volume-balanced if needed, and tested once through SoundDeck Virtual Mic.",
];

export const proLibraryFaqs = [
  {
    q: "Is the Pro Sound Library included in the free plan?",
    a: "No. The free plan can use the starter library and custom imports within the Free limits. The browsable Pro Sound Library requires SoundDeck Pro.",
  },
  {
    q: "Does the Pro Library upload my microphone audio?",
    a: "No. SoundDeck sends optional library browsing, search, preview, and download requests to the provider. Microphone audio and imported clips stay local.",
  },
  {
    q: "Why are no Pro Library sounds loading?",
    a: "Confirm SoundDeck Pro is active, network access is available, and the selected tab or search query has results. Use Try Again if the provider request failed.",
  },
  {
    q: "Does Pro Library preview send audio into my call?",
    a: "No. Pro Library preview is local preview playback. The target app receives audio only when a sound pad is triggered through SoundDeck Virtual Mic.",
  },
];

export const folderOrganizationSteps = [
  {
    title: "Start with the sidebar",
    body: "Use All to see the full board, then use the folder rows to focus on one group of sounds. Default folders help separate effects, music, voice clips, and custom imports.",
  },
  {
    title: "Create a folder",
    body: "Choose Folder at the bottom of the sidebar, enter a readable name, and create the folder before importing sounds for a meeting, stream, podcast, class, or workshop.",
  },
  {
    title: "Import into the selected folder",
    body: "Select a folder, then use Add Sound or drag audio files onto the grid. New imports are assigned directly to the selected folder.",
  },
  {
    title: "Move existing sounds",
    body: "Right-click a sound pad, choose Move to Folder, then pick a destination folder or All Sounds to remove the folder assignment.",
  },
  {
    title: "Rename or delete folders safely",
    body: "Right-click a folder to rename it or delete it. Deleting a folder moves its sounds back to All Sounds and does not delete the copied audio files.",
  },
  {
    title: "Verify the live board",
    body: "Open the folder you need, search or sort if useful, preview important clips, and keep Stop All ready before the folder is used in a live route.",
  },
];

export const folderOrganizationChecks = [
  "All shows the full soundboard and each folder filters only sounds assigned to it.",
  "Folder names are readable and specific to the workflow.",
  "Add Sound imports into the currently selected folder.",
  "Drag-and-drop imports use the currently selected folder.",
  "Move to Folder can move an existing pad into another folder.",
  "Move to Folder can move an existing pad back to All Sounds.",
  "Deleting a folder moves its sounds back to All Sounds without deleting audio files.",
  "The final live folder has been previewed and tested once through SoundDeck Virtual Mic.",
];

export const folderOrganizationFaqs = [
  {
    q: "Does deleting a folder delete my sounds?",
    a: "No. Deleting a folder removes the folder and moves its sounds back to All Sounds. It does not delete the copied audio files from SoundDeck storage.",
  },
  {
    q: "How do I move an existing sound into a folder?",
    a: "Right-click the sound pad, choose Move to Folder, then choose the destination folder. Choose All Sounds to remove the folder assignment.",
  },
  {
    q: "Can I import directly into a folder?",
    a: "Yes. Select the folder first, then use Add Sound or drag supported audio files onto the grid.",
  },
  {
    q: "Do folders change what the target app hears?",
    a: "No. Folders only organize the sound grid. The target app still receives sounds through SoundDeck Virtual Mic when you trigger a pad.",
  },
];

export const trimVolumeSteps = [
  {
    title: "Open the pad menu",
    body: "Right-click or secondary-click a sound pad. Use Duplicate Sound before risky edits, Volume for level changes, or Trim Audio when SoundDeck Pro is active.",
  },
  {
    title: "Duplicate before risky edits",
    body: "Choose Duplicate Sound when you want a second version with different trim points or volume. The duplicate keeps the same audio, folder, icon, color, volume, and trim settings, but starts without a hotkey.",
  },
  {
    title: "Set per-sound volume",
    body: "Open Sound Volume and move the 0 to 100 percent slider in small steps. Start lower for loud clips and raise only after previewing.",
  },
  {
    title: "Open Trim Audio",
    body: "Trim Audio is a SoundDeck Pro control. Open it from the pad menu to see the waveform, start handle, end handle, Preview, Save, and Cancel.",
  },
  {
    title: "Trim silence and rough edges",
    body: "Drag the start and end handles inward to remove dead air, accidental noise, or tails that should not reach a live call.",
  },
  {
    title: "Preview before saving",
    body: "Use Preview inside the trim editor to hear the selected region locally. Save only after the duration and start/end points feel right.",
  },
  {
    title: "Test through the live route",
    body: "After saving, trigger one short pad through SoundDeck Virtual Mic, check SFX Monitor if needed, and keep Stop All ready.",
  },
];

export const trimVolumeChecks = [
  "Pad volume is balanced against the hardware microphone.",
  "Loud clips are reduced before a live call, stream, recording, or workshop.",
  "Duplicate Sound is used before making a risky alternate version.",
  "The duplicated variant does not reuse the original sound hotkey.",
  "Trim Audio is unlocked only when SoundDeck Pro is active.",
  "Trim start removes silence or accidental noise before the sound begins.",
  "Trim end removes long tails or unwanted endings.",
  "Preview inside the trim editor plays the selected region locally.",
  "Save was used only after the selected region sounded correct.",
  "A short SoundDeck Virtual Mic test confirms the live route receives the adjusted clip.",
];

export const trimVolumeFaqs = [
  {
    q: "Is per-sound volume a Pro feature?",
    a: "No. The pad menu includes Sound Volume for balancing individual clips. SoundDeck Pro is required for Trim Audio.",
  },
  {
    q: "What does Trim Audio change?",
    a: "Trim Audio stores start and end points for the sound so silence, rough starts, or long endings are skipped when the pad plays.",
  },
  {
    q: "Should I duplicate before trimming?",
    a: "Duplicate Sound is useful when you want to keep the original pad unchanged while testing a shorter or quieter variant.",
  },
  {
    q: "Why does my saved trim sound different live?",
    a: "Preview confirms the local clip region, but the target app route still matters. Test one short trigger through SoundDeck Virtual Mic after saving.",
  },
  {
    q: "How should I set volume for very loud clips?",
    a: "Start below full volume, preview locally, compare against your hardware microphone, then test one short trigger before going live.",
  },
];

export const voiceEffectsSteps = [
  {
    title: "Confirm Pro access",
    body: "Voice changer controls are a SoundDeck Pro feature. The free plan can test the virtual mic route before upgrading.",
  },
  {
    title: "Grant microphone permission",
    body: "SoundDeck needs macOS microphone permission so it can receive your hardware microphone before applying voice effects locally.",
  },
  {
    title: "Open Voice Changer",
    body: "Open the Voice Changer control, enable it, and start near Normal before choosing Deep, High, Chipmunk, or a custom pitch.",
  },
  {
    title: "Set pitch carefully",
    body: "Use the -12 to +12 semitone slider in small moves. Extreme pitch changes are best tested privately before a live room hears them.",
  },
  {
    title: "Monitor and test the route",
    body: "Use Voice Monitor through headphones, choose SoundDeck Virtual Mic in the target app, and send one short test phrase before going live.",
  },
  {
    title: "Add a toggle hotkey",
    body: "In Settings, Hotkeys, assign Toggle voice changer so you can turn the effect on or off while the meeting, stream, or recorder stays focused.",
  },
];

export const voiceEffectsChecks = [
  "SoundDeck Pro is active before enabling Voice Changer.",
  "SoundDeck has macOS microphone permission.",
  "Your hardware microphone is selected inside SoundDeck.",
  "SoundDeck Virtual Mic is selected in the target app.",
  "Voice Changer is enabled only when you intend the target app to hear it.",
  "Pitch starts near Normal before trying Deep, High, Chipmunk, or a custom value.",
  "Voice Monitor is tested through headphones to avoid speaker feedback.",
  "Toggle voice changer and Stop All hotkeys are ready before a live session.",
];

export const voiceEffectsFaqs = [
  {
    q: "Are voice effects included in the free plan?",
    a: "No. The free plan can test the soundboard, monitoring, and virtual mic route. Voice changer controls require SoundDeck Pro.",
  },
  {
    q: "Does SoundDeck upload my voice to change it?",
    a: "No. Voice processing runs locally on your Mac before the mixed output is sent through SoundDeck Virtual Mic.",
  },
  {
    q: "Why does the target app still hear my normal voice?",
    a: "Check that Voice Changer is enabled, SoundDeck Pro is active, your hardware microphone is selected inside SoundDeck, and the target app is using SoundDeck Virtual Mic.",
  },
  {
    q: "How do I avoid feedback while monitoring?",
    a: "Use headphones for Voice Monitor, keep speaker output away from the microphone, and turn monitoring off before switching rooms if you do not need it.",
  },
];

export const monitoringPreviewSteps = [
  {
    title: "Choose a monitor output",
    body: "Open Settings and choose Preview / Monitor Output. Headphones are safest because speakers can feed back into the hardware microphone.",
  },
  {
    title: "Preview clips privately",
    body: "Use Preview before sending a pad through SoundDeck Virtual Mic. Private preview helps catch silence, rough trims, and loud clips.",
  },
  {
    title: "Use SFX Monitor intentionally",
    body: "Turn on SFX Monitor when you need to hear the same sound effects locally while the target app receives the mixed virtual microphone feed.",
  },
  {
    title: "Use Voice Monitor with headphones",
    body: "Turn on Voice Monitor only when you need to check your microphone or voice changer output. Keep headphones on to avoid feedback.",
  },
  {
    title: "Confirm the target app route",
    body: "Keep your hardware microphone selected inside SoundDeck and choose SoundDeck Virtual Mic in the meeting, stream, recorder, or browser app.",
  },
  {
    title: "Stop monitoring before switching rooms",
    body: "Use Stop All, turn off monitor modes you no longer need, and recheck output selection before joining another live room.",
  },
];

export const monitoringPreviewChecks = [
  "Preview / Monitor Output is set to headphones or the intended local output device.",
  "Preview plays locally without reaching the target app.",
  "SFX Monitor is on only when you need to hear sent sound effects locally.",
  "Voice Monitor is on only when checking microphone or voice changer output.",
  "Speaker output is not feeding back into the hardware microphone.",
  "SoundDeck Virtual Mic remains selected in the target app.",
  "Stop All is available before changing meetings, scenes, recordings, or browser tabs.",
  "A support email includes output device, monitor toggles, target app, SoundDeck version, and macOS version.",
];

export const monitoringPreviewFaqs = [
  {
    q: "What is the difference between Preview and SFX Monitor?",
    a: "Preview plays a clip locally before you send it. SFX Monitor lets you hear sound effects locally while the target app receives them through SoundDeck Virtual Mic.",
  },
  {
    q: "What does Voice Monitor do?",
    a: "Voice Monitor lets you hear your microphone path locally, including voice changer output when it is active.",
  },
  {
    q: "Why should I use headphones?",
    a: "Headphones reduce the chance that monitored audio comes out of speakers and re-enters the hardware microphone as feedback or echo.",
  },
  {
    q: "Why can I hear audio locally but others cannot?",
    a: "Local monitoring does not prove the target app route. Confirm the target app is using SoundDeck Virtual Mic and send one short test through that app.",
  },
];

export const microphonePermissionSteps = [
  {
    title: "Open macOS System Settings",
    body: "Open System Settings from the Apple menu, then choose Privacy & Security.",
  },
  {
    title: "Choose Microphone",
    body: "Open Microphone and find SoundDeck in the app list. Launch SoundDeck once if it has not appeared yet.",
  },
  {
    title: "Enable SoundDeck",
    body: "Turn on microphone access for SoundDeck so the app can receive your hardware microphone before mixing audio locally.",
  },
  {
    title: "Quit and reopen SoundDeck",
    body: "Restart SoundDeck after changing permission so macOS grants the new access to the audio engine.",
  },
  {
    title: "Recheck the virtual mic route",
    body: "Select the hardware mic inside SoundDeck, choose SoundDeck Virtual Mic in the target app, and trigger a short test pad.",
  },
];

export const microphonePermissionChecks = [
  "SoundDeck appears in System Settings, Privacy & Security, Microphone.",
  "The microphone toggle for SoundDeck is enabled.",
  "SoundDeck was quit and reopened after the permission change.",
  "The hardware microphone is selected inside SoundDeck.",
  "SoundDeck Virtual Mic is selected inside the target app.",
  "Browser-based call tabs were reloaded after permission changed.",
  "The support email includes macOS version, SoundDeck version, target app, selected microphone, and permission status.",
];

export const microphonePermissionFaqs = [
  {
    q: "Why does SoundDeck need microphone permission?",
    a: "SoundDeck needs permission to receive your hardware microphone locally before mixing it with sound pads and voice effects.",
  },
  {
    q: "Why is SoundDeck missing from the Microphone list?",
    a: "macOS usually adds an app after it asks for microphone access. Launch SoundDeck once, open the soundboard, then check the Microphone list again.",
  },
  {
    q: "What if the toggle is enabled but audio still does not pass through?",
    a: "Quit and reopen SoundDeck, confirm the hardware microphone is selected inside SoundDeck, and restart the target app.",
  },
  {
    q: "Can I reset the permission prompt?",
    a: "Advanced users can reset microphone permission for com.sounddeck.app with macOS privacy tools, then reopen SoundDeck to trigger a fresh prompt.",
  },
];

export const uninstallSteps = [
  {
    title: "Remove SoundDeck Virtual Mic first",
    body: "Open SoundDeck Settings, choose Audio Driver, and uninstall the SoundDeck CoreAudio driver with administrator approval before removing the app.",
  },
  {
    title: "Quit SoundDeck completely",
    body: "Quit SoundDeck from the menu bar so no audio engine, preview, SFX monitor, or virtual microphone process is still active.",
  },
  {
    title: "Move SoundDeck.app to Trash",
    body: "Move SoundDeck.app from Applications to Trash after the virtual microphone driver reports uninstalled.",
  },
  {
    title: "Restart target apps",
    body: "Quit and reopen Zoom, Discord, Google Meet, Microsoft Teams, OBS, Riverside, browsers, or any app that still lists SoundDeck Virtual Mic.",
  },
  {
    title: "Verify the microphone picker",
    body: "Open macOS Sound settings and the target app microphone picker to confirm SoundDeck Virtual Mic is no longer available.",
  },
];

export const uninstallVerificationChecks = [
  "SoundDeck Settings showed the audio driver as uninstalled before the app was removed.",
  "SoundDeck is no longer running in the menu bar or Activity Monitor.",
  "SoundDeck.app has been moved out of Applications.",
  "macOS Sound input settings no longer list SoundDeck Virtual Mic.",
  "Target apps were restarted after driver removal.",
  "Browser-based call tabs were reloaded after target apps restarted.",
  "A support email includes macOS version, SoundDeck version, driver status, and any app that still lists SoundDeck Virtual Mic.",
];

export const uninstallFaqs = [
  {
    q: "Should I uninstall the driver or the app first?",
    a: "Uninstall SoundDeck Virtual Mic from SoundDeck Settings first, then quit SoundDeck and remove SoundDeck.app.",
  },
  {
    q: "Why does a target app still show SoundDeck Virtual Mic?",
    a: "Many apps cache microphone devices while they are open. Quit and reopen the app, or reload the browser tab if the call runs in a browser.",
  },
  {
    q: "Do I need to restart my Mac?",
    a: "Usually no. Restarting the target app is normally enough, but a full Mac restart is a useful final check if another app keeps a stale microphone list.",
  },
  {
    q: "Can I reinstall SoundDeck later?",
    a: "Yes. Install SoundDeck again, open Settings, install SoundDeck Virtual Mic, grant administrator approval, and restart the target app.",
  },
];

export const docsGuides = [
  {
    title: "Getting Started",
    href: "/docs/getting-started",
    summary:
      "Install SoundDeck, grant microphone permission, choose SoundDeck Virtual Mic, import sounds, and monitor playback.",
    bestFor: "First setup, clean route checks, and testing the virtual mic path.",
  },
  {
    title: "Free Plan And Pro",
    href: "/docs/free-plan",
    summary:
      "Understand the Free plan, 8 custom import slots, watermark behavior, Pro unlocks, Restore Purchases, and Apple subscription management.",
    bestFor: "Users deciding when to upgrade, restoring Pro access, or checking whether Free plan limits are expected.",
  },
  {
    title: "Microphone Permission",
    href: "/docs/microphone-permission",
    summary:
      "Grant macOS microphone access to SoundDeck, restart the app, recheck the hardware mic route, and recover missing permission prompts.",
    bestFor: "Users blocked by macOS Privacy & Security settings before the virtual microphone route can work.",
  },
  {
    title: "Audio Driver",
    href: "/docs/audio-driver",
    summary:
      "Install, approve, reinstall, and verify the SoundDeck CoreAudio driver so SoundDeck Virtual Mic appears in target apps.",
    bestFor: "Users and IT reviewers who need the exact driver approval path before calls, streams, recordings, or clean-Mac validation.",
  },
  {
    title: "Import Sounds",
    href: "/docs/import-sounds",
    summary:
      "Import MP3, WAV, M4A, AAC, AIFF, or CAF files, organize folders, respect Free limits, trim clips, balance volume, and preview safely.",
    bestFor: "Users preparing a soundboard library before meetings, streams, podcasts, classes, workshops, or live shows.",
  },
  {
    title: "Pro Library",
    href: "/docs/pro-library",
    summary:
      "Use SoundDeck Pro Library tabs, search, local preview, Add to Library imports, optional network requests, and live-route verification.",
    bestFor: "Pro users who want to browse downloadable sounds, preview them privately, and import only the clips that are ready for a board.",
  },
  {
    title: "Folders",
    href: "/docs/folders",
    summary:
      "Create, rename, delete, filter, import into, and move existing sounds between folders without deleting copied audio files.",
    bestFor: "Users who need boards organized by show, meeting, stream scene, class segment, podcast section, or live production workflow.",
  },
  {
    title: "Trim And Volume",
    href: "/docs/trim-volume",
    summary:
      "Adjust per-sound volume, use the Pro trim editor, preview waveform start/end points, and verify clips before a live route.",
    bestFor: "Users polishing imported clips so sounds land cleanly and comfortably in meetings, streams, recordings, and workshops.",
  },
  {
    title: "Voice Effects",
    href: "/docs/voice-effects",
    summary:
      "Use Pro voice changer controls, pitch presets, Voice Monitor, target-app routing, and toggle hotkeys without surprising a live room.",
    bestFor: "Creators, hosts, streamers, and workshop leads who need voice effects through SoundDeck Virtual Mic.",
  },
  {
    title: "Monitoring And Preview",
    href: "/docs/monitoring-preview",
    summary:
      "Choose Preview / Monitor Output, use Preview, SFX Monitor, and Voice Monitor safely, avoid feedback, and verify the target-app route.",
    bestFor: "Users who need to hear cues locally without leaking audio, echo, or feedback into a live room.",
  },
  {
    title: "Virtual Microphone",
    href: "/docs/virtual-microphone",
    summary:
      "Understand the SoundDeck Virtual Mic route: driver, hardware mic, target app picker, monitoring, browser refreshes, and Stop All safety.",
    bestFor: "Users who need a precise audio routing checklist before a call, stream, recording, or workshop.",
  },
  {
    title: "Troubleshooting",
    href: "/docs/troubleshooting",
    summary:
      "Fix driver approval, virtual mic visibility, microphone permission, routing, playback, and uninstall issues.",
    bestFor: "When setup works in SoundDeck but not in a call, stream, browser, or recording app.",
  },
  {
    title: "Uninstall",
    href: "/docs/uninstall",
    summary:
      "Remove SoundDeck Virtual Mic first, quit the app, remove SoundDeck.app, restart target apps, and verify stale microphone pickers.",
    bestFor: "IT cleanup, reinstall prep, privacy review, and support handoff when a target app still lists the virtual mic.",
  },
  {
    title: "Hotkeys",
    href: "/docs/hotkeys",
    summary:
      "Configure Free mute and Stop All shortcuts, Pro voice changer toggling, per-sound hotkeys, and shortcut conflict checks.",
    bestFor: "Live calls, shows, workshops, and production workflows where another app stays focused.",
  },
  {
    title: "System Requirements",
    href: "/system-requirements",
    summary:
      "Check supported macOS versions, Mac hardware, driver approval, microphone permission, imports, network access, and plan requirements.",
    bestFor: "Pre-install checks, IT review, support handoff, and public launch readiness.",
  },
];

export const hotkeyActions = [
  {
    title: "Mute microphone",
    availability: "Free and Pro",
    shortcutName: "globalMute",
    setup: "Open Settings, choose Hotkeys, and record the Mute microphone shortcut.",
    behavior:
      "Toggles SoundDeck microphone mute while a call, stream, recorder, or browser app stays focused.",
  },
  {
    title: "Stop All",
    availability: "Free and Pro",
    shortcutName: "stopAll",
    setup: "Open Settings, choose Hotkeys, and record the Stop all sounds shortcut.",
    behavior:
      "Stops active sound pads, SFX monitor playback, and preview playback before you switch rooms, scenes, or recordings.",
  },
  {
    title: "Toggle voice changer",
    availability: "SoundDeck Pro",
    shortcutName: "toggleVoiceChanger",
    setup: "Upgrade to Pro, open Settings, choose Hotkeys, and record the Toggle voice changer shortcut.",
    behavior:
      "Turns the real-time voice changer on or off without leaving the current app.",
  },
  {
    title: "Per-sound hotkeys",
    availability: "SoundDeck Pro",
    shortcutName: "sound_<UUID>",
    setup: "Upgrade to Pro, add sounds, then assign each sound pad shortcut in Settings under Sound Pads.",
    behavior:
      "Triggers a specific sound pad from anywhere. Pressing the same shortcut again stops that sound.",
  },
];

export const hotkeyConflictChecks = [
  "Use combinations that are not already reserved by macOS, your meeting app, OBS, or a browser extension.",
  "If a shortcut stops working, open SoundDeck Settings and record a new combination.",
  "For Pro sound pads, confirm the shortcut appears on the pad badge and that SoundDeck Pro is active.",
  "Keep a Stop All shortcut available before live calls, recording sessions, and scene changes.",
];

export const supportTopics = [
  {
    title: "Driver install needs approval",
    body: "Open SoundDeck Settings, choose Audio Driver, and install the driver with administrator approval. macOS may require you to confirm the system audio plugin before apps can see it.",
    steps: [
      "Open SoundDeck Settings and choose Audio Driver.",
      "Install or reinstall the SoundDeck audio driver.",
      "Enter administrator approval when macOS asks.",
      "Restart the target app after the driver status shows installed.",
    ],
  },
  {
    title: "Virtual mic not appearing",
    body: "Reinstall the driver from SoundDeck Settings, then restart the target app. Check that the app is choosing SoundDeck Virtual Mic as its microphone input.",
    steps: [
      "Reinstall the driver from SoundDeck Settings.",
      "Quit and reopen Zoom, Discord, Google Meet, OBS, or the target app.",
      "Open the target app microphone picker and choose SoundDeck Virtual Mic.",
      "Reload browser-based call tabs if they cached a previous microphone.",
    ],
  },
  {
    title: "Sounds not reaching a call",
    body: "Confirm the bottom-right engine indicator is green, SFX are not stopped, and the meeting app is using SoundDeck Virtual Mic.",
    steps: [
      "Confirm the SoundDeck audio engine indicator is green.",
      "Choose SoundDeck Virtual Mic as the microphone in the call, stream, or recording app.",
      "Keep your real microphone selected inside SoundDeck.",
      "Trigger a short pad, then use Stop All before changing rooms or scenes.",
    ],
  },
  {
    title: "Trim or volume changes sound wrong",
    body: "Reopen the pad menu, duplicate the pad if you need a safe variant, check Sound Volume, confirm Pro is active for Trim Audio, preview the selected region, then send one short test through SoundDeck Virtual Mic.",
    steps: [
      "Use Duplicate Sound first if you want to preserve the original pad.",
      "Right-click the sound pad and open Sound Volume.",
      "Lower loud clips and compare them against the hardware microphone.",
      "If trimming is needed, confirm SoundDeck Pro is active and open Trim Audio.",
      "Use Preview inside Trim Audio before saving start and end points.",
      "Trigger one short test through SoundDeck Virtual Mic after saving.",
    ],
  },
  {
    title: "Duplicated sound or variant looks wrong",
    body: "Duplicate Sound creates a new stored audio copy in the same folder and keeps trim, volume, icon, and color settings while clearing the hotkey so variants do not share one shortcut.",
    steps: [
      "Right-click the original pad and choose Duplicate Sound.",
      "Check that the new pad appears with Copy in the name.",
      "Confirm it appears in the same folder as the original sound.",
      "Assign a new hotkey only if this variant needs one.",
      "If the Free custom sound limit appears, remove unused custom sounds or upgrade to SoundDeck Pro.",
    ],
  },
  {
    title: "Pro library search or import not working",
    body: "Confirm SoundDeck Pro is active, network access is available, the selected library tab or search query has results, and Add to Library completes before testing the imported pad.",
    steps: [
      "Confirm SoundDeck Pro is active and the Pro Library row is unlocked.",
      "Try Trending, Popular, or Recent before narrowing to Search.",
      "Use a shorter search term if no sounds appear.",
      "Preview a result locally before choosing Add to Library.",
      "After Add to Library completes, find the imported sound in the local grid and test one short SoundDeck Virtual Mic trigger.",
    ],
  },
  {
    title: "Free plan limit or Pro access looks wrong",
    body: "Check whether Settings shows Free Plan or SoundDeck Pro Active, confirm custom imports are within the 8 Free slots, and use Restore Purchases if a subscription should be active.",
    steps: [
      "Open SoundDeck Settings and find the Subscription section.",
      "Confirm it shows Free Plan or SoundDeck Pro Active.",
      "If you are on Free, count only custom imported sounds; bundled defaults do not use the 8 custom slots.",
      "Use Restore Purchases if Pro should already be active.",
      "Use Manage Subscription when Pro is active and you need Apple subscription management.",
    ],
  },
  {
    title: "Folders not showing the right sounds",
    body: "Check whether All or a specific folder is selected, move existing pads with Move to Folder, and remember that deleting a folder returns its sounds to All Sounds without deleting audio.",
    steps: [
      "Select All to confirm the sound still exists in the full board.",
      "Select the intended folder and check its visible count.",
      "Right-click a sound pad and use Move to Folder if it belongs somewhere else.",
      "Choose All Sounds in Move to Folder to remove a folder assignment.",
      "If a folder was deleted, look for its sounds back under All Sounds.",
    ],
  },
  {
    title: "Voice effects not reaching a call",
    body: "Confirm SoundDeck Pro is active, Voice Changer is enabled, your hardware mic is selected inside SoundDeck, and the target app is using SoundDeck Virtual Mic.",
    steps: [
      "Open Voice Changer and confirm the effect is enabled.",
      "Confirm SoundDeck Pro is active if the Voice Changer controls are locked.",
      "Keep your real microphone selected inside SoundDeck.",
      "Choose SoundDeck Virtual Mic as the microphone in the target app.",
      "Use Voice Monitor through headphones and send one short test phrase.",
    ],
  },
  {
    title: "Monitoring or preview not audible",
    body: "Check Preview / Monitor Output, confirm headphones or the intended output device are selected, and verify the monitor mode you expect is enabled.",
    steps: [
      "Open SoundDeck Settings and choose Preview / Monitor Output.",
      "Select headphones or the intended local output device.",
      "Use Preview for a private clip check before sending audio live.",
      "Turn on SFX Monitor only when you need to hear sent sound effects locally.",
      "Turn on Voice Monitor only when checking microphone or voice changer output.",
    ],
  },
  {
    title: "Microphone permission denied",
    body: "Open macOS System Settings, go to Privacy & Security, choose Microphone, and enable SoundDeck.",
    steps: [
      "Open macOS System Settings.",
      "Go to Privacy & Security, then Microphone.",
      "Enable SoundDeck.",
      "Quit and reopen SoundDeck so macOS grants the new permission.",
    ],
  },
  {
    title: "Uninstalling",
    body: "Open Settings, Audio Driver, and choose Uninstall. Then move SoundDeck.app to Trash.",
    steps: [
      "Open SoundDeck Settings and choose Audio Driver.",
      "Choose Uninstall to remove SoundDeck Virtual Mic.",
      "Quit SoundDeck.",
      "Move SoundDeck.app to Trash and restart any app that still lists the old input.",
    ],
  },
];

export const securityPoints = [
  "Audio processing is local to your Mac.",
  "SoundDeck does not include analytics or advertising trackers.",
  "Payment and subscription status are handled through Apple's purchase infrastructure in the app.",
  "The optional Pro Sound Library sends only library search requests to the third-party provider.",
  "The virtual audio driver can be removed from the app settings.",
];

export const pressFacts = [
  "Product: SoundDeck",
  "Category: macOS menu bar soundboard and virtual microphone",
  "Platform: macOS 13+ on Apple Silicon and Intel",
  "Audience: remote teams, streamers, podcasters, educators, and live hosts",
  "Pricing: free plan with optional Pro subscription",
  "Contact: press@sounddeck.app",
];

export const comparisonRows = [
  ["Sound into calls", "Virtual microphone", "Desktop audio workaround", "Requires manual routing"],
  ["Mac menu bar access", "Native", "Often browser-only", "Hardware dependent"],
  ["Private preview", "Built in", "Rare", "Separate setup"],
  ["Voice changer", "Built in with Pro", "Usually separate", "Separate setup"],
  ["Per-sound hotkeys", "Built in with Pro", "Limited", "Hardware dependent"],
];

export const comparisonDetails = [
  {
    option: "SoundDeck",
    summary:
      "Native macOS menu bar soundboard with a virtual microphone, local monitoring, hotkeys, voice effects, trimming, and driver setup controls.",
    bestFor:
      "Users who need sound effects to arrive inside calls, streams, recordings, and workshops through a normal microphone input.",
    tradeoff:
      "Requires a one-time macOS virtual audio driver install and microphone permission.",
  },
  {
    option: "Web soundboards",
    summary:
      "Browser-based pads can play local sounds, but usually rely on tab audio, screen sharing, or manual desktop-audio capture.",
    bestFor:
      "Simple playback for the person at the keyboard when the audience does not need the sound inside a microphone feed.",
    tradeoff:
      "Often browser-only, difficult to route into calls cleanly, and rarely includes private preview or global hotkeys.",
  },
  {
    option: "Hardware-only setups",
    summary:
      "Dedicated buttons are tactile and fast, but still need separate audio routing, mixer setup, or companion software.",
    bestFor:
      "Studios that already have hardware control surfaces and a repeatable routing chain.",
    tradeoff:
      "More hardware, more cabling or software setup, and less portable for a Mac menu bar workflow.",
  },
  {
    option: "Manual routing",
    summary:
      "Aggregate devices, loopback chains, and desktop-audio capture can work, but they are fragile under live call pressure.",
    bestFor:
      "Advanced audio users who want full control and are comfortable debugging macOS audio routes.",
    tradeoff:
      "Harder to explain, harder to reset quickly, and easier to leave stale audio playing between meetings.",
  },
];
