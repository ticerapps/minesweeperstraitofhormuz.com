# Website and web demo update, 2026-10-14

## Changes

- Shared responsive navigation; cleaner home hero and game download links on guides and board pages.
- Twelve original Minesweeper examples verified by enumerating every possible mine assignment. Interactive safe-tile exercise and revealable solutions.
- Corrected no-guess density from 25% to the source's 21% cap, with actual rounded mine counts. Removed unsupported performance claims and the unavailable App Store offer/link.
- TikTok creator profile and selected YouTube video b3fSf2jTIck load only when requested. Direct links remain available. YouTube uses its privacy-enhanced domain with an origin referrer so the player can verify its embed host.
- Website privacy policy and original developer policy cross-link. App store privacy URLs remain unchanged.
- GA4 property: Minesweeper Strait of Hormuz website. Stream 16125318322, measurement ID G-T2V0T6R4H6. Enhanced measurement off. Optional analytics records page_view, store_click (store: google_play/itch), and demo_start after opt-in only. No gameplay/profile data. Query strings/fragments removed; referring origin only. GPC/DNT suppress analytics. Local previews do not report events.
- Sitemap excludes the raw /play/ export; its HTML carries noindex,follow. Landing and board pages remain indexable.
- Web pinch: don't expire held fingers; rebase when the active fingers change; suppress compatibility mouse events after consumed touch gestures; anchor scaling to the previous midpoint; clear gesture on focus loss.

## Verification

- `python3 tests/check_site.py`: 9 page/link/anchor/schema/asset checks and all 12 exhaustive pattern proofs passed.
- `python3 tools/render_shared.py`: repeat run leaves output unchanged.
- `node --check assets/site.js` and `node --check assets/analytics.js`: passed.
- Godot 4.7 release web export: completed without errors or warnings.
- `tests/zoom_gesture_test.gd`: 22 checks, including both release orders, remaining-finger movement with incorrect browser-relative delta, late compatibility mouse motion, a stationary finger held for 1.35 seconds, three-finger handoff, focus loss, cancellation, and fresh taps.
- Browser checks: phone 320/390, tablet 768, desktop 1280; responsive navigation, both quiz outcomes, reveal solution, click-to-load YouTube and TikTok. No horizontal page overflow after layout settles. Third-party ad frames resize independently.

The gesture tests drive the actual Godot controller. Physical-device Safari/Chrome multi-touch still needs a hands-on retest; it cannot be proven by a desktop browser screenshot.

## Reproduce

The Godot project is local at `/Users/ticer/Desktop/dev/hormuz-web` and is not itself a Git repository. The deployed site is its nested `site` repository. `tools/web-source/ZoomController.gd` preserves the controller source shipped in this update; copy it to the project's `scripts/core/ZoomController.gd` if restoring from the website repository. Copy the gesture test into the project's `tests` directory and run:

```
Godot --headless --path /path/to/hormuz-web --script tests/zoom_gesture_test.gd
Godot --headless --path /path/to/hormuz-web --export-release Web build/web/index.html
```

The Web export preset excludes `site/*`, `build/*`, `docs/*`, `tests/*`, and Markdown. Keep `html/head_include` set to `<meta name="robots" content="noindex, follow">`. Copy `build/web/.` into `site/play/` and verify `/play/index.html` retains that tag.

Run `python3 tools/boards.py` for board pages and `python3 tools/render_shared.py` for the common navigation, footer, download sections and pattern guide. Website source is ordinary HTML plus shared CSS/JS; no JS framework is required.
