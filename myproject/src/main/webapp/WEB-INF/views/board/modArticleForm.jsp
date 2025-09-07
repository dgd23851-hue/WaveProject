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

<c:set var="articleNO" value="${a.articleNO}" />
<c:set var="title" value="${a.title}" />
<c:set var="writer" value="${a.id}" />
<c:set var="cat" value="${a.cat}" />
<c:set var="sub" value="${a.sub}" />
<c:set var="imageFileName" value="${a.imageFileName}" />
<c:set var="content" value="${a.content}" />

<link rel="stylesheet"
	href="<c:url value='/resources/css/modArticleForm.css'/>?v=1" />

<div class="ma2-main" role="main" data-article-no="${articleNO}">
	<div class="ma2-container">
		<header class="ma2-head">
			<h1 class="ma2-title">기사 수정</h1>
			<nav class="ma2-breadcrumb">
				<a href="<c:url value='/'/>">홈</a> <span class="sep">›</span> <a
					href="<c:url value='/board/listArticles.do'/>">기사 목록</a> <span
					class="sep">›</span> <span>수정</span>
			</nav>
		</header>

		<form id="ma2-form" class="ma2-form" method="post"
			action="<c:url value='/board/modArticle.do'/>"
			enctype="multipart/form-data">
			<c:if test="${_csrf != null}">
				<input type="hidden" name="${_csrf.parameterName}"
					value="${_csrf.token}" />
			</c:if>
			<input type="hidden" name="articleNO" value="${articleNO}" /> <input
				type="hidden" name="returnUrl"
				value="<c:url value='/board/viewArticle.do'><c:param name='articleNO' value='${articleNO}'/></c:url>" />

			<!-- Title -->
			<div class="ma2-field">
				<label for="title">제목</label>
				<div class="ma2-titleRow">
					<input id="title" name="title" type="text" maxlength="150"
						value="${fn:escapeXml(title)}" placeholder="제목을 입력하세요" required />
					<span class="ma2-counter" id="titleCount">0/150</span>
				</div>
			</div>

			<!-- Category / Sub -->
			<div class="ma2-row">
				<div class="ma2-field">
					<label for="cat">카테고리</label> <select id="cat" name="cat" required>
						<option value="" ${empty cat ? 'selected' : ''} disabled>선택</option>
						<option value="politics" ${cat=='politics' ? 'selected' : ''}>정치</option>
						<option value="economy" ${cat=='economy'  ? 'selected' : ''}>경제</option>
						<option value="society" ${cat=='society'  ? 'selected' : ''}>사회</option>
						<option value="culture" ${cat=='culture'  ? 'selected' : ''}>문화</option>
						<option value="world" ${cat=='world'    ? 'selected' : ''}>국제</option>
						<option value="sports" ${cat=='sports'   ? 'selected' : ''}>스포츠</option>
						<option value="tech" ${cat=='tech'     ? 'selected' : ''}>IT·과학</option>
					</select>
				</div>
				<div class="ma2-field">
					<label for="sub">세부</label> <select id="sub" name="sub"
						data-initial="${fn:escapeXml(sub)}">
						<option value="">-</option>
					</select>
				</div>
			</div>

			<!-- Image -->
			<div class="ma2-field">
				<label>대표 이미지</label>
				<div class="ma2-uploader" id="uploader" aria-label="이미지 업로드">
					<input id="image" name="image" type="file" accept="image/*" />
					<div class="ma2-drop" id="dropzone">
						<div class="ma2-drop__header">
							<button type="button" class="ma2-choose" id="btnChoose">이미지
								선택</button>
							<span class="ma2-drop__hint">또는 파일을 이 영역으로 드래그하세요 (JPG ·
								PNG · GIF · WEBP · 최대 10MB)</span>
						</div>
						<div class="ma2-cards" id="cards" aria-live="polite">
							<!-- JS fills -->
						</div>
					</div>
				</div>
				<c:if test="${not empty imageFileName}">
					<div class="ma2-current">
						<img
							src="<c:url value='/board/img/${articleNO}/${imageFileName}'/>"
							alt="현재 이미지"> <label class="ma2-remove"><input
							type="checkbox" name="removeImage" value="1"> 현재 이미지 삭제</label>
					</div>
				</c:if>
			</div>

			<!-- Content -->
			<div class="ma2-field">
				<label for="content">본문</label>
				<textarea id="content" name="content" rows="16"
					placeholder="본문을 입력하세요" required>${fn:escapeXml(content)}</textarea>
			</div>

			<!-- Tags (optional) -->
			<div class="ma2-field">
				<label for="tags">태그</label> <input id="tags" name="tags"
					type="text" placeholder="쉼표(,)로 구분해 입력 (예: 경제,주식,환율)"
					value="${fn:escapeXml(param.tags)}" />
			</div>

			<!-- Actions -->
			<div class="ma2-actions">
				<a class="ma2-btn is-ghost"
					href="<c:url value='/board/viewArticle.do'><c:param name='articleNO' value='${articleNO}'/></c:url>">취소</a>
				<div class="ma2-flex"></div>
				<button type="button" class="ma2-btn is-outline" id="btnPreview">미리보기</button>
				<button type="button" class="ma2-btn" id="btnSaveDraft">임시저장</button>
				<button type="submit" class="ma2-btn is-primary" id="btnSubmit">저장</button>
			</div>
		</form>
	</div>

	<!-- Preview modal -->
	<div class="ma2-modal" id="previewModal" role="dialog"
		aria-modal="true" aria-labelledby="pvTitle">
		<div class="ma2-modal__card">
			<header class="ma2-modal__head">
				<h3 id="pvTitle">미리보기</h3>
				<button class="ma2-close" data-close>×</button>
			</header>
			<div class="ma2-modal__body">
				<h2 class="pv-title"></h2>
				<div class="pv-meta"></div>
				<figure class="pv-figure is-hidden">
					<img alt="">
				</figure>
				<div class="pv-content"></div>
			</div>
			<footer class="ma2-modal__foot">
				<button class="ma2-btn is-primary" data-close>닫기</button>
			</footer>
		</div>
	</div>

	<!-- Toast -->
	<div class="ma2-toast" id="toast" aria-live="polite"></div>
</div>

<script defer
	src="<c:url value='/resources/js/modArticleForm.js'/>?v=1"></script>
