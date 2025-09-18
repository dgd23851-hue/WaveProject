<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" isELIgnored="false"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>

<c:set var="curCat" value="${param.cat}" />
<c:set var="curSub" value="${param.sub}" />
<c:set var="q" value="${param.q}" />

<%-- Data source fallback --%>
<c:set var="listData" value="${articlesList}" />
<c:if test="${empty listData}">
	<c:set var="listData" value="${list}" />
</c:if>
<c:if test="${empty listData}">
	<c:set var="listData" value="${articleList}" />
</c:if>
<c:if test="${empty listData}">
	<c:set var="listData" value="${articles}" />
</c:if>

<div class="cl-main" role="main">
	<div class="cl-container">
		<header class="cl-head">
			<link rel="stylesheet"
				href="<c:url value='/resources/css/listArticles.css'/>?v=2">
			<%-- 새 CSS --%>

			<h1 class="cl-title">
				<c:choose>
					<c:when test="${empty curCat}">전체 기사</c:when>
					<c:when test="${curCat=='politics'}">정치</c:when>
					<c:when test="${curCat=='economy'}">경제</c:when>
					<c:when test="${curCat=='society'}">사회</c:when>
					<c:when test="${curCat=='culture'}">문화</c:when>
					<c:when test="${curCat=='world'}">국제</c:when>
					<c:when test="${curCat=='sports'}">스포츠</c:when>
					<c:when test="${curCat=='tech'}">IT·과학</c:when>
					<c:otherwise>전체</c:otherwise>
				</c:choose>
				<c:if test="${not empty curSub}"> · ${curSub}</c:if>
			</h1>

				<%-- 글쓰기 버튼 (현재 cat/sub 유지) --%>
				<c:url var="writeUrl" value="/board/articleForm.do">
					<c:if test="${not empty curCat}">
						<c:param name="cat" value="${curCat}" />
					</c:if>
					<c:if test="${not empty curSub}">
						<c:param name="sub" value="${curSub}" />
					</c:if>
				</c:url>
				<a class="cl-btn" href="${writeUrl}">글쓰기</a>
			</form>
		</header>

		<%-- ====== 서브카테고리 탭바 (cat 있을 때만) ====== --%>
		<c:if test="${not empty curCat}">
			<nav class="cl-subtabs" aria-label="세부 카테고리">
				<div class="cl-subtabs__row">
					<c:choose>
						<c:when test="${curCat=='politics'}">
							<a class="cl-tab ${curSub=='election'  ? 'is-active':''}"
								href="<c:url value='/board/listArticles.do?cat=politics&sub=election'/>">선거</a>
							<a class="cl-tab ${curSub=='assembly'  ? 'is-active':''}"
								href="<c:url value='/board/listArticles.do?cat=politics&sub=assembly'/>">국회</a>
							<a class="cl-tab ${curSub=='bluehouse' ? 'is-active':''}"
								href="<c:url value='/board/listArticles.do?cat=politics&sub=bluehouse'/>">정부/청와대</a>
						</c:when>
						<c:when test="${curCat=='economy'}">
							<a class="cl-tab ${curSub=='market' ? 'is-active':''}"
								href="<c:url value='/board/listArticles.do?cat=economy&sub=market'/>">증시</a>
							<a class="cl-tab ${curSub=='macro'  ? 'is-active':''}"
								href="<c:url value='/board/listArticles.do?cat=economy&sub=macro'/>">거시</a>
							<a class="cl-tab ${curSub=='industry'? 'is-active':''}"
								href="<c:url value='/board/listArticles.do?cat=economy&sub=industry'/>">산업</a>
						</c:when>
						<c:when test="${curCat=='society'}">
							<a class="cl-tab ${curSub=='incident' ? 'is-active':''}"
								href="<c:url value='/board/listArticles.do?cat=society&sub=incident'/>">사건사고</a>
							<a class="cl-tab ${curSub=='welfare'  ? 'is-active':''}"
								href="<c:url value='/board/listArticles.do?cat=society&sub=welfare'/>">복지/노동</a>
							<a class="cl-tab ${curSub=='education'? 'is-active':''}"
								href="<c:url value='/board/listArticles.do?cat=society&sub=education'/>">교육</a>
						</c:when>
						<c:when test="${curCat=='culture'}">
							<a class="cl-tab ${curSub=='movie' ? 'is-active':''}"
								href="<c:url value='/board/listArticles.do?cat=culture&sub=movie'/>">영화</a>
							<a class="cl-tab ${curSub=='music' ? 'is-active':''}"
								href="<c:url value='/board/listArticles.do?cat=culture&sub=music'/>">음악</a>
							<a class="cl-tab ${curSub=='book'  ? 'is-active':''}"
								href="<c:url value='/board/listArticles.do?cat=culture&sub=book'/>">책</a>
						</c:when>
						<c:when test="${curCat=='world'}">
							<a class="cl-tab ${curSub=='usa'    ? 'is-active':''}"
								href="<c:url value='/board/listArticles.do?cat=world&sub=usa'/>">미국</a>
							<a class="cl-tab ${curSub=='china'  ? 'is-active':''}"
								href="<c:url value='/board/listArticles.do?cat=world&sub=china'/>">중국</a>
							<a class="cl-tab ${curSub=='europe' ? 'is-active':''}"
								href="<c:url value='/board/listArticles.do?cat=world&sub=europe'/>">유럽</a>
							<a class="cl-tab ${curSub=='meafrica'? 'is-active':''}"
								href="<c:url value='/board/listArticles.do?cat=world&sub=meafrica'/>">중동/아프리카</a>
						</c:when>
						<c:when test="${curCat=='sports'}">
							<a class="cl-tab ${curSub=='football' ? 'is-active':''}"
								href="<c:url value='/board/listArticles.do?cat=sports&sub=football'/>">축구</a>
							<a class="cl-tab ${curSub=='baseball' ? 'is-active':''}"
								href="<c:url value='/board/listArticles.do?cat=sports&sub=baseball'/>">야구</a>
							<a class="cl-tab ${curSub=='esports'  ? 'is-active':''}"
								href="<c:url value='/board/listArticles.do?cat=sports&sub=esports'/>">e스포츠</a>
						</c:when>
						<c:when test="${curCat=='tech'}">
							<a class="cl-tab ${curSub=='ai'     ? 'is-active':''}"
								href="<c:url value='/board/listArticles.do?cat=tech&sub=ai'/>">AI</a>
							<a class="cl-tab ${curSub=='mobile' ? 'is-active':''}"
								href="<c:url value='/board/listArticles.do?cat=tech&sub=mobile'/>">모바일</a>
							<a class="cl-tab ${curSub=='science'? 'is-active':''}"
								href="<c:url value='/board/listArticles.do?cat=tech&sub=science'/>">과학</a>
						</c:when>
					</c:choose>
				</div>
			</nav>
		</c:if>

		<%-- ====== 섹션 렌더링 ====== --%>
		<c:set var="limit" value="6" />

		<c:choose>
			<%-- 1) 전체 페이지: 카테고리별 섹션 --%>
			<c:when test="${empty curCat}">
				<c:set var="cats"
					value="politics,economy,society,culture,world,sports,tech" />
				<c:forTokens var="catKey" items="${cats}" delims=",">
					<c:choose>
						<c:when test="${catKey=='politics'}">
							<c:set var="catTitle" value="정치" />
						</c:when>
						<c:when test="${catKey=='economy'}">
							<c:set var="catTitle" value="경제" />
						</c:when>
						<c:when test="${catKey=='society'}">
							<c:set var="catTitle" value="사회" />
						</c:when>
						<c:when test="${catKey=='culture'}">
							<c:set var="catTitle" value="문화" />
						</c:when>
						<c:when test="${catKey=='world'}">
							<c:set var="catTitle" value="국제" />
						</c:when>
						<c:when test="${catKey=='sports'}">
							<c:set var="catTitle" value="스포츠" />
						</c:when>
						<c:when test="${catKey=='tech'}">
							<c:set var="catTitle" value="IT·과학" />
						</c:when>
					</c:choose>

					<%-- 개수 카운트 --%>
					<c:set var="cnt" value="0" />
					<c:forEach var="a" items="${listData}">
						<c:if test="${a.cat == catKey}">
							<c:set var="cnt" value="${cnt + 1}" />
						</c:if>
					</c:forEach>

					<c:if test="${cnt > 0}">
						<section class="cl-sec">
							<div class="cl-sec__head">
								<h2 class="cl-sec__title">${catTitle}</h2>
								<a class="cl-sec__more"
									href="<c:url value='/board/listArticles.do?cat=${catKey}'/>">더보기</a>
							</div>

							<ul class="cl-sec__grid">
								<c:set var="printed" value="0" />
								<c:forEach var="a" items="${listData}">
									<c:if test="${a.cat == catKey && printed < limit}">
										<li class="cl-item"><a class="cl-thumb"
											href="<c:url value='/board/viewArticle.do'><c:param name='articleNO' value='${a.articleNO}'/></c:url>">
												<c:choose>
													<c:when test="${not empty a.imageFileName}">
														<img
															src="<c:url value='/board/img/${a.articleNO}/${a.imageFileName}'/>"
															alt="${fn:escapeXml(a.title)}" />
													</c:when>
													<c:otherwise>
														<div class="cl-thumb__placeholder" aria-hidden="true">No
															Image</div>
													</c:otherwise>
												</c:choose>
										</a>
											<div class="cl-body">
												<a class="cl-cat"
													href="<c:url value='/board/listArticles.do?cat=${a.cat}&sub=${a.sub}'/>">${a.cat}
													· ${a.sub}</a>
												<h3 class="cl-title__h3">
													<a
														href="<c:url value='/board/viewArticle.do'><c:param name='articleNO' value='${a.articleNO}'/></c:url>">${fn:escapeXml(a.title)}</a>
												</h3>
												<p class="cl-meta">작성자 ${fn:escapeXml(a.id)} ·
													${a.writeDate}</p>
											</div></li>
										<c:set var="printed" value="${printed + 1}" />
									</c:if>
								</c:forEach>
							</ul>
						</section>
					</c:if>
				</c:forTokens>
			</c:when>

			<%-- 2) 특정 카테고리 페이지: 서브카테고리별 섹션 --%>
			<c:otherwise>
				<c:choose>
					<c:when test="${curCat=='politics'}">
						<c:set var="subs" value="election,assembly,bluehouse" />
						<c:set var="titles" value="선거,국회,정부/청와대" />
					</c:when>
					<c:when test="${curCat=='economy'}">
						<c:set var="subs" value="market,macro,industry" />
						<c:set var="titles" value="증시,거시,산업" />
					</c:when>
					<c:when test="${curCat=='society'}">
						<c:set var="subs" value="incident,welfare,education" />
						<c:set var="titles" value="사건사고,복지/노동,교육" />
					</c:when>
					<c:when test="${curCat=='culture'}">
						<c:set var="subs" value="movie,music,book" />
						<c:set var="titles" value="영화,음악,책" />
					</c:when>
					<c:when test="${curCat=='world'}">
						<c:set var="subs" value="usa,china,europe,meafrica" />
						<c:set var="titles" value="미국,중국,유럽,중동/아프리카" />
					</c:when>
					<c:when test="${curCat=='sports'}">
						<c:set var="subs" value="football,baseball,esports" />
						<c:set var="titles" value="축구,야구,e스포츠" />
					</c:when>
					<c:when test="${curCat=='tech'}">
						<c:set var="subs" value="ai,mobile,science" />
						<c:set var="titles" value="AI,모바일,과학" />
					</c:when>
				</c:choose>

				<c:forTokens var="subKey" items="${subs}" delims="," varStatus="st">
					<c:set var="subTitle" value="${fn:split(titles, ',')[st.index]}" />

					<%-- 개수 카운트 --%>
					<c:set var="cnt" value="0" />
					<c:forEach var="a" items="${listData}">
						<c:if test="${a.cat == curCat && a.sub == subKey}">
							<c:set var="cnt" value="${cnt + 1}" />
						</c:if>
					</c:forEach>

					<c:if test="${cnt > 0}">
						<section class="cl-sec">
							<div class="cl-sec__head">
								<h2 class="cl-sec__title">${subTitle}</h2>
								<a class="cl-sec__more"
									href="<c:url value='/board/listArticles.do?cat=${curCat}&sub=${subKey}'/>">더보기</a>
							</div>

							<ul class="cl-sec__grid">
								<c:set var="printed" value="0" />
								<c:forEach var="a" items="${listData}">
									<c:if
										test="${a.cat == curCat && a.sub == subKey && printed < limit}">
										<li class="cl-item"><a class="cl-thumb"
											href="<c:url value='/board/viewArticle.do'><c:param name='articleNO' value='${a.articleNO}'/></c:url>">
												<c:choose>
													<c:when test="${not empty a.imageFileName}">
														<img
															src="<c:url value='/board/img/${a.articleNO}/${a.imageFileName}'/>"
															alt="${fn:escapeXml(a.title)}" />
													</c:when>
													<c:otherwise>
														<div class="cl-thumb__placeholder" aria-hidden="true">No
															Image</div>
													</c:otherwise>
												</c:choose>
										</a>
											<div class="cl-body">
												<a class="cl-cat"
													href="<c:url value='/board/listArticles.do?cat=${a.cat}&sub=${a.sub}'/>">${a.cat}
													· ${a.sub}</a>
												<h3 class="cl-title__h3">
													<a
														href="<c:url value='/board/viewArticle.do'><c:param name='articleNO' value='${a.articleNO}'/></c:url>">${fn:escapeXml(a.title)}</a>
												</h3>
												<p class="cl-meta">작성자 ${fn:escapeXml(a.id)} ·
													${a.writeDate}</p>
											</div></li>
										<c:set var="printed" value="${printed + 1}" />
									</c:if>
								</c:forEach>
							</ul>
						</section>
					</c:if>
				</c:forTokens>
			</c:otherwise>
		</c:choose>

		<%-- 페이지네이션은 기존 그대로 유지 (섹션형에서는 보통 숨김) --%>
		<c:if
			test="${not empty page and not empty totalPages and not empty curCat and not empty curSub}">
			<nav class="cl-paging" aria-label="페이지네이션">
				<c:if test="${page > 1}">
					<a class="cl-page"
						href="<c:url value='/board/listArticles.do'><c:param name='cat' value='${curCat}'/><c:param name='sub' value='${curSub}'/><c:param name='page' value='${page-1}'/></c:url>">이전</a>
				</c:if>
				<span class="cl-page__status">${page} / ${totalPages}</span>
				<c:if test="${page < totalPages}">
					<a class="cl-page"
						href="<c:url value='/board/listArticles.do'><c:param name='cat' value='${curCat}'/><c:param name='sub' value='${curSub}'/><c:param name='page' value='${page+1}'/></c:url>">다음</a>
				</c:if>
			</nav>
		</c:if>
	</div>
</div>
