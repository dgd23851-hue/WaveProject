// Write Article Form — clean & instrumented (v5)
(function(){
  'use strict';

  function log(){ try{ console.log.apply(console, arguments); }catch(e){} }

  var root = document.querySelector('.wa2-main');
  if(!root){ log('[form] .wa2-main not found'); return; }
  var form = root.querySelector('#wa2-form');
  if(!form){ log('[form] #wa2-form not found'); return; }

  // Elements
  var title = form.querySelector('#title');
  var titleCount = form.querySelector('#titleCount');
  var catSel = form.querySelector('#cat');
  var subSel = form.querySelector('#sub');
  var fileInput = form.querySelector('#image');
  var drop = root.querySelector('#dropzone');
  var cards = root.querySelector('#cards');
  var toast = root.querySelector('#toast');
  var btnChoose = root.querySelector('#btnChoose');
  var btnPreview = root.querySelector('#btnPreview');
  var btnSaveDraft = root.querySelector('#btnSaveDraft');
  var modal = root.querySelector('#previewModal');
  var modalCloseBtns = modal ? modal.querySelectorAll('[data-close]') : [];

  log('[form] script loaded');

  // Subcategory map (if elements missing, skip quietly)
  var SUBS = {
    politics: [{v:'election',t:'선거'},{v:'assembly',t:'국회'},{v:'bluehouse',t:'정부/청와대'}],
    economy:  [{v:'market',t:'증시'},{v:'macro',t:'거시'},{v:'industry',t:'산업'}],
    society:  [{v:'incident',t:'사건사고'},{v:'welfare',t:'복지/노동'},{v:'education',t:'교육'}],
    culture:  [{v:'movie',t:'영화'},{v:'music',t:'음악'},{v:'book',t:'책'}],
    world:    [{v:'usa',t:'미국'},{v:'china',t:'중국'},{v:'europe',t:'유럽'},{v:'meafrica',t:'중동/아프리카'}],
    sports:   [{v:'football',t:'축구'},{v:'baseball',t:'야구'},{v:'esports',t:'e스포츠'}],
    tech:     [{v:'ai',t:'AI'},{v:'mobile',t:'모바일'},{v:'science',t:'과학'}]
  };
  var initialSub = subSel && subSel.getAttribute('data-initial') || '';

  function renderSubs(cat, current){
    if(!subSel || !cat || !SUBS[cat]) return;
    subSel.innerHTML = '<option value="">-</option>';
    SUBS[cat].forEach(function(o){
      var opt = document.createElement('option');
      opt.value = o.v; opt.textContent = o.t;
      if(current && current === o.v) opt.selected = true;
      subSel.appendChild(opt);
    });
  }
  if (catSel) {
    renderSubs(catSel.value, initialSub);
    catSel.addEventListener('change', function(){ renderSubs(catSel.value, ''); });
  }

  // Title counter
  function updateCounter(){
    if(!title || !titleCount) return;
    titleCount.textContent = (title.value.length) + '/150';
  }
  if (title) {
    title.addEventListener('input', updateCounter);
    updateCounter();
  }

  // File choose
  if(btnChoose && fileInput){
    btnChoose.addEventListener('click', function(){ fileInput.click(); });
  }

  // Drag & drop preview
  if (drop && fileInput){
    ['dragenter','dragover'].forEach(function(ev){
      drop.addEventListener(ev, function(e){ e.preventDefault(); drop.classList.add('is-drag'); });
    });
    ['dragleave','drop'].forEach(function(ev){
      drop.addEventListener(ev, function(e){ e.preventDefault(); drop.classList.remove('is-drag'); });
    });
    drop.addEventListener('drop', function(e){
      var file = e.dataTransfer && e.dataTransfer.files && e.dataTransfer.files[0];
      if(file){ fileInput.files = e.dataTransfer.files; renderCard(file); }
    });
  }
  if (fileInput){
    fileInput.addEventListener('change', function(){
      var file = fileInput.files && fileInput.files[0];
      if(file) renderCard(file);
    });
  }

  function renderCard(file){
    try{
      if(!cards || !file || !file.type || file.type.indexOf('image/') !== 0) return;
      var url = (window.URL || window.webkitURL).createObjectURL(file);
      cards.innerHTML = '';
      var card = document.createElement('div');
      card.className = 'wa2-card';
      var img = document.createElement('img');
      img.src = url; img.alt = file.name || 'image';
      var foot = document.createElement('div');
      foot.className = 'wa2-card__foot';
      var name = document.createElement('span');
      name.className = 'wa2-card__name'; name.textContent = file.name || '';
      var size = document.createElement('span');
      size.className = 'wa2-card__size'; size.textContent = humanSize(file.size || 0);
      foot.appendChild(name); foot.appendChild(size);
      card.appendChild(img); card.appendChild(foot);
      cards.innerHTML = ''; cards.appendChild(card);
    }catch(e){ log('[preview] error', e); }
  }

  function humanSize(bytes){
    var KB=1024, MB=KB*1024;
    if(bytes < KB) return bytes + ' B';
    if(bytes < MB) return (bytes/KB).toFixed(0) + ' KB';
    return (bytes/MB).toFixed(1) + ' MB';
  }

  function showToast(msg){
    if(!toast) { log('[toast]', msg); return; }
    toast.textContent = msg;
    toast.classList.add('is-show');
    setTimeout(function(){ toast.classList.remove('is-show'); }, 1200);
  }

  // Preview modal (optional)
  function openPreview(){
    if(!modal) return;
    modal.classList.add('is-open');
    var pvTitle = modal.querySelector('.pv-title');
    if (pvTitle) pvTitle.textContent = title && title.value ? title.value : '(제목 없음)';
    var meta = modal.querySelector('.pv-meta');
    if (meta && catSel){
      var catText = catSel.options && catSel.selectedIndex >= 0 ? catSel.options[catSel.selectedIndex].text : '';
      var subText = '';
      if (subSel && subSel.value){
        var sel = subSel.options && subSel.selectedIndex >= 0 ? subSel.options[subSel.selectedIndex].text : '';
        subText = sel ? (' · ' + sel) : '';
      }
      meta.textContent = (catText || '') + subText;
    }
    var pvFig = modal.querySelector('.pv-figure');
    var pvImg = pvFig ? pvFig.querySelector('img') : null;
    var cardImg = cards ? cards.querySelector('img') : null;
    if(pvFig && pvImg){
      if(cardImg){ pvImg.src = cardImg.src; pvFig.classList.remove('is-hidden'); }
      else { pvImg.src = ''; pvFig.classList.add('is-hidden'); }
    }
    var pvContent = modal.querySelector('.pv-content');
    var c = form.querySelector('#content');
    if (pvContent && c) pvContent.textContent = c.value;
  }
  if (btnPreview) btnPreview.addEventListener('click', openPreview);
  if (modal){
    Array.prototype.forEach.call(modalCloseBtns, function(b){
      b.addEventListener('click', function(){ modal.classList.remove('is-open'); });
    });
    modal.addEventListener('click', function(e){
      if(e.target === modal){ modal.classList.remove('is-open'); }
    });
  }

  // ===== Server draft save =====
  function saveDraftServer(){
    try{
      var fd = new FormData(form); // includes hidden inputs / CSRF
      // ensure file named 'imageFile'
      if (fileInput && fileInput.files && fileInput.files[0]) {
        fd.set('imageFile', fileInput.files[0]);
      }
      var url = form.getAttribute('data-save-draft-url') ||
                (form.getAttribute('action') ? form.getAttribute('action').replace('/addNewArticle.do','/saveDraft.do') : '/board/saveDraft.do');
      log('[draft] POST', url);
      return fetch(url, { method:'POST', body:fd, credentials:'same-origin' })
        .then(function(resp){
          log('[draft] status', resp.status);
          if(!resp.ok) throw new Error('HTTP '+resp.status);
          return resp.json();
        })
        .then(function(data){
          log('[draft] response', data);
          if (data && data.ok){
            showToast('임시저장 완료');
            if (data.imageFileName && cards) {
              var prefix = form.getAttribute('data-temp-img-prefix') || '/board/img/temp/';
              var fig = document.createElement('figure'); fig.className = 'wa2-card is-initial';
              var img = new Image(); img.alt='임시 이미지 미리보기';
              img.src = prefix + encodeURIComponent(data.imageFileName);
              fig.appendChild(img); cards.innerHTML=''; cards.appendChild(fig);
            }
          } else {
            showToast(data && data.reason ? ('임시저장 실패: '+data.reason) : '임시저장 실패');
          }
        })
        .catch(function(err){
          log('[draft] error', err);
          showToast('임시저장 오류');
        });
    }catch(err){
      log('[draft] exception', err);
      showToast('임시저장 오류');
    }
  }

  if (btnSaveDraft){
    btnSaveDraft.addEventListener('click', function(){
      saveDraftServer();
    });
  } else {
    log('[draft] #btnSaveDraft not found');
  }
})();