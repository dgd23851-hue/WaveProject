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
