# Automatic embeds release — October 14, 2026

Published at https://minesweeperstraitofhormuz.com/ from `a1cef25` after the approved local preview.

## Shipped

- Automatic itch.io download widget, YouTube player and TikTok creator preview as their section approaches the viewport.
- Fixed-size placeholder artwork stays visible while providers load, then fades out. Slow or failed previews retain direct provider links. Reduced motion is respected; hidden placeholder animations stop.
- “One guy. Making games.” developer heading and a locally served profile thumbnail.
- Homepage game hosted in the user-specified itch.io iframe. A normal Play button starts the game; it does not boot while someone is reading the page. Board-specific pages retain their preselected local export.
- Privacy policy describes automatic third-party connections and the separate optional Analytics setting.
- Advertising initializes after the initial document load and paint, using the same publisher account and AdSense consent integration. Publisher verification remains in an HTML meta tag. No user-agent conditions or artificial multi-second audit delay.

## Audit-driven changes

The first release's eager game iframe returned HTTP 429 to Google's scanner; the real browser loaded it successfully. Moving the game behind Play removed this dependency from initial page loading and avoids game autofocus while browsing.

Mobile first paint remained slow on the unchanged strategy page as well. Its audit showed early Google advertising/consent work. Moving that work after the document's initial load and paint brought FCP to 1.1 s on both pages. Advertising still initializes once, and the final Lighthouse reports still include its third-party requests.

## Final live Lighthouse results

Lighthouse 13.5.0 via Google's PageSpeed Insights, October 14 at 10:19 AM EDT. These are lab runs, not real-user Core Web Vitals or a ranking guarantee.

| Page | Device | Performance | Accessibility | Best practices | SEO | FCP | LCP | Blocking time | CLS |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Home | Mobile | 100 | 100 | 100 | 100 | 1.1 s | 1.4 s | 50 ms | 0 |
| Home | Desktop | 99 | 100 | 100 | 100 | 0.3 s | 0.7 s | 80 ms | 0 |
| Strategy | Mobile | 100 | 100 | 100 | 100 | 1.1 s | 1.2 s | 60 ms | 0 |
| Strategy | Desktop | 100 | 100 | 100 | 100 | 0.3 s | 0.3 s | 30 ms | 0 |

- [Home report](https://pagespeed.web.dev/analysis/https-minesweeperstraitofhormuz-com/4tkcfpy7y5?form_factor=mobile)
- [Strategy report](https://pagespeed.web.dev/analysis/https-minesweeperstraitofhormuz-com-strategy/rgggtqh71p?form_factor=mobile)
- [Initial eager-game report](https://pagespeed.web.dev/analysis/https-minesweeperstraitofhormuz-com/oi74z0js0x?form_factor=mobile)
- [Home before the advertising adjustment](https://pagespeed.web.dev/analysis/https-minesweeperstraitofhormuz-com/8tefo07hzj?form_factor=mobile)
- [Strategy before the advertising adjustment](https://pagespeed.web.dev/analysis/https-minesweeperstraitofhormuz-com-strategy/65p1rca9vm?form_factor=mobile)

## Verification

- `python3 tests/check_site.py`: passed across nine pages, checking local links, anchors, assets, canonical URLs, structured data, store availability, sitemap and 12 exhaustive puzzle proofs.
- Shared generator rerun is idempotent. External and edited inline JavaScript parse successfully; `git diff --check` passes.
- All nine public page URLs, robots.txt, sitemap.xml and the two new media assets returned HTTP 200. Homepage remains indexable and has its canonical URL.
- Production has no preview toolbar, artificial loading modes or preview noindex directive.
- Browser: all three media previews reached ready state with stable reserved heights. Phone-width check at 390 px had no horizontal page overflow. Desktop media embeds rendered correctly; direct provider links remain accessible.
- Browser: zero game iframes before Play, exactly one correct itch.io iframe afterward.
- Browser: wrong and correct quiz choices, reset, and reveal-solution controls work.
- Browser: post-load advertising initializes one runtime using the correct publisher account. No site JavaScript errors seen in the checked live page.

Screenshots and text exports are kept outside the public repository in `../build/qa/2026-10-14-automatic-embeds/` from the site root: `social-live.jpg`, `lighthouse-home-mobile.jpg`, and `lighthouse-results.json`. The original approved local preview remains in the build/previews folder. No large intermediate renders were created.

Implementation references: [Google on loading third-party JavaScript](https://web.dev/articles/efficiently-load-third-party-javascript), [AdSense verification methods](https://support.google.com/adsense/answer/7584263?hl=en).
