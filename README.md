# Disk Inventory X

**Disk Inventory X** is a disk-usage visualizer for macOS. It scans a folder or volume,
builds a model of the file system, and renders it as a **treemap** — a "cushion"
visualization where each file is a rectangle sized by how much disk space it uses — so you
can see at a glance what is filling up your disk and act on it.

It is a native Cocoa (AppKit), document-based macOS application written in Objective-C, and
is free software under the **GNU General Public License v3** (see [`COPYING`](COPYING)).

## Features

- **Treemap view** — squarified cushion rendering of a whole volume or folder, full
  resolution on Retina displays, with Dark Mode support.
- **File kinds statistic** — space grouped by file type, with per-kind colors.
- **File outline & selection list** — drill into the tree and inspect individual items.
- **Act on results** — reveal an item in Finder or move it to the Trash.
- **Incremental refresh** — re-scan just the selection instead of the whole volume.
- **Localized** in English, German, Spanish, and French.

## Platform support

| | |
|--|--|
| macOS | 10.11 (El Capitan) or later |
| Apple Silicon | ⚠️ **Runs under Rosetta 2 only** — the app currently ships as an Intel-only (x86_64) binary. Native arm64 / universal support is in progress: see **[Epic #2](https://github.com/gberhault/Disk-Inventory/issues/2)**. |
| Intel | ✅ Native (x86_64) |

The application's own code is not architecture-restricted; the arm64 blockers are the
prebuilt external frameworks it links (see [Dependencies](#dependencies)).

## Building

Open `Disk Inventory X.xcodeproj` in Xcode and build the **Disk Inventory X** scheme, or:

```bash
xcodebuild -project "Disk Inventory X.xcodeproj" -scheme "Disk Inventory X" -configuration Debug build
```

`BuildRelease.sh` runs a plain Release build. The project is configured for **Hardened
Runtime** and Developer ID signing + notarization.

### Dependencies

The project links four **prebuilt frameworks that are not included in this repository** and
are referenced by paths outside it:

- `TreeMapView.framework` — the treemap renderer (its own Xcode project, external to this repo)
- `OmniAppKit.framework`, `OmniFoundation.framework`, `OmniBase.framework` — the
  [Omni Group](https://github.com/omnigroup/OmniGroup) frameworks (a 2018 prebuilt set)

You must supply these frameworks (matching the search paths in the Xcode project) to build.
Reducing/removing this dependency is tracked under the Apple Silicon epic
([#5](https://github.com/gberhault/Disk-Inventory/issues/5),
[#4](https://github.com/gberhault/Disk-Inventory/issues/4),
[#7](https://github.com/gberhault/Disk-Inventory/issues/7)).

## Project layout

Sources sit mostly at the repository root:

- **Model / scanning** — `FSItem`, `FSItem-Utilities`, `FSItemIndex`, `NSURL-Extensions`,
  `FileSystemDoc` (the `NSDocument`)
- **Views / controllers** — `MainWindowController`, `TreeMapViewController`,
  `FilesOutlineViewController`, `FileKindsTableController`, `SelectionListController`, panels
- **Preferences** — `Preferences`, `PrefsPanelController`, `*PrefPage`
- **Formatters / transformers** — `FileSizeFormatter`, `*Transformer`
- `Foundation Extensions/` — category helpers · `*.lproj/` — localized resources ·
  `documentation/` — project notes · `CocoaTech-Depreciated/` — legacy, not built

See [`CLAUDE.md`](CLAUDE.md) for the full annotated structure and common-task map.

## Contributing / development workflow

This repository follows a spec-driven, test-first workflow documented in
[`CLAUDE.md`](CLAUDE.md):

- Work is tracked as **GitHub Issues** (epics → issues); create the issue before branching.
- Never commit directly to `master`; use `feature/…` / `bugfix/…` / `chore/…` branches and
  open a PR into `master`.
- Every change ships with tests; the project targets **80%+ coverage** (XCTest + `xccov`).
- Version bump (`MARKETING_VERSION`) lands on the branch before the PR; tag `vX.Y.Z` after merge.
- User-facing text must be localized into all supported languages.

## License

Disk Inventory X is licensed under the **GNU General Public License, version 3** — see
[`COPYING`](COPYING). Originally created by **Tjark Derlien**.
