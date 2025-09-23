<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<!-- 엔드포인트 URL -->
<c:url var="addUrl" value="/comment/add.do" />
<c:url var="delUrl" value="/comment/delete.do" />

<!-- (옵션) 디버그 패널: URL에 ?debug=1 붙이면 현재 articleId를 확인 -->
<c:set var="DEBUG" value="${param.debug eq '1'}" />
<c:if test="${DEBUG}">
	<div
		style="padding: 10px; margin: 10px 0; border: 1px dashed #bbb; background: #fffbe6; font-family: monospace;">
		DEBUG articleId=${articleId}, addUrl=<a href="${addUrl}"
			target="_blank">${addUrl}</a>
	</div>
</c:if>

<style>
.comment-section {
	margin-top: 30px;
	padding: 20px;
	border-top: 2px solid #ddd;
	background: #fafafa;
	font-family: Arial, "Malgun Gothic", sans-serif;
}

.comment-section h3 {
	font-size: 18px;
	margin: 0 0 15px;
	color: #333;
}

.comment-form {
	margin-bottom: 18px;
}

.comment-form textarea {
	width: 100%;
	height: 100px;
	padding: 10px;
	resize: vertical;
	border: 1px solid #ccc;
	border-radius: 6px;
	font-size: 14px;
	margin-bottom: 10px;
	background: #fff;
}

.comment-form .btn {
	background: #007bff;
	border: 0;
	color: #fff;
	padding: 8px 14px;
	border-radius: 6px;
	cursor: pointer;
	font-size: 14px;
}

.comment-form .btn:hover {
	background: #0056b3;
}

.comment-list {
	list-style: none;
	margin: 0;
	padding: 0;
}

.comment-item {
	padding: 12px 10px;
	margin-bottom: 10px;
	border-bottom: 1px solid #eee;
	background: #fff;
	border-radius: 6px;
}

.comment-item .meta {
	font-size: 12px;
	color: #666;
	margin-bottom: 4px;
}

.comment-item .content {
	font-size: 14px;
	color: #222;
	margin-bottom: 6px;
	white-space: pre-wrap;
	word-break: break-word;
}

.comment-item .actions {
	font-size: 12px;
}

.comment-item .actions .del {
	background: none;
	border: none;
	color: #d00;
	cursor: pointer;
	padding: 0;
}

.warn {
	padding: 10px;
	background: #fff3cd;
	border: 1px solid #ffeeba;
	border-radius: 6px;
	margin-bottom: 12px;
}
</style>

<div class="comment-section">
	<h3>댓글</h3>

	<!-- articleId가 없으면 입력 비활성화(컨트롤러에서 반드시 넣어줘야 함: mav.addObject("articleId", ...) ) -->
	<c:if test="${empty articleId}">
		<div class="warn">
			댓글을 사용할 수 없습니다. (articleId 누락) — 상세 컨트롤러에서
			<code>mav.addObject("articleId", ...)</code>
			를 내려주세요.
		</div>
	</c:if>

	<!-- 외부 분리 폼을 사용: 중첩 폼/JS 미실행 환경에서도 확실히 전송 -->
	<div class="comment-form">
		<textarea name="content" form="commentPostForm"
			placeholder="댓글을 입력하세요"
			<c:if test="${empty articleId}">disabled</c:if> required></textarea>
		<button type="submit" class="btn" form="commentPostForm"
			<c:if test="${empty articleId}">disabled</c:if>>등록</button>
	</div>

	<!-- 댓글 목록 -->
	<ul class="comment-list">
		<c:forEach var="c" items="${comments}">
			<li class="comment-item" data-id="${c.id}">
				<div class="meta">
					<b>${c.writer}</b>
					<c:if test="${not empty c.writeDate}">
            &nbsp;|&nbsp;<fmt:formatDate value="${c.writeDate}"
							pattern="yyyy-MM-dd HH:mm" />
					</c:if>
				</div>
				<div class="content">${c.content}</div>
				<div class="actions">
					<!-- 삭제는 항목별 POST -->
					<form action="${delUrl}" method="post" style="display: inline;">
						<input type="hidden" name="id" value="${c.id}" /> <input
							type="hidden" name="articleId" value="${articleId}" /> <input
							type="hidden" name="articleNO" value="${articleId}" />
						<!-- 화면 복귀용 -->
						<c:if test="${not empty _csrf}">
							<input type="hidden" name="${_csrf.parameterName}"
								value="${_csrf.token}" />
						</c:if>
						<button class="del" type="submit"
							<c:if test="${empty articleId}">disabled</c:if>>삭제</button>
					</form>
				</div>
			</li>
		</c:forEach>
	</ul>
</div>

<!-- 실제 제출 대상(숨김 폼): FK/리다이렉트용으로 오직 articleId만 사용 -->
<form id="commentPostForm" action="${addUrl}" method="post"
	style="display: none;">
	<input type="hidden" name="articleId" value="${articleId}" /> <input
		type="hidden" name="articleNO" value="${articleId}" />
	<c:if test="${not empty _csrf}">
		<input type="hidden" name="${_csrf.parameterName}"
			value="${_csrf.token}" />
	</c:if>
</form>
