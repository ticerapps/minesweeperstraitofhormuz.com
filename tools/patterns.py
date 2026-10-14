"""Original teaching examples. Verify each forced move by enumerating all layouts."""
from itertools import product

# # = outside the example; ? = hidden; F = a proven mine. All hidden neighbours
# of the numbered clues are shown. Totals are used only when explicitly labelled.
PATTERNS = [
    dict(id="all-mines", title="All remaining tiles are mines", group="Start here", board=["2#", "??"], mines=[2,3], safe=[], text="The 2 needs two mines and has only two hidden neighbours. Both must be mines."),
    dict(id="satisfied", title="The satisfied number", group="Start here", board=["1F", "??"], mines=[], safe=[2,3], text="The proven flag already accounts for the 1. Its other neighbours are safe. A wrong flag breaks this deduction."),
    dict(id="one-one", title="1–1 on an edge", group="Edge patterns", board=["???", "11#"], mines=[], safe=[2], text="Both 1s share the same mine. The extra tile seen only by the right 1 is safe."),
    dict(id="one-two", title="1–2 on an edge", group="Edge patterns", board=["???", "12#"], mines=[2], safe=[], text="The shared pair contains one mine. The 2 needs one more, so its extra tile is a mine."),
    dict(id="one-two-one", title="1–2–1", group="Edge patterns", board=["???", "121"], mines=[0,2], safe=[1], text="The two outer tiles are mines. The middle tile is safe. Match the hidden neighbours, not just the three numbers."),
    dict(id="one-two-two-one", title="1–2–2–1", group="Edge patterns", board=["????", "1221"], mines=[1,2], safe=[0,3], text="The two middle tiles are mines. The outside tiles are safe. This is the 1–2 deduction applied from both ends."),
    dict(id="one-one-plus", title="1–1+ / a small hole", group="Beyond a straight edge", board=["???", "?1?", "#1#"], mines=[], safe=[0,1,2], text="The lower 1 pins one mine to the side pair. That also satisfies the upper 1, clearing all three extra tiles."),
    dict(id="one-two-plus", title="1–2+ / extra mines", group="Beyond a straight edge", board=["???", "?4?", "#1#"], mines=[0,1,2], safe=[], text="The side pair holds one mine. The 4 still needs three, so every tile in the top row is a mine."),
    dict(id="reduction", title="Reduce 2–3–2 to 1–2–1", group="Use your flags", board=["???", "232", "#F#"], mines=[0,2], safe=[1], text="Subtract the proven flag from every number it touches. The remaining counts are 1–2–1, with the same safe middle tile."),
    dict(id="corner", title="1–3–1 corner", group="Beyond a straight edge", board=["#1?", "13?", "???"], mines=[8], safe=[], text="Each 1 allows one mine in its pair. Together those pairs supply only two of the 3’s mines. The far corner must hold the third."),
    dict(id="counting", title="Use the whole-board count", group="Endgame", board=["????", "#1##"], mines=[], safe=[3], total=1, text="Exactly one mine remains in this entire example. The 1 accounts for it in its three neighbours, so the far-right tile is safe. Verify every flag before trusting the counter."),
    dict(id="fifty-fifty", title="Recognise a real 50/50", group="Endgame", board=["??", "11"], mines=[], safe=[], text="Either hidden tile can hold the mine. These clues alone do not choose one. Look elsewhere for more information; do not label either tile safe."),
]

def solutions(p):
    width = len(p["board"][0]); cells = "".join(p["board"])
    unknown = [i for i,c in enumerate(cells) if c == "?"]
    flags = {i for i,c in enumerate(cells) if c == "F"}
    adjacent = lambda a,b: a != b and max(abs(a%width-b%width), abs(a//width-b//width)) <= 1
    valid = []
    for bits in product((0,1), repeat=len(unknown)):
        mines = flags | {i for i,b in zip(unknown,bits) if b}
        if "total" in p and len(mines) != p["total"]: continue
        if all(sum(adjacent(i,m) for m in mines) == int(c) for i,c in enumerate(cells) if c.isdigit()): valid.append(mines)
    return unknown, valid

def verify():
    for p in PATTERNS:
        assert len({len(row) for row in p["board"]}) == 1, p["id"]
        unknown, valid = solutions(p)
        assert valid, f'{p["id"]}: impossible board'
        forced_mines = {i for i in unknown if all(i in s for s in valid)}
        forced_safe = {i for i in unknown if all(i not in s for s in valid)}
        assert forced_mines == set(p["mines"]), (p["id"], forced_mines)
        assert forced_safe == set(p["safe"]), (p["id"], forced_safe)
    return len(PATTERNS)

if __name__ == "__main__": print(f"Verified {verify()} patterns against every possible mine placement.")
