// /resources/js/main.js
// 헤더 네비 + 서브카테고리 + 로그인 드롭다운 통합 스크립트 (optional chaining 제거, 메가드롭다운 대응)

document.addEventListener('DOMContentLoaded', () => {
  'use strict';

  // ----- 공통 선택자 -----
  const bar = document.querySelector('.category-bar');
  const mainNav = document.getElementById('mainNav'); // 없으면 아래 items가 빈 배열
  const toggleBtn = document.querySelector('.nav-toggle');
  const subWrap = document.querySelector('.subcategory-container');

  const items = mainNav ? mainNav.querySelectorAll('.category-item[data-sub]') : [];
  const panels = subWrap ? subWrap.querySelectorAll('.subcategory') : [];

  let hideTimer = null;

  // ----- 유틸 -----
  const on = (el, type, handler) => { if (el) el.addEventListener(type, handler); };
  const isCollapsed = () => !!(bar && bar.classList.contains('nav-collapsed'));
  const cancelHide = () => { if (hideTimer) clearTimeout(hideTimer); };
  const scheduleHide = () => { cancelHide(); hideTimer = setTimeout(closeSub, 160); };

  function setCollapsed(collapsed){
    if (!bar || !toggleBtn) return;
    bar.classList.toggle('nav-collapsed', collapsed);
    toggleBtn.setAttribute('aria-expanded', String(!collapsed));
  }

  function closeSub(){
    items.forEach(i => { i.classList.remove('active'); i.setAttribute('aria-expanded','false'); });
    panels.forEach(p => p.classList.remove('active'));
    if (subWrap) subWrap.classList.remove('show');
  }

  // ★ 메가드롭다운 버전: 위치 계산 없이 전체 폭 컨테이너만 열고 패널만 스위치
  function openSub(id, anchorEl){
    if (!subWrap) return;
    subWrap.classList.add('show');
    panels.forEach(p => p.classList.toggle('active', p.id === id));
    items.forEach(i => {
      const active = (i === anchorEl);
      i.classList.toggle('active', active);
      i.setAttribute('aria-expanded', active ? 'true' : 'false');
    });
  }

  // ----- 모바일 토글 -----
  on(toggleBtn, 'click', () => { setCollapsed(!isCollapsed()); });
  // 초기 상태(모바일에서만 숨김; 데스크톱에는 CSS상 영향 없음)
  setCollapsed(true);

  // ----- 항목 인터랙션 (호버/포커스/클릭/키보드) -----
  items.forEach(item => {
    const id = item.getAttribute('data-sub');

    // 호버 & 포커스
    on(item, 'mouseenter', () => { cancelHide(); if (!isCollapsed()) openSub(id, item); });
    on(item, 'focus',      () => { cancelHide(); if (!isCollapsed()) openSub(id, item); });

    // 클릭: 모바일에서도 열리도록
    on(item, 'click', (e) => {
      e.preventDefault();
      if (isCollapsed()) setCollapsed(false);
      openSub(id, item);
    });

    // 키보드 내비게이션
    on(item, 'keydown', (e) => {
      const list = Array.prototype.slice.call(items);
      const idx = list.indexOf(item);
      if (e.key === 'ArrowRight'){ e.preventDefault(); (list[idx+1] || list[0]).focus(); }
      if (e.key === 'ArrowLeft'){  e.preventDefault(); (list[idx-1] || list[list.length-1]).focus(); }
      if (e.key === 'Escape'){ closeSub(); item.blur(); }
      if (e.key === 'Enter' || e.key === ' '){ e.preventDefault(); openSub(id, item); }
    });
  });

  // 바/패널 영역 이탈 시 닫기
  on(bar, 'mouseleave', scheduleHide);
  on(subWrap, 'mouseenter', cancelHide);
  on(subWrap, 'mouseleave', scheduleHide);
  on(window, 'scroll', closeSub);
  on(window, 'resize', () => {
    const active = document.querySelector('.category-item.active');
    if (active) openSub(active.getAttribute('data-sub'), active);
  });

  // ----- 단순 카테고리 'active' 토글 (.category가 별도로 있을 경우) -----
  Array.prototype.forEach.call(document.querySelectorAll('.category'), (el) => {
    on(el, 'click', function(){
      Array.prototype.forEach.call(document.querySelectorAll('.category'), (i) => i.classList.remove('active'));
      this.classList.add('active');
    });
  });

  // ----- 로그인 드롭다운 -----
  (function initLoginDropdown(){
    const loginBtn = document.querySelector('.login-btn');
    const loginDropdown = document.querySelector('.login-dropdown');
    if (!loginBtn || !loginDropdown) return;

    on(loginBtn, 'click', (e) => {
      e.stopPropagation();
      loginDropdown.classList.toggle('open');
    });
    on(document, 'click', () => loginDropdown.classList.remove('open'));

    const loginForm = loginDropdown.querySelector('form');
    if (loginForm){
      on(loginForm, 'submit', (e) => {
        e.preventDefault();
        alert('로그인 기능은 준비중입니다.');
        loginDropdown.classList.remove('open');
      });
    }
  })();
});
