/* Basic consent mode: the Analytics tag is not loaded until permission is given.
 * AdSense manages its own consent separately. No gameplay/account data is sent. */
(() => {
  'use strict';
  const ID='G-T2V0T6R4H6', KEY='hormuz-analytics-choice-v1';
  const live=location.hostname==='minesweeperstraitofhormuz.com';
  const privacySignal=navigator.globalPrivacyControl===true || navigator.doNotTrack==='1';
  const choices=document.querySelectorAll('[data-analytics-settings]');
  let accepted=false, initialized=false, saved=null;
  try {saved=JSON.parse(localStorage.getItem(KEY));} catch (_) {}
  if(saved && (!saved.at || Date.now()-saved.at>180*86400000)) saved=null;
  const cleanReferrer=()=>{try {return new URL(document.referrer).origin+'/';}catch(_){return '';}};
  const send=function(){(window.dataLayer=window.dataLayer||[]).push(arguments);};
  const start=()=>{
    accepted=true;
    if(!live) return;
    window['ga-disable-'+ID]=false;
    if(initialized){send('consent','update',{analytics_storage:'granted'});return;}
    initialized=true;
    send('consent','default',{analytics_storage:'denied',ad_storage:'denied',ad_user_data:'denied',ad_personalization:'denied'});
    send('consent','update',{analytics_storage:'granted'});
    send('js',new Date());
    send('config',ID,{send_page_view:false,allow_google_signals:false,allow_ad_personalization_signals:false,cookie_expires:60*86400,cookie_update:false,page_location:location.origin+location.pathname,page_referrer:cleanReferrer()});
    send('event','page_view',{page_location:location.origin+location.pathname,page_referrer:cleanReferrer(),page_title:document.title});
    const script=document.createElement('script');script.async=true;script.src='https://www.googletagmanager.com/gtag/js?id='+ID;script.dataset.analyticsTag='';document.head.appendChild(script);
  };
  const stop=()=>{
    accepted=false;window['ga-disable-'+ID]=true;
    if(initialized) send('consent','update',{analytics_storage:'denied'});
    for(const cookie of document.cookie.split(';')) {
      const name=cookie.split('=')[0].trim();if(!/^_ga(?:_|$)/.test(name))continue;
      for(const domain of ['',location.hostname,'.'+location.hostname]) document.cookie=name+'=; Max-Age=0; Path=/; SameSite=Lax'+(domain?'; Domain='+domain:'');
    }
  };
  const banner=document.createElement('section');banner.className='analytics-choice';banner.hidden=true;banner.setAttribute('aria-label','Optional website analytics');
  banner.innerHTML='<div><strong>Help improve the site?</strong><p>Allow Google Analytics to count visits and game-download clicks. <a href="/privacy/#website-analytics">Privacy details</a></p></div><div class="analytics-actions"><button type="button" data-consent="no">No thanks</button><button type="button" data-consent="yes">Allow analytics</button></div>';
  document.body.appendChild(banner);
  const apply=value=>{
    try{localStorage.setItem(KEY,JSON.stringify({allowed:value,at:Date.now()}));}catch(_){}
    if(value&&!privacySignal)start();else stop();banner.hidden=true;
  };
  banner.querySelectorAll('[data-consent]').forEach(b=>b.addEventListener('click',()=>apply(b.dataset.consent==='yes')));
  choices.forEach(b=>{b.hidden=false;b.addEventListener('click',()=>{banner.hidden=false;banner.querySelector('button').focus();});});
  if(privacySignal){
    banner.querySelector('p').textContent='Your browser requests privacy protection. Website analytics stays off.';
    banner.querySelector('[data-consent="yes"]').hidden=true;banner.querySelector('[data-consent="no"]').textContent='Close';stop();
  }else if(saved){if(saved.allowed)start();else stop();}else banner.hidden=false;
  document.addEventListener('click',event=>{
    if(!accepted||!live)return;
    const link=event.target.closest('a[data-destination]');
    if(link && ['google_play','itch'].includes(link.dataset.destination))send('event','store_click',{store:link.dataset.destination,page_path:location.pathname});
    const play=event.target.closest('#playBtn');if(play)send('event','demo_start',{page_path:location.pathname});
  });
})();
