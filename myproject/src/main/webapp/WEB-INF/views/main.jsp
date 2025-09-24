<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" isELIgnored="false"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<%-- ===== 최신 기사 소스(유연 매핑) ===== --%>
<c:choose>
	<c:when test="${not empty latestArticles}">
		<c:set var="latest" value="${latestArticles}" />
	</c:when>
	<c:when test="${not empty articlesList}">
		<c:set var="latest" value="${articlesList}" />
	</c:when>
	<c:when
		test="${not empty resultMap and not empty resultMap.articlesList}">
		<c:set var="latest" value="${resultMap.articlesList}" />
	</c:when>
	<c:otherwise>
		<c:set var="latest" value="${requestScope.articlesList}" />
	</c:otherwise>
</c:choose>

<style>
/* ================== Variables / Base ================== */
:root {
	--text: #111;
	--muted: #8b96a6;
	--line: #e9edf2;
	--chip: #606fc7;
	--card-bg: #fff;
	--shadow: 0 1px 2px rgba(0, 0, 0, .06)
}

.wrap-main {
	max-width: 1160px;
	margin: 0 auto;
	padding: 16px 16px 28px;
	box-sizing: border-box
}

.wrap-main a {
	color: inherit;
	text-decoration: none;
	-webkit-tap-highlight-color: transparent
}

.wrap-main a:visited {
	color: inherit
}

.more {
	color: var(--chip)
}

.more:visited {
	color: var(--chip)
}
/* ================== Latest ================== */
.sec-latest .head {
	display: flex;
	align-items: center;
	margin: 8px 2px 14px
}

.sec-latest .head h2 {
	font-size: 1.35rem;
	font-weight: 800;
	color: var(--text);
	margin: 0
}

.sec-latest .head .more {
	margin-left: auto
}

.sec-latest .head .more::after {
	content: "›";
	margin-left: 6px
}

.latest-grid {
	display: grid;
	grid-template-columns: repeat(3, 1fr);
	gap: 18px
}

@media ( max-width :1024px) {
	.latest-grid {
		grid-template-columns: repeat(2, 1fr)
	}
}

@media ( max-width :640px) {
	.latest-grid {
		grid-template-columns: 1fr
	}
}

.card {
	display: block;
	border: 1px solid var(--line);
	border-radius: 14px;
	background: var(--card-bg);
	box-shadow: var(--shadow);
	overflow: hidden;
	transition: transform .18s ease, box-shadow .18s ease
}

.card:hover {
	transform: translateY(-2px);
	box-shadow: 0 8px 20px rgba(0, 0, 0, .08)
}

.card-thumb {
	position: relative;
	aspect-ratio: 16/9;
	background: #f6f7f9;
	overflow: hidden
}

.card-thumb img {
	width: 100%;
	height: 100%;
	object-fit: cover;
	display: block
}

.card-thumb .noimg {
	position: absolute;
	inset: 0;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: .95rem;
	color: #a3acb8;
	background: repeating-linear-gradient(45deg, #fbfcfe, #fbfcfe 12px, #f2f5f9 12px,
		#f2f5f9 24px)
}

.card-body {
	padding: 12px 14px 14px
}

.card-title {
	font-weight: 700;
	color: var(--text);
	display: -webkit-box;
	-webkit-box-orient: vertical;
	-webkit-line-clamp: 2;
	overflow: hidden;
	min-height: 2.6em
}

.card-meta {
	display: flex;
	align-items: center;
	margin-top: 8px;
	color: var(--muted);
	font-size: .9rem
}

.badge {
	font-size: .8rem;
	border: 1px solid var(--line);
	border-radius: 999px;
	padding: 2px 8px;
	margin-right: 8px;
	color: #555
}

.date {
	margin-left: auto;
	color: var(--muted)
}

.empty {
	grid-column: 1/-1;
	text-align: center;
	color: var(--muted);
	padding: 18px 0
}
/* ================== Categories (말줄임 적용) ================== */
.sec-cats {
	margin-top: 28px
}

.sec-cats .title-left {
	font-size: 1.35rem;
	font-weight: 800;
	margin: 0 2px 14px;
	color: var(--text);
	text-align: left
}

.cat-grid {
	display: grid;
	grid-template-columns: repeat(4, minmax(0, 1fr));
	gap: 16px
}

@media ( max-width :1024px) {
	.cat-grid {
		grid-template-columns: repeat(2, minmax(0, 1fr))
	}
}

@media ( max-width :640px) {
	.cat-grid {
		grid-template-columns: minmax(0, 1fr)
	}
}

.cat-card {
	border: 1px solid var(--line);
	border-radius: 12px;
	background: #fff;
	box-shadow: var(--shadow);
	padding: 14px 16px;
	min-width: 0
}

.cat-head {
	display: flex;
	align-items: center;
	margin-bottom: 10px
}

.cat-name {
	font-weight: 800;
	font-size: 1.05rem
}

.cat-head .more {
	margin-left: auto
}

.cat-head .more::after {
	content: "›";
	margin-left: 6px
}

a.line {
	display: flex;
	gap: 10px;
	align-items: center;
	padding: 7px 0;
	border-top: 1px solid #f4f6f8;
	width: 100%;
	max-width: 100%;
	overflow: hidden;
	min-width: 0
}

a.line:first-child {
	border-top: none
}

.t-ellipsis {
	display: block;
	flex: 1 1 0%;
	min-width: 0;
	white-space: nowrap;
	overflow: hidden;
	text-overflow: ellipsis;
	word-break: keep-all
}

.headline .t-ellipsis {
	font-weight: 600
}

.headline .date {
	font-size: .88rem;
	color: var(--muted);
	flex: 0 0 auto;
	white-space: nowrap;
	margin-left: 6px
}
</style>

<div class="wrap-main">

	<!-- ========== 최신 기사 ========== -->
	<section class="sec-latest">
		<div class="head">
			<h2>최신 기사</h2>
			<a class="more" href="<c:url value='/board/listArticles.do'/>">더보기</a>
		</div>

		<div class="latest-grid">
			<c:choose>
				<c:when test="${not empty latest}">
					<c:set var="shown" value="0" />
					<c:forEach var="a" items="${latest}">
						<c:if test="${shown lt 6}">
							<c:url var="viewUrl" value="/board/viewArticle.do">
								<c:param name="articleNO" value="${a.articleNO}" />
							</c:url>

							<a class="card" href="${viewUrl}">
								<div class="card-thumb">
									<c:choose>
										<c:when test="${not empty a.imageFileName}">
											<%-- ★ 썸네일 URL은 컨트롤러 thumb.do로 통일 --%>
											<c:url var="thumbUrl" value="/board/thumb.do">
												<c:param name="articleNO" value="${a.articleNO}" />
												<c:param name="imageFileName" value="${a.imageFileName}" />
											</c:url>
											<img src="${thumbUrl}" alt="${fn:escapeXml(a.title)}"
												loading="lazy"
												onerror="this.onerror=null;this.closest('.card-thumb').innerHTML='<span class=&quot;noimg&quot;>No image</span>';">
										</c:when>
										<c:otherwise>
											<span class="noimg">No image</span>
										</c:otherwise>
									</c:choose>
								</div>
								<div class="card-body">
									<div class="card-title">${fn:escapeXml(a.title)}</div>
									<div class="card-meta">
										<span class="badge"> <c:out value="${a.cat}" />
											<c:if test="${not empty a.sub}"> · <c:out
													value="${a.sub}" />
											</c:if>
										</span> <span class="date"> <c:if
												test="${not empty a.writeDate}">
												<fmt:formatDate value="${a.writeDate}" pattern="yyyy.MM.dd" />
											</c:if>
										</span>
									</div>
								</div>
							</a>
							<c:set var="shown" value="${shown + 1}" />
						</c:if>
					</c:forEach>
				</c:when>
				<c:otherwise>
					<div class="empty">표시할 최신 기사가 없습니다.</div>
				</c:otherwise>
			</c:choose>
		</div>
	</section>

	<!-- ========== 카테고리별로 보기 (말줄임 적용) ========== -->
	<section class="sec-cats">
		<h2 class="title-left">카테고리별로 보기</h2>

		<div class="cat-grid">
			<c:set var="codes"
				value="${fn:split('politics,economy,society,world', ',')}" />
			<c:set var="labels" value="${fn:split('정치,경제,사회,국제', ',')}" />

			<c:forEach var="cname" items="${codes}" varStatus="st">
				<div class="cat-card">
					<div class="cat-head">
						<div class="cat-name">${labels[st.index]}</div>
						<c:url var="moreUrl" value="/board/listArticles.do">
							<c:param name="cat" value="${cname}" />
						</c:url>
						<a class="more" href="${moreUrl}">더보기</a>
					</div>

					<c:set var="printed" value="0" />
					<c:forEach var="a" items="${latest}">
						<c:if test="${a.cat eq cname and printed lt 4}">
							<c:url var="itemUrl" value="/board/viewArticle.do">
								<c:param name="articleNO" value="${a.articleNO}" />
							</c:url>

							<c:choose>
								<c:when test="${printed == 0}">
									<a class="line headline" href="${itemUrl}"> <span
										class="t-ellipsis">${fn:escapeXml(a.title)}</span> <span
										class="date"> <c:if test="${not empty a.writeDate}">
												<fmt:formatDate value="${a.writeDate}" pattern="MM.dd" />
											</c:if>
									</span>
									</a>
								</c:when>
								<c:otherwise>
									<a class="line" href="${itemUrl}"> <span class="t-ellipsis">${fn:escapeXml(a.title)}</span>
									</a>
								</c:otherwise>
							</c:choose>

							<c:set var="printed" value="${printed + 1}" />
						</c:if>
					</c:forEach>

					<c:if test="${printed == 0}">
						<div class="line">
							<span class="t-ellipsis" style="color: #9aa5b1;">표시할 글이
								없습니다.</span>
						</div>
					</c:if>
				</div>
			</c:forEach>
		</div>
	</section>
</div>
