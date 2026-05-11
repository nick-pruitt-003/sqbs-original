# SQBS — Science Quiz Bowl Scoring (Original Source)

This repository contains the original Objective-C source code for **SQBS**, a Mac and iOS quiz bowl tournament scoring application.

## Credits

SQBS was created by **Chris Sewell** and created for Mac and Updated by **Ben Smith and Neil Smith**. All original work is theirs.

This source is archived here with permission from the authors. Use is subject to the same terms they have always applied to SQBS: **Free Software, this software is not for sale or to be expanded upon without crediting the original authors.**

## What's Here

| Directory | Description |
|---|---|
| `SQBS2/` | Main Mac desktop app — tournament management, game entry, HTML report generation |
| `SQBS2 with server/` | Variant of SQBS2 with Bonjour networking active (server code commented out in the main build) |
| `SQBS Scoring/` | iOS companion app — real-time toss-up scoring at the table, syncs back to the Mac over TCP |
| `SQBSScore/` | Standalone Bonjour chat prototype, appears to be a networking testbed |
| `SQBS Common/` | Shared `Constants.h` |
| `SQBS sample files/` | Sample `.qzx` tournament files for testing |
| `SQBS screenshots/` | Screenshots of the original app |
| `Icons/` | App icons |
| `documentation/` | Original documentation |
| `investigations/` | Notes and investigations |

## Architecture Overview

SQBS2 (the Mac app) is an `NSDocument`-based Cocoa application. The document class (`Tournament`) handles all file I/O, standings computation, and HTML report generation. Four tab views handle Tournament Setup, Game Entry, Reports, and Settings.

The file format (`.qzx` on Mac, no extension on Windows) is plain text with `\r\n` line endings. Each game record is exactly 129 lines. Bounce-back data is packed into bonus fields using a 10,000 multiplier for Windows compatibility.

SQBS Scoring (iOS) discovers the Mac app over Bonjour (`_quiz._tcp.`) and exchanges data over a simple TCP length-prefix protocol using `NSKeyedArchiver` payloads.

## Related

**sqbs-plus** — a modernization fork adding multi-phase support, yellowfruit/.yft import, and a SwiftUI interface: https://github.com/nick-pruitt-003/sqbs-plus

## Building

The Mac app requires Xcode on macOS. The original project targets OS X 10.7+ with the 10.8 SDK. The iOS app targets iOS 4.0.

Note: Several model classes used by the iOS app (`GameFileContents`, `GameResult`, `TossupResult`, `PointsResult`, `PublishedTournament`) were stored in a shared directory not included in this archive. The iOS app will not compile as-is without those files being reconstructed.
