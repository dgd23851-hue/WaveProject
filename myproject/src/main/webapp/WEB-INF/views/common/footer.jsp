<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" isELIgnored="false"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<link rel="stylesheet" href="<c:url value='/resources/css/style.css'/>">
<link rel="stylesheet" href="<c:url value='/resources/css/footer.css'/>">
<footer class="site-footer" role="contentinfo">
	<div class="footer-grid">
		<section class="foot-block">
			<a class="brand" href="<c:url value='/'/>">WAVE NEWS</a>
			<p class="tagline">빠르고 선명한 뉴스</p>
			<p class="copy">ⓒ 2025 WAVE NEWS. 일부 콘텐츠의 저작권은 각 언론사에 있습니다.</p>
		</section>

		<nav class="foot-block" aria-label="섹션">
			<h3>섹션</h3>
			<ul class="foot-list">
				<li><a
					href="<c:url value='/board/listArticles.do?cat=politics'/>">정치</a></li>
				<li><a
					href="<c:url value='/board/listArticles.do?cat=economy'/>">경제</a></li>
				<li><a
					href="<c:url value='/board/listArticles.do?cat=society'/>">사회</a></li>
				<li><a
					href="<c:url value='/board/listArticles.do?cat=culture'/>">문화</a></li>
				<li><a href="<c:url value='/board/listArticles.do?cat=world'/>">세계</a></li>
				<li><a
					href="<c:url value='/board/listArticles.do?cat=sports'/>">스포츠</a></li>
			</ul>
		</nav>

		<nav class="foot-block" aria-label="도움말">
			<h3>도움말</h3>
			<ul class="foot-list">
				<li><a href="<c:url value='/about.do'/>">회사소개</a></li>
				<li><a href="<c:url value='/contact.do'/>">제보/문의</a></li>
				<li><a href="<c:url value='/advertise.do'/>">광고문의</a></li>
				<li><a href="<c:url value='/faq.do'/>">자주 묻는 질문</a></li>
			</ul>
		</nav>

		<section class="foot-block" aria-label="연락처">
			<h3>연락처</h3>
			<ul class="foot-list">
				<li><a href="mailto:admin@wave.com">admin@wave.com</a></li>
				<li><span>02-000-0000</span></li>
				<li><span>대전광역시</span></li>
			</ul>

			<div class="social">
				<a href="#" aria-label="X"> <svg viewBox="0 0 24 24" width="18"
						height="18" aria-hidden="true">
						<path fill="currentColor"
							d="M3 3h3l6 8 6-8h3l-7.5 10L21 21h-3l-6-8-6 8H3l7.5-10L3 3z" /></svg>
				</a> <a href="#" aria-label="YouTube"> <svg viewBox="0 0 24 24"
						width="18" height="18" aria-hidden="true">
						<path fill="currentColor"
							d="M23 7s-.2-1.4-.8-2C21.5 4 20.5 4 20.5 4 17 3.7 12 3.7 12 3.7h0S7 3.7 3.5 4c0 0-1 .1-1.7 1C1.2 5.6 1 7 1 7S.8 8.6.8 10.2v1.6C.8 13.4 1 15 1 15s.2 1.4.8 2c.7.9 1.7 1 1.7 1C7 18.3 12 18.3 12 18.3s5 0 8.5-.3c0 0 1-.1 1.7-1 .6-.6.8-2 .8-2s.2-1.6.2-3.2v-1.6C23.2 8.6 23 7 23 7zM9.8 14.6V7.9l6 3.4-6 3.3z" /></svg>
				</a> <a href="#" aria-label="Instagram"> <svg viewBox="0 0 24 24"
						width="18" height="18" aria-hidden="true">
						<path fill="currentColor"
							d="M7 2h10a5 5 0 015 5v10a5 5 0 01-5 5H7a5 5 0 01-5-5V7a5 5 0 015-5zm5 5a5 5 0 100 10 5 5 0 000-10zm6.5-.9a1.1 1.1 0 110 2.2 1.1 1.1 0 010-2.2zM12 9a3 3 0 110 6 3 3 0 010-6z" /></svg>
				</a>
			</div>
		</section>
	</div>

	<div class="foot-bottom">
		<div class="legal">
			<a href="<c:url value='/tos.do'/>">이용약관</a> <span aria-hidden="true">·</span>
			<a href="<c:url value='/privacy.do'/>">개인정보처리방침</a> <span
				aria-hidden="true">·</span> <a href="<c:url value='/youth.do'/>">청소년보호정책</a>
		</div>
	</div>
</footer>
