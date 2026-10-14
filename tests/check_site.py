"""Run with python3 tests/check_site.py. No third-party dependencies."""
from pathlib import Path
from html.parser import HTMLParser
from urllib.parse import urljoin, urlparse, unquote
import json, re, sys
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'tools'))
from patterns import verify
class Page(HTMLParser):
 def __init__(self,text):
  super().__init__(); self.ids=[]; self.links=[]; self.headings=0; self.canonical=[];self.feed(text)
 def handle_starttag(self,tag,attrs):
  a=dict(attrs)
  if 'id' in a:self.ids.append(a['id'])
  if tag=='h1':self.headings+=1
  if tag=='a' and a.get('href'):self.links.append(a['href'])
  if tag=='link' and a.get('rel')=='canonical':self.canonical.append(a.get('href'))
verify()
files=[ROOT/'index.html',ROOT/'privacy/index.html',ROOT/'strategy/index.html',ROOT/'how-to-play/index.html',ROOT/'no-guess-minesweeper/index.html',*ROOT.glob('boards/*/index.html')]
pages={p:Page(p.read_text()) for p in files}
errors=[]
for p,page in pages.items():
 rel=p.relative_to(ROOT);url='https://minesweeperstraitofhormuz.com/'+str(rel).replace('index.html','')
 if len(page.ids)!=len(set(page.ids)):errors.append(f'{rel}: duplicate id')
 if page.headings!=1:errors.append(f'{rel}: expected one h1')
 if page.canonical!=[url]:errors.append(f'{rel}: canonical mismatch {page.canonical}')
 for schema in re.findall(r'<script type="application/ld\+json">(.*?)</script>',p.read_text(),re.S):json.loads(schema)
 for link in page.links:
  target=urlparse(urljoin(url,link))
  if target.netloc!='minesweeperstraitofhormuz.com':continue
  local=ROOT/unquote(target.path.lstrip('/'))
  if local.is_dir():local=local/'index.html'
  if not local.exists():errors.append(f'{rel}: missing link {link}')
  elif target.fragment and local in pages and target.fragment not in pages[local].ids:errors.append(f'{rel}: missing anchor {link}')
 for src in re.findall(r'(?:src|href)="(/assets/[^"?#]+)',p.read_text()):
  if not (ROOT/src.lstrip('/')).exists():errors.append(f'{rel}: missing asset {src}')
 assert 'apps.apple.com/app/id6795665498' not in p.read_text(), rel
 assert '/assets/analytics.js' in p.read_text(), rel
assert 'name="robots" content="noindex, follow"' in (ROOT/'play/index.html').read_text()
assert '/play/' not in (ROOT/'sitemap.xml').read_text()
assert 'adsbygoogle.js' not in (ROOT/'privacy/index.html').read_text()
if errors:print('\n'.join(errors));sys.exit(1)
print(f'PASS: {len(files)} pages, local links/anchors/assets, structured data, availability, sitemap, and 12 exhaustive puzzle proofs')
