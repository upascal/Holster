# Holster

A lightweight macOS menu bar app that lets you instantly toggle any application on and off with a single click.

![macOS](https://img.shields.io/badge/macOS-14.0+-blue?logo=apple)
![Swift](https://img.shields.io/badge/Swift-5-orange?logo=swift)
![License](https://img.shields.io/badge/license-MIT-green)

## Quick Download

<p align="center">
  <a href="https://github.com/upascal/Holster/releases/download/v1.0.0/Holster.dmg">
    <img src="Assets/download-button.svg" width="220" alt="Download Holster">
  </a>
</p>




## What It Does

Holster sits quietly in your menu bar displaying the icon of your chosen app. One click shows or hides that app — perfect for apps you frequently toggle like Claude, Spotify, Messages, Slack, or even Adobe tools.

**Think of it as a quick-draw holster for your favorite app.**

## Features

- **One-click toggle** — Left-click to show/hide your holstered app
- **Native app icon** — Menu bar shows the actual icon of your chosen app
- **Lightweight** — Runs as a pure menu bar app (no Dock icon)
- **Simple setup** — Right-click to choose or change your target app
- **Remembers your choice** — Settings persist between launches

## Screenshots

<p align="center" style="margin-bottom: 0px;">
  <img src="Assets/holster-menu-bar.png" alt="Holster menu bar icon" width="400">
</p>

<p align="center" style="margin-top: 0px; margin-bottom: 40px;">
  <em>Holster lives in the menu bar (circled in red)</em>
</p>

<p align="center" style="margin-bottom: 0px;">
  <img src="Assets/settings-empty.png" alt="Holster Settings empty" width="400"/>
</p>

<p align="center" style="margin-top: 0px; margin-bottom: 40px;">
  <em>Settings panel with no app selected</em>
</p>

<p align="center" style="margin-bottom: 0px;">
  <img src="Assets/settings-configured.png" alt="Holster Settings with Claude selected" width="400"/>
</p>

<p align="center" style="margin-top: 0px; margin-bottom: 40px;">
  <em>Settings panel with Claude as the holstered app — menu bar shows the Claude icon</em>
</p>

<p align="center" style="margin-bottom: 0px;">
  <img src="Assets/holster-in-action.gif" alt="Holster in action" width="400"/>
</p>

<p align="center" style="margin-top: 0px; margin-bottom: 40px;">
  <em>Holster in action — one click shows/hides Claude</em>
</p>

## Usage

| Action | Result |
|--------|--------|
| **Left-click** | Toggle the holstered app (show if hidden, hide if visible) |
| **Right-click** | Open menu with options |

### First Launch

1. Click the Holster icon in your menu bar
2. Choose an application from the file picker
3. Done! Now left-click anytime to toggle that app

## Installation Options

### Download

Download the latest `.dmg` from the [Releases](../../releases) page.

### Build from Source

1. Clone the repository
2. Open `Holster.xcodeproj` in Xcode
3. Build and run (⌘R)

## Requirements

- macOS 14.0 (Sonoma) or later

## License

MIT License — see [LICENSE](LICENSE) for details.
