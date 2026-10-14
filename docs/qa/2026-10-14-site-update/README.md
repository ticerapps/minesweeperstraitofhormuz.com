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

## Google scanners and deployment

All checks below used the deployed HTTPS site on 2026-10-14, not just a local preview.

- PageSpeed Insights / Lighthouse 13.5.0: mobile and desktop runs for the home page, strategy guide, and a representative board page. The initial homepage mobile performance score was 63 (FCP 4.2 s, LCP 6.4 s, CLS 0.121).
- Optimizations: self-hosted OFL font subsets with renamed internal families and optional rendering, font preloads, shared critical styles inlined by the generator, click-to-load social/itch embeds, manual ads requested only as their own slot approaches the viewport, and mobile-menu state applied before first paint.
- Google Rich Results Test: homepage has one valid Breadcrumb item. Strategy has two valid items (Article and Breadcrumb), with no remaining warnings after adding the author URL and complete publication/modification timestamps.
- Search Console URL Inspection: the strategy page's live test allows indexing; the indexing request was accepted into Google's crawl queue. This does not mean Google has indexed it yet.
- Search Console HTTPS: no critical issues, zero non-HTTPS URLs reported. Report last updated October 10.
- Search Console Core Web Vitals: insufficient real-user data for mobile and desktop; a lab Lighthouse result is not a field Core Web Vitals assessment.
- GA4 Realtime received the consented `page_view` and `store_click` test events. Browser checks found zero GA scripts before opt-in, one after opt-in, and zero after revocation/reload.
- GitHub Pages deployed website commit `5519872` successfully (run `38522519840`). The developer-site cross-links deployed from `26a578a` (run `38520847448`).
- The live web pack SHA256 matches the tested local export: `aa0dc03b88683d67efd76d04823fe42af2aace2131ec45cdde697c45ef9fc987`.
- Task-only font tooling, a downloaded comparison pack, and scratch logs were removed after verification (50.6 MiB). Source, runtime assets, font licenses, latest export, and QA evidence are preserved.

Rich Results reports:

- [Home](https://search.google.com/test/rich-results/result?id=1ScSlw3YNqddbL8SBVUyzw)
- [Strategy](https://search.google.com/test/rich-results/result?id=08O466VHBXNYNjb9GHiLgA)

Google's ad response varies between runs. A mobile run reported a deprecated `unload` listener in `pagead2.googlesyndication.com/pagead/js/lidar.js`, reducing Best Practices to 81; desktop runs scored 100. That script is maintained by Google, not this site's code. Remaining third-party cache and unused-JavaScript suggestions depend on AdSense and its served ads.

### Final Lighthouse results

Scores are single-run lab measurements and will vary with network conditions and served ads.

| Page | Mobile performance | Desktop performance | Accessibility | SEO | Mobile CLS |
| --- | ---: | ---: | ---: | ---: | ---: |
| Home | 99 | 100 | 100 | 100 | 0 |
| Strategy | 100 | 99 | 100 | 100 | 0 |
| Small Hands board | 93 | 100 | 100 | 100 | 0 |

Final home run: FCP 1.1 s, LCP 2.0 s, blocking time 60 ms; Best Practices 100. Final strategy run: FCP 1.1 s, LCP 1.2 s, blocking time 80 ms; Best Practices 81 solely from the Google ad-script deprecation described above. Desktop Best Practices is 100 on all three pages. The representative board run preceded the menu first-paint fix and already had zero measured CLS.

- [Home final report](https://pagespeed.web.dev/analysis/https-minesweeperstraitofhormuz-com/au6nqvtvem?form_factor=mobile)
- [Strategy final report](https://pagespeed.web.dev/analysis/https-minesweeperstraitofhormuz-com-strategy/dahjg8mclg?form_factor=mobile)
- [Board report](https://pagespeed.web.dev/analysis/https-minesweeperstraitofhormuz-com-boards-small-hands/doen6rn3jb?form_factor=mobile)
- [Homepage initial report](https://pagespeed.web.dev/analysis/https-minesweeperstraitofhormuz-com/emhi5dq7s3?form_factor=mobile)

Local screenshots (kept outside the public repo) are in `../build/qa/2026-10-14-site-update/`: `strategy-live.jpg`, `lighthouse-home-mobile.jpg`, `analytics-realtime.jpg`, and `indexing-requested.jpg`.

Google explicitly cautions that excellent performance scores do not guarantee top search rankings: https://developers.google.com/search/docs/appearance/page-experience. The crawl request still depends on Google's scheduling and indexing decisions.
