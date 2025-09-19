<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%! 
  private static String esc(Object v) {
    if (v == null) return "";
    String s = String.valueOf(v);
    StringBuilder b = new StringBuilder(s.length() + 16);
    for (int i = 0; i < s.length(); i++) {
      char ch = s.charAt(i);
      switch (ch) {
        case '<': b.append("&lt;"); break;
        case '>': b.append("&gt;"); break;
        case '&': b.append("&amp;"); break;
        case '"': b.append("&quot;"); break;
        case '\'': b.append("&#39;"); break;
        default: b.append(ch);
      }
    }
    return b.toString();
  }
  private static Object getProp(Object bean, String... names) {
    if (bean == null || names == null) return null;
    Class<?> z = bean.getClass();
    for (String n : names) {
      String base = n.substring(0,1).toUpperCase() + n.substring(1);
      String[] getters = new String[]{ "get" + base, "is" + base, n };
      for (String g : getters) {
        try {
          java.lang.reflect.Method m = z.getMethod(g);
          return m.invoke(bean);
        } catch (Exception ignore) {}
      }
    }
    return null;
  }
  private static int countReplies(Object cmt) {
    Object listObj = getProp(cmt, "replies", "children");
    if (!(listObj instanceof java.util.Collection)) return 0;
    java.util.Collection<?> coll = (java.util.Collection<?>) listObj;
    int sum = coll.size();
    for (Object x : coll) sum += countReplies(x);
    return sum;
  }
  private static void renderComment(javax.servlet.jsp.PageContext pc, javax.servlet.jsp.JspWriter out, Object cmt,
                                    long articleId, int depth, boolean logged, String replyAction) throws java.io.IOException {
    String writer = String.valueOf(java.util.Optional.ofNullable(getProp(cmt, "authorName", "writerName", "writer", "nickname")).orElse("익명"));
    Object created = getProp(cmt, "createdAt", "writeDate", "created", "regDate");
    String content = String.valueOf(java.util.Optional.ofNullable(getProp(cmt, "content", "text", "body")).orElse(""));
    Object idObj = getProp(cmt, "commentId", "id", "cid");
    String cid = (idObj == null ? null : String.valueOf(idObj));
    int rCount = countReplies(cmt);
    String ctx = pc.getRequest().getServletContext().getContextPath();
    out.write("<div class='cmt' data-depth='" + depth + "'>");
    out.write("<div class='cmt-head'><strong>" + esc(writer) + "</strong>");
    if (created != null && created.toString().length() > 0) {
      out.write("<span class='dot'>·</span><span class='time'>" + esc(created) + "</span>");
    }
    out.write("</div>");
    out.write("<div class='cmt-body'>" + esc(content).replace("\n", "<br/>") + "</div>");
    out.write("<div class='cmt-actions'>");
    String rid = (cid == null ? ("x" + System.nanoTime()) : ("r-" + cid));
    out.write("<a href='javascript:void(0)' class='link' onclick=\"toggleReply('" + rid + "')\">답글</a>");
    if (rCount > 0 && cid != null) {
      out.write("<a href='javascript:void(0)' class='link' onclick=\"toggleChildren('ch-" + cid + "')\">답글 " + rCount + "개 보기</a>");
    }
    String action = (replyAction == null || replyAction.isEmpty()) ? (ctx + "/board/comment/reply.do") : (ctx + "/board/" + replyAction);
    out.write("<form class='cmt-reply hidden' id='" + rid + "' method='post' action='" + esc(action) + "' onsubmit='return cleanAndSubmit(this)'>");
    out.write("<input type='hidden' name='articleNO' value='" + articleId + "'/>");
    if (cid != null) out.write("<input type='hidden' name='parentId' value='" + cid + "'/>");
    out.write("<textarea name='content' rows='3' placeholder='답글을 입력하세요' required></textarea>");
    out.write("<button type='submit'>등록</button>");
    out.write("</form>");
    Object kids = getProp(cmt, "replies", "children");
    if (kids instanceof java.util.Collection) {
      out.write("<div class='cmt-children hidden' id='ch-" + cid + "'>");
      for (Object child : (java.util.Collection<?>) kids) {
        renderComment(pc, out, child, articleId, depth + 1, logged, replyAction);
      }
      out.write("</div>");
    }
    out.write("</div>");
  }
%>
<style>
  .cmt-module { border-top: 1px solid #eee; padding-top: 16px; }
  .cmt-module h2 { font-size:20px; margin:0 0 12px; }
  .cmt-module .cmt-form textarea { width:100%; min-height:90px; padding:10px; }
  .cmt-module .cmt-form button { margin-top:8px; }
  .cmt-module .cmt-root { border-bottom: 1px solid #f2f2f2; padding:12px 0; }
  .cmt-module .cmt { margin:8px 0 0 0; }
  .cmt-module .cmt[data-depth='1'] { margin-left:20px; }
  .cmt-module .cmt[data-depth='2'] { margin-left:40px; }
  .cmt-module .cmt-head { color:#555; font-size:14px; margin-bottom:4px; }
  .cmt-module .cmt-body { font-size:15px; line-height:1.6; white-space:normal; }
  .cmt-module .cmt-actions { margin-top:6px; display:flex; gap:8px; }
  .cmt-module .cmt-actions .link { font-size:13px; color:#2563eb; text-decoration:none; cursor:pointer; }
  .cmt-module .hidden { display:none; }
  .cmt-module .more-wrap { text-align:center; margin-top:8px; }
</style>
<c:set var="actionCommentAdd" value="${empty actionCommentAdd ? 'comment/add.do' : actionCommentAdd}"/>
<c:set var="actionCommentReply" value="${empty actionCommentReply ? 'comment/reply.do' : actionCommentReply}"/>
<div class="cmt-module">
  <h2>댓글</h2>
  <c:choose>
    <c:when test="${sessionScope.isLogOn or not empty sessionScope.loginUser or not empty sessionScope.member}">
      <form class="cmt-form" method="post" action="<c:url value='/board/${actionCommentAdd}'/>" onsubmit="return cleanAndSubmit(this)">
        <input type="hidden" name="articleNO" value="${article.articleNO}"/>
        <textarea name="content" placeholder="댓글을 입력하세요" required>${param.cmt}</textarea>
        <div><button type="submit">등록</button></div>
      </form>
    </c:when>
    <c:otherwise>
      <p style="color:#666; font-size:14px;">로그인 후 댓글을 작성할 수 있습니다.</p>
    </c:otherwise>
  </c:choose>
  <div class="cmt-list">
    <c:if test="${empty comments}">
      <p style="color:#888;">아직 댓글이 없습니다.</p>
    </c:if>
    <c:if test="${not empty comments}">
      <c:forEach var="c" items="${comments}" varStatus="st">
        <div class="cmt-root" data-idx="${st.index}">
          <%
            Object cmt = pageContext.getAttribute("c");
            java.io.Writer out0 = out;
            long aid = 0L;
            try { aid = Long.parseLong(String.valueOf(pageContext.findAttribute("article").getClass().getMethod("getArticleNO").invoke(pageContext.findAttribute("article")))); } catch (Exception ignore) {}
            renderComment(pageContext, (javax.servlet.jsp.JspWriter)out0, cmt, aid, 0,
                          (Boolean.TRUE.equals(pageContext.findAttribute("isLogOn"))),
                          (String)pageContext.findAttribute("actionCommentReply"));
          %>
        </div>
      </c:forEach>
    </c:if>
  </div>
  <c:if test="${not empty comments and fn:length(comments) > 10}">
    <div class="more-wrap"><button type="button" onclick="showMore()">댓글 더 보기</button></div>
  </c:if>
</div>
<script>
  function toggleReply(id) { var el = document.getElementById(id); if (el) el.classList.toggle('hidden'); }
  function toggleChildren(id) { var el = document.getElementById(id); if (el) el.classList.toggle('hidden'); }
  function cleanAndSubmit(form) {
    var ta = form.querySelector('textarea[name="content"]');
    if (!ta) return true;
    var s = ta.value || '';
    s = s.replace(/^(?:\uFEFF|\s)*본문\s*/, '');
    s = s.replace(/[ \t]{3,}/g, '  ').trim();
    if (s.length === 0) { alert('내용을 입력하세요.'); ta.focus(); return false; }
    ta.value = s;
    return true;
  }
  (function initHide() {
    var roots = document.querySelectorAll('.cmt-root');
    for (var i = 0; i < roots.length; i++) {
      var n = parseInt(roots[i].getAttribute('data-idx') || '0', 10);
      if (n > 10) roots[i].classList.add('hidden');
    }
  })();
  function showMore() {
    var roots = document.querySelectorAll('.cmt-root.hidden');
    var shown = 0;
    for (var i = 0; i < roots.length && shown < 10; i++) {
      roots[i].classList.remove('hidden');
      shown++;
    }
    if (document.querySelectorAll('.cmt-root.hidden').length === 0) {
      var w = document.querySelector('.more-wrap');
      if (w) w.style.display = 'none';
    }
  }
</script>
