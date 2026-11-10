# App Store links and strategy practice — November 10, 2026

## Changes

- Live App Store buttons on the homepage, rules, strategy, no-guess and board pages; removed stale iOS availability text from visible copy, search/social descriptions and FAQ structured data.
- Added the verified free iOS offer to the homepage structured data. Shared rendering preserves Apple links. Existing analytics consent also gates the new `app_store` download-click destination.
- Added chording practice with flag toggles, correct/incorrect outcomes, count-mismatch feedback and reset. The trainer explicitly distinguishes its tap-to-flag controls from the full game's hold/right-click controls.
- Added a four-step 2–3–2 reduction example using a proven flag. Remaining counts are labelled as mental calculations; original board clues return in the solved view.
- Lessons use the existing exhaustive solver-verified examples. All explanations are present in HTML, with a no-JavaScript fallback and direct demo links. No third-party code, requests or persistent progress added by the lessons.
- Updated strategy descriptions, article modification date, homepage guide link and sitemap modification dates for the updated content pages.

## Verification before publication

- Apple lookup API identifies app 6795665498 as Minesweeper: Strait of Hormuz, free, with iPhone/iPad support. The public App Store link returns HTTP 200.
- `python3 tests/check_site.py`: nine pages passed local links, anchors, assets, canonical URLs, structured data, availability, sitemap and exhaustive proofs for all twelve patterns.
- Generator rerun produced identical page hashes; `git diff --check` passed.
- Browser: every one of the eight possible flag combinations produces the correct outcome (five blocked count mismatches, two wrong-flag failures, one safe chord). Reset permits another attempt.
- Browser: all four reduction states, solved markings, replay, start-over and keyboard activation passed. Original quiz and pattern solution controls still work.
- Browser: phone widths 320/390, tablet 768, desktop 1200 have no horizontal overflow after reflow on the homepage and strategy page. New tile controls measure 56 × 56 CSS pixels.
- Browser: Apple badge loads; both homepage Apple links target the verified app; no remaining visible coming-soon text. No application JavaScript errors were recorded. The pre-existing AdSense unsupported `data-adsense-runtime` warning remains outside this change.
- Added lesson JS and CSS total about 3.2 KB gzipped (9.4 KB source), loaded only by the strategy page. No Lighthouse score is claimed for this change.

Selected screenshots and machine-readable browser results are outside the published source in `../build/qa/2026-11-10-ios-links-strategy/` from the site root. No large media intermediates were generated.
