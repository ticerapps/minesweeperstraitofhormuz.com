"""Build shared HTML chrome and the original, solver-checked strategy examples.

Run from any directory. The ordinary HTML remains the source for page content.
"""
from pathlib import Path
import html
import json
import re
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from patterns import PATTERNS, verify

ROOT = Path(__file__).resolve().parents[1]
BASE = "https://minesweeperstraitofhormuz.com"
PLAY = "https://play.google.com/store/apps/details?id=com.ticer.minesweeperstraitofhormuz"
ITCH = "https://btror.itch.io/minesweeper-strait-of-hormuz"

def downloads():
    return f'''<section class="download-strip" aria-label="Get the full game"><div><h2>Take the strait with you.</h2><p>44 campaign puzzles, daily competition, ranks and custom loadouts. Play offline, too.</p></div><div><div class="download-actions"><a class="action-primary" data-destination="google_play" href="{PLAY}">Get it on Google Play <span aria-hidden="true">↗</span></a><a class="action-secondary" data-destination="itch" href="{ITCH}">Play on itch.io</a></div><small>iPhone and iPad: coming soon.</small></div></section>'''

def board(p, quiz=False):
    width=len(p['board'][0]); out=[]
    for i,c in enumerate(''.join(p['board'])):
        cls='pattern-cell '; label=''; inside=html.escape(c)
        if c=='#': cls+='outside'; inside=''; label='Outside this example'
        elif c=='F': cls+='flag'; inside='⚑'; label='Proven mine'
        elif c.isdigit(): cls+='clue n'+c; label=f'{c} adjacent mines'
        else:
            cls+='covered'; label=f'Hidden tile {i+1}'
            answer=''
            if i in p['mines']: cls+=' answer-marked answer-mine';answer='⚑'
            if i in p['safe']: cls+=' answer-marked answer-safe';answer='✓'
            inside=f'<span class="hidden-symbol" aria-hidden="true">?</span><span class="answer-symbol" aria-hidden="true">{answer}</span>'
        if quiz and c=='?':
            out.append(f'<button type="button" class="{cls}" data-quiz-answer="{"safe" if i in p["safe"] else "mine"}" data-original-label="Try {("left","middle","right")[i]} tile" aria-label="Try {("left","middle","right")[i]} tile">{inside}</button>')
        else: out.append(f'<span role="img" class="{cls}" aria-label="{label}" data-original-label="{label}">{inside}</span>')
    return f'<div class="pattern-board" id="{"quiz-board" if quiz else "board-"+p["id"]}" style="--cols:{width}" role="group" aria-label="{html.escape(p["title"])} example">'+''.join(out)+'</div>'

def render_strategy():
    path=ROOT/'strategy/index.html'; page=path.read_text()
    cards=[]
    for n,p in enumerate(PATTERNS,1):
        note='1 mine in this whole example' if 'total' in p else 'Rotate or mirror the same layout'
        cards.append(f'''<section class="pattern-card" id="{p['id']}"><p class="pattern-group">{n:02d} / {p['group']}</p><h2>{p['title']}</h2><div class="pattern-stage">{board(p)}</div><div class="pattern-answer"><button type="button" data-answer="board-{p['id']}" aria-controls="board-{p['id']}" aria-expanded="false">Show solution</button><small>{note}</small></div><details><summary>Why it works</summary><p>{p['text']}</p></details></section>''')
    intro=f'''<article class="visual-guide"><div class="guide-intro"><div><p class="guide-kicker">The field guide / 12 visual reads</p><h1>Minesweeper patterns.<br>See the next move.</h1><p class="lead">Read the numbers. Spot the pattern. Open a tile you can prove is safe.</p><p><a href="/how-to-play/">New to minesweeper? Start with the rules.</a></p></div><section class="quiz" aria-label="Interactive 1–2–1 exercise"><h2>Which tile is safe?</h2>{board(PATTERNS[4],True)}<p class="quiz-feedback" id="quiz-feedback" role="status" aria-live="polite">Tap one of the three hidden tiles.</p><button type="button" class="text-button" data-quiz-reset hidden>Try again</button><noscript><p>The middle tile is safe. The outer two must be mines.</p></noscript></section></div>
<div class="pattern-legend"><span>? Unresolved</span><span class="legend-safe">✓ Proven safe</span><span class="legend-mine">⚑ Proven mine</span></div>
<p class="pattern-note">These are cropped examples: all hidden neighbours of the numbered clues are shown. Hatched cells are outside the example. Flags stand for proven mines. A matching string of numbers is not enough if extra hidden neighbours change the clues.</p>
<nav class="guide-jump" aria-label="Pattern groups"><a href="#all-mines">Start here</a><a href="#one-one">Edge patterns</a><a href="#one-one-plus">Holes &amp; corners</a><a href="#reduction">Reduce with flags</a><a href="#counting">Endgame</a></nav>
<div class="pattern-cards">{''.join(cards)}</div>
<div class="guide-end"><section><h2>Chord once the flags are proven.</h2><p>When the adjacent flags match a number, tap that number to open its remaining neighbours. Chording trusts your flags; it does not check whether they are correct.</p></section><section><h2>Follow the coastline.</h2><p>Strait boards use the same eight-neighbour rule, including diagonals. Land removes neighbours. Count the actual water tiles before applying an edge pattern.</p></section><section><h2>A zero counter is not proof.</h2><p>The counter subtracts placed flags, including wrong ones. Only treat the remaining tiles as safe when every flag is justified and every mine is accounted for.</p></section><section><h2>Keep learning.</h2><p>Try these reads in the <a href="/#play">free strait demo</a>. For more community terminology and advanced examples, visit <a href="https://minesweeper.online/help/patterns">Minesweeper Online’s pattern reference</a>. Diagrams on this page are our own.</p></section></div>
</article>'''
    page=re.sub(r'<article>.*?</article>',lambda _:intro,page,flags=re.S)
    if '<article class="visual-guide">' in page and page.count('class="visual-guide"')==1:
        # On subsequent runs replace the generated article as well.
        page=re.sub(r'<article class="visual-guide">.*?</article>',lambda _:intro,page,flags=re.S)
    page=re.sub(r'<title>.*?</title>','<title>Minesweeper Patterns: 12 Visual Examples &amp; Practice | Ticerapps</title>',page)
    page=re.sub(r'<meta name="description"[^>]*>','<meta name="description" content="Learn minesweeper patterns with 12 illustrated examples: 1-2-1, 1-2-2-1, reduction, corners and mine counting. Reveal solutions and try an interactive puzzle.">',page)
    page=page.replace('the patterns that solve every board','12 visual patterns and practice').replace('2026-10-12", "mainEntityOfPage"','2026-10-14", "mainEntityOfPage"')
    path.write_text(page)

def apply_chrome():
    for path in ROOT.rglob('index.html'):
        if any(part in path.parts for part in ('.git','play','docs','tests')): continue
        page=path.read_text(); rel=path.relative_to(ROOT).as_posix().replace('index.html',''); current='/'+rel
        nav=[('/#play','Play'),('/#boards','Boards'),('/how-to-play/','How to play'),('/strategy/','Patterns'),('/no-guess-minesweeper/','No-guess')]
        links=''.join(f'<a href="{url}"'+(' aria-current="page"' if current==url else '')+f'>{label}</a>' for url,label in nav)
        header=f'''<!-- shared-header:start --><header class="top site-header"><a class="brand" href="/" aria-label="Minesweeper: Strait of Hormuz by Ticerapps, home"><img src="/assets/icon-192.png" width="42" height="42" alt=""><span><b>Minesweeper: Strait of Hormuz</b><small>by Ticerapps</small></span></a><button type="button" class="menu-toggle" aria-expanded="false" aria-controls="site-nav">Menu <span aria-hidden="true">☰</span></button><nav class="site-nav" id="site-nav" aria-label="Main navigation">{links}<a class="nav-download" href="/#get">Get the game <span aria-hidden="true">↗</span></a></nav></header><!-- shared-header:end -->'''
        if '<!-- shared-header:start -->' in page:page=re.sub(r'<!-- shared-header:start -->.*?<!-- shared-header:end -->',lambda _:header,page,flags=re.S)
        else:page=re.sub(r'<header class="top">.*?</header>',lambda _:header,page,count=1,flags=re.S)
        footer='''<!-- shared-footer:start --><footer class="site-footer"><p>© 2026 Ticerapps<br>Minesweeper: Strait of Hormuz</p><nav aria-label="Footer"><a href="/privacy/">Privacy policy</a><a href="https://ticerapps.github.io/">More from Ticerapps</a><a href="mailto:ticerapps@gmail.com">Support</a><a href="https://www.tiktok.com/@ticerapps_dev" data-destination="tiktok">TikTok ↗</a><button type="button" class="text-button" data-analytics-settings hidden>Analytics choices</button><button type="button" class="text-button" data-ad-choices hidden>Ad privacy choices</button></nav></footer><!-- shared-footer:end -->'''
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
        # Offers must match actual availability; keep old app/store policy URLs stable.
        page=re.sub(r'<a[^>]+href="https://apps.apple.com/app/id6795665498"[^>]*>.*?</a>','<span class="coming-soon"><strong>iPhone &amp; iPad</strong>Coming soon on the App Store</span>',page,flags=re.S)
        for url,destination in ((PLAY,'google_play'),(ITCH,'itch')):
            page=re.sub(r'<a(?![^>]*data-destination)([^>]*href="'+re.escape(url)+r'"[^>]*)>',lambda m:'<a data-destination="'+destination+'"'+m[1]+'>',page)
        path.write_text(page)

if __name__=='__main__':
    verify();render_strategy();apply_chrome();print('Shared navigation, download panels and 12 verified pattern cards rendered.')
