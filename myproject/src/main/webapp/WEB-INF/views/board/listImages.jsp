<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" isELIgnored="false"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<%
	request.setCharacterEncoding("UTF-8");
%>
<!DOCTYPE html>
<html>
<head>
<style>
.wrapper {
	max-width: 1100px;
	margin: 0 auto;
	
}

.grid {
	display: grid;
	grid-template-columns: repeat(3, 1fr);
	gap: 20px;
	margin: 40px 0;
}

.item {
	width: 100%;
	height: 300px;
	border: 1px solid #ccc;
	border-radius: 8px;
	overflow: hidden;
	text-align: center;
	background-color: #f9f9f9;
	box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.item img {
	width: cover;
	height: 200px;
	object-fit: cover;
	border-bottom: 1px solid #ccc;
}

.item p {
	padding: 10px;
	font-size: 18px;
	font-weight: bold;
	color: #333;
}

.page-title {
	text-align: center;
	font-size: 30px;
	margin: 20px 0;
}

.cls1 {
	text-decoration: none;
}

.cls2 {
	text-align: center;
	font-size: 30px;
}
</style>
<meta charset="UTF-8">
<title>글목록창</title>
</head>
<script>
	function fn_articleForm(isLogOn, articleForm, loginForm) {
		if
	(isLogOn != '' && isLogOn != 'false') {
			location.href = articleForm;
		} else {
			alert("로그인 후 글쓰기가 가능합니다.")
			location.href = loginForm + '?action=/board/articleForm.do';
		}
	}
</script>
<body>
	<div class="wrapper">
		<h2 class="page-title">글 목록</h2>
		<div class="grid">
			<c:choose>
				<c:when test="${imageList == null}">
					<p style="text-align: center; font-size: 18px;">등록된 글이 없습니다.</p>
				</c:when>
				<c:when test="${imageList != null}">
					<c:forEach var="article" items="${imageList}"
						varStatus="articleNum">
						<div class="item">
							<c:choose>
								<c:when test="${article.imageFileName != null}">
									<img
										src="${contextPath}/download.do?articleNO=${article.articleNO}&imageFileName=${article.imageFileName}"
										alt="글 이미지">
								</c:when>
								<c:otherwise>
									<img src="${contextPath}/images/default-image.jpg" alt="기본 이미지">
								</c:otherwise>
							</c:choose>
							<p>
								<a
									href="${contextPath}/board/viewArticle.do?articleNO=${article.articleNO}">
									${article.title} </a>
							</p>
						</div>
					</c:forEach>
				</c:when>
			</c:choose>
		</div>
	</div>
	<!-- <a  class="cls1"  href="#"><p class="cls2">글쓰기</p></a> -->
	<a class="cls1"
		href="javascript:fn_articleForm('${isLogOn}','${contextPath}/board/articleForm.do', 
                                                    '${contextPath}/member/loginForm.do')"><p
			class="cls2">글쓰기</p></a>
</body>
</html>