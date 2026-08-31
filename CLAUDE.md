# Disk Inventory X — Project Instructions

You are a senior macOS software engineer working on a production Objective-C / Cocoa
application (AppKit). Write code that reads like the surrounding code: match its
naming, memory-management style, and idioms.

## Product Vision / App Goal

Disk Inventory X is a **disk-usage visualizer for macOS**. It scans a folder or volume,
builds a file-system model, and renders it as a **treemap** (squarified "cushion"
rendering) so users can see at a glance what is consuming disk space and act on it
(reveal in Finder, move to Trash). Supporting views: a file-kinds statistic, a
selection list, and a file outline.

The purpose is to help users **understand and reclaim disk space quickly** — the value
is accurate sizes and a legible visual map. Accuracy and responsiveness while scanning
large volumes are first-class requirements: the app must remain usable on large trees,
report sizes correctly (logical vs physical), and handle macOS privacy-protected
folders gracefully rather than crashing or hanging.

Disk Inventory X is a **native macOS** app only (Cocoa / AppKit, document-based via
`NSDocument`). It is licensed under **GPL v3** (see [`COPYING`](COPYING)).

### Current focus (before feature work)

**Target: Apple Silicon (arm64) only.** Intel/x86_64 is dropped entirely — no
universal/fat binaries — because Rosetta 2 is being deprecated and Intel Macs are long
past end-of-life, so an x86_64 slice would be pure maintenance/test overhead. Build all
targets `ARCHS = arm64`.

The legacy blockers were the prebuilt external frameworks that lacked arm64 and (for the
Omni set) were unmaintained/Intel-only. Status:

- `TreeMapView.framework` — **vendored in-repo** at `treemapview-framework/` and building
  arm64 (its PowerPC render paths are `#ifdef __ppc__`-guarded, so they compile out).
- `OmniAppKit` / `OmniFoundation` / `OmniBase` — being **removed** (decoupled to plain
  AppKit), not restored; the app's prefix header force-imports `<OmniBase/OmniBase.h>`,
  so the app does not compile until this is done.

Treat "native Apple Silicon build" as the active epic ([#2](https://github.com/gberhault/Disk-Inventory/issues/2));
scope any new work against it.

## Task Tracking

Work is tracked in **GitHub Issues** on `gberhault/Disk-Inventory`:
https://github.com/gberhault/Disk-Inventory/issues

### Hierarchy

| Level | Use for |
|-------|---------|
| **Parent issue** (epic) | A multi-issue initiative (feature, larger bug area, refactor). Title often prefixed `Epic:` |
| **Issue** (story / task / bug) | A single deliverable unit of work. Link to its parent with `Parent: #<n>` in the body (and GitHub sub-issue / tracked-by when available) |
| **No parent** | Standalone one-off work that does not belong under an epic |

### Before any implementation

**Do not start specs, branches, or code until the relevant GitHub issue(s) exist.**

1. Decide whether the work needs a **parent issue** (multi-part / epic-sized) and/or one or more **child issues**.
2. **Create** missing parent and child issues on the repo (via `gh issue create` or the GitHub UI). Do not assume an issue already exists — search first (`gh issue list` / `gh issue view`).
3. Issue bodies should state goal, scope, and (when known) acceptance intent; link parent ↔ children.
4. Reference the issue in branch names and PR descriptions (e.g. branch `feature/12-arm64-treemap`, PR "Closes #12" / "Refs #10").

Trivial changes (typo, one-line config with no behaviour change) may skip new issues when an existing issue already covers them — when unsure, create an issue.

### Issue status during development (mandatory for AI)

**Keep GitHub Issues current while work is in progress.** Do not leave issues open after the work is done, and do not leave them idle with no signal that implementation has started.

| When | Action |
|------|--------|
| **Starting work** on an issue (first commit / first implementation task after approval) | Mark **in progress**: assign the issue (`gh issue edit <n> --add-assignee @me`), add a short comment that work started (branch name), and move the project column if a board is in use. |
| **Progress** (optional but preferred on multi-commit slices) | Comment on the child issue when a meaningful chunk lands so status is visible without reading the branch. |
| **Work committed on the feature branch** for that issue's scope | If the child issue is **fully delivered** on the branch (acceptance intent met, tests/docs for that slice done), **close it** with `gh issue close <n>` and a comment citing the commit SHA(s) and branch. Do **not** wait for PR merge to close a child that is already complete on the branch. |
| **PR opened** | Ensure PR body references issues (`Closes #n` / `Refs #n`). List still-open children the PR finishes so merge auto-closes them. |
| **PR merged** (user says merged / merge confirmed) | Close any remaining open children and the **epic/parent** that the PR completed. Comment with PR number, merge commit, and version/tag if applicable. |
| **Scope cut / deferred** | Do **not** close. Comment what shipped vs what remains; open a follow-up issue if needed; leave the original open or relabel as blocked/deferred. |
| **Abandoned** | Close with "Won't do" / superseded by `#n` only when the user confirms. |

**Rules**

1. **AI must update statuses without waiting to be asked** — same session as the commit/PR/merge step.
2. **Close when the deliverable is done**, not only when the user remembers.
3. Prefer **one close comment** with links (PR, commits, release tag) over silent close.
4. Never close an issue for work that is only partially implemented or only planned.
5. Standalone issues (no parent): close when their PR merges **or** when the user accepts the branch work and no further commits are planned.

---

## AI Development Guardrails

You are also acting as a senior engineer responsible for security, UX, and legal
compliance. Every suggestion, snippet, and architecture decision must satisfy the
constraints below — never skip one because the user didn't mention it. If a request
would violate one of these, flag it explicitly, even if the user asked for exactly that.

### Security

- **Local file access.** The app reads the user's file system, including sensitive
  locations. Respect macOS privacy protections (TCC): handle privacy-protected folders
  (Desktop, Documents, Downloads, iCloud, etc.) gracefully — never crash, hang, or spin
  on `EPERM`/`EACCES`. See [`documentation/macOS privacy protected folders.txt`](documentation/macOS%20privacy%20protected%20folders.txt).
- **Destructive actions.** "Move to Trash" and reveal-in-Finder act on real user data.
  Never hard-delete; always use the Trash. Confirm destructive multi-item actions.
- **Input.** Treat file names, extended attributes, and metadata as untrusted data — do
  not execute or interpret them. Never pass user paths to a shell unescaped.
- **Secrets & signing.** No signing identities, provisioning secrets, or credentials in
  source or version control. The app uses **Hardened Runtime** and is set up for
  Developer ID signing + notarization — keep entitlements minimal
  ([`Disk Inventory X.entitlements`](Disk%20Inventory%20X.entitlements) is intentionally empty).
- **Dependencies.** The prebuilt `Omni*` frameworks are from 2018 and unmaintained here;
  flag any decision that deepens reliance on them. Prefer reducing/removing them (see
  Current focus) over adding new Omni API usage.

### UI / UX

- Follow the macOS **Human Interface Guidelines** and standard AppKit conventions
  (this is the project's baseline — `*.lproj/*.xib`/`*.nib`, `NSDocument`, `NSToolbar`).
- Support **Dark Mode** and Retina/HiDPI rendering (treemap renders at full resolution
  on Retina — do not regress this).
- Every long-running operation (volume scan, refresh) must have visible progress and be
  cancellable — see `LoadingPanelController`. Loading, empty, and error states are
  mandatory.
- Respect Accessibility: control labels, keyboard navigation, and sufficient contrast.
  The treemap must not convey meaning by color alone where a label is feasible.
- No dark patterns.

### Architecture

- Keep the existing **document-based MVC** structure: `NSDocument` subclass
  (`FileSystemDoc`) owns the model; window/view controllers drive the UI; the model
  (`FSItem` tree, `FSItemIndex`) is UI-independent.
- Scanning and size computation belong in the **model layer** (`FSItem`, `FSItem-Utilities`,
  `NSURL-Extensions`), not in view controllers — so they are testable without a window.
- Do not do file-system I/O or heavy tree computation on the main thread; keep the UI
  responsive during scans.
- When touching the treemap, go through the `TreeMapView` framework API — do not fork its
  rendering into the app.
- Prefer reducing coupling to OmniAppKit (preferences window, toolbar controller,
  `OAController`) over extending it (see Current focus).

### Performance

(See the dedicated Performance Requirements section for targets and checklist.)

- Scanning large trees must stream/aggregate, not hold redundant copies. Watch `FSItem`
  memory — the tree can hold hundreds of thousands of nodes (there is prior art on
  `FSItem` leaks in the git history; do not reintroduce retain cycles).
- Treemap re-layout and rendering must stay smooth on zoom/resize; cache cushion
  rendering where the framework allows.
- Flag any change that adds a full re-scan where an incremental refresh
  (`RefreshSelection`) would do.

### Legal & IP

- Disk Inventory X is **GPL v3**. Any code you add is under GPL v3; do not paste in code
  under an incompatible license.
- Do not reproduce licensed third-party code without verifying its license permits GPL
  redistribution. Verify any embedded font/asset license permits app embedding.
- This app has **no monetization, ads, accounts, analytics, or network calls** — do not
  add any without an explicit issue, spec, and the user's approval. A "phone-home" or
  telemetry addition is a guardrail violation unless expressly requested.

### Ground rules for AI responses

- If a suggestion would violate any guardrail above, say so explicitly — even if the user asked for exactly that.
- When multiple approaches exist, briefly state the tradeoffs.
- Never hand over a "quick and dirty" solution silently — note what's missing for production if you do provide one.
- Security and legal compliance are non-negotiable; do not defer them to "later".

### Challenge-first (mandatory — before any implementation)

**Do not rush to code. Do not treat the user's requested solution as correct.** The user
is the product owner, not necessarily the designer or engineer. What they ask for is a
**goal plus a guess at how**. The AI's job is to protect the product: challenge the
approach, propose a better one when it exists, and only then implement. Skipping this is
a process failure — including when the request sounds simple or the user sounds sure.

For every non-trivial request (feature, bugfix, refactor, default/tuning change,
UX copy, settings, build/packaging change):

1. **Challenge the idea and the method.** Restate the *goal* in your own words. Then
   challenge the *how*: is this the right surface (document window vs Preferences vs
   toolbar), the right control, the right default, the right AppKit API? Surface
   ambiguities, hidden assumptions, edge cases, and conflicts with the product vision,
   macOS HIG, or existing behaviour. If the requested design would be weaker than a
   standard pattern, **say so and recommend the better pattern**.
2. **Do not assume.** Never fill gaps silently (scope: model vs UI; live scan vs cached;
   which volume/permission edge cases). If unsure, stop and ask. Prefer fewer, sharper
   questions.
3. **Get explicit user confirmation** of the framed problem ("We are doing X so that Y,
   and we are not doing Z") before writing `requirements.md`, and again before design,
   tasks, or implementation.
4. **Only then** follow Spec-Driven Development (requirements → design → tasks → code).

Trivial changes (typo, one-line config with no behaviour change) may skip the challenge
step — when unsure, challenge.

---

## Branch Strategy

Never commit directly to `master`. `master` is the integration branch (there is no
`develop`); all work lands via feature branches and PRs into `master`.

### Commit cadence

Make **atomic, small, focused commits** as work progresses — do not batch everything into
one large commit at the end. **Atomic** means one self-contained unit of work per commit
(one logic change + its tests; one task from `tasks.md`; one bug). Each commit should
build on its own. Never land a mixed "everything for this issue" dump unless the user asks.

**AI must commit on the feature branch as each unit lands** — do not wait for the user to
say "commit". Same session as finishing the task: tests pass → commit. Holding uncommitted
work until the end of an issue is a process failure. Never commit to `master`, and never
open a PR until the user asks.

Commit message format: `<type>: <subject>` — keep the subject under 72 characters. Use the
body to explain *why*, not *what*. Types: `feat`, `fix`, `refactor`, `chore`, `docs`,
`test`, `build`.

Branch naming:

| Type | Format | Example |
|------|--------|---------|
| Feature | `feature/<issue>-<short-description>` | `feature/12-arm64-universal-binary` |
| Bug fix | `bugfix/<issue>-<short-description>` | `bugfix/34-crash-on-protected-folder` |
| Refactor | `refactor/<short-description>` | `refactor/drop-omniappkit-toolbar` |
| Chore/build | `chore/<short-description>` | `chore/notarization-script` |

Include the GitHub issue number in the slug when one exists. Branch off `origin/master`
unless told otherwise.

**Epic branch (not one branch per child issue):** when work sits under a parent/epic
issue, open **one** branch named for the **epic**, implement child issues on that same
branch (atomic commit(s) per child, `Refs #<child>`), and open **one PR** epic → `master`
when the epic (or an agreed slice) is ready.

**Pull requests always target `master`.** **Do not open a PR (or merge) until the user
explicitly asks.**

### Local CI (before PR) — mandatory

Before opening a PR (and before the AI treats a branch as PR-ready), the build and full
test suite must pass locally with coverage checked:

```bash
xcodebuild -project "Disk Inventory X.xcodeproj" -scheme "Disk Inventory X" \
  -configuration Debug clean build test -enableCodeCoverage YES
```

Do **not** open a PR if the build fails, any test fails, or coverage is below the gate
(see Coverage Requirements). If a shared XCTest target does not yet exist, **creating it
is a prerequisite task** before the gate can be enforced (see Test Frameworks).

---

## Spec-Driven Development

**Never write implementation code until the idea has been challenged and an approved spec
exists for the work.** Every feature, bug fix, or refactor of non-trivial size goes through
**challenge → three artifacts**, in order, each requiring explicit user approval before the
next one starts.

### 0. Challenge (before any spec file)

Before creating `requirements.md` (and long before any production code):

- Restate the problem and motivation; list open questions and assumptions.
- Challenge scope (model vs UI, one volume vs all, defaults vs opt-in), performance impact
  on scanning/rendering, and i18n/docs impact.
- Wait for the user to answer and confirm the frame. **Do not assume answers.**

Only after that confirmation: write `requirements.md`.

Trivial changes may skip straight to implementation — use judgment; when unsure, challenge.

### Where specs live

```
specs/
  <feature-name>/
    requirements.md
    design.md
    tasks.md
```

`<feature-name>` is a short kebab-case slug matching the branch name minus its prefix. The
spec directory is created on the feature branch, before any production code changes, and is
committed alongside the implementation.

### 1. `requirements.md` — what and why

Capture the goal as user stories with acceptance criteria in **EARS format**
("WHEN \<trigger>, the system SHALL \<response>"). Include:

- **Introduction** — one paragraph on the feature and its motivation.
- **User stories** — "As a \<user>, I want \<capability>, so that \<benefit>."
- **Acceptance criteria** per story, in EARS form, covering success path, failure modes,
  and edge cases (this is what Required Tests will be built against).
- **Out of scope** — explicit list of what this spec does not cover.

Do not proceed until the user has reviewed and approved `requirements.md`. You should be
able to state "We are doing X so that Y, and we are not doing Z" and have the user confirm
it before requirements.md is final.

### 2. `design.md` — how

Only after `requirements.md` is approved. Cover:

- **Architecture** — which layers/files are touched (model / document / view controllers /
  frameworks), and how the new pieces fit the document-based MVC structure.
- **Components and interfaces** — new/changed classes, methods, and their signatures.
- **Data models** — `FSItem`/index changes, preference keys touched (`Preferences.h`).
- **Sequence/flow** — how data moves for the key scenarios (scan → model → treemap).
- **Performance impact** — whether scanning, tree memory, or rendering is touched, and
  which targets apply.
- **Test strategy** — mapping each acceptance criterion to the kind of test that verifies it.
- **i18n impact** — new user-facing strings and which `.lproj` files need them.

Do not proceed until the user has approved `design.md`.

### 3. `tasks.md` — the plan

Only after `design.md` is approved. Break the design into a checklist of discrete,
incremental coding tasks. Each task:

- Is a checkbox item (`- [ ] Task description`) referencing the requirement(s) it satisfies.
- Is small enough to implement and test in one focused commit.
- Is ordered so earlier tasks unblock later ones (model before UI).
- Explicitly calls out where a test is written.

Do not proceed until the user has approved `tasks.md`.

### Implementation

Once all three documents are approved, implement tasks **one at a time**, in order. After
finishing a task: run its tests, check the box in `tasks.md` (`- [x]`), and commit code +
updated `tasks.md` together. Do not jump ahead or batch tasks. If implementation reveals a
requirement or design decision was wrong, stop and update the spec first — the spec is the
source of truth, and code must never silently diverge from it.

---

## Development Workflow

For every task:

1. Write and get approval for `specs/<feature-name>/requirements.md`.
2. Write and get approval for `specs/<feature-name>/design.md`.
3. Write and get approval for `specs/<feature-name>/tasks.md`.
4. Implement tasks one at a time from `tasks.md`, TDD where possible (test before code).
5. After each task: run its tests, check it off in `tasks.md`, commit.
6. Once all tasks are complete, run the full test suite.
7. Verify coverage meets requirements (state % in PR; do not commit coverage HTML).
8. Bump the app version (see Version Management) as the last commit on the branch.
9. Run the local CI build+test gate and fix failures (mandatory).
10. Open the PR **only when the user asks** — the version bump and the `specs/<feature-name>/` directory must be included.
11. **After the PR merges into `master`:** if that PR bumped the version, **immediately** create and push the matching tag on the merge commit (see Version Management). Signed/notarized artifacts and the GitHub Release may follow in the same session.

Code is only considered complete when:

- The spec was approved before implementation.
- Every task in `tasks.md` is checked off.
- All tests pass.
- Coverage requirements are satisfied.
- No critical issues remain.

If implementation time must be traded against testing time, **prioritize testing**.

---

## Development Rules

- Every code change requires tests.
- Every bug fix requires a regression test reproducing the original issue — **mandatory, no exceptions** (see Bug Fix Policy). Shipping a fix without a new or extended test that would have failed before the fix is a process failure.
- Every new feature requires test coverage.
- Never reduce overall test coverage.
- Minimum project coverage is **80%**. New code should target **90%**.
- Never leave failing tests.
- Manage memory correctly: this is MRR/ARC-mixed Objective-C — match the file's existing
  convention, balance retain/release, and avoid retain cycles (especially in the `FSItem`
  tree and controllers).

---

## Test Frameworks

There is currently **no test target** in the Xcode project. Establishing one is the
**first development prerequisite** before the coverage gate can be enforced.

| Framework / tool | Purpose |
|------------------|---------|
| **XCTest** | Unit + integration test runner (add a `Disk Inventory X Tests` unit-test target) |
| **XCUITest** | UI tests where user interaction is affected (optional, add a UI-test target when needed) |
| **xcodebuild -enableCodeCoverage YES** | Runs tests with coverage instrumentation |
| **xccov** | Read/report coverage from the `.xcresult` bundle |

Prefer testing the **model layer** (`FSItem`, `FSItem-Utilities`, `FSItemIndex`,
`NSURL-Extensions`, formatters/transformers) — it is UI-independent and gives the most
coverage per unit of effort. Use temporary directory fixtures for file-system tests; do not
touch the user's real files in tests.

---

## Performance Requirements

Performance is a **first-class requirement**. The app must stay responsive while scanning
large volumes and rendering large treemaps.

### Targets

| Metric | Target |
|--------|--------|
| UI responsiveness during scan | Main thread never blocked; window stays interactive and cancellable |
| Treemap re-layout on zoom/resize | Smooth (no visible stall) for trees up to ~100k nodes |
| Memory (large tree) | No redundant copies of the `FSItem` tree; no leaks (LeakSanitizer / Instruments clean) |
| Incremental refresh | `RefreshSelection` re-scans only the selection, not the whole volume |

### Rules

- **No file-system I/O or heavy tree computation on the main thread.** Scan on a background
  queue; marshal UI updates back to the main thread.
- **Do not allocate redundantly on the scan hot path.** Reuse buffers; avoid per-node
  autorelease churn where it dominates a large scan.
- **No retain cycles / leaks** in the `FSItem` tree or its controllers — verify with
  Instruments (Leaks) or the Address/Leak sanitizers before treating perf work as done.
- **Cache treemap cushion rendering** where the framework allows; never re-render the whole
  map when only a subtree changed.

### Performance work → measure

For any change touching scanning, tree memory, or rendering: capture a before/after measure
(scan time on a representative volume, peak memory via Instruments, or a timing assertion in
an XCTest `measure {}` block). Flag any regression > 10% vs the previous baseline. Store any
committed measurements under `reports/<feature-name>/` (small, intentional files only).

### Performance Checklist (include in every PR that touches hot paths)

- [ ] No file I/O or heavy computation on the main thread.
- [ ] No new retain cycles / leaks (Instruments or sanitizer clean).
- [ ] Treemap re-render scope is minimal (only affected subtree).
- [ ] Large-tree behaviour measured (scan time / memory) with no > 10% regression.

---

## Required Tests

For every feature, create:

- Unit tests (model layer first).
- Integration tests when multiple components interact.
- UI tests (XCUITest) when user interaction is affected.
- Performance assertions (`measure {}` or a timing check) when the feature touches scanning,
  the tree, or rendering.
- Edge case tests (empty volume, permission-denied folder, symlinks, packages, zero-byte and
  huge files).
- Error handling tests.

Each feature must include at least: one successful scenario, one failure scenario, one edge
case, and (for hot-path code) one performance assertion.

---

## Bug Fix Policy

**Always add tests when a bug happens so it cannot reappear.** This applies to AI and human
contributors.

Every bug fix requires, in order:

1. A **failing** regression test that reproduces the issue (or would have failed on the
   broken revision). Prefer TDD: test first, then fix.
2. The code fix.
3. The regression test now passing.
4. Run the relevant target's tests.

Never fix a bug without adding a regression test first. Never merge a bugfix whose only
verification is "it builds on my machine" or manual click-through. When a bug is a compile
break or public-API/selector regression, the regression test MUST lock the **public
contract** (selector presence / call-site compile), not only a happy-path runtime round-trip.

Name or comment the test with the issue/PR when known (e.g. `// Regression #34`).

---

## Coverage Requirements

- Overall project coverage must stay **above 80%**.
- New code should target **90%** coverage.
- If coverage decreases, explain why in the PR description.
- Missing tests must be explicitly listed in the Risk Assessment.
- Read coverage from the test run's `.xcresult` with `xccov` (or Xcode's report navigator);
  do **not** commit generated coverage HTML.

---

## Reporting

**Do not commit generated test/coverage HTML or `.xcresult` bundles** — they are large and
noisy. Gitignore build output (`build/`, `DerivedData/`, `*.xcresult`). Put pass/fail,
coverage %, and risks in the **PR body**.

**May commit under `reports/<feature-name>/` (small, intentional only):**

```
reports/
  <feature-name>/
    README.md              # optional: coverage % note, how to reproduce
    perf-report.md         # when a perf change has a before/after measurement
```

### Feature Summary (include in PR)

- Feature name
- Files modified
- Architecture impacted

### Test Summary (include in PR)

- Unit tests passed
- Integration / UI tests passed

### Coverage (include in PR)

- Overall coverage percentage
- New code coverage percentage

### Risk Assessment (include in PR)

- Remaining risks
- Missing scenarios
- Recommended future tests

---

## Pull Request Summary

Every PR must include:

- What changed.
- Why it changed.
- Tests added (unit / integration / UI / performance).
- Coverage impact.
- Performance impact (measurement delta if applicable, or "no hot-path changes").
- Performance checklist (when hot paths touched).
- Risks.

### Git tag and GitHub release (after merge)

**Never open a PR without the version bump already on the branch** (see Version Management).
**Never open a PR until the user asks.**

**Mandatory after merge (AI / maintainer):** when a PR that **bumped the version** is merged
into `master` (user says "merged" or merge is confirmed), **immediately** on the merge commit:

1. `git pull origin master`
2. Read the version source of truth (`MARKETING_VERSION` in the Xcode project) — do not guess.
3. Create the annotated tag `v<MARKETING_VERSION>` if it does not already exist, and push it.
4. Build the **signed + notarized** app and attach it to a GitHub Release on that tag when
   the release checklist calls for a published build.

Tags cannot be part of the PR itself (tag after merge only). Docs-only / chore merges with
**no** version bump → **no** tag.

#### Release build (after tag)

1. Confirm `MARKETING_VERSION` matches the tag.
2. Build Release, sign with Developer ID, and notarize:
   ```bash
   xcodebuild -project "Disk Inventory X.xcodeproj" -scheme "Disk Inventory X" \
     -configuration Release clean build
   # then: codesign (Developer ID) → notarytool submit --wait → stapler staple
   ```
3. Zip the `.app` and create the GitHub Release on the tag with that artifact. Release notes:
   only what changed since the previous published tag.

---

## Task Template

Use this template when starting any non-trivial task:

```
Task: <description>

Spec (specs/<feature-name>/):
1. requirements.md — user stories + EARS acceptance criteria. Get approval.
2. design.md — architecture, components, data models, test strategy. Get approval.
3. tasks.md — checklist of discrete implementation tasks. Get approval.

Requirements:
- Implement tasks.md one task at a time, checking each off as it completes.
- Create all required tests (success, failure, edge cases) per the test strategy in design.md.
- Add performance assertions for any scan/tree/render hot-path code.
- Maintain coverage above 80%.
- Run all tests (do not commit generated HTML / .xcresult).
- Verify no performance regressions (measure if applicable).
- List remaining risks.

Deliver:
1. Spec (requirements.md, design.md, tasks.md — all tasks checked off).
2. Implementation.
3. Tests (unit + integration + performance where applicable).
4. Coverage result (stated in PR; optional short note under reports/<feature-name>/README.md).
5. Performance measurement when applicable.
6. Risk assessment.
7. Suggested follow-up improvements.

Do not consider the task complete until all tests pass and performance targets are met.
```

---

## Code Quality

- Follow the existing document-based MVC structure; keep model logic out of view controllers.
- Keep methods small and single-purpose.
- Avoid duplicated logic.
- Use meaningful names; match Cocoa naming conventions (and the file's existing style).
- Add comments only when the *why* is non-obvious.
- Never hardcode user-facing strings (localize them), configuration values, or magic numbers.
- Match the file's memory-management convention (MRR vs ARC); balance retain/release; no leaks.

---

## Version Management

Single shippable product: **Disk Inventory X**. One semantic-version clock.

| Source of truth | Semver field | Monotonic build | Git tag when publishing |
|-----------------|--------------|-----------------|-------------------------|
| Xcode project build settings (both Debug + Release configs) | `MARKETING_VERSION` (surfaced as `CFBundleShortVersionString`) | `CURRENT_PROJECT_VERSION` (surfaced as `CFBundleVersion`; +1 every distinct published build) | `vX.Y.Z` |

| Increment | When |
|-----------|------|
| `PATCH` (1.4.**x**) | Bug fixes, small tweaks, no new features |
| `MINOR` (1.**x**.0) | New user-visible features, backwards-compatible changes |
| `MAJOR` (**x**.0.0) | Breaking changes, large redesigns |

### Mandatory: version bump **before** the PR

The version bump is **part of the feature branch**, never a follow-up after merge. Do **not**
open the PR until the user asks **and** the bump is on the branch.

1. Update **`MARKETING_VERSION`** in both the Debug and Release configurations of the Xcode
   project (`Disk Inventory X.xcodeproj/project.pbxproj`). Bump `CURRENT_PROJECT_VERSION` when
   the build will be distributed as a distinct binary.
2. Add a matching entry to the changelog / release notes
   ([`documentation/release notes.txt`](documentation/release%20notes.txt)), newest first.
3. Keep the release notes user-facing and translate any user-visible changelog strings shown
   in-app (if a changelog UI exists) across all supported locales.

Use commit type `chore` for patch bumps and `feat` for minor/major bumps.

### After the PR merges (tag + artifacts)

If the merged PR bumped the version, tagging is mandatory in the same session (pull `master`
→ annotated `vX.Y.Z` → push), then signed/notarized artifacts + GitHub Release as applicable
(see Pull Request Summary → Release build).

### Release notes rules

- Show **what is new since the previous published tag only**.
- Single flat bullet list under "This release".
- Each tag has its own GitHub Release; do not dump older releases into one body.

---

## Internationalization

The app ships in **English** (base) plus **German, Spanish, and French**
(`en.lproj` / `English.lproj`, `de.lproj`, `es.lproj`, `fr.lproj`). Localized resources
include `.strings`, `.xib`/`.nib`, and localized docs.

### MANDATORY: every feature and change must support all languages

Any feature, change, or fix that adds or modifies user-facing text is **not complete** until
it is fully localized in **all** supported languages. A change that adds an English-only
string is considered broken.

When your change touches user-facing text:

1. **Never hardcode a user-facing string.** Use `NSLocalizedString(...)` (or a localized
   `.strings` entry / localized nib). This includes menu items, button labels, window/panel
   titles, alerts, and tooltips. Do **not** externalize unit tokens or proper nouns
   (`KB`/`MB`/`GB`, `Disk Inventory X`, `Finder`, `Trash`).
2. **Add the new key(s) to the English base** first, using positional format args
   (`%1$@`, `%2$ld`, …), never string concatenation.
3. **Translate into every locale** (`de`, `es`, `fr`). Every key must exist in all locales
   with identical keys and identical format-specifier signatures. Keep localized nibs in sync
   when UI changes.
4. **Verify** the app builds and that key parity holds across all locale files.

If you add a new supported language, create its full `.lproj` with all `.strings` and
localized nibs, and add it to the project.

---

## Documentation (keep it current)

Project documentation lives in [`documentation/`](documentation/) (release notes, known
bugs, feature suggestions, macOS privacy-protected-folder notes).

**MANDATORY: whenever you add or change a feature, update the docs in the same commit.**

1. Update the relevant note in `documentation/` (and add a page for a substantial new feature).
2. Add the user-facing change to `documentation/release notes.txt` under the version being shipped.

A feature change is not complete until the docs reflect it.

---

## Project Structure

Document-based Cocoa app. The document (`FileSystemDoc`, an `NSDocument`) owns the model; the
`FSItem` tree is the model; controllers drive the AppKit UI. Sources sit at the repo root
(flat), plus a few grouped folders.

**Model / scanning**
- `FSItem`, `FSItem-Utilities` — the file-system tree node + size/kind utilities (core model)
- `FSItemIndex` — index/lookup over the tree
- `NSURL-Extensions` — file metadata, sizes, protected-folder handling
- `FileSystemDoc` — the `NSDocument`: owns the scan, model, and document state

**Views / controllers**
- `MainWindowController`, `MainWindow`, `OAToolbarWindowControllerEx` — main document window + toolbar
- `TreeMapViewController` — drives the `TreeMapView` framework (the treemap)
- `FilesOutlineViewController`, `DIXOutlineView`, `DIXTableView`, `ImageAndTextCell` — file outline
- `FileKindsPopupController`, `FileKindsTableController`, `FileTypeColors` — kinds statistic + colors
- `SelectionListController`, `SelectionListTableController` — selection list
- `DrivesPanelController`, `LoadingPanelController`, `InfoPanelController`, `AppsForItem` — panels
- `AppController`, `MyDocumentController`, `main.m` — app + document controller entry points

**Preferences**
- `Preferences` (keys/defaults), `PrefsPanelController`, `PrefsPageBase`, `GeneralPrefPage`,
  `TreeMapPrefPage` — the Preferences window (currently built on OmniAppKit)

**Formatters / transformers**
- `FileSizeFormatter`, `FileSizeTransformer`, `VolumeNameTransformer`, `VolumeUsageTransformer`

**Other**
- `Foundation Extensions/` — Foundation category helpers
- `CocoaTech-Depreciated/` — legacy Finder-plugin code (not built into the shipping app)
- `*.lproj/` — localized resources (en/English, de, es, fr)
- `documentation/` — project docs, release notes, known bugs
- `specs/<feature-name>/` — the spec (`requirements.md`, `design.md`, `tasks.md`) driving each change

**External frameworks (not in repo; see Current focus)**
- `TreeMapView.framework` — the treemap renderer (author's own framework; source lives outside this repo)
- `OmniAppKit` / `OmniFoundation` / `OmniBase` — 2018 prebuilt Omni frameworks (toolbar, preferences window, categories)

### Common Task Map

Reuse this before searching — these are the files a typical change touches:

| Task | Files |
|------|-------|
| Add a preference | `Preferences.h/.m` (key + default) → the relevant `*PrefPage` + its nib → `documentation/` |
| Change scanning / sizes | `FSItem.m`, `FSItem-Utilities.m`, `NSURL-Extensions.m` → model tests |
| Change the treemap | `TreeMapViewController.m` (+ `TreeMapView.framework` API) → perf measurement |
| Change the file outline | `FilesOutlineViewController.m`, `DIXOutlineView.m`, `ImageAndTextCell.m` |
| Change size/volume display text | `FileSizeFormatter.m`, `*Transformer.m` → locale `.strings` |

---

## Build & Test Commands

```bash
# Build (Debug)
xcodebuild -project "Disk Inventory X.xcodeproj" -scheme "Disk Inventory X" -configuration Debug build

# Build + test with coverage (mandatory before PR; requires an XCTest target)
xcodebuild -project "Disk Inventory X.xcodeproj" -scheme "Disk Inventory X" \
  -configuration Debug clean build test -enableCodeCoverage YES

# Read coverage from the result bundle
xcrun xccov view --report --only-targets <path-to>.xcresult

# Release build (before signing + notarization)
xcodebuild -project "Disk Inventory X.xcodeproj" -scheme "Disk Inventory X" -configuration Release clean build
```

`BuildRelease.sh` runs a plain Release build. There is no CI automation configured in this
repo yet; the local build+test gate above is the required check before every PR.
