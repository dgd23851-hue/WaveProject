<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" isELIgnored="false"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<!-- ===== Precompute ===== -->
<fmt:formatDate value="${article.writeDate}"
	pattern="yyyy-MM-dd'T'HH:mm:ss" var="pubIso" />
<fmt:formatDate value="${article.writeDate}" pattern="yyyy.MM.dd HH:mm"
	var="pubDisp" />
<c:set var="displayWriter"
	value="${empty article.writerName ? (empty article.id ? (empty article.writerId ? '익명' : article.writerId) : article.id) : article.writerName}" />
<c:set var="writerInitial" value="${fn:substring(displayWriter, 0, 1)}" />
<c:url var="listUrl" value="/board/listArticles.do" />
<c:url var="editUrl" value="/board/modArticleForm.do">
	<c:param name="articleNO" value="${article.articleNO}" />
</c:url>
<c:url var="removeUrl" value="/board/removeArticle.do">
	<c:param name="articleNO" value="${article.articleNO}" />
</c:url>
<c:url var="imageUrl" value="/board/download.do">
	<c:param name="articleNO" value="${article.articleNO}" />
	<c:param name="imageFileName" value="${article.imageFileName}" />
</c:url>

<!-- Guess login id from common session keys -->
<c:set var="loginIdGuess" value="${sessionScope.loginId}" />
<c:if test="${empty loginIdGuess}">
	<c:set var="loginIdGuess" value="${sessionScope.userId}" />
</c:if>
<c:if test="${empty loginIdGuess}">
	<c:set var="loginIdGuess" value="${sessionScope.id}" />
</c:if>
<c:if test="${empty loginIdGuess}">
	<c:set var="loginIdGuess" value="${sessionScope.memberId}" />
</c:if>
<c:if test="${empty loginIdGuess and not empty sessionScope.member}">
	<c:set var="loginIdGuess" value="${sessionScope.member.id}" />
</c:if>
<c:set var="ownerId" value="${article.id}" />
<c:if test="${empty ownerId}">
	<c:set var="ownerId" value="${article.writerId}" />
</c:if>
<c:if test="${empty ownerId}">
	<c:set var="ownerId" value="${article.memberId}" />
</c:if>
<c:if test="${empty ownerId}">
	<c:set var="ownerId" value="${article.member_id}" />
</c:if>
<c:set var="loginNorm" value="${fn:toLowerCase(fn:trim(loginIdGuess))}" />
<c:set var="ownerNorm" value="${fn:toLowerCase(fn:trim(ownerId))}" />
<c:set var="isAdmin"
	value="${sessionScope.isAdmin or sessionScope.admin or sessionScope.role eq 'admin' or loginNorm eq 'admin'}" />
<c:set var="canManage"
	value="${isAdmin or (not empty loginNorm and not empty ownerNorm and loginNorm eq ownerNorm)}" />

<article class="article-view portal theme-naver" itemscope
	itemtype="https://schema.org/NewsArticle">
	<div class="reading-progress" aria-hidden="true">
		<span class="bar"></span>
	</div>

	<nav class="portal-breadcrumb" aria-label="breadcrumb">
		<span class="crumb main" itemprop="articleSection"><c:out
				value="${empty article.cat ? '카테고리' : article.cat}" /></span>
		<c:if test="${not empty article.sub}">
			<span class="chev">›</span>
			<span class="crumb sub"><c:out value="${article.sub}" /></span>
		</c:if>
	</nav>

	<header class="header">
		<h1 class="headline" itemprop="headline">
			<c:out value="${article.title}" />
		</h1>
		<div class="meta">
			<span class="avatar" aria-hidden="true"><c:out
					value="${writerInitial}" /></span> <span class="byline" itemprop="author"
				itemscope itemtype="https://schema.org/Person"> <span
				class="writer" itemprop="name"><c:out
						value="${displayWriter}" /></span>
			</span> <span class="dot">·</span>
			<time class="pubdate" itemprop="datePublished" datetime="${pubIso}">${pubDisp}</time>
		</div>
	</header>

	<c:if test="${not empty article.imageFileName}">
		<figure class="cover" itemprop="image" itemscope
			itemtype="https://schema.org/ImageObject">
			<img src="${imageUrl}" alt="${fn:escapeXml(article.title)}"
				itemprop="url" />
			<meta itemprop="width" content="1200" />
			<meta itemprop="height" content="630" />
		</figure>
	</c:if>

	<div class="content" itemprop="articleBody" id="articleBody">
		<c:out value="${article.content}" escapeXml="false" />
	</div>

	<footer class="footer">
		<div class="footer-top">
			<a class="btn-back black" href="${listUrl}" id="backBtn"><span
				class="ico" aria-hidden="true">←</span> 목록으로</a>
		</div>

		<div class="toolbar">
			<div class="tool-group share">
				<button class="btn btn-outline" id="copyLink" title="링크 복사"
					aria-label="링크 복사">🔗 링크복사</button>
				<a class="btn btn-outline" id="shareX" title="X로 공유"
					aria-label="X로 공유" target="_blank" rel="noopener">X 공유</a> <a
					class="btn btn-outline" id="shareFB" title="Facebook 공유"
					aria-label="Facebook 공유" target="_blank" rel="noopener">Facebook</a>
			</div>

			<div class="tool-group font">
				<button class="btn btn-soft" id="fontDec" title="글자 작게"
					aria-label="글자 작게">A−</button>
				<button class="btn btn-soft" id="fontReset" title="기본 크기"
					aria-label="기본 크기">A</button>
				<button class="btn btn-soft" id="fontInc" title="글자 크게"
					aria-label="글자 크게">A+</button>
			</div>

			<div class="tool-group misc">
				<button type="button" class="btn btn-soft" id="printBtn">인쇄</button>
			</div>

			<div class="tool-group manage">
				<c:if test="${canManage}">
					<a href="${editUrl}" class="btn btn-outline">수정</a>
					<a href="${removeUrl}" class="btn btn-outline"
						onclick="return confirm('삭제할까요?')">삭제</a>
				</c:if>
			</div>
		</div>
	</footer>
</article>

<style>
.article-view.portal { -
	-accent: #03C75A; -
	-accent-text: #fff; -
	-muted: #6b7280; -
	-fg: #111827; -
	-rule: #e5e7eb; -
	-soft: #f9fafb; -
	-btn-radius: 8px;
	font-family: system-ui, -apple-system, "Apple SD Gothic Neo",
		"Noto Sans KR", Roboto, Arial, sans-serif;
	color: var(- -fg);
}

.article-view.portal.theme-daum { -
	-accent: #3a67ea;
}

.article-view.portal .reading-progress {
	position: sticky;
	top: 0;
	left: 0;
	right: 0;
	height: 3px;
	background: linear-gradient(to right, var(- -accent) 0 0) no-repeat
		var(- -soft); -
	-w: 0%;
	background-size: var(- -w) 100%;
	z-index: 5
}

.portal-breadcrumb {
	display: flex;
	align-items: center;
	gap: 8px;
	margin: 2px 0 8px;
	font-size: 13px;
	color: #4b5563
}

.portal-breadcrumb .crumb {
	padding: 4px 8px;
	border-radius: 6px;
	background: #f3f4f6;
	border: 1px solid #e5e7eb;
	color: #374151
}

.portal-breadcrumb .crumb.main {
	background: #ecfdf5;
	border-color: #bbf7d0;
	color: #065f46
}

.portal-breadcrumb .crumb.sub {
	background: #eef2ff;
	border-color: #c7d2fe;
	color: #3730a3
}

.portal-breadcrumb .chev {
	color: #94a3b8
}

.header {
	padding-bottom: 14px;
	border-bottom: 2px solid #111
}

.headline {
	margin: 0 0 8px;
	font-size: clamp(26px, 2.1vw + 1rem, 38px);
	line-height: 1.25;
	font-weight: 800;
	letter-spacing: -.01em
}

.meta {
	display: flex;
	align-items: center;
	gap: 10px 14px;
	color: var(- -muted);
	font-size: 13.5px
}

.meta .writer {
	color: var(- -fg);
	font-weight: 700
}

.meta .dot {
	color: #d1d5db;
	margin: 0 2px
}

.avatar {
	width: 28px;
	height: 28px;
	border-radius: 50%;
	display: inline-flex;
	align-items: center;
	justify-content: center;
	background: #e5f7ee;
	color: #047857;
	font-weight: 800;
	font-size: 14px
}

.cover {
	margin: 16px 0 4px
}

.cover img {
	width: 100%;
	height: auto;
	display: block;
	border-radius: 8px;
	box-shadow: 0 6px 20px rgba(0, 0, 0, .05)
}

.content {
	max-width: 100%;
	width: 100%;
	margin: 16px 0 0;
	font-size: 16.5px;
	line-height: 1.85;
	word-break: keep-all;
	white-space: pre-wrap;
	overflow-wrap: anywhere;
}

.content p, .content div, .content h1, .content h2, .content h3,
	.content h4, .content h5, .content h6, .content ul, .content ol,
	.content li, .content table, .content blockquote, .content section,
	.content article {
	white-space: normal;
}

.content pre {
	white-space: pre;
}

.content p {
	margin: 0 0 1.05em
}

.content h2 {
	font-size: 22px;
	margin: 1.6em 0 .7em;
	font-weight: 800
}

.content h3 {
	font-size: 19px;
	margin: 1.4em 0 .6em;
	font-weight: 800
}

.content h4 {
	font-size: 17px;
	margin: 1.2em 0 .5em;
	font-weight: 700
}

.content blockquote {
	margin: 1.1em 0;
	padding: 12px 14px;
	border-left: 3px solid var(- -accent);
	background: #f3f4f6;
	border-radius: 6px;
	color: #111827
}

.content a {
	color: #2563eb;
	text-decoration: none
}

.content a:hover {
	text-decoration: underline
}

.btn {
	display: inline-flex;
	align-items: center;
	justify-content: center;
	height: 36px;
	padding: 0 12px;
	border-radius: var(- -btn-radius);
	border: 1px solid #d1d5db;
	background: #fff;
	color: #1f2937;
	text-decoration: none;
	cursor: pointer;
	transition: background .15s ease, border-color .15s ease, transform .02s
}

.btn:hover {
	background: #f3f4f6;
	border-color: #cbd5e1
}

.btn:active {
	transform: translateY(1px)
}

.btn .ico {
	margin-right: 8px
}

.btn-primary {
	background: var(- -accent);
	border-color: var(- -accent);
	color: var(- -accent-text)
}

.btn-primary:hover {
	filter: brightness(.96)
}

.btn-outline {
	background: #fff;
	border-color: #e5e7eb;
	color: #111827
}

.btn-outline:hover {
	background: #f9fafb;
	border-color: #d1d5db
}

.btn-soft {
	background: #f9fafb;
	border-color: #e5e7eb;
	color: #111827
}

.btn-soft:hover {
	background: #f3f4f6
}

.btn-back.black {
	color: #111;
	text-decoration: none;
	font-weight: 700
}

.btn-back.black .ico {
	margin-right: 6px;
	color: #111
}

.btn-back.black:hover {
	color: #111
}

.btn-back.black:focus, .btn-back.black:active {
	text-decoration: none !important;
	outline: none;
}

.footer {
	margin-top: 24px
}

.footer-top {
	margin: 0 0 8px;
	display: flex;
	justify-content: flex-start
}

.toolbar {
	display: flex;
	flex-wrap: wrap;
	gap: 10px 14px;
	border-top: 1px solid var(- -rule);
	border-bottom: 1px solid var(- -rule);
	padding: 12px 0;
	margin: 0 0 14px 0;
	justify-content: flex-start
}

.tool-group {
	display: flex;
	flex-wrap: wrap;
	gap: 8px
}

.tool-group.manage {
	margin-left: auto
}

.inline {
	display: inline
}

@media ( max-width :768px) {
	.content {
		padding: 0 4px;
		font-size: 16px
	}
	.headline {
		font-size: clamp(22px, 5vw, 30px)
	}
}

@media print {
	.reading-progress, .toolbar, .footer-top {
		display: none !important
	}
	.header {
		border-bottom: 2px solid #000
	}
	.content a {
		color: #000;
		text-decoration: underline
	}
	.cover img {
		box-shadow: none
	}
}

@media ( prefers-color-scheme :dark) {
	.article-view.portal { -
		-fg: #e5e7eb; -
		-muted: #9ca3af; -
		-rule: #243142; -
		-soft: #0b1220
	}
	.btn {
		background: #0b1220;
		border-color: #243142;
		color: #e5e7eb
	}
	.btn:hover {
		background: #121a2a
	}
	.btn-outline {
		background: transparent;
		color: #e5e7eb
	}
	.btn-back.black {
		color: #e5e7eb
	}
	.btn-back.black .ico {
		color: #e5e7eb
	}
}
</style>

<script>
	(function() {
		function r(f) {
			if (document.readyState === 'loading')
				document.addEventListener('DOMContentLoaded', f);
			else
				f();
		}
		r(function() {
			var bodyEl = document.getElementById('articleBody'), progressBar = document
					.querySelector('.article-view .reading-progress'), printBtn = document
					.getElementById('printBtn'), btnInc = document
					.getElementById('fontInc'), btnDec = document
					.getElementById('fontDec'), btnReset = document
					.getElementById('fontReset'), btnCopy = document
					.getElementById('copyLink'), btnX = document
					.getElementById('shareX'), btnFB = document
					.getElementById('shareFB');

			/* Clean first-line indent if any */
			(function() {
				if (!bodyEl)
					return;
				var firstP = bodyEl.querySelector('p');
				if (firstP && /^\s*본문\s*$/.test(firstP.textContent)) {
					firstP.remove();
				}
				try {
					var walker = document.createTreeWalker(bodyEl,
							NodeFilter.SHOW_TEXT, null);
					var tn = walker.nextNode();
					if (tn && tn.nodeValue) {
						tn.nodeValue = tn.nodeValue.replace(
								/^(?:\uFEFF|\u00A0|[\s\t])+/, '');
					}
				} catch (e) {/* ignore */
				}
			})();

			/* reading progress */
			(function() {
				if (!progressBar)
					return;
				var ticking = false;
				function upd() {
					ticking = false;
					var d = document.documentElement;
					var st = d.scrollTop || document.body.scrollTop || 0, sh = (d.scrollHeight - d.clientHeight) || 1;
					var pct = Math.min(100, Math.max(0, (st / sh) * 100));
					progressBar.style.setProperty('--w', pct.toFixed(2) + '%');
				}
				function on() {
					if (!ticking) {
						ticking = true;
						window.requestAnimationFrame(upd);
					}
				}
				document.addEventListener('scroll', on, {
					passive : true
				});
				upd();
			})();

			/* share links */
			var url = window.location.href, title = (document
					.querySelector('.headline') || {}).textContent
					|| document.title || '';
			if (btnX)
				btnX.href = 'https://twitter.com/intent/tweet?text='
						+ encodeURIComponent(title) + '&url='
						+ encodeURIComponent(url);
			if (btnFB)
				btnFB.href = 'https://www.facebook.com/sharer/sharer.php?u='
						+ encodeURIComponent(url);

			/* Safe copy with layered fallbacks, no uncaught rejections */
			(function() {
				if (!btnCopy)
					return;
				btnCopy
						.addEventListener(
								'click',
								function(ev) {
									try {
										ev.preventDefault();
									} catch (e) {
									}
									var original = btnCopy.textContent
											|| '🔗 링크복사';
									function restore() {
										try {
											btnCopy.disabled = false;
											btnCopy.textContent = original;
										} catch (e) {
										}
									}
									function success() {
										try {
											btnCopy.disabled = true;
											btnCopy.textContent = '✅ 복사됨';
											setTimeout(restore, 1200);
										} catch (e) {
										}
									}

									function legacyClip(text) {
										try {
											var ta = document
													.createElement('textarea');
											ta.value = text;
											ta.setAttribute('readonly', '');
											ta.style.position = 'fixed';
											ta.style.top = '-1000px';
											document.body.appendChild(ta);
											ta.select();
											var ok = false;
											try {
												ok = document
														.execCommand('copy');
											} catch (e) {
											}
											document.body.removeChild(ta);
											if (ok) {
												success();
												return;
											}
										} catch (e) {
										}
										try {
											window.prompt('링크를 복사하세요:', text);
											success();
											return;
										} catch (e) {
										}
										try {
											alert(text);
											success();
										} catch (e) {
											restore();
										}
									}

									try {
										if (navigator.clipboard
												&& typeof navigator.clipboard.writeText === 'function'
												&& window.isSecureContext) {
											navigator.clipboard.writeText(url)
													.then(function() {
														success();
													}, function() {
														legacyClip(url);
													});
										} else {
											legacyClip(url);
										}
									} catch (e) {
										legacyClip(url);
									}
									return false;
								});
			})();

			if (printBtn) {
				printBtn.addEventListener('click', function() {
					window.print();
				});
			}

			(function() {
				if (!bodyEl)
					return;
				var KEY = 'wa:articleFontSize';
				function get() {
					var v = parseFloat(localStorage.getItem(KEY));
					if (isNaN(v) || v<12||v>28) {
						var cs = window.getComputedStyle(bodyEl), px = parseFloat(cs
								&& cs.fontSize || '16.5');
						return Math.min(22, Math.max(14, px));
					}
					return v;
				}
				function set(px) {
					px = Math.min(22, Math.max(14, px));
					bodyEl.style.fontSize = px + 'px';
					try {
						localStorage.setItem(KEY, String(px));
					} catch (e) {
					}
				}
				set(get());
				if (btnInc)
					btnInc.addEventListener('click', function() {
						set(get() + 1);
					});
				if (btnDec)
					btnDec.addEventListener('click', function() {
						set(get() - 1);
					});
				if (btnReset)
					btnReset.addEventListener('click', function() {
						set(16.5);
					});
			})();
		});
	})();
</script>
