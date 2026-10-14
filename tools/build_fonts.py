"""Subset the web game's OFL fonts for the website. Needs fonttools + brotli.
Run from site: python3 tools/build_fonts.py
"""
from fontTools.ttLib import TTFont
from fontTools import subset
from pathlib import Path
import shutil
root=Path(__file__).resolve().parents[2]
out=root/'site/assets/fonts'
out.mkdir(exist_ok=True)
for name,family,style,output in [('Oxanium-SemiBold','Hormuz Web Display','SemiBold','display'),('IBMPlexSansCondensed-Medium','Hormuz Web Sans','Medium','body-medium'),('IBMPlexSansCondensed-SemiBold','Hormuz Web Sans','SemiBold','body-semibold'),('IBMPlexMono-SemiBold','Hormuz Web Mono','SemiBold','mono')]:
    font=TTFont(root/'assets/fonts'/f'{name}.ttf')
    options=subset.Options()
    options.flavor='woff2'
    sub=subset.Subsetter(options)
    sub.populate(unicodes=list(range(0x20,0x100))+list(range(0x2000,0x2070)))
    sub.subset(font)
    # Rename modified subsets; preserve copyright and OFL records.
    for record in font['name'].names:
        replacements={1:family,2:style,3:family+' '+style+' subset 2026-10-14',4:family+' '+style,6:family.replace(' ','')+'-'+style,16:family,17:style}
        if record.nameID in replacements:record.string=replacements[record.nameID].encode(record.getEncoding())
    font.flavor='woff2'
    font.save(out/f'hormuz-{output}.woff2')
for name in ['IBM-Plex-OFL.txt','Oxanium-OFL.txt']:
    shutil.copy2(root/'assets/fonts/licenses'/name,out/name)
for p in out.iterdir():print(p.name,p.stat().st_size)
