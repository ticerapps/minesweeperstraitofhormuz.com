"""Small, progressively enhanced lessons using the solver-verified patterns."""
from patterns import PATTERNS


def render_practice():
    chord = next(p for p in PATTERNS if p['id'] == 'one-two-one')
    reduction = next(p for p in PATTERNS if p['id'] == 'reduction')
    chord_cells = []
    for i, c in enumerate(''.join(chord['board'])):
        if c == '?':
            position = ('Left', 'Middle', 'Right')[i]
            chord_cells.append(f'<button type="button" class="pattern-cell covered" data-flag="{i}" data-position="{position}" data-mine="{str(i in chord["mines"]).lower()}" aria-label="{position} hidden tile: toggle flag" aria-pressed="false" disabled>?</button>')
        elif i == 4:
            chord_cells.append('<button type="button" class="pattern-cell clue n2 chord-target" data-chord aria-label="Chord the 2: open unflagged neighbours" disabled>2</button>')
        else:
            chord_cells.append(f'<span role="img" class="pattern-cell clue n{c}" aria-label="{c} adjacent mine">{c}</span>')
    reduction_cells = []
    for i, c in enumerate(''.join(reduction['board'])):
        if c == '?':
            label = ('Left', 'Middle', 'Right')[i] + ' hidden tile'
            reduction_cells.append(f'<span role="img" class="pattern-cell covered" data-result="{"mine" if i in reduction["mines"] else "safe"}" data-label="{label}" aria-label="{label}">?</span>')
        elif c.isdigit():
            reduction_cells.append(f'<span role="img" class="pattern-cell clue n{c}" data-clue="{c}" aria-label="{c} adjacent mines">{c}</span>')
        elif c == 'F':
            reduction_cells.append('<span role="img" class="pattern-cell flag" aria-label="Previously proven mine">⚑</span>')
        else:
            reduction_cells.append('<span role="img" class="pattern-cell outside" aria-label="Outside this example"></span>')
    return '''<div class="practice-lessons">
<section class="practice-card" id="chord-practice" aria-labelledby="chord-heading">
  <div class="lesson-copy"><p class="guide-kicker">Try it / chording</p><h2 id="chord-heading">One tap. Every safe neighbour.</h2>
  <p>Chording opens the unflagged tiles around a number when its adjacent flags match that number. <strong>Prove the mines first:</strong> matching the count does not make a misplaced flag safe.</p>
  <p>Read this 1–2–1 edge. In this trainer, tap a hidden tile to place or remove a flag, then tap the outlined <strong>2</strong> to chord. No timer, no saved score.</p>
  <details class="lesson-solution"><summary>Explain the solution</summary><p>The two outer tiles must be mines; the middle is safe. Flag the left and right tiles, then tap the 2. It opens the middle tile, which also reads 2 because it touches both mines. In the full game, hold or right-click to flag; tap a satisfied number to chord.</p></details></div>
  <div class="lesson-demo"><div class="lesson-meter" data-flag-count>0 / 2 flags</div>
  <div class="pattern-board practice-board" style="--cols:3" role="group" aria-label="Chording practice: three hidden tiles above a 1, 2, 1 edge">''' + ''.join(chord_cells) + '''</div>
  <p class="lesson-feedback" data-chord-feedback role="status" aria-live="polite" aria-atomic="true">Place flags on the two tiles you can prove are mines.</p>
  <button type="button" class="lesson-button" data-chord-reset disabled>Reset practice</button>
  <noscript><p>Enable JavaScript to try the buttons, or open “Explain the solution” to follow the same moves.</p></noscript></div>
</section>
<section class="practice-card" id="flag-reduction" aria-labelledby="reduction-heading">
  <div class="lesson-copy"><p class="guide-kicker">Worked example / reduction</p><h2 id="reduction-heading">A 2–3–2 hiding a 1–2–1.</h2>
  <p>A known flag does some of the counting for you. Subtract it from <em>every</em> clue it touches, including diagonally, to find how many mines are still unaccounted for.</p>
  <ol class="reduction-steps">
    <li><strong>Start with a proven flag.</strong> The bottom flag is already known to be a mine. It touches all three clues.</li>
    <li><strong>Subtract one from each clue.</strong> 2 − 1 = 1, 3 − 1 = 2, 2 − 1 = 1. You now need 1–2–1 mines in the hidden row.</li>
    <li><strong>Read the remaining pattern.</strong> Each outer 1 allows only one mine in its pair. To satisfy the middle 2 as well, the two outer tiles must be mines.</li>
    <li><strong>Flag the outside. Open the middle.</strong> The centre tile is safe. The real board numbers stay 2–3–2; the smaller numbers are your mental calculation.</li>
  </ol></div>
  <div class="lesson-demo"><div class="lesson-meter" data-reduction-count>Step 1 / 4</div>
  <div class="pattern-board practice-board" style="--cols:3" role="group" aria-label="Flag reduction: three hidden tiles over 2, 3, 2 with a proven flag below the middle">''' + ''.join(reduction_cells) + '''</div>
  <p class="lesson-caption" data-reduction-caption>Original board clues</p>
  <p class="lesson-feedback" data-reduction-feedback role="status" aria-live="polite" aria-atomic="true">The bottom flag touches all three numbers. It already accounts for one mine in each.</p>
  <div class="lesson-controls"><button type="button" class="lesson-button" data-reduction-next disabled>Subtract the flag →</button><button type="button" class="text-button" data-reduction-reset disabled>Start over</button></div>
  <noscript><p>The four steps beside this board contain the complete solution. No JavaScript is needed to read them.</p></noscript></div>
</section>
<div class="practice-cta"><p>Ready to use it on a real board?</p><a class="action-primary" href="/#frame">Try the free browser game <span aria-hidden="true">→</span></a><a href="#all-mines">Explore all 12 patterns ↓</a></div>
</div>'''
