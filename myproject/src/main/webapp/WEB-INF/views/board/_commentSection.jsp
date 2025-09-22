<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<!-- 안전한 기사 ID 계산: article.id -> article.articleNO -> articleId -> param.articleNO -->
<c:set var="aid"
	value="${not empty article.id ? article.id : (not empty article.articleNO ? article.articleNO : (not empty articleId ? articleId : param.articleNO))}" />

<style>
/* ===== 댓글 섹션 ===== */
.comment-section {
	margin-top: 30px;
	padding: 20px;
	border-top: 2px solid #ddd;
	background: #fafafa;
	font-family: Arial, sans-serif;
}

.comment-section h3 {
	font-size: 18px;
	margin: 0 0 15px;
	color: #333;
}

.comment-form {
	margin-bottom: 20px;
}

.comment-form textarea {
	width: 100%;
	height: 80px;
	padding: 10px;
	resize: vertical;
	border: 1px solid #ccc;
	border-radius: 6px;
	font-size: 14px;
	margin-bottom: 10px;
}

.comment-form button {
	background: #007bff;
	border: 0;
	color: #fff;
	padding: 8px 14px;
	border-radius: 4px;
	cursor: pointer;
	font-size: 14px;
}

.comment-form button:hover {
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
}

.comment-item .actions {
	font-size: 12px;
}

.comment-item .actions form {
	display: inline;
}

.comment-item .actions button {
	background: none;
	border: none;
	color: #d00;
	cursor: pointer;
	padding: 0;
}
</style>

<div class="comment-section">
	<h3>댓글</h3>

	<!-- 댓글 작성 폼 -->
	<form class="comment-form" action="<c:url value='/comment/add.do'/>"
		method="post">
		<c:if test="${not empty aid}">
			<input type="hidden" name="articleId" value="${aid}" />
		</c:if>
		<textarea name="content" placeholder="댓글을 입력하세요" required></textarea>
		<button type="submit">등록</button>
	</form>

	<!-- 댓글 목록 -->
	<ul class="comment-list">
		<c:forEach var="c" items="${comments}">
			<li class="comment-item">
				<div class="meta">
					<b>${c.writer}</b>
					<c:if test="${not empty c.writeDate}"> | <fmt:formatDate
							value="${c.writeDate}" pattern="yyyy-MM-dd HH:mm" />
					</c:if>
				</div>
				<div class="content">${c.content}</div>
				<div class="actions">
					<form action="<c:url value='/comment/delete.do'/>" method="post">
						<input type="hidden" name="id" value="${c.id}" />
						<c:if test="${not empty aid}">
							<input type="hidden" name="articleId" value="${aid}" />
						</c:if>
						<button type="submit">삭제</button>
					</form>
				</div>
			</li>
		</c:forEach>
	</ul>
</div>
