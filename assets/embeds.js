/* Reserve each embed's layout and reveal it only after its provider is ready. */
(() => {
  'use strict';
  function loadEmbed(shell){
    if(shell.dataset.loaded)return;
    shell.dataset.loaded='true';shell.dataset.state='loading';shell.setAttribute('aria-busy','true');
    const host=shell.querySelector('.embed-live'),placeholder=shell.querySelector('.embed-placeholder');
    let ready=false,scheduled=false,providerObserver=null;
    const unavailable=()=>{if(ready)return;shell.dataset.state='unavailable';shell.classList.add('is-unavailable');shell.setAttribute('aria-busy','false');shell.querySelector('[data-loading-status]').textContent='Preview unavailable';};
    const timeout=setTimeout(unavailable,20000);
    const reveal=()=>{
      if(ready||scheduled)return;scheduled=true;clearTimeout(timeout);
      setTimeout(()=>requestAnimationFrame(()=>requestAnimationFrame(()=>{
        ready=true;clearTimeout(timeout);providerObserver?.disconnect();
        shell.dataset.state='ready';shell.classList.remove('is-unavailable');shell.classList.add('is-ready');shell.setAttribute('aria-busy','false');
        host.inert=false;host.removeAttribute('aria-hidden');placeholder.inert=true;placeholder.setAttribute('aria-hidden','true');
      })),180);
    };
    const kind=shell.dataset.autoEmbed;
    if(kind==='itch'||kind==='youtube'){
      const frame=document.createElement('iframe');
      frame.title=kind==='itch'?'Get Minesweeper: Strait of Hormuz on itch.io':'Minesweeper: Strait of Hormuz on YouTube';
      frame.addEventListener('load',reveal,{once:true});frame.addEventListener('error',unavailable,{once:true});
      frame.src=kind==='itch'?shell.dataset.src:'https://www.youtube-nocookie.com/embed/b3fSf2jTIck?rel=0&playsinline=1';
      if(kind==='youtube'){frame.allow='accelerometer; encrypted-media; gyroscope; picture-in-picture; fullscreen';frame.allowFullscreen=true;frame.referrerPolicy='strict-origin-when-cross-origin';}
      host.appendChild(frame);return;
    }
    let player=null,frameLoaded=false;
    const check=()=>{
      const frame=host.querySelector('iframe');if(!frame)return;
      if(frame!==player){player=frame;frameLoaded=false;frame.title='Ticerapps TikTok profile';frame.addEventListener('load',()=>{frameLoaded=true;check();},{once:true});frame.addEventListener('error',unavailable,{once:true});}
      // TikTok reveals and sizes its frame after the profile renders. Keep
      // our card until both the document and that provider-controlled state are ready.
      if(frameLoaded&&parseFloat(frame.style.height)>=200&&frame.style.visibility!=='hidden'&&frame.style.visibility!=='')reveal();
    };
    providerObserver=new MutationObserver(check);providerObserver.observe(host,{childList:true,subtree:true,attributes:true,attributeFilter:['style','height']});
    const quote=document.createElement('blockquote');quote.className='tiktok-embed';quote.cite='https://www.tiktok.com/@ticerapps_dev';quote.dataset.uniqueId='ticerapps_dev';quote.dataset.embedType='creator';quote.dataset.embedFrom='oembed';quote.style.cssText='max-width:720px;min-width:288px;';
    const section=document.createElement('section'),link=document.createElement('a');link.href=quote.cite;link.textContent='@ticerapps_dev on TikTok';link.target='_blank';link.rel='noopener';section.appendChild(link);quote.appendChild(section);host.appendChild(quote);
    const script=document.createElement('script');script.src='https://www.tiktok.com/embed.js';script.async=true;script.onerror=unavailable;document.body.appendChild(script);
  }
  const embeds=document.querySelectorAll('[data-auto-embed]');
  if('IntersectionObserver' in window){const observer=new IntersectionObserver(entries=>entries.forEach(entry=>{if(entry.isIntersecting){observer.unobserve(entry.target);loadEmbed(entry.target);}}),{rootMargin:'600px 0px'});embeds.forEach(el=>observer.observe(el));}else embeds.forEach(loadEmbed);
})();
