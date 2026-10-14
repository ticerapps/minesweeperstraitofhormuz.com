/* Navigation and educational examples work without external services. */
(() => {
  'use strict';
  document.documentElement.classList.add('js');
  const toggle = document.querySelector('.menu-toggle');
  const nav = document.getElementById('site-nav');
  const closeMenu = () => { if (!toggle || !nav) return; nav.classList.remove('is-open'); toggle.setAttribute('aria-expanded','false'); };
  if (toggle && nav) {
    toggle.addEventListener('click', () => { const open = toggle.getAttribute('aria-expanded') !== 'true'; nav.classList.toggle('is-open',open); toggle.setAttribute('aria-expanded',String(open)); });
    nav.addEventListener('click', e => { if (e.target.closest('a')) closeMenu(); });
    document.addEventListener('keydown', e => { if (e.key === 'Escape' && toggle.getAttribute('aria-expanded') === 'true') { closeMenu(); toggle.focus(); } });
  }
  const showBoard = (board, show) => {
    board.classList.toggle('show-answer',show);
    board.querySelectorAll('[data-original-label]').forEach(cell => {
      cell.setAttribute('aria-label',show && cell.classList.contains('answer-safe') ? 'Proven safe' : show && cell.classList.contains('answer-mine') ? 'Proven mine' : cell.dataset.originalLabel);
    });
  };
  document.querySelectorAll('[data-answer]').forEach(button => {
    button.addEventListener('click',() => {
      const board=document.getElementById(button.dataset.answer);
      const show=button.getAttribute('aria-expanded') !== 'true';
      showBoard(board,show);
      if(!board.querySelector('.answer-marked'))board.closest('.pattern-card').querySelector('details').open=show;
      button.setAttribute('aria-expanded',String(show));
      button.textContent=show?'Hide solution':'Show solution';
    });
  });
  const quiz=document.getElementById('quiz-board');
  if (quiz) {
    const feedback=document.getElementById('quiz-feedback'), reset=document.querySelector('[data-quiz-reset]');
    quiz.querySelectorAll('button').forEach(button=>button.addEventListener('click',()=>{
      if (button.dataset.quizAnswer==='safe') {
        showBoard(quiz,true); feedback.textContent='Exactly. The 2 needs both outer tiles to be mines. The middle is safe.';
        quiz.querySelectorAll('button').forEach(b=>{b.disabled=true;});reset.hidden=false;
      } else feedback.textContent='That outer tile must be a mine. The two 1s limit the 2. Try another tile.';
    }));
    reset.addEventListener('click',()=>{ showBoard(quiz,false);quiz.querySelectorAll('button').forEach(b=>{b.disabled=false;});feedback.textContent='Tap one of the three hidden tiles.';reset.hidden=true;quiz.querySelector('button').focus(); });
  }
  const youtubeButton=document.querySelector('[data-load-youtube]');
  if(youtubeButton)youtubeButton.addEventListener('click',()=>{
    const frame=document.createElement('iframe');frame.src='https://www.youtube-nocookie.com/embed/b3fSf2jTIck?rel=0';frame.title='Minesweeper: Strait of Hormuz on YouTube';frame.allow='accelerometer; encrypted-media; gyroscope; picture-in-picture; fullscreen';frame.allowFullscreen=true;frame.referrerPolicy='strict-origin-when-cross-origin';document.getElementById('youtube-slot').replaceChildren(frame);
  },{once:true});
  const embedButton=document.querySelector('[data-load-tiktok]');
  if (embedButton) embedButton.addEventListener('click',()=>{
    embedButton.disabled=true;embedButton.textContent='Loading TikTok…';
    const slot=document.getElementById('tiktok-slot');
    const quote=document.createElement('blockquote');quote.className='tiktok-embed';quote.cite='https://www.tiktok.com/@ticerapps_dev';quote.dataset.uniqueId='ticerapps_dev';quote.dataset.embedType='creator';quote.dataset.embedFrom='oembed';quote.style.cssText='max-width:720px;min-width:288px;';
    const section=document.createElement('section'), link=document.createElement('a');link.href=quote.cite;link.textContent='@ticerapps_dev on TikTok';link.target='_blank';link.rel='noopener';section.appendChild(link);quote.appendChild(section);slot.appendChild(quote);
    const script=document.createElement('script');script.src='https://www.tiktok.com/embed.js';script.async=true;
    script.onload=()=>{embedButton.hidden=true;};script.onerror=()=>{embedButton.textContent='Preview unavailable. Use the TikTok link below.';};document.body.appendChild(script);
    setTimeout(()=>{if(!slot.querySelector('iframe')){embedButton.hidden=false;embedButton.textContent='Preview unavailable. Use the TikTok link below.';}},12000);
  },{once:true});
  // Google exposes this control only when an AdSense privacy message applies.
  window.googlefc=window.googlefc||{};window.googlefc.callbackQueue=window.googlefc.callbackQueue||[];
  window.googlefc.callbackQueue.push({CONSENT_DATA_READY:()=>{
    if(typeof window.googlefc.showRevocationMessage==='function') document.querySelectorAll('[data-ad-choices]').forEach(b=>{b.hidden=false;b.addEventListener('click',()=>window.googlefc.showRevocationMessage());});
  }});
})();
