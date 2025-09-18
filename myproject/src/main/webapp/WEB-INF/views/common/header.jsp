<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" isELIgnored="false"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="curCat" value="${param.cat}" />
<c:set var="curSub" value="${param.sub}" />

<!-- Revamped News Header -->
<link rel="stylesheet" href="<c:url value='/resources/css/header.css'/>">

<header class="nh-header" role="banner">
	<!-- Topbar -->
	<div class="nh-topbar">
		<div class="nh-container nh-topbar__inner">
			<div class="nh-topbar__left">
				<span class="nh-topbar__brand">WAVE NEWS</span> <span
					class="nh-topbar__dot" aria-hidden="true">•</span>
				<time id="nh-now" class="nh-topbar__time" aria-live="polite">—</time>
			</div>
			<nav class="nh-topbar__links" aria-label="유틸리티 메뉴">
				<c:choose>
					<c:when test="${not empty sessionScope.member}">
						<c:set var="displayName"
							value="${not empty sessionScope.member.name ? sessionScope.member.name :
                 (not empty sessionScope.member.memberName ? sessionScope.member.memberName :
                  (not empty sessionScope.member.username ? sessionScope.member.username :
                   (not empty sessionScope.member.userName ? sessionScope.member.userName :
                    (not empty sessionScope.member.id ? sessionScope.member.id : '회원'))))}" />
						<span class="nh-topbar__hello"><c:out
								value="${displayName}" />님</span>
						<span class="nh-topbar__dot" aria-hidden="true">•</span>
						<a href="<c:url value='/member/logout.do'/>">로그아웃</a>
					</c:when>
					<c:otherwise>
						<a href="<c:url value='/member/loginForm.do'/>">로그인</a>
						<a href="<c:url value='/member/loginForm.do'/>?tab=signup">회원가입</a>
					</c:otherwise>
				</c:choose>
			</nav>
		</div>
	</div>

	<!-- Masthead -->
	<div class="nh-masthead">
		<div class="nh-container nh-masthead__inner">
			<a class="nh-logo" href="<c:url value='/main.do'/>" aria-label="홈으로">
				<span class="nh-logo__mark">W</span> <span class="nh-logo__type">Wave
					News</span>
			</a>

			<form class="nh-search" role="search" method="get"
				action="<c:url value='/board/listArticles.do'/>">
				<label class="sr-only" for="q">검색</label> <input id="q" name="q"
					type="search" placeholder="검색어를 입력하세요" value="${param.q}" />
				<button type="submit" class="nh-btn">검색</button>
			</form>

			<button id="nh-burger" class="nh-burger" aria-expanded="false"
				aria-controls="nh-primary">
				<span class="sr-only">메뉴 열기</span> <span class="nh-burger__bar"
					aria-hidden="true"></span> <span class="nh-burger__bar"
					aria-hidden="true"></span> <span class="nh-burger__bar"
					aria-hidden="true"></span>
			</button>
		</div>
	</div>

	<!-- Primary Nav -->
	<nav id="nh-primary" class="nh-nav" role="navigation"
		aria-label="주요 카테고리">
		<div class="nh-container">
			<ul class="nh-nav__list">
				<li class="nh-nav__item ${curCat=='politics' ? 'is-active' : ''}">
					<button class="nh-nav__btn" aria-expanded="false"
						data-target="sub-politics">정치</button>
				</li>
				<li class="nh-nav__item ${curCat=='economy' ? 'is-active' : ''}">
					<button class="nh-nav__btn" aria-expanded="false"
						data-target="sub-economy">경제</button>
				</li>
				<li class="nh-nav__item ${curCat=='society' ? 'is-active' : ''}">
					<button class="nh-nav__btn" aria-expanded="false"
						data-target="sub-society">사회</button>
				</li>
				<li class="nh-nav__item ${curCat=='culture' ? 'is-active' : ''}">
					<button class="nh-nav__btn" aria-expanded="false"
						data-target="sub-culture">문화</button>
				</li>
				<li class="nh-nav__item ${curCat=='world' ? 'is-active' : ''}">
					<button class="nh-nav__btn" aria-expanded="false"
						data-target="sub-world">국제</button>
				</li>
				<li class="nh-nav__item ${curCat=='sports' ? 'is-active' : ''}">
					<button class="nh-nav__btn" aria-expanded="false"
						data-target="sub-sports">스포츠</button>
				</li>
				<li class="nh-nav__item ${curCat=='tech' ? 'is-active' : ''}">
					<button class="nh-nav__btn" aria-expanded="false"
						data-target="sub-tech">IT/과학</button>
				</li>
			</ul>
		</div>

		<!-- Mega rows -->
		<div class="nh-mega" aria-live="polite">
			<!-- 정치 -->
			<div class="nh-mega__row" id="sub-politics">
				<a
					class="chip${curCat=='politics' && curSub=='election'  ? ' active' : ''}"
					href="<c:url value='/board/listArticles.do?cat=politics&sub=election'/>">선거</a>
				<a
					class="chip${curCat=='politics' && curSub=='assembly'  ? ' active' : ''}"
					href="<c:url value='/board/listArticles.do?cat=politics&sub=assembly'/>">국회</a>
				<a
					class="chip${curCat=='politics' && curSub=='bluehouse' ? ' active' : ''}"
					href="<c:url value='/board/listArticles.do?cat=politics&sub=bluehouse'/>">정부/청와대</a>
			</div>

			<!-- 경제 -->
			<div class="nh-mega__row" id="sub-economy">
				<a
					class="chip${curCat=='economy' && curSub=='market' ? ' active' : ''}"
					href="<c:url value='/board/listArticles.do?cat=economy&sub=market'/>">증시</a>
				<a
					class="chip${curCat=='economy' && curSub=='macro'  ? ' active' : ''}"
					href="<c:url value='/board/listArticles.do?cat=economy&sub=macro'/>">거시</a>
				<a
					class="chip${curCat=='economy' && curSub=='industry'? ' active' : ''}"
					href="<c:url value='/board/listArticles.do?cat=economy&sub=industry'/>">산업</a>
			</div>

			<!-- 사회 -->
			<div class="nh-mega__row" id="sub-society">
				<a
					class="chip${curCat=='society' && curSub=='incident' ? ' active' : ''}"
					href="<c:url value='/board/listArticles.do?cat=society&sub=incident'/>">사건사고</a>
				<a
					class="chip${curCat=='society' && curSub=='welfare'  ? ' active' : ''}"
					href="<c:url value='/board/listArticles.do?cat=society&sub=welfare'/>">복지/노동</a>
				<a
					class="chip${curCat=='society' && curSub=='education'? ' active' : ''}"
					href="<c:url value='/board/listArticles.do?cat=society&sub=education'/>">교육</a>
			</div>

			<!-- 문화 -->
			<div class="nh-mega__row" id="sub-culture">
				<a
					class="chip${curCat=='culture' && curSub=='movie' ? ' active' : ''}"
					href="<c:url value='/board/listArticles.do?cat=culture&sub=movie'/>">영화</a>
				<a
					class="chip${curCat=='culture' && curSub=='music' ? ' active' : ''}"
					href="<c:url value='/board/listArticles.do?cat=culture&sub=music'/>">음악</a>
				<a
					class="chip${curCat=='culture' && curSub=='book'  ? ' active' : ''}"
					href="<c:url value='/board/listArticles.do?cat=culture&sub=book'/>">책</a>
			</div>

			<!-- 국제 -->
			<div class="nh-mega__row" id="sub-world">
				<a
					class="chip${curCat=='world' && curSub=='usa'   ? ' active' : ''}"
					href="<c:url value='/board/listArticles.do?cat=world&sub=usa'/>">미국</a>
				<a
					class="chip${curCat=='world' && curSub=='china' ? ' active' : ''}"
					href="<c:url value='/board/listArticles.do?cat=world&sub=china'/>">중국</a>
				<a
					class="chip${curCat=='world' && curSub=='europe'? ' active' : ''}"
					href="<c:url value='/board/listArticles.do?cat=world&sub=europe'/>">유럽</a>
				<a
					class="chip${curCat=='world' && curSub=='meafrica'? ' active' : ''}"
					href="<c:url value='/board/listArticles.do?cat=world&sub=meafrica'/>">중동/아프리카</a>
			</div>

			<!-- 스포츠 -->
			<div class="nh-mega__row" id="sub-sports">
				<a
					class="chip${curCat=='sports' && curSub=='football' ? ' active' : ''}"
					href="<c:url value='/board/listArticles.do?cat=sports&sub=football'/>">축구</a>
				<a
					class="chip${curCat=='sports' && curSub=='baseball' ? ' active' : ''}"
					href="<c:url value='/board/listArticles.do?cat=sports&sub=baseball'/>">야구</a>
				<a
					class="chip${curCat=='sports' && curSub=='esports'  ? ' active' : ''}"
					href="<c:url value='/board/listArticles.do?cat=sports&sub=esports'/>">e스포츠</a>
			</div>

			<!-- IT/과학 -->
			<div class="nh-mega__row" id="sub-tech">
				<a class="chip${curCat=='tech' && curSub=='ai'   ? ' active' : ''}"
					href="<c:url value='/board/listArticles.do?cat=tech&sub=ai'/>">AI</a>
				<a class="chip${curCat=='tech' && curSub=='mobile'? ' active' : ''}"
					href="<c:url value='/board/listArticles.do?cat=tech&sub=mobile'/>">모바일</a>
				<a
					class="chip${curCat=='tech' && curSub=='science'? ' active' : ''}"
					href="<c:url value='/board/listArticles.do?cat=tech&sub=science'/>">과학</a>
			</div>
		</div>
	</nav>
</header>

<script src="<c:url value='/resources/js/header.js'/>"></script>
