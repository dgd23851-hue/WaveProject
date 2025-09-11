<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" isELIgnored="false"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<%--
  안전한 통합본 JSP
  - ArticleVO에 존재하는지 확실치 않은 속성( writer, authorName, own 등 )은 절대 접근하지 않음
  - 댓글은 CommentDTO의 확실한 필드만 사용: id, writer, content, createdAt, replies
  - 댓글 등록/답글 action은 기본 /board/addComment.do (컨트롤러에서 필요시 모델로 덮어쓰기 가능)
  - 상단 목록 버튼 제거, 본문 하단에 "← 목록으로" 추가
--%>

<c:set var="actionCommentAdd"
	value="${empty actionCommentAdd ? 'comment/add.do' : actionCommentAdd}" />
<c:set var="actionCommentReply"
	value="${empty actionCommentReply ? 'comment/reply.do' : actionCommentReply}" />

<link rel="stylesheet"
	href="<c:url value='/resources/css/viewArticle.css'/>" />

<div class="va-main">
	<div class="va-container">

		<!-- 머리 -->
		<header class="va-head">
			<div class="va-breadcrumb">
				<a href="<c:url value='/'/>">홈</a> <span class="sep">/</span> <span>게시글</span>
			</div>

			<h1 class="va-title">
				<c:out value="${article.title}" />
			</h1>

			<%-- 작성자/소유자 표시는 제거 (ArticleVO 속성 불확실) --%>
		</header>

		<!-- 본문 -->
		<article class="va-article">
			<c:if test="${not empty article.content}">
				<pre
					style="white-space: pre-wrap; font-family: inherit; font-size: 1rem;">
					<c:out value="${article.content}" />
				</pre>
			</c:if>
			<c:if test="${empty article.content && not empty article.html}">
        ${article.html}
      </c:if>
		</article>

		<!-- 하단 액션 -->
		<div
			style="display: flex; gap: 8px; align-items: center; margin: 20px 0 30px;">
			<a class="va-btn is-outline"
				href="<c:url value='/board/listArticles.do'/>">← 목록으로</a>
			<c:url var="editUrl" value="/board/modArticleForm.do">
				<c:param name="articleNO" value="${param.articleNO}" />
			</c:url>
			<c:url var="deleteUrl" value="/board/removeArticle.do">
				<c:param name="articleNO" value="${param.articleNO}" />
			</c:url>
			<a class="va-btn is-ghost" href="${editUrl}">수정</a> <a
				class="va-btn is-ghost" href="${deleteUrl}"
				onclick="return confirm('정말 삭제하시겠습니까?');">삭제</a>
		</div>

		<!-- 댓글 작성 -->
		<section style="margin: 16px 0 24px">
			<h2 style="font-size: 1.1rem; margin: 0 0 10px">댓글</h2>

			<form method="post" action="${actionCommentAdd}" class="va-card">
				<input type="hidden" name="articleNO" value="${param.articleNO}" />
				<textarea name="content" rows="4"
					style="width: 100%; border: 1px solid var(- -line); border-radius: 10px; padding: 10px"
					placeholder="댓글을 입력하세요"></textarea>
				<div
					style="margin-top: 10px; display: flex; align-items: center; gap: 8px; flex-wrap: wrap">
					<button type="submit" class="va-btn">등록</button>
				</div>
				<c:if test="${not empty _csrf}">
					<input type="hidden" name="${_csrf.parameterName}"
						value="${_csrf.token}" />
				</c:if>
			</form>
		</section>

		<!-- 댓글 리스트 -->
		<section style="margin: 16px 0 50px">
			<c:forEach var="cmt" items="${comments}">
				<div style="border-top: 1px solid var(- -line); padding: 14px 0">
					<div class="va-meta" style="margin-bottom: 6px">
						<strong><c:out value="${cmt.writer}" /></strong> <span
							class="dot">·</span> <span> <fmt:formatDate
								value="${cmt.createdAt}" pattern="yyyy-MM-dd HH:mm" />
						</span>
					</div>

					<div style="white-space: pre-wrap">
						<c:out value="${cmt.content}" />
					</div>

					<div class="va-actions" style="margin-top: 8px">
						<a class="va-btn is-ghost" href="javascript:void(0)"
							onclick="toggleReplyForm('${cmt.id}')">답글</a>
					</div>

					<!-- 답글 폼 -->
					<div id="reply-${cmt.id}" style="display: none; margin-top: 10px">
						<form method="post" action="${actionCommentReply}"
							style="border: 1px solid var(- -line); border-radius: 12px; padding: 10px">
							<input type="hidden" name="articleNO" value="${param.articleNO}" />
							<input type="hidden" name="parentId" value="${cmt.id}" />
							<textarea name="content" rows="3"
								style="width: 100%; border: 1px solid var(- -line); border-radius: 10px; padding: 10px"
								placeholder="답글을 입력하세요"></textarea>
							<div
								style="margin-top: 8px; display: flex; align-items: center; gap: 8px; flex-wrap: wrap">
								<button type="submit" class="va-btn">등록</button>
							</div>
							<c:if test="${not empty _csrf}">
								<input type="hidden" name="${_csrf.parameterName}"
									value="${_csrf.token}" />
							</c:if>
						</form>
					</div>

					<!-- 대댓글 -->
					<c:if test="${not empty cmt.replies}">
						<div
							style="margin-top: 12px; padding-left: 14px; border-left: 2px solid var(- -line)">
							<c:forEach var="rp" items="${cmt.replies}">
								<div
									style="padding: 10px 0; border-top: 1px dashed var(- -line)">
									<div class="va-meta" style="margin-bottom: 6px">
										<strong><c:out value="${rp.writer}" /></strong> <span
											class="dot">·</span> <span><fmt:formatDate
												value="${rp.createdAt}" pattern="yyyy-MM-dd HH:mm" /></span>
									</div>
									<div style="white-space: pre-wrap">
										<c:out value="${rp.content}" />
									</div>
								</div>
							</c:forEach>
						</div>
					</c:if>
				</div>
			</c:forEach>
		</section>

	</div>
</div>

<script>
	function toggleReplyForm(id) {
		var el = document.getElementById('reply-' + id);
		if (!el)
			return;
		el.style.display = (el.style.display === 'none' || el.style.display === '') ? 'block'
				: 'none';
	}
</script>
