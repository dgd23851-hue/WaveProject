<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" isELIgnored="false"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%-- ==============================
     Bind Article safely (var a)
     ============================== --%>
<c:set var="a" value="${article}" />
<c:if test="${empty a}">
	<c:set var="a" value="${view}" />
</c:if>
<c:if test="${empty a}">
	<c:set var="a" value="${articleVO}" />
</c:if>
<c:if test="${empty a}">
	<c:set var="a" value="${map.article}" />
</c:if>

<%-- Extract common fields (null-safe) --%>
<c:set var="articleNO" value="${a.articleNO}" />
<c:set var="title" value="${a.title}" />
<c:set var="writer" value="${a.id}" />
<c:set var="cat" value="${a.cat}" />
<c:set var="sub" value="${a.sub}" />
<c:set var="imageFileName" value="${a.imageFileName}" />
<c:set var="content" value="${a.content}" />
<c:set var="tagsStr" value="${param.tags}" />
<c:set var="writeDate" value="${a.writeDate}" />

<%-- Owner/Admin check (avoid unknown nested props) --%>
<c:set var="isOwner"
	value="${not empty sessionScope.member and sessionScope.member.id == writer}" />
<c:set var="isAdmin"
	value="${not empty sessionScope.admin and sessionScope.admin}" />

<link rel="stylesheet"
	href="<c:url value='/resources/css/viewArticle.css'/>?v=1" />

<div class="va-progress" id="vaProgress" aria-hidden="true"></div>

<div class="va-main" role="main" data-article-no="${articleNO}">
	<div class="va-container">
		<header class="va-head">
			<nav class="va-breadcrumb" aria-label="breadcrumb">
				<a href="<c:url value='/'/>">홈</a> <span class="sep">›</span> <a
					href="<c:url value='/board/listArticles.do'/>">기사</a>
				<c:if test="${not empty cat}">
					<span class="sep">›</span>
					<a href="<c:url value='/board/listArticles.do?cat=${cat}'/>"> <c:choose>
							<c:when test="${cat=='politics'}">정치</c:when>
							<c:when test="${cat=='economy'}">경제</c:when>
							<c:when test="${cat=='society'}">사회</c:when>
							<c:when test="${cat=='culture'}">문화</c:when>
							<c:when test="${cat=='world'}">국제</c:when>
							<c:when test="${cat=='sports'}">스포츠</c:when>
							<c:when test="${cat=='tech'}">IT·과학</c:when>
							<c:otherwise>${cat}</c:otherwise>
						</c:choose>
					</a>
					<c:if test="${not empty sub}">
						<span class="sep">›</span>
						<a
							href="<c:url value='/board/listArticles.do?cat=${cat}&sub=${sub}'/>">${sub}</a>
					</c:if>
				</c:if>
			</nav>

			<h1 class="va-title">${fn:escapeXml(title)}</h1>
			<div class="va-meta">
				<span class="va-author">작성자 ${fn:escapeXml(writer)}</span> <span
					class="dot" aria-hidden="true">·</span>
				<time class="va-time">${writeDate}</time>
			</div>

			<div class="va-actions">
				<a class="va-btn is-ghost"
					href="<c:url value='/board/listArticles.do'/>">목록</a>
				<button type="button" class="va-btn is-outline" id="btnCopy">링크
					복사</button>
				<c:if test="${isOwner or isAdmin}">
					<a class="va-btn"
						href="<c:url value='/board/modArticleForm.do'><c:param name='articleNO' value='${articleNO}'/></c:url>">수정</a>
					<form id="vaDelForm" class="va-inline" method="post"
						action="<c:url value='/board/removeArticle.do'/>">
						<c:if test="${_csrf != null}">
							<input type="hidden" name="${_csrf.parameterName}"
								value="${_csrf.token}" />
						</c:if>
						<input type="hidden" name="articleNO" value="${articleNO}" />
						<button type="button" class="va-btn is-danger" id="btnDelete">삭제</button>
					</form>
				</c:if>
			</div>
		</header>

		<c:if test="${not empty imageFileName}">
			<figure class="va-hero">
				<img src="<c:url value='/board/img/${articleNO}/${imageFileName}'/>"
					alt="${fn:escapeXml(title)}">
				<figcaption class="sr-only">${fn:escapeXml(title)}</figcaption>
			</figure>
		</c:if>

		<article class="va-article" id="articleBody">
			<%-- NOTE: If content is sanitized HTML on server, keep escapeXml=false. --%>
			<c:out value="${content}" escapeXml="false" />
		</article>

		<c:if test="${not empty tagsStr}">
			<div class="va-tags">
				<c:forEach var="t" items="${fn:split(tagsStr, ',')}">
					<c:if test="${not empty fn:trim(t)}">
						<a class="va-chip"
							href="<c:url value='/board/listArticles.do?q=${fn:trim(t)}'/>">#${fn:trim(t)}</a>
					</c:if>
				</c:forEach>
			</div>
		</c:if>

		<nav class="va-bottom">
			<a class="va-btn is-ghost"
				href="<c:url value='/board/listArticles.do'/>">← 목록으로</a>
			<div class="va-flex"></div>
			<button type="button" class="va-btn is-outline" id="btnTop">맨
				위로</button>
		</nav>
	</div>

	<div class="va-toast" id="vaToast" aria-live="polite"></div>
</div>

<script defer src="<c:url value='/resources/js/viewArticle.js'/>?v=1"></script>




<!-- WA2-COMMENTS-START -->
<section id="wa2-comments" class="wa2-comments"
	aria-labelledby="wa2-comments-title">
	<h2 id="wa2-comments-title" class="wa2-comments__title">댓글</h2>

	<c:choose>
		<c:when test="${not empty commentList}">
			<ul class="wa2-comments__list">
				<c:forEach var="c" items="${commentList}">
					<li class="wa2-comment" data-comment-id="${c.id}">
						<div class="wa2-comment__avatar">${fn:substring(fn:escapeXml(c.authorName),0,1)}</div>
						<div class="wa2-comment__main">
							<div class="wa2-comment__meta">
								<span class="wa2-comment__author">${fn:escapeXml(c.authorName)}</span>
								<time class="wa2-comment__time" datetime="${c.regDate}">${c.regDate}</time>
							</div>
							<p class="wa2-comment__body">${fn:escapeXml(c.content)}</p>
						</div>
					</li>
				</c:forEach>
			</ul>
		</c:when>
		<c:otherwise>
			<p class="wa2-comments__empty">아직 댓글이 없습니다. 첫 댓글을 남겨보세요.</p>
		</c:otherwise>
	</c:choose>

	<c:if test="${not empty sessionScope.member}">
		<form id="wa2-comment-form" class="wa2-comment-form"
			action="<c:url value='/comments/add'/>" method="post" novalidate>
			<!-- articleNo resolver -->
			<c:set var="commentArticleNo" value="${param.articleNo}" />
			<c:if test="${empty commentArticleNo}">
				<c:set var="commentArticleNo" value="${param.articleNO}" />
			</c:if>
			<c:if test="${empty commentArticleNo}">
				<c:set var="commentArticleNo" value="${requestScope.articleNo}" />
			</c:if>
			<c:if test="${empty commentArticleNo}">
				<c:set var="commentArticleNo" value="${requestScope.articleNO}" />
			</c:if>

			<input type="hidden" name="articleNo" value="${commentArticleNo}" />
			<c:if test="${not empty _csrf}">
				<input type="hidden" name="${_csrf.parameterName}"
					value="${_csrf.token}" />
			</c:if>

			<div class="wa2-comment-form__row">
				<div class="wa2-comment-form__logged">
					로그인: <strong><c:out value='${sessionScope.member.name}' /></strong>
				</div>
			</div>

			<label class="wa2-field wa2-field--textarea"> <span
				class="wa2-field__label">내용</span> <textarea class="wa2-textarea"
					name="content" rows="3" maxlength="1000" required
					placeholder="부적절한 표현, 광고성 글은 예고 없이 숨김/삭제될 수 있습니다."></textarea>
				<div class="wa2-field__hint">
					<span id="wa2-char">0</span>/1000
				</div>
			</label>

			<div class="wa2-comment-form__actions">
				<button type="reset" class="wa2-btn wa2-btn--ghost">취소</button>
				<button type="submit" class="wa2-btn wa2-btn--primary">등록</button>
			</div>
		</form>
	</c:if>
	<c:if test="${empty sessionScope.member}">
		<div class="wa2-comment-locked">
			댓글은 로그인 후에만 작성할 수 있습니다. <a
				href="<c:url value='/member/loginForm.do'/>"
				class="wa2-btn wa2-btn--primary">로그인</a>
		</div>
	</c:if>
</section>

<style>
/* ===== Comments (narrow, centered) ===== */
.wa2-comments {
	width: 945px;
	height: 345px;
	box-sizing: border-box;
	overflow-y: auto;
	overflow-x: hidden;
	margin: .5rem auto;
	padding: .6rem;
	border: 1px solid #e5e7eb;
	border-radius: .6rem;
	background: #fff
}

.wa2-comments__title {
	margin: 0 0 .5rem 0;
	font-size: 1rem;
	line-height: 1.4rem
}

.wa2-comments__empty {
	margin: .25rem 0 .5rem 0;
	color: #6b7280;
	font-size: .9rem
}

.wa2-comments__list {
	list-style: none;
	margin: 0;
	padding: 0;
	display: flex;
	flex-direction: column;
	gap: .45rem
}

.wa2-comment {
	display: flex;
	gap: .4rem;
	padding: .4rem;
	border: 1px solid #f1f5f9;
	border-radius: .5rem;
	background: #fafafa
}

.wa2-comment__avatar {
	width: 24px;
	height: 24px;
	border-radius: 9999px;
	background: #e5e7eb;
	display: flex;
	align-items: center;
	justify-content: center;
	font-weight: 700
}

.wa2-comment__main {
	flex: 1;
	min-width: 0
}

.wa2-comment__meta {
	display: flex;
	gap: .5rem;
	align-items: baseline;
	flex-wrap: wrap
}

.wa2-comment__author {
	font-weight: 600
}

.wa2-comment__time {
	color: #6b7280;
	font-size: .85rem
}

.wa2-comment__body {
	margin: .1rem 0 0 0;
	white-space: pre-wrap;
	word-break: break-word
}

.wa2-comment-form {
	margin-top: .6rem;
	display: flex;
	flex-direction: column;
	gap: .5rem
}

.wa2-comment-form__logged {
	padding: .35rem .5rem;
	background: #f8fafc;
	border: 1px solid #e5e7eb;
	border-radius: .4rem
}

.wa2-field {
	display: flex;
	flex-direction: column;
	gap: .2rem
}

.wa2-field__label {
	font-size: .9rem;
	color: #374151
}

.wa2-textarea {
	width: 100%;
	padding: .45rem .6rem;
	border: 1px solid #d1d5db;
	border-radius: .5rem;
	font: inherit;
	font-size: .95rem;
	min-height: 72px;
	max-height: 200px;
	resize: vertical
}

.wa2-textarea:focus {
	outline: 2px solid transparent;
	border-color: #9ca3af;
	box-shadow: 0 0 0 3px rgba(59, 130, 246, .2)
}

.wa2-field--textarea {
	position: relative
}

.wa2-field__hint {
	position: absolute;
	bottom: .35rem;
	right: .5rem;
	font-size: .75rem;
	color: #6b7280
}

.wa2-comment-form__actions {
	display: flex;
	gap: .3rem;
	flex-wrap: wrap;
	justify-content: flex-end
}

.wa2-btn {
	font-size: .9rem;
	appearance: none;
	border: 1px solid #111827;
	background: #111827;
	color: #fff;
	border-radius: .45rem;
	padding: .3rem .55rem;
	cursor: pointer
}

.wa2-btn--primary {
	background: #111827;
	border-color: #111827
}

.wa2-btn--ghost {
	background: #fff;
	color: #111827;
	border-color: #d1d5db
}

.wa2-btn:disabled {
	opacity: .5;
	cursor: not-allowed
}

.wa2-comment-locked {
	width: 100%;
	box-sizing: border-box;
	margin: .5rem 0 0 0;
	padding: .5rem;
	border: 1px dashed #d1d5db;
	border-radius: .5rem;
	color: #6b7280;
	text-align: center
}

@media ( max-width : 720px) {
	.wa2-comments, .wa2-comment-locked {
		max-width: 100%;
		margin-left: 0;
		margin-right: 0;
		border-radius: .5rem
	}
}

@media ( prefers-color-scheme : dark) {
	.wa2-comments {
		background: #0b0f14;
		border-color: #1f2937
	}
	.wa2-comment {
		background: #0e141b;
		border-color: #1f2937
	}
	.wa2-textarea {
		background: #0e141b;
		border-color: #1f2937;
		color: #e5e7eb
	}
	.wa2-btn--ghost {
		background: #0e141b;
		color: #e5e7eb;
		border-color: #1f2937
	}
	.wa2-comment-form__logged {
		background: #0e141b;
		border-color: #1f2937
	}
	.wa2-comments__empty, .wa2-comment__time, .wa2-field__label {
		color: #9ca3af
	}
}

@media ( max-width : 980px) {
	.wa2-comments, .wa2-comment-locked {
		width: 100%;
	}
}
}
</style>

<script>
	(function() {
		var form = document.getElementById('wa2-comment-form');
		var ta = form ? form.querySelector('textarea[name="content"]') : null;
		var counter = document.getElementById('wa2-char');

		function updateCount() {
			if (counter && ta)
				counter.textContent = (ta.value || '').length;
		}

		if (ta) {
			updateCount();
			ta.addEventListener('input', function() {
				this.style.height = 'auto';
				this.style.height = Math.min(this.scrollHeight, 200) + 'px';
				updateCount();
			});
		}

		if (form) {
			form.addEventListener('submit', function(e) {
				var content = ta ? ta.value.trim() : '';
				if (!content) {
					e.preventDefault();
					alert('내용을 입력해주세요.');
				}
			});
		}
	})();
</script>
<!-- WA2-COMMENTS-END -->