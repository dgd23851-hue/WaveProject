<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" isELIgnored="false"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<c:set var="pTitle" value="${empty param.title ? '' : param.title}" />
<c:set var="pCat" value="${empty param.cat   ? '' : param.cat}" />
<c:set var="pSub" value="${empty param.sub   ? '' : param.sub}" />
<c:set var="pTags" value="${empty param.tags  ? '' : param.tags}" />
<c:set var="pCont" value="${empty param.content ? '' : param.content}" />

<link rel="stylesheet"
	href="<c:url value='/resources/css/articleForm.css'/>?v=1" />

<div class="wa2-main" role="main" data-article-no="new">
	<div class="wa2-container">
		<header class="wa2-head">
			<h1 class="wa2-title">새 글쓰기</h1>
			<nav class="wa2-breadcrumb">
				<a href="<c:url value='/'/>">홈</a> <span class="sep">›</span> <a
					href="<c:url value='/board/listArticles.do'/>">기사 목록</a> <span
					class="sep">›</span> <span>작성</span>
			</nav>
		</header>

		<!-- action을 addNewArticle.do(POST)로 변경 -->
		<form id="wa2-form" class="wa2-form" method="post"
			action="<c:url value='/board/addNewArticle.do'/>"
			enctype="multipart/form-data">
			<c:if test="${_csrf != null}">
				<input type="hidden" name="${_csrf.parameterName}"
					value="${_csrf.token}" />
			</c:if>
			<input type="hidden" name="returnUrl"
				value="<c:url value='/board/listArticles.do'/>" />

			<!-- Title -->
			<div class="wa2-field">
				<label for="title">제목</label>
				<div class="wa2-titleRow">
					<input id="title" name="title" type="text" maxlength="150"
						value="${fn:escapeXml(pTitle)}" placeholder="제목을 입력하세요" required />
					<span class="wa2-counter" id="titleCount">0/150</span>
				</div>
			</div>

			<!-- Category / Sub -->
			<div class="wa2-row">
				<div class="wa2-field">
					<label for="cat">카테고리</label> <select id="cat" name="cat" required>
						<option value="" ${empty pCat ? 'selected' : ''} disabled>선택</option>
						<option value="politics" ${pCat=='politics' ? 'selected' : ''}>정치</option>
						<option value="economy" ${pCat=='economy'  ? 'selected' : ''}>경제</option>
						<option value="society" ${pCat=='society'  ? 'selected' : ''}>사회</option>
						<option value="culture" ${pCat=='culture'  ? 'selected' : ''}>문화</option>
						<option value="world" ${pCat=='world'    ? 'selected' : ''}>국제</option>
						<option value="sports" ${pCat=='sports'   ? 'selected' : ''}>스포츠</option>
						<option value="tech" ${pCat=='tech'     ? 'selected' : ''}>IT·과학</option>
					</select>
				</div>
				<div class="wa2-field">
					<label for="sub">세부</label> <select id="sub" name="sub"
						data-initial="${fn:escapeXml(pSub)}">
						<option value="">-</option>
					</select>
				</div>
			</div>

			<!-- Image -->
			<div class="wa2-field">
				<label>대표 이미지</label>
				<div class="wa2-uploader" id="uploader" aria-label="이미지 업로드">
					<!-- name을 imageFile로 변경 -->
					<input id="image" name="imageFile" type="file" accept="image/*" />
					<div class="wa2-drop" id="dropzone">
						<div class="wa2-drop__header">
							<button type="button" class="wa2-choose" id="btnChoose">이미지
								선택</button>
							<span class="wa2-drop__hint">또는 파일을 이 영역으로 드래그하세요 (JPG ·
								PNG · GIF · WEBP · 최대 10MB)</span>
						</div>
						<div class="wa2-cards" id="cards" aria-live="polite"></div>
					</div>
				</div>
			</div>

			<!-- Content -->
			<div class="wa2-field">
				<label for="content">본문</label>
				<textarea id="content" name="content" rows="16"
					placeholder="본문을 입력하세요" required>${fn:escapeXml(pCont)}</textarea>
			</div>

			<!-- Tags (optional) -->
			<div class="wa2-field">
				<label for="tags">태그</label> <input id="tags" name="tags"
					type="text" placeholder="쉼표(,)로 구분해 입력 (예: 경제,주식,환율)"
					value="${fn:escapeXml(pTags)}" />
			</div>

			<!-- Actions -->
			<div class="wa2-actions">
				<a class="wa2-btn is-ghost"
					href="<c:url value='/board/listArticles.do'/>">취소</a>
				<div class="wa2-flex"></div>
				<button type="button" class="wa2-btn is-outline" id="btnPreview">미리보기</button>
				<button type="button" class="wa2-btn" id="btnSaveDraft">임시저장</button>
				<button type="submit" class="wa2-btn is-primary" id="btnSubmit">등록</button>
			</div>
		</form>
	</div>

	<!-- Preview modal -->
	<div class="wa2-modal" id="previewModal" role="dialog"
		aria-modal="true" aria-labelledby="pvTitle">
		<div class="wa2-modal__card">
			<header class="wa2-modal__head">
				<h3 id="pvTitle">미리보기</h3>
				<button class="wa2-close" data-close>×</button>
			</header>
			<div class="wa2-modal__body">
				<h2 class="pv-title"></h2>
				<div class="pv-meta"></div>
				<figure class="pv-figure is-hidden">
					<img alt="">
				</figure>
				<div class="pv-content"></div>
			</div>
			<footer class="wa2-modal__foot">
				<button class="wa2-btn is-primary" data-close>닫기</button>
			</footer>
		</div>
	</div>

	<div class="wa2-toast" id="toast" aria-live="polite"></div>
</div>

<script defer src="<c:url value='/resources/js/articleForm.js'/>?v=1"></script>