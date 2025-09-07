(function(){
  // Set current time in KST
  function formatKST(){
    try{
      const now = new Date();
      // Convert to KST without external libs: KST = UTC+9
      const utc = now.getTime() + (now.getTimezoneOffset()*60000);
      const kst = new Date(utc + 9*3600*1000);
      const y = kst.getFullYear();
      const m = ('0'+(kst.getMonth()+1)).slice(-2);
      const d = ('0'+kst.getDate()).slice(-2);
      const w = ['일','월','화','수','목','금','토'][kst.getDay()];
      const hh=('0'+kst.getHours()).slice(-2);
      const mm=('0'+kst.getMinutes()).slice(-2);
      return y+'-'+m+'-'+d+' ('+w+') '+hh+':'+mm+' KST';
    }catch(e){ return ''; }
  }
  var nowEl = document.getElementById('nh-now');
  if(nowEl){ nowEl.textContent = formatKST(); setInterval(function(){ nowEl.textContent = formatKST(); }, 60000); }

  // Mega behavior
  var nav = document.getElementById('nh-primary');
  var mega = document.querySelector('.nh-mega');
  var buttons = document.querySelectorAll('.nh-nav__btn');
  var burger = document.getElementById('nh-burger');

  function openMega(id){
    if(!mega) return;
    mega.classList.add('is-open');
    document.querySelectorAll('.nh-mega__row').forEach(function(r){ r.classList.remove('is-active'); });
    var row = document.getElementById(id);
    if(row){ row.classList.add('is-active'); }
  }
  function closeMega(){
    if(!mega) return;
    mega.classList.remove('is-open');
    document.querySelectorAll('.nh-mega__row').forEach(function(r){ r.classList.remove('is-active'); });
  }
  // Hover (desktop) & click (mobile)
  buttons.forEach(function(btn){
    var target = btn.getAttribute('data-target');
    btn.addEventListener('mouseenter', function(){ if(window.matchMedia('(hover:hover)').matches){ openMega(target); }});
    btn.addEventListener('focus', function(){ openMega(target); });
    btn.addEventListener('click', function(e){
      // toggle on mobile
      e.preventDefault();
      if(mega.classList.contains('is-open')){
        // if same section -> close
        var row = document.getElementById(target);
        if(row && row.classList.contains('is-active')){ closeMega(); }
        else { openMega(target); }
      }else{
        openMega(target);
      }
    });
  });
  // Close mega when leaving nav area (desktop)
  if(nav){
    nav.addEventListener('mouseleave', function(){ if(window.matchMedia('(hover:hover)').matches){ closeMega(); }});
  }
  // Close on ESC
  document.addEventListener('keydown', function(e){ if(e.key === 'Escape'){ closeMega(); }});

  // Burger toggle primary nav visibility (for very small screens you might hide/show nav; here we keep it simple)
  if(burger && nav){
    burger.addEventListener('click', function(){
      var expanded = this.getAttribute('aria-expanded') === 'true';
      this.setAttribute('aria-expanded', String(!expanded));
      nav.classList.toggle('is-open'); // optional hook if you want to add CSS transitions
    });
  }
})();