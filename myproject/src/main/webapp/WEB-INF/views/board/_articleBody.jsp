<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<div class="article-view">
  <div class="breadcrumb">
    <a href="<c:url value='/board/listArticles.do'/>">전체</a>
    <span class="sep">&gt;</span>
    <c:out value="${empty article.cat ? '-' : article.cat}" />
    <span class="sep">&gt;</span>
    <c:out value="${empty article.sub ? '-' : article.sub}" />
  </div>
  <div class="header">
    <h1><c:out value="${article.title}" /></h1>
    <div class="meta">
      <c:set var="displayWriter"
        value="${empty article.nickname ? (empty article.name ? article.id : article.name) : article.nickname}" />
      <span class="writer"><c:out value="${displayWriter}" /></span>
      <span class="dot">·</span>
      <span class="date"><fmt:formatDate value="${article.writeDate}" pattern="yyyy.MM.dd HH:mm" /></span>
      <span class="dot">·</span>
      <span class="read">조회 <c:out value="${article.readCnt}" /></span>
    </div>
  </div>
  <c:if test="${not empty article.imageFileName}">
    <div class="cover">
      <img src="<c:url value='/board/download.do?articleNO=${article.articleNO}&imageFileName=${article.imageFileName}'/>" alt="cover"/>
    </div>
  </c:if>
  <div class="content">
    <c:out value="${article.content}" escapeXml="false" />
  </div>
  <div class="actions">
    <c:if test="${loginId == article.id || loginId == 'admin'}">
      <a href="<c:url value='/board/articleForm.do?articleNO=${article.articleNO}'/>">수정</a>
      <a class="danger" href="<c:url value='/board/removeArticle.do?articleNO=${article.articleNO}'/>"
         onclick="return confirm('삭제할까요?')">삭제</a>
    </c:if>
  </div>
  <a class="back" href="<c:url value='/board/listArticles.do'/>">목록으로</a>
</div>
<style>
  .article-view { font-family: system-ui, -apple-system, Segoe UI, Roboto, Arial, sans-serif; }
  .article-view .breadcrumb { color:#666; font-size:14px; margin-bottom:12px; }
  .article-view .sep { margin:0 6px; }
  .article-view .header h1 { font-size:28px; margin:0 0 8px; }
  .article-view .meta { color:#777; font-size:14px; }
  .article-view .meta .dot { margin:0 6px; color:#bbb; }
  .article-view .cover { margin:20px 0; }
  .article-view .cover img { max-width:100%; height:auto; display:block; border-radius:8px; }
  .article-view .content { font-size:16px; line-height:1.75; margin-top:16px; }
  .article-view .actions { display:flex; gap:8px; margin:16px 0; }
  .article-view .actions a { padding:8px 12px; border:1px solid #ddd; border-radius:8px; text-decoration:none; color:#222; }
  .article-view .actions a.danger { border-color:#e11; color:#c00; }
  .article-view .back { display:inline-block; margin-top:8px; text-decoration:none; color:#2563eb; }
</style>
