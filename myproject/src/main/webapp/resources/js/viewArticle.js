// viewArticle interactions (scoped .va-*)
(function() {
	const root = document.querySelector('.va-main');
	if (!root) return;
	const progress = document.getElementById('vaProgress');
	const toast = document.getElementById('vaToast');
	const btnCopy = document.getElementById('btnCopy');
	const btnTop = document.getElementById('btnTop');
	const btnDelete = document.getElementById('btnDelete');
	const delForm = document.getElementById('vaDelForm');

	// Reading progress
	const onScroll = () => {
		const h = document.documentElement;
		const bh = h.scrollHeight - h.clientHeight;
		const y = h.scrollTop;
		const pct = bh > 0 ? Math.min(100, Math.max(0, (y / bh) * 100)) : 0;
		progress.style.width = pct + '%';
	};
	document.addEventListener('scroll', onScroll, { passive: true });
	window.addEventListener('resize', onScroll);
	onScroll();

	// Copy link
	function showToast(msg) {
		if (!toast) return;
		toast.textContent = msg;
		toast.classList.add('is-show');
		setTimeout(() => toast.classList.remove('is-show'), 1500);
	}
	async function copyLink() {
		const url = location.href;
		try {
			await navigator.clipboard.writeText(url);
			showToast('링크를 복사했습니다');
		} catch (e) {
			// fallback
			const ta = document.createElement('textarea');
			ta.value = url; document.body.appendChild(ta); ta.select();
			try { document.execCommand('copy'); showToast('링크를 복사했습니다'); }
			catch (e2) { showToast('복사에 실패했습니다'); }
			document.body.removeChild(ta);
		}
	}
	btnCopy && btnCopy.addEventListener('click', copyLink);

	// Scroll to top
	btnTop && btnTop.addEventListener('click', () => window.scrollTo({ top: 0, behavior: 'smooth' }));

	// Delete (confirm)
	btnDelete && btnDelete.addEventListener('click', () => {
		if (confirm('정말 이 기사를 삭제할까요?')) {
			delForm && delForm.submit();
		}
	});
})();