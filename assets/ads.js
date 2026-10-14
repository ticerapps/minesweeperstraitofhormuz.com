/* Keep advertising and its consent flow behind the page's initial content load.
 * No fixed multi-second delay and no device/bot-specific behavior. */
(() => {
  'use strict';
  const account=document.querySelector('meta[name="google-adsense-account"]');
  if(!account)return;
  const load=()=>{
    if(document.querySelector('script[data-adsense-runtime]'))return;
    const script=document.createElement('script');
    script.dataset.adsenseRuntime='';
    script.async=true;script.crossOrigin='anonymous';
    script.src='https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client='+encodeURIComponent(account.content);
    document.head.appendChild(script);
  };
  const schedule=()=>requestAnimationFrame(()=>requestAnimationFrame(()=>{
    if('requestIdleCallback' in window)requestIdleCallback(load,{timeout:1000});
    else load();
  }));
  if(document.readyState==='complete')schedule();
  else window.addEventListener('load',schedule,{once:true});
})();
