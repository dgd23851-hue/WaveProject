
// Main page interactions (no backend required for behavior)
(function(){
  // Breaking banner close
  document.querySelectorAll('.mn-breaking__close').forEach(btn => {
    btn.addEventListener('click', () => {
      const sec = btn.closest('.mn-breaking');
      if (sec) sec.remove();
    });
  });

  // Tabs
  document.querySelectorAll('[data-module="tabs"]').forEach(box => {
    const tabs = box.querySelectorAll('.mn-tab');
    const panes = box.querySelectorAll('.mn-pane');
    tabs.forEach(tab => {
      tab.addEventListener('click', () => {
        tabs.forEach(t => t.classList.remove('is-active'));
        panes.forEach(p => p.classList.remove('is-active'));
        tab.classList.add('is-active');
        const pane = document.getElementById(tab.getAttribute('aria-controls'));
        if (pane) pane.classList.add('is-active');
        tabs.forEach(t => t.setAttribute('aria-selected', t===tab ? 'true' : 'false'));
      });
    });
  });

  // Photo rail controls
  document.querySelectorAll('[data-module="rail"]').forEach(sec => {
    const rail = sec.querySelector('.mn-rail');
    sec.querySelectorAll('.mn-rail__btn').forEach(btn => {
      const dir = parseInt(btn.dataset.dir || '0', 10);
      btn.addEventListener('click', () => {
        if (!rail) return;
        rail.scrollBy({left: dir * 260, behavior: 'smooth'});
      });
    });
  });
})();
