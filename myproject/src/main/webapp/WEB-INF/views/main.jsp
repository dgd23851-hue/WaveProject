<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false" %>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<%
  request.setCharacterEncoding("UTF-8");
%>
<link rel="stylesheet" href="<c:url value='/resources/css/main.css'/>">
<main class="home container">
  <!-- recentArticles가 있으면 사용, 없으면 articlesList로 폴백 -->
  <c:set var="list" value="${not empty recentArticles ? recentArticles : articlesList}" />

  <c:choose>
    <c:when test="${empty list}">
      <section class="empty-wrap">
        <p class="empty">표시할 최신 기사가 없습니다.</p>
      </section>
    </c:when>

    <c:otherwise>
      <!-- ========= 만화 컷씬형 그리드 ========= -->
      <section class="comic-grid" aria-label="헤드라인/최신 기사">
        <c:forEach var="a" items="${list}" varStatus="st">
          <c:if test="${st.index < 12}">
            <c:set var="panelClass">
              <c:choose>
                <c:when test="${st.index == 0}">span-2x2</c:when>
                <c:when test="${st.index == 3 || st.index == 6}">span-2x1</c:when>
                <c:when test="${st.index == 5 || st.index == 9}">span-1x2</c:when>
                <c:otherwise>span-1x1</c:otherwise>
              </c:choose>
            </c:set>

            <article class="panel ${panelClass}">
              <a class="panel-link"
                 href="<c:url value='/board/viewArticle.do'><c:param name='articleNO' value='${a.articleNO}'/></c:url>">
                <c:choose>
                  <c:when test="${not empty a.imageFileName}">
                    <img class="panel-img"
                         src="<c:url value='/download.do'>
                                <c:param name='articleNO'   value='${a.articleNO}'/>
                                <c:param name='imageFileName' value='${a.imageFileName}'/>
                              </c:url>"
                         alt="" />
                  </c:when>
                  <c:otherwise>
                    <div class="panel-noimg" aria-hidden="true">NO IMAGE</div>
                  </c:otherwise>
                </c:choose>

                <div class="panel-overlay">
                  <h3 class="panel-title"><c:out value="${a.title}" /></h3>
                  <p class="panel-meta">
                    <span class="by"><c:out value="${a.id}" /></span>
                    <span class="dot">·</span>
                    <time datetime="<fmt:formatDate value='${a.writeDate}' pattern='yyyy-MM-dd'/>">
                      <fmt:formatDate value='${a.writeDate}' pattern='yyyy.MM.dd HH:mm'/>
                    </time>
                    <c:if test="${not empty a.cat}">
                      <span class="dot">·</span>
                      <span class="tag">
                        <c:out value="${a.cat}" />
                        <c:if test="${not empty a.sub}">/<c:out value="${a.sub}" /></c:if>
                      </span>
                    </c:if>
                  </p>
                </div>
              </a>
            </article>
          </c:if>
        </c:forEach>
      </section>

      <!-- ========= 리스트 더 보기 ========= -->
      <div class="more-row">
        <a class="more-link" href="<c:url value='/board/listArticles.do'/>">전체 기사 더보기</a>
      </div>
    </c:otherwise>
  </c:choose>
</main>
