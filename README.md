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
| Chip | **Apple Silicon (arm64) only** |
| macOS | 12.0 (Monterey) or later |
| Intel | ❌ Not supported — Intel/x86_64 is intentionally dropped (Rosetta is being deprecated; Intel Macs are past end-of-life). |

Native arm64 support is in progress under **[Epic #2](https://github.com/gberhault/Disk-Inventory/issues/2)**:
the `TreeMapView` renderer is now vendored in-repo and builds for arm64; the legacy Omni
frameworks are being removed rather than restored (see [Dependencies](#dependencies)).

## Building

Open `Disk Inventory X.xcodeproj` in Xcode and build the **Disk Inventory X** scheme, or:

```bash
xcodebuild -project "Disk Inventory X.xcodeproj" -scheme "Disk Inventory X" -configuration Debug build
```

`BuildRelease.sh` runs a plain Release build. The project is configured for **Hardened
Runtime** and Developer ID signing + notarization.

### Dependencies

Historically the project linked several **prebuilt external frameworks**. These are being
brought in-repo or removed so the project builds self-contained for Apple Silicon:

- `TreeMapView.framework` — the treemap renderer. **Now vendored** in
  [`treemapview-framework/`](treemapview-framework/) and built for arm64
  ([#7](https://github.com/gberhault/Disk-Inventory/issues/7)).
- `OmniAppKit`, `OmniFoundation`, `OmniBase` — the
  [Omni Group](https://github.com/omnigroup/OmniGroup) frameworks (an unmaintained 2018
  Intel-only set). **Being removed** (decoupled to plain AppKit), not restored
  ([#5](https://github.com/gberhault/Disk-Inventory/issues/5),
  [#4](https://github.com/gberhault/Disk-Inventory/issues/4)).

Until the Omni decoupling lands, the app target does not yet compile (its prefix header
imports `<OmniBase/OmniBase.h>`); the vendored `TreeMapView` framework builds on its own.

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
