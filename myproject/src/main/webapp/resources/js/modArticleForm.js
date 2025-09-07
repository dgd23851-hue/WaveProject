// Mod Article Form v3 interactions (scoped .ma2-*)
(function() {
	const root = document.querySelector('.ma2-main');
	if (!root) return;
	const form = root.querySelector('#ma2-form');
	const title = form.querySelector('#title');
	const titleCount = form.querySelector('#titleCount');
	const catSel = form.querySelector('#cat');
	const subSel = form.querySelector('#sub');
	const fileInput = form.querySelector('#image');
	const drop = root.querySelector('#dropzone');
	const cards = root.querySelector('#cards');
	const toast = root.querySelector('#toast');
	const btnChoose = root.querySelector('#btnChoose');
	const btnPreview = root.querySelector('#btnPreview');
	const btnSaveDraft = root.querySelector('#btnSaveDraft');
	const content = form.querySelector('#content');
	const modal = root.querySelector('#previewModal');
	const modalCloseBtns = modal.querySelectorAll('[data-close]');
	const articleNo = root.getAttribute('data-article-no') || 'new';

	// Subcategory options
	const SUBS = {
		politics: [{ v: 'election', t: '선거' }, { v: 'assembly', t: '국회' }, { v: 'bluehouse', t: '정부/청와대' }],
		economy: [{ v: 'market', t: '증시' }, { v: 'macro', t: '거시' }, { v: 'industry', t: '산업' }],
		society: [{ v: 'incident', t: '사건사고' }, { v: 'welfare', t: '복지/노동' }, { v: 'education', t: '교육' }],
		culture: [{ v: 'movie', t: '영화' }, { v: 'music', t: '음악' }, { v: 'book', t: '책' }],
		world: [{ v: 'usa', t: '미국' }, { v: 'china', t: '중국' }, { v: 'europe', t: '유럽' }, { v: 'meafrica', t: '중동/아프리카' }],
		sports: [{ v: 'football', t: '축구' }, { v: 'baseball', t: '야구' }, { v: 'esports', t: 'e스포츠' }],
		tech: [{ v: 'ai', t: 'AI' }, { v: 'mobile', t: '모바일' }, { v: 'science', t: '과학' }]
	};
	const initialSub = (subSel.getAttribute('data-initial') || '').trim();

	function renderSubs(cat, current) {
		subSel.innerHTML = '<option value="">-</option>';
		if (!cat || !SUBS[cat]) return;
		SUBS[cat].forEach(({ v, t }) => {
			const opt = document.createElement('option');
			opt.value = v; opt.textContent = t;
			if (current && current === v) opt.selected = true;
			subSel.appendChild(opt);
		});
	}
	renderSubs(catSel.value, initialSub);
	catSel.addEventListener('change', () => renderSubs(catSel.value, ''));

	// Title counter
	const updateCounter = () => {
		titleCount.textContent = (title.value.length) + '/150';
	};
	title.addEventListener('input', updateCounter);
	updateCounter();

	// File choose button
	if (btnChoose) {
		btnChoose.addEventListener('click', () => fileInput.click());
	}

	// Drag-drop
	;['dragenter', 'dragover'].forEach(ev => drop.addEventListener(ev, e => { e.preventDefault(); drop.classList.add('is-drag'); }));
	;['dragleave', 'drop'].forEach(ev => drop.addEventListener(ev, e => { e.preventDefault(); drop.classList.remove('is-drag'); }));
	drop.addEventListener('drop', (e) => {
		const file = e.dataTransfer.files && e.dataTransfer.files[0];
		if (file) { fileInput.files = e.dataTransfer.files; renderCard(file); }
	});
	fileInput.addEventListener('change', () => {
		const file = fileInput.files && fileInput.files[0];
		if (file) renderCard(file);
	});

	function renderCard(file) {
		if (!file || !file.type.startsWith('image/')) return;
		const url = URL.createObjectURL(file);
		// Single representative image: clear previous
		cards.innerHTML = '';
		const card = document.createElement('div');
		card.className = 'ma2-card';
		const img = document.createElement('img');
		img.src = url; img.alt = file.name;
		const foot = document.createElement('div');
		foot.className = 'ma2-card__foot';
		const name = document.createElement('span');
		name.className = 'ma2-card__name';
		name.textContent = file.name;
		const size = document.createElement('span');
		size.className = 'ma2-card__size';
		size.textContent = humanSize(file.size);
		foot.appendChild(name); foot.appendChild(size);
		card.appendChild(img); card.appendChild(foot);
		cards.appendChild(card);
	}

	function humanSize(bytes) {
		const KB = 1024, MB = KB * 1024;
		if (bytes < KB) return bytes + ' B';
		if (bytes < MB) return (bytes / KB).toFixed(0) + ' KB';
		return (bytes / MB).toFixed(1) + ' MB';
	}

	// Preview modal
	function openPreview() {
		modal.classList.add('is-open');
		modal.querySelector('.pv-title').textContent = title.value || '(제목 없음)';
		const meta = modal.querySelector('.pv-meta');
		meta.textContent = `${catSel.options[catSel.selectedIndex]?.text || ''}${subSel.value ? ' · ' + (subSel.options[subSel.selectedIndex]?.text || '') : ''}`;
		const pvFig = modal.querySelector('.pv-figure');
		const pvImg = pvFig.querySelector('img');
		const cardImg = cards.querySelector('img');
		if (cardImg) {
			pvImg.src = cardImg.src; pvFig.classList.remove('is-hidden');
		} else {
			pvImg.src = ''; pvFig.classList.add('is-hidden');
		}
		// plain text preview for now
		modal.querySelector('.pv-content').textContent = form.querySelector('#content').value;
	}
	btnPreview.addEventListener('click', openPreview);
	modalCloseBtns.forEach(b => b.addEventListener('click', () => modal.classList.remove('is-open')));
	modal.addEventListener('click', (e) => { if (e.target === modal) modal.classList.remove('is-open'); });

	// Toast helper
	const showToast = (msg) => {
		if (!toast) return;
		toast.textContent = msg;
		toast.classList.add('is-show');
		setTimeout(() => toast.classList.remove('is-show'), 1500);
	};

	// Local draft (manual save)
	const DRAFT_KEY = 'ma2:' + articleNo;
	function saveDraft() {
		const data = {
			title: title.value, cat: catSel.value, sub: subSel.value,
			content: form.querySelector('#content').value, tags: form.querySelector('#tags')?.value || ''
		};
		try { localStorage.setItem(DRAFT_KEY, JSON.stringify(data)); showToast('임시저장 완료'); } catch (e) { }
	}
	btnSaveDraft.addEventListener('click', saveDraft);

	// Offer load draft if exists
	try {
		const raw = localStorage.getItem(DRAFT_KEY);
		if (raw) {
			setTimeout(() => {
				if (confirm('이 문서의 임시 저장본을 불러올까요?')) {
					const d = JSON.parse(raw);
					if (d.title) title.value = d.title;
					if (d.cat) catSel.value = d.cat;
					renderSubs(catSel.value, d.sub || '');
					if (d.content) form.querySelector('#content').value = d.content;
					const tags = form.querySelector('#tags'); if (tags && d.tags) tags.value = d.tags;
					updateCounter();
					showToast('임시 저장본을 불러왔습니다');
				}
			}, 200);
		}
	} catch (e) { }

	// Validation + submit
	function validate() {
		if (!title.value.trim()) { showToast('제목을 입력하세요'); title.focus(); return false; }
		if (!catSel.value) { showToast('카테고리를 선택하세요'); catSel.focus(); return false; }
		const c = form.querySelector('#content');
		if (!c.value.trim() || c.value.trim().length < 5) { showToast('본문을 더 작성하세요'); c.focus(); return false; }
		const f = fileInput.files && fileInput.files[0];
		if (f) {
			if (!f.type.startsWith('image/')) { showToast('이미지 파일만 업로드 가능합니다'); return false; }
			if (f.size > 10 * 1024 * 1024) { showToast('10MB 이하 이미지만 업로드 가능합니다'); return false; }
		}
		return true;
	}
	form.addEventListener('submit', (e) => {
		if (!validate()) e.preventDefault();
	});

	// Ctrl/Cmd + S to submit
	document.addEventListener('keydown', (e) => {
		if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 's') {
			e.preventDefault();
			if (validate()) form.submit();
		}
	});
})();