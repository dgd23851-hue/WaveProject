<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" isELIgnored="false"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<c:set var="curCat" value="${empty param.cat ? '' : param.cat}" />
<c:set var="curSub" value="${empty param.sub ? '' : param.sub}" />
<c:set var="q" value="${empty param.q ? '' : param.q}" />

<c:set var="listData" value="${articlesList}" />
<c:if test="${empty listData}">
	<c:set var="listData" value="${list}" />
</c:if>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>WAVE | 뉴스 리스트</title>
<style>
/* actions */
.hy3-actions {
	display: flex;
	gap: 8px;
	align-items: center
}

.btn {
	display: inline-flex;
	align-items: center;
	gap: 6px;
	padding: 10px 12px;
	border-radius: 10px;
	border: 1px solid #dfe3ed;
	background: #fff;
	color: #0b0f1a;
	cursor: pointer
}

.btn-primary {
	border-color: #0b0f1a;
	background: #0b0f1a;
	color: #fff
}

.btn[aria-disabled="true"] {
	opacity: .6;
	pointer-events: none
}

.fab-write {
	position: fixed;
	right: 16px;
	bottom: 16px;
	display: none;
	z-index: 20;
	padding: 14px 16px;
	border-radius: 999px;
	border: 1px solid #0b0f1a;
	background: #0b0f1a;
	color: #fff;
	box-shadow: 0 8px 24px rgba(0, 0, 0, .12)
}

@media ( max-width :640px) {
	.fab-write {
		display: inline-flex
	}
}

*, *::before, *::after {
	box-sizing: border-box
}

body {
	margin: 0;
	background: #f7f8fb;
	color: #0b0f1a;
	font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto,
		"Noto Sans KR", "Apple SD Gothic Neo", "Malgun Gothic", Arial,
		sans-serif
}

a {
	text-decoration: none;
	color: inherit
}

img {
	display: block;
	max-width: 100%;
	height: auto
}

.hy3-wrap {
	max-width: 1200px;
	margin: 0 auto;
	padding: 20px 16px
}

.hy3-top {
	display: flex;
	gap: 8px;
	align-items: center;
	justify-content: space-between;
	margin-bottom: 10px
}

.hy3-brand {
	font-weight: 800;
	letter-spacing: -.2px
}

.hy3-search {
	display: flex;
	gap: 8px
}

.hy3-search input {
	width: 260px;
	padding: 10px 12px;
	border: 1px solid #dfe3ed;
	border-radius: 10px
}

.hy3-search button {
	padding: 10px 14px;
	border-radius: 10px;
	border: 1px solid #0b0f1a;
	background: #0b0f1a;
	color: #fff;
	cursor: pointer
}

.hy3-catbar {
	display: flex;
	gap: 8px;
	overflow: auto;
	padding: 6px 0 12px;
	margin-bottom: 8px
}

.hy3-cat {
	padding: 8px 12px;
	border: 1px solid #e3e7f1;
	border-radius: 999px;
	background: #fff;
	color: #333;
	white-space: nowrap
}

.hy3-cat.is-active {
	background: #0b0f1a;
	color: #fff;
	border-color: #0b0f1a
}

.hy3-sechead {
	display: flex;
	align-items: baseline;
	gap: 10px;
	margin: 18px 0 10px
}

.hy3-sechead__title {
	font-size: 18px;
	font-weight: 800
}

.hy3-sechead__meta {
	font-size: 12px;
	color: #7a8092
}

/* 1) 헤드라인 */
.hy3-hero {
	border: 1px solid #eaedf5;
	background: #fff;
	border-radius: 16px;
	overflow: hidden;
	margin-top: 6px
}

.hy3-hero__media {
	aspect-ratio: 16/9;
	background: #f0f2f8
}

.hy3-hero__media img {
	width: 100%;
	height: 100%;
	object-fit: cover
}

.hy3-hero__body {
	padding: 14px 16px
}

.hy3-hero__cat {
	font-size: 12px;
	color: #7a8092
}

.hy3-hero__title {
	font-size: 26px;
	line-height: 1.2;
	font-weight: 800;
	margin: 6px 0 8px
}

.hy3-meta {
	font-size: 12px;
	color: #7a8092
}

/* 2) 포토 카드 그리드 (이미지 있는 나머지) */
.hy3-grid {
	display: grid;
	grid-template-columns: repeat(3, minmax(0, 1fr));
	gap: 16px
}

.hy3-card {
	background: #fff;
	border: 1px solid #eaedf5;
	border-radius: 14px;
	overflow: hidden
}

.hy3-thumb {
	aspect-ratio: 16/10;
	background: #f0f2f8
}

.hy3-thumb img {
	width: 100%;
	height: 100%;
	object-fit: cover
}

.hy3-card__body {
	padding: 12px 14px
}

.hy3-catlbl {
	font-size: 12px;
	color: #7a8092
}

.hy3-title {
	font-size: 18px;
	line-height: 1.35;
	font-weight: 800;
	margin: 6px 0 8px
}

/* 3) 텍스트 목록창 (이미지 없는 기사) */
.hy3-listwin {
	background: #fff;
	border: 1px solid #eaedf5;
	border-radius: 14px;
	overflow: hidden
}

.hy3-list {
	list-style: none;
	margin: 0;
	padding: 0
}

.hy3-li {
	display: grid;
	grid-template-columns: auto 120px;
	gap: 8px;
	align-items: center;
	padding: 10px 14px;
	border-top: 1px solid #f0f2f8
}

.hy3-li:first-child {
	border-top: none
}

.hy3-li__left {
	min-width: 0
}

.hy3-li__cat {
	font-size: 12px;
	color: #7a8092;
	margin-bottom: 2px
}

.hy3-li__title {
	font-weight: 700;
	line-height: 1.35;
	white-space: nowrap;
	overflow: hidden;
	text-overflow: ellipsis
}

.hy3-li__right {
	text-align: right;
	color: #7a8092;
	font-size: 12px
}

/* 레이아웃: 카드와 목록을 2칸으로 */
.hy3-main {
	display: grid;
	grid-template-columns: 1.6fr 1fr;
	gap: 20px;
	align-items: start;
	margin-top: 16px
}

@media ( max-width :1024px) {
	.hy3-grid {
		grid-template-columns: repeat(2, minmax(0, 1fr))
	}
	.hy3-main {
		grid-template-columns: 1fr
	}
}

@media ( max-width :640px) {
	.hy3-search input {
		width: 100%
	}
	.hy3-grid {
		grid-template-columns: 1fr
	}
}
</style>
</head>
<body>
	<div class="hy3-wrap">
		<div class="hy3-top">
			<div class="hy3-brand">WAVE News</div>
			<form class="hy3-search" method="get"
				action="<c:url value='/board/listArticles.do'/>">
				<input type="hidden" name="cat" value="${curCat}" /> <input
					type="text" name="q" value="${fn:escapeXml(q)}"
					placeholder="검색어를 입력하세요" />
				<button type="submit">검색</button>
			</form>

			<c:set var="isLoggedIn"
				value="${not empty sessionScope.member or not empty sessionScope.loginMember or sessionScope.isLogOn}" />
			<c:url var="writeUrl" value="/board/articleForm.do">
				<c:if test="${not empty curCat}">
					<c:param name="cat" value="${curCat}" />
				</c:if>
				<c:if test="${not empty curSub}">
					<c:param name="sub" value="${curSub}" />
				</c:if>
			</c:url>
			<div class="hy3-actions">
				<a class="btn btn-primary" href="${writeUrl}">글쓰기</a>
			</div>

		</div>

		<div class="hy3-catbar">
			<a class="hy3-cat ${empty curCat ? 'is-active':''}"
				href="<c:url value='/board/listArticles.do'/>">전체</a> <a
				class="hy3-cat ${curCat=='politics'?'is-active':''}"
				href="<c:url value='/board/listArticles.do?cat=politics'/>">정치</a> <a
				class="hy3-cat ${curCat=='economy'?'is-active':''}"
				href="<c:url value='/board/listArticles.do?cat=economy'/>">경제</a> <a
				class="hy3-cat ${curCat=='society'?'is-active':''}"
				href="<c:url value='/board/listArticles.do?cat=society'/>">사회</a> <a
				class="hy3-cat ${curCat=='world'?'is-active':''}"
				href="<c:url value='/board/listArticles.do?cat=world'/>">국제</a> <a
				class="hy3-cat ${curCat=='culture'?'is-active':''}"
				href="<c:url value='/board/listArticles.do?cat=culture'/>">문화</a> <a
				class="hy3-cat ${curCat=='sports'?'is-active':''}"
				href="<c:url value='/board/listArticles.do?cat=sports'/>">스포츠</a> <a
				class="hy3-cat ${curCat=='tech'?'is-active':''}"
				href="<c:url value='/board/listArticles.do?cat=tech'/>">IT·과학</a>
		</div>

		<%-- Prepass: pick hero (first with image) and count text-only --%>
		<c:set var="heroArticleNO" value="" />
		<c:set var="textCount" value="0" />
		<c:forEach var="a" items="${listData}">
			<c:if
				test="${empty heroArticleNO and not empty a.imageFileName and a.imageFileName ne 'null'}">
				<c:set var="heroArticleNO" value="${a.articleNO}" />
			</c:if>
			<c:if test="${empty a.imageFileName or a.imageFileName eq 'null'}">
				<c:set var="textCount" value="${textCount + 1}" />
			</c:if>
		</c:forEach>

		<%-- 1) 헤드라인 섹션 --%>
		<c:if test="${not empty heroArticleNO}">
			<div class="hy3-sechead">
				<div class="hy3-sechead__title">헤드라인</div>
			</div>
			<c:forEach var="a" items="${listData}">
				<c:if test="${a.articleNO == heroArticleNO}">
					<article class="hy3-hero">
						<a class="hy3-hero__media"
							href="<c:url value='/board/viewArticle.do'><c:param name='articleNO' value='${a.articleNO}'/></c:url>">
							<img alt="${fn:escapeXml(a.title)}"
							src="<c:url value='/board/img/${a.articleNO}/${a.imageFileName}'/>" />
						</a>
						<div class="hy3-hero__body">
							<a class="hy3-hero__cat"
								href="<c:url value='/board/listArticles.do?cat=${a.cat}&sub=${a.sub}'/>">${a.cat}
								· ${a.sub}</a>
							<h2 class="hy3-hero__title">
								<a
									href="<c:url value='/board/viewArticle.do'><c:param name='articleNO' value='${a.articleNO}'/></c:url>">${fn:escapeXml(a.title)}</a>
							</h2>
							<div class="hy3-meta">
								작성자 ${fn:escapeXml(a.id)} ·
								<fmt:formatDate value="${a.writeDate}"
									pattern="yyyy.MM.dd HH:mm" />
							</div>
						</div>
					</article>
				</c:if>
			</c:forEach>
		</c:if>

		<div class="hy3-main">
			<%-- 2) 포토 카드 --%>
			<section>
				<div class="hy3-sechead">
					<div class="hy3-sechead__title">포토 기사</div>
					<div class="hy3-sechead__meta">이미지 포함</div>
				</div>
				<div class="hy3-grid">
					<c:forEach var="a" items="${listData}">
						<c:if
							test="${not empty a.imageFileName and a.imageFileName ne 'null' and a.articleNO != heroArticleNO}">
							<article class="hy3-card">
								<a class="hy3-thumb"
									href="<c:url value='/board/viewArticle.do'><c:param name='articleNO' value='${a.articleNO}'/></c:url>">
									<img alt="${fn:escapeXml(a.title)}"
									src="<c:url value='/board/img/${a.articleNO}/${a.imageFileName}'/>" />
								</a>
								<div class="hy3-card__body">
									<a class="hy3-catlbl"
										href="<c:url value='/board/listArticles.do?cat=${a.cat}&sub=${a.sub}'/>">${a.cat}
										· ${a.sub}</a>
									<h3 class="hy3-title">
										<a
											href="<c:url value='/board/viewArticle.do'><c:param name='articleNO' value='${a.articleNO}'/></c:url>">${fn:escapeXml(a.title)}</a>
									</h3>
									<div class="hy3-meta">
										작성자 ${fn:escapeXml(a.id)} ·
										<fmt:formatDate value="${a.writeDate}"
											pattern="yyyy.MM.dd HH:mm" />
									</div>
								</div>
							</article>
						</c:if>
					</c:forEach>
				</div>
			</section>

			<%-- 3) 텍스트 목록창 --%>
			<aside>
				<div class="hy3-sechead">
					<div class="hy3-sechead__title">텍스트 기사</div>
					<div class="hy3-sechead__meta">${textCount}건</div>
				</div>
				<div class="hy3-listwin" role="region" aria-label="텍스트 뉴스 목록">
					<ul class="hy3-list">
						<c:forEach var="a" items="${listData}">
							<c:if
								test="${empty a.imageFileName or a.imageFileName eq 'null'}">
								<li class="hy3-li">
									<div class="hy3-li__left">
										<a class="hy3-li__cat"
											href="<c:url value='/board/listArticles.do?cat=${a.cat}&sub=${a.sub}'/>">${a.cat}
											· ${a.sub}</a>
										<div class="hy3-li__title">
											<a
												href="<c:url value='/board/viewArticle.do'><c:param name='articleNO' value='${a.articleNO}'/></c:url>">${fn:escapeXml(a.title)}</a>
										</div>
									</div>
									<div class="hy3-li__right">
										<fmt:formatDate value="${a.writeDate}"
											pattern="yyyy.MM.dd HH:mm" />
									</div>
								</li>
							</c:if>
						</c:forEach>
					</ul>
				</div>
			</aside>
		</div>
	</div>

	<c:set var="isLoggedIn"
		value="${not empty sessionScope.member or not empty sessionScope.loginMember or sessionScope.isLogOn}" />
	<c:url var="writeUrlFab" value="/board/articleForm.do">
		<c:if test="${not empty curCat}">
			<c:param name="cat" value="${curCat}" />
		</c:if>
		<c:if test="${not empty curSub}">
			<c:param name="sub" value="${curSub}" />
		</c:if>
	</c:url>
	<a class="fab-write" href="${writeUrlFab}" aria-label="글쓰기">글쓰기</a>
</body>
</html>
