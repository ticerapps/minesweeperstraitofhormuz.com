"""Build the shared HTML chrome (header, footer, download strip) for every page.

The pattern guide and the no-guess guide moved to ticerapps.com/minesweeper/ on 2026-11-10,
with their solver-checked examples (tools/minesweeper/ in the ticerapps.github.io repo).
strategy/ and no-guess-minesweeper/ here are redirect pages and are left alone.

Run from any directory. The ordinary HTML remains the source for page content.
"""
from pathlib import Path
import html
import json
import re

ROOT = Path(__file__).resolve().parents[1]
BASE = "https://minesweeperstraitofhormuz.com"
PLAY = "https://play.google.com/store/apps/details?id=com.ticer.minesweeperstraitofhormuz"
ITCH = "https://btror.itch.io/minesweeper-strait-of-hormuz"
APPLE = "https://apps.apple.com/app/id6795665498"

def downloads():
    return f'''<section class="download-strip" aria-label="Get the full game"><div><h2>Take the strait with you.</h2><p>44 campaign puzzles, daily competition, ranks and custom loadouts. Play offline, too.</p></div><div><div class="download-actions"><a class="action-primary" data-destination="app_store" href="{APPLE}">Get it on the App Store <span aria-hidden="true">↗</span></a><a class="action-secondary" data-destination="google_play" href="{PLAY}">Get it on Google Play <span aria-hidden="true">↗</span></a><a class="action-secondary" data-destination="itch" href="{ITCH}">Play on itch.io</a></div><small>Free on iPhone, iPad and Android. Contains ads and optional purchases.</small></div></section>'''


def apply_chrome():
    for path in ROOT.rglob('index.html'):
        if any(part in path.parts for part in ('.git','play','docs','tests')): continue
        page=path.read_text()
        if 'http-equiv="refresh"' in page: continue  # moved-guide redirect pages
        rel=path.relative_to(ROOT).as_posix().replace('index.html',''); current='/'+rel
        nav=[('/#play','Play'),('/#boards','Boards'),('/how-to-play/','How to play'),('https://ticerapps.com/minesweeper/strategy/','Patterns'),('https://ticerapps.com/minesweeper/','Guides')]
        links=''.join(f'<a href="{url}"'+(' aria-current="page"' if current==url else '')+f'>{label}</a>' for url,label in nav)
        header=f'''<!-- shared-header:start --><header class="top site-header"><a class="brand" href="/" aria-label="Minesweeper: Strait of Hormuz by Ticerapps, home"><img src="/assets/icon-192.png" width="42" height="42" alt=""><span><b>Minesweeper: Strait of Hormuz</b><small>by Ticerapps</small></span></a><button type="button" class="menu-toggle" aria-expanded="false" aria-controls="site-nav">Menu <span aria-hidden="true">☰</span></button><nav class="site-nav" id="site-nav" aria-label="Main navigation">{links}<a class="nav-download" href="/#get">Get the game <span aria-hidden="true">↗</span></a></nav></header><!-- shared-header:end -->'''
        if '<!-- shared-header:start -->' in page:page=re.sub(r'<!-- shared-header:start -->.*?<!-- shared-header:end -->',lambda _:header,page,flags=re.S)
        else:page=re.sub(r'<header class="top">.*?</header>',lambda _:header,page,count=1,flags=re.S)
        footer='''<!-- shared-footer:start --><footer class="site-footer"><p>© 2026 Ticerapps<br>Minesweeper: Strait of Hormuz</p><nav aria-label="Footer"><a href="/privacy/">Privacy policy</a><a href="https://ticerapps.com/">More from Ticerapps</a><a href="mailto:ticerapps@gmail.com">Support</a><a href="https://www.tiktok.com/@ticerapps_dev" data-destination="tiktok">TikTok ↗</a><button type="button" class="text-button" data-analytics-settings hidden>Analytics choices</button><button type="button" class="text-button" data-ad-choices hidden>Ad privacy choices</button></nav></footer><!-- shared-footer:end -->'''
        if '<!-- shared-footer:start -->' in page:page=re.sub(r'<!-- shared-footer:start -->.*?<!-- shared-footer:end -->',lambda _:footer,page,flags=re.S)
        else:page=re.sub(r'<footer>.*?</footer>',lambda _:footer,page,count=1,flags=re.S)
        page=page.replace('<link rel="stylesheet" href="/assets/refresh.css">','')
        page=re.sub(r'<!-- shared-style:start -->.*?<!-- shared-style:end -->','',page,flags=re.S)
        page=re.sub(r'<noscript><link[^>]*fonts.googleapis.com[^>]*></noscript>','',page)
        page=re.sub(r'<link[^>]*(?:fonts.googleapis.com|fonts.gstatic.com)[^>]*>','',page)
        # Set the mobile menu state before first paint, not when deferred JS arrives.
        style='<!-- shared-style:start --><script>document.documentElement.classList.add("js");</script><link rel="preload" href="/assets/fonts/hormuz-display.woff2" as="font" type="font/woff2" crossorigin><link rel="preload" href="/assets/fonts/hormuz-body-medium.woff2" as="font" type="font/woff2" crossorigin><style>'+(ROOT/'assets/refresh.css').read_text()+'</style><!-- shared-style:end -->'
        page=page.replace('</head>',style+'\n</head>')
        page=page.replace('<script defer src="/assets/site.js"></script>','')
        page=page.replace('<script defer src="/assets/analytics.js"></script>','')
        page=re.sub(r'\n{3,}', '\n\n', page)
        page=page.replace('</head>','<script defer src="/assets/site.js"></script>\n<script defer src="/assets/analytics.js"></script>\n</head>')
        page=re.sub(r'<!-- shared-downloads:start -->.*?<!-- shared-downloads:end -->','',page,flags=re.S)
        if current not in ('/','/privacy/'):
            page=page.replace('</main>','<!-- shared-downloads:start -->'+downloads()+'<!-- shared-downloads:end -->\n</main>')
        # Both mobile listings are live. Preserve links when regenerating pages.
        for url,destination in ((PLAY,'google_play'),(APPLE,'app_store'),(ITCH,'itch')):
            page=re.sub(r'<a(?![^>]*data-destination)([^>]*href="'+re.escape(url)+r'"[^>]*)>',lambda m:'<a data-destination="'+destination+'"'+m[1]+'>',page)
        path.write_text(page)

if __name__=='__main__':
    apply_chrome();print('Shared navigation and download panels rendered.')
