<p align="center">
  <img src="https://img.shields.io/badge/macOS-14%2B-black?style=flat-square&logo=apple" alt="macOS 14+">
  <img src="https://img.shields.io/badge/Swift-5.9-F05138?style=flat-square&logo=swift&logoColor=white" alt="Swift 5.9">
  <img src="https://img.shields.io/badge/License-MIT-blue?style=flat-square" alt="MIT License">
</p>

<h1 align="center">
  <br>
  TextGrab
  <br>
</h1>

<h4 align="center">Ekrandaki her metni aninda yakala. Screen OCR for macOS.</h4>

<p align="center">
  <a href="#demo">Demo</a> &bull;
  <a href="#features">Features</a> &bull;
  <a href="#installation">Installation</a> &bull;
  <a href="#usage">Usage</a> &bull;
  <a href="#building">Building</a> &bull;
  <a href="#license">License</a>
</p>

---

## Demo

https://github.com/user-attachments/assets/textgrab-promo.mp4

> Press **Control + Option + T**, select a region, text is copied to your clipboard. That's it.

## Features

- **Instant OCR** — Select any region on screen, get the text in your clipboard
- **Global Hotkey** — Works from any app with `⌃⌥T` (customizable)
- **Multi-Language** — Turkish, English, German, French recognition
- **Apple Vision** — Uses Apple's native Vision framework for high accuracy
- **Multi-Monitor** — Works across all connected displays
- **Retina Support** — Captures at native resolution for best OCR results
- **Lightweight** — Menu bar app, no dock icon, ~860 lines of Swift
- **Privacy First** — Everything runs locally, no data leaves your Mac

## Installation

### Download

Download the latest release from [Releases](../../releases).

### Build from Source

```bash
git clone https://github.com/abdullahcadirci/TextGrab.git
cd TextGrab
swift build -c release
```

The binary will be at `.build/release/TextGrab`.

## Usage

1. Launch TextGrab — it appears as a **magnifier icon** in the menu bar
2. Press **⌃⌥T** (Control + Option + T) or click the menu bar icon
3. **Drag to select** the region containing text
4. Text is automatically **copied to your clipboard**
5. **Paste anywhere** with ⌘V

### First Launch

macOS will ask for **Screen Recording** permission on first use.
Go to **System Settings > Privacy & Security > Screen Recording** and enable TextGrab.

### Change Shortcut

Click the menu bar icon > **Ayarlar...** to open the settings window.
Click the shortcut field and press your desired key combination.

### Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `⌃⌥T` | Capture text from screen (default, customizable) |
| `Escape` | Cancel selection |
| `⌘Q` | Quit |

## How It Works

```
Hotkey → Screen Overlay → Region Selection → ScreenCaptureKit → Vision OCR → Clipboard
```

1. Global hotkey registered via Carbon API
2. Transparent overlay window covers all screens
3. User drags to select a region
4. ScreenCaptureKit captures the selected area at native resolution
5. Vision framework performs text recognition
6. Recognized text is copied to the system clipboard
7. Toast notification confirms the result

## Tech Stack

| Component | Technology |
|-----------|-----------|
| UI | SwiftUI (MenuBarExtra) |
| Screen Capture | ScreenCaptureKit |
| OCR | Apple Vision (VNRecognizeTextRequest) |
| Global Hotkey | Carbon (RegisterEventHotKey) |
| Preferences | UserDefaults |
| Build | Swift Package Manager |

## Project Structure

```
TextGrab/
├── Package.swift
├── Sources/
│   ├── TextGrabApp.swift          # App entry + menu bar
│   ├── CaptureCoordinator.swift   # Orchestrates capture flow
│   ├── HotkeyManager.swift        # Carbon global hotkey
│   ├── SelectionOverlay.swift     # Region selection UI
│   ├── OCREngine.swift            # Vision framework OCR
│   ├── PreferencesManager.swift   # Shortcut preferences
│   ├── SettingsView.swift         # Settings window
│   └── ToastWindow.swift          # Toast notifications
└── video/                         # Promo video (Remotion)
```

## Building

Requirements:
- macOS 14 (Sonoma) or later
- Xcode Command Line Tools (`xcode-select --install`)

```bash
# Debug build
swift build

# Release build
swift build -c release

# Run directly
swift run TextGrab
```

## License

MIT License. See [LICENSE](LICENSE) for details.

---

<p align="center">
  Built with Swift and Vision framework.<br>
  Made by <a href="https://github.com/abdullahcadirci">Abdullah Cadirci</a>
</p>
