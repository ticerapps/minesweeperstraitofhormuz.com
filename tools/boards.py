#!/usr/bin/env python3
"""Generate site/boards/<slug>/index.html for the four strait boards.

Run from hormuz-web/site:  python3 boards.py
Shares the site stylesheet (assets/site.css, inlined) plus the landing page's
game-frame rules, and the same header/nav/footer as the guide pages.
"""
import json, re, os, html
from pathlib import Path
os.chdir(Path(__file__).resolve().parents[1])

SITE = os.getcwd()
BASE = "https://minesweeperstraitofhormuz.com"
DATE = '2026-10-14T02:19:47-04:00'

DIFFS = [("easy", "Easy"), ("medium", "Medium"), ("hard", "Hard"), ("veteran", "Veteran")]

BOARDS = [
    {
        "slug": "small-hands",
        "name": "Small Hands, Small Grid",
        "short": "Small Hands",
        "cells": 115,
        "mines": [12, 17, 23, 24],
        "xp": "1×",
        "title": "Small Hands, Small Grid – Play the Smallest Strait Minesweeper Board",
        "desc": "Play Small Hands, Small Grid free in your browser: a 115-tile minesweeper board cut from the Strait of Hormuz coastline, 12 to 24 mines, first tap always safe.",
        "h1": "Small Hands, Small Grid",
        "tag": "The smallest strait board · 115 tiles",
        "intro": "The board the demo opens on. A small patch of water wrapped around the tip of the Musandam peninsula at the narrowest point of the strait, small enough to finish in a couple of minutes and irregular enough that no two corners play the same way.",
        "shape": [
            "Small Hands sits on the headland itself: a strip of tiles on the Persian Gulf side, a strip on the Gulf of Oman side, and the two joined around the point past a small island. The land cuts into the board from the middle, so most tiles touch the coast and have five or six neighbours instead of eight. A 1 on a concave bend often has only two covered neighbours, which makes it one of the fastest reads in the game.",
            "With 115 tiles there is nowhere to hide a long guess chain. On Easy the board usually opens up from the first tap; on Veteran the 24 mines pack in tightly and the mine counter in the top right does real work in the last ten tiles.",
        ],
        "play": [
            "Open with a tap near the middle of the water. The first tap is always safe and the generator certifies the rest of the board can be solved without guessing.",
            "Work the coast first. Perimeter numbers see fewer tiles, so they resolve earlier than numbers in open water.",
            "On Veteran, count. When fewer than ten covered tiles remain, the flag counter tells you exactly how many are safe.",
        ],
        "next": ("sanctions-season", "Sanctions Season", "Three times the tiles and the first real channel."),
    },
    {
        "slug": "sanctions-season",
        "name": "Sanctions Season",
        "short": "Sanctions Season",
        "cells": 346,
        "mines": [35, 52, 69, 72],
        "xp": "2×",
        "title": "Sanctions Season – Mid-Size Strait of Hormuz Minesweeper Board",
        "desc": "Play Sanctions Season free in your browser: a 346-tile minesweeper board shaped by the Strait of Hormuz, 35 to 72 mines, no-guess layouts, first tap always safe.",
        "h1": "Sanctions Season",
        "tag": "The mid-size strait board · 346 tiles",
        "intro": "The second board, three times the size of Small Hands. A rounded basin on the Gulf of Oman side of the peninsula, off the eastern coast, with enough open water that more than one front is open at once.",
        "shape": [
            "Sanctions Season is one connected body of water hugging the coast south-east of the headland. The seaward edge is open and round; the landward edge follows the shoreline and breaks into coves two or three tiles wide. Those coves behave like corridors: a number sitting in one sees very few tiles, and solving the mouth usually unlocks the cove behind it.",
            "It is the board where the 1-2-1 and 1-2-2-1 patterns start to appear on open water, not just along the edge. Expect to flag in batches rather than one at a time.",
        ],
        "play": [
            "Open in the widest part of the water so the cascade has room to run.",
            "Clear coves from their mouth inward. The narrow entrance is the easiest read; the interior follows from it.",
            "When the open fronts stall, switch to the far coast. There is almost always a second front with an easy read waiting.",
        ],
        "next": ("no-mans-strait", "No Man's Strait", "615 tiles on both sides of the strait."),
    },
    {
        "slug": "no-mans-strait",
        "name": "No Man's Strait",
        "short": "No Man's Strait",
        "cells": 615,
        "mines": [62, 92, 123, 129],
        "xp": "3×",
        "title": "No Man's Strait – Large Strait of Hormuz Minesweeper Board",
        "desc": "Play No Man's Strait free in your browser: a 615-tile minesweeper board spanning both sides of the Strait of Hormuz, 62 to 129 mines, no-guess layouts.",
        "h1": "No Man's Strait",
        "tag": "The large strait board · 615 tiles",
        "intro": "The third board moves to the Persian Gulf side of the peninsula: a broad sheet of open water against the western coast, nearly twice the size of Sanctions Season and wide enough that you solve it in regions.",
        "shape": [
            "No Man's Strait is a single large basin west of the headland. Its inland edge follows the coast and its seaward edge runs out into open water, so the middle of the board is pure open-water minesweeper with eight neighbours per tile, while the shoreline hands you the easy reads. The peninsula coast on the east side is long and jagged and is where most games get going.",
            "At 615 tiles the board is too big to read in one glance. Zoom in to work a section, zoom out to pick the next one. The HUD's flag counter stays useful all game because the mine count is high enough that a miscount shows up.",
        ],
        "play": [
            "Open on one side and finish most of it before crossing. Solving a basin gives you a solid wall of numbers to read the narrows from.",
            "Treat the peninsula coast like an edge: numbers along it see fewer tiles and resolve first.",
            "Use chording. Tap a satisfied number to clear its remaining neighbours in one move; on a board this size it saves hundreds of taps.",
        ],
        "next": ("hormuz-closed", "Hormuz Closed", "The full strait, 891 tiles."),
    },
    {
        "slug": "hormuz-closed",
        "name": "Hormuz Closed",
        "short": "Hormuz Closed",
        "cells": 891,
        "mines": [89, 134, 178, 187],
        "xp": "4.5×",
        "title": "Hormuz Closed – The Full Strait of Hormuz Minesweeper Board",
        "desc": "Play Hormuz Closed free in your browser: the full 891-tile Strait of Hormuz minesweeper board, 89 to 187 mines, no-guess layouts, first tap always safe.",
        "h1": "Hormuz Closed",
        "tag": "The full strait · 891 tiles",
        "intro": "The whole strait. Every tile of water from the Persian Gulf through the narrows to the Gulf of Oman, with the peninsula, the islands and the full coastline in play. It is the biggest board in the game and the one the name is about.",
        "shape": [
            "Hormuz Closed joins the other three boards' water and everything between: the Persian Gulf basin, the narrows around the headland, and the Gulf of Oman basin, with the coastline running the whole way round and the islands in the strait sitting as obstacles with numbers on every side. Tiles touching an island are the closest thing the game has to a classic corner, and they are scattered through open water.",
            "With up to 187 mines it is a long solve. The no-guess generator still certifies every layout, so a stall is a missed read, never a true coin flip; the Veteran tier is the only one allowed to need a short counting line.",
        ],
        "play": [
            "Pick a basin and settle in. Clearing the Gulf of Oman side first gives you the easier coast to start from.",
            "Islands are your friends. A number next to an island sees fewer covered tiles, so the water around islands resolves early.",
            "Take the hint if you stall. INTEL points at the next certain move without touching the board, and it beats guessing on a board this size.",
        ],
        "next": ("small-hands", "Small Hands, Small Grid", "Back to the small one."),
    },
]


def page(b):
    css = open("assets/site.css").read()
    landing = open("index.html").read()
    # Game frame rules live only on the landing page; lift them verbatim.
    frame_css = []
    for sel in [r"\.game\{", r"\.bracket\{", r"\.bracket::before,", r"\.bracket::before\{", r"\.bracket::after\{",
                r"\.bracket i::before\{", r"\.bracket i::after\{", r"\.frame\{", r"@media \(max-width:700px\)\{\.frame",
                r"\.frame iframe\{", r"\.poster\{", r"\.poster::before\{", r"\.poster>\*\{", r"\.poster h2\{",
                r"\.poster p\{", r"\.play\{", r"\.play:hover", r"\.play:focus-visible\{", r"\.poster small\{",
                r"\.under\{", r"\.under a\{", r"\.under \.legend\{", r"\.under \.legend b\{", r"\.h2-inline\{",
                r"\.skip\{", r"\.skip:focus\{", r"\.hero p\.lead\{"]:
        m = re.search(sel + r"[^\n]*", landing)
        assert m, sel
        frame_css.append(m.group(0))
    frame_css = "\n".join(frame_css).replace('url("assets/demo-poster.webp")', 'url("../../assets/board-%s.webp")' % b["slug"])
    extra = """
.board-head{display:grid;gap:18px;grid-template-columns:minmax(0,1fr) auto;align-items:end}
.board-head h1{margin:6px 0 0}
article p.lead{font-size:clamp(18px,2.4vw,23px);color:var(--mint);margin:14px 0 0;max-width:40ch}
.stats{display:grid;grid-template-columns:repeat(auto-fit,minmax(150px,1fr));gap:10px;margin:18px 0 0}
.stats div{background:var(--panel);border:1px solid var(--line);border-radius:10px;padding:12px 14px}
.stats b{display:block;font-family:var(--display);font-size:26px;color:var(--cream)}
.stats span{font-family:var(--mono);font-size:12px;letter-spacing:.08em;text-transform:uppercase;color:var(--mint)}
table.mines{border-collapse:collapse;margin:14px 0 0;font-family:var(--mono);font-size:14px}
table.mines th,table.mines td{border:1px solid var(--line);padding:8px 14px;text-align:left}
table.mines th{color:var(--mint);font-weight:600;letter-spacing:.06em;text-transform:uppercase;font-size:12px}
table.mines td a{text-decoration:none}
.boards-nav{display:grid;grid-template-columns:repeat(auto-fit,minmax(170px,1fr));gap:10px;list-style:none;padding:0;margin:14px 0 0}
.boards-nav a{display:block;background:var(--panel);border:1px solid var(--line);border-radius:10px;padding:12px 14px;text-decoration:none}
.boards-nav a[aria-current]{border-color:var(--gold)}
.boards-nav b{display:block;color:var(--cream)}
.boards-nav span{font-family:var(--mono);font-size:12px;color:var(--mint)}
"""
    url = "%s/boards/%s/" % (BASE, b["slug"])
    mines_rows = "".join(
        '<tr><th scope="row">%s</th><td>%.1f%%</td><td>%d mines</td><td><a href="../../play/?board=%s&amp;difficulty=%s">Play %s %s ↗</a></td></tr>'
        % (label, 100 * b["mines"][i] / b["cells"], b["mines"][i], b["slug"], key, b["short"], label.lower())
        for i, (key, label) in enumerate(DIFFS))
    boards_nav = "".join(
        '<li><a href="../%s/"%s><b>%s</b><span>%d tiles · %s XP</span></a></li>'
        % (o["slug"], ' aria-current="page"' if o is b else "", o["name"], o["cells"], o["xp"])
        for o in BOARDS)
    ld = {"@context": "https://schema.org", "@graph": [
        {"@type": "BreadcrumbList", "itemListElement": [
            {"@type": "ListItem", "position": 1, "name": "Home", "item": BASE + "/"},
            {"@type": "ListItem", "position": 2, "name": "Strait boards", "item": BASE + "/#boards"},
            {"@type": "ListItem", "position": 3, "name": b["name"], "item": url}]},
        {"@type": "VideoGame", "name": "Minesweeper: Strait of Hormuz – " + b["name"],
         "url": url, "image": BASE + "/assets/board-%s.webp" % b["slug"],
         "description": b["desc"], "genre": ["Puzzle", "Minesweeper"],
         "playMode": "SinglePlayer", "applicationCategory": "Game",
         "gamePlatform": ["Web browser", "iOS", "Android"],
         "author": {"@type": "Organization", "name": "Ticerapps", "url": "https://ticerapps.github.io/"},
         "offers": {"@type": "Offer", "price": "0", "priceCurrency": "USD"}},
        {"@type": "WebPage", "name": b["title"], "url": url, "description": b["desc"],
         "datePublished": "2026-10-13T00:39:47-04:00", "dateModified": DATE, "isPartOf": {"@type": "WebSite", "name": "Minesweeper: Strait of Hormuz", "url": BASE + "/"}},
    ]}
    nxt = b["next"]
    html_out = f"""<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{html.escape(b["title"])}</title>
<meta name="description" content="{html.escape(b["desc"])}">
<link rel="canonical" href="{url}">
<meta name="robots" content="index, follow, max-image-preview:large">
<meta property="og:type" content="website"><meta property="og:site_name" content="Minesweeper: Strait of Hormuz"><meta property="og:title" content="{html.escape(b["title"])}"><meta property="og:description" content="{html.escape(b["desc"])}"><meta property="og:url" content="{url}"><meta property="og:image" content="{BASE}/assets/board-{b["slug"]}.webp">
<meta name="twitter:card" content="summary_large_image">
<link rel="icon" href="../../assets/icon-192.png" type="image/png">
<link rel="preload" as="image" href="../../assets/board-{b["slug"]}.webp" fetchpriority="high">
<link rel="preconnect" href="https://fonts.googleapis.com"><link rel="preconnect" href="https://fonts.gstatic.com" crossorigin><link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Oxanium:wght@600;700&family=IBM+Plex+Sans+Condensed:wght@500;600&family=IBM+Plex+Mono:wght@500;600&display=swap" media="print" onload="this.media='all'"><noscript><link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Oxanium:wght@600;700&family=IBM+Plex+Sans+Condensed:wght@500;600&family=IBM+Plex+Mono:wght@500;600&display=swap"></noscript>
<style>{css}
{frame_css}
{extra}</style>
<meta name="google-adsense-account" content="ca-pub-9806107692884322">
<script defer src="/assets/ads.js"></script>
<script type="application/ld+json">{json.dumps(ld)}</script>
</head>
<body>
<a class="skip" href="#play">Skip to the game</a>
<div class="wrap">
<header class="top">
  <a class="brand" href="../../"><img src="../../assets/icon-192.png" width="40" height="40" alt=""><span><b>Minesweeper: Strait of Hormuz</b><small>by Ticerapps</small></span></a>
  <nav class="nav" aria-label="Site"><a href="../../#play">Play</a><a href="../../#modes">Modes</a><a href="../../how-to-play/">How to play</a><a href="../../strategy/">Strategy</a><a href="../../no-guess-minesweeper/">No-guess</a><a href="../../#get">Get the game</a></nav>
</header>
<main>
<nav class="crumbs" aria-label="Breadcrumb"><a href="../../">Home</a> › <a href="../../#boards">Strait boards</a> › {html.escape(b["name"])}</nav>
<article>
<div class="board-head">
  <div><p class="eyebrow">{html.escape(b["tag"])} · Free in your browser</p><h1>{html.escape(b["h1"])}</h1></div>
</div>
<p class="lead">{html.escape(b["intro"])}</p>
<div class="stats">
  <div><b>{b["cells"]}</b><span>tiles</span></div>
  <div><b>{b["mines"][0]}–{b["mines"][3]}</b><span>mines, Easy to Veteran</span></div>
  <div><b>{b["xp"]}</b><span>XP scale</span></div>
  <div><b>100%</b><span>no-guess layouts</span></div>
</div>

<div class="game" id="play">
  <h2 class="h2-inline">Play {html.escape(b["name"])} online</h2>
  <div class="bracket"><i></i>
    <div class="frame" id="frame">
      <div class="poster" id="poster">
        <h2>{html.escape(b["name"])}</h2>
        <p>The real game, running in your browser. {b["cells"]} tiles, {b["mines"][0]} mines on Easy, first tap always safe. Tap to reveal, hold to flag.</p>
        <button class="play" id="playBtn" type="button">Play now</button>
        <small>Loads about 35 MB the first time. On phones it opens full screen.</small>
      </div>
    </div>
  </div>
  <div class="under">
    <div class="legend"><span><b>Tap</b> reveal</span><span><b>Hold</b> flag</span><span><b>Right-click</b> flag</span><span><b>Tap a number</b> clear its neighbours when the flags add up</span></div>
    <a href="../../play/?board={b["slug"]}" target="_blank" rel="noopener">Open full screen ↗</a>
  </div>
</div>

<h2>The shape of the board</h2>
{"".join("<p>%s</p>" % html.escape(p) for p in b["shape"])}

<h2>Mines by difficulty</h2>
<p>Difficulty sets the mine density. The exact count is fixed per board, so a {html.escape(b["name"])} game on Hard always has {b["mines"][2]} mines. The in-game MENU switches difficulty at any time; the links below open the board at that tier directly.</p>
<table class="mines"><thead><tr><th scope="col">Difficulty</th><th scope="col">Density</th><th scope="col">Mines</th><th scope="col">Link</th></tr></thead><tbody>{mines_rows}</tbody></table>

<h2>How to play {html.escape(b["name"])}</h2>
<ul>{"".join("<li>%s</li>" % html.escape(p) for p in b["play"])}</ul>
<p>Every layout is certified by the <a href="../../no-guess-minesweeper/">no-guess generator</a>, so there is always a logical next move. The <a href="../../strategy/">strategy guide</a> covers the patterns, and <a href="../../how-to-play/">how to play</a> covers the controls.</p>

<h2>The other strait boards</h2>
<ul class="boards-nav">{boards_nav}</ul>
</article>
<section class="related"><h2>Keep reading</h2><ul><li><a href="../{nxt[0]}/"><b>Next board: {html.escape(nxt[1])}</b><span>{html.escape(nxt[2])}</span></a></li><li><a href="../../strategy/"><b>Minesweeper strategy</b><span>The patterns that solve every board.</span></a></li><li><a href="../../#get"><b>Get the full game</b><span>All boards, puzzles and the daily sweep on iOS and Android.</span></a></li></ul></section>
</main>
<footer><div>© 2026 Ticerapps · Minesweeper: Strait of Hormuz</div><nav aria-label="Legal"><a href="../../privacy/">Privacy policy</a><a href="https://ticerapps.github.io/">Support</a><a href="../../">Home</a></nav></footer>
</div>
<script>
(function(){{
  var btn=document.getElementById('playBtn'),frame=document.getElementById('frame'),poster=document.getElementById('poster');
  var q='?board={b["slug"]}'+(/[?&]difficulty=(easy|medium|hard|veteran)/.test(location.search)?'&difficulty='+location.search.match(/difficulty=(easy|medium|hard|veteran)/)[1]:'');
  function start(){{
    if(window.innerWidth<700||window.matchMedia('(pointer: coarse)').matches&&window.innerWidth<900){{location.href='../../play/'+q;return;}}
    if(frame.querySelector('iframe'))return;
    var f=document.createElement('iframe');
    f.src='../../play/index.html'+q;f.title='Minesweeper: Strait of Hormuz, {html.escape(b["name"])}';
    f.setAttribute('allow','fullscreen; autoplay');f.setAttribute('allowfullscreen','');
    frame.appendChild(f);poster.remove();
    try{{frame.scrollIntoView({{block:'center',behavior:'smooth'}})}}catch(e){{}}
  }}
  btn.addEventListener('click',start);
  if(location.hash==='#play-now')start();
}})();
</script>
</body>
</html>
"""
    os.makedirs("boards/%s" % b["slug"], exist_ok=True)
    open("boards/%s/index.html" % b["slug"], "w").write(html_out)
    print("wrote boards/%s/index.html (%d bytes)" % (b["slug"], len(html_out)))


if __name__ == "__main__":
    for b in BOARDS:
        page(b)
    from render_shared import apply_chrome
    apply_chrome()
