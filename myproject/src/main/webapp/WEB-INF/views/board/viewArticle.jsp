<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" isELIgnored="false"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<c:set var="CTX" value="${pageContext.request.contextPath}" />
<c:set var="actionCommentAdd"
	value="${empty actionCommentAdd   ? 'comment/add.do'   : actionCommentAdd}" />
<c:set var="actionCommentReply"
	value="${empty actionCommentReply ? 'comment/reply.do' : actionCommentReply}" />

<%!/* -------------- 공통 유틸 -------------- */
	private static String h(Object o) {
		if (o == null)
			return "";
		String s = String.valueOf(o);
		return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
	}
	private static String str(Object o) {
		return (o == null) ? "" : String.valueOf(o);
	}
	private static String cap(String n) {
		if (n == null || n.isEmpty())
			return n;
		return Character.toUpperCase(n.charAt(0)) + (n.length() > 1 ? n.substring(1) : "");
	}
	private static Long asLong(Object v) {
		if (v == null)
			return null;
		if (v instanceof Long)
			return (Long) v;
		if (v instanceof Integer)
			return ((Integer) v).longValue();
		if (v instanceof Number)
			return ((Number) v).longValue();
		try {
			return Long.parseLong(String.valueOf(v));
		} catch (Exception e) {
			return null;
		}
	}
	private static boolean eq(Object a, Object b) {
		return (a == b) || (a != null && a.equals(b));
	}
	private static String normalizeText(String s) {
		if (s == null)
			return "";
		s = s.replaceFirst("^[\\uFEFF\\s]*본문\\s*", ""); // 앞의 BOM/공백 + '본문'
		s = s.replaceAll("[ \\t]{3,}", "  "); // 과한 스페이스 축약
		return s.trim();
	}

	/* bean/map에서 필드 탐색 */
	private static Object getProp(Object bean, String... names) {
		if (bean == null)
			return null;
		for (String name : names) {
			if (name == null)
				continue;
			try {
				if (bean instanceof java.util.Map) {
					Object v = ((java.util.Map) bean).get(name);
					if (v != null)
						return v;
				}
				java.lang.reflect.Method m = null;
				try {
					m = bean.getClass().getMethod("get" + cap(name));
				} catch (NoSuchMethodException ignore) {
				}
				if (m == null) {
					try {
						m = bean.getClass().getMethod("is" + cap(name));
					} catch (NoSuchMethodException ignore) {
					}
				}
				if (m != null) {
					Object v = m.invoke(bean);
					if (v != null)
						return v;
				}
				try {
					java.lang.reflect.Field f = bean.getClass().getDeclaredField(name);
					f.setAccessible(true);
					Object v = f.get(bean);
					if (v != null)
						return v;
				} catch (NoSuchFieldException ignore) {
				}
			} catch (Exception ignore) {
			}
		}
		return null;
	}

	/* URL 처리/첨부 렌더 */
	private static boolean looksImageUrl(String url) {
		if (url == null)
			return false;
		String u = url.toLowerCase();
		return u.endsWith(".jpg") || u.endsWith(".jpeg") || u.endsWith(".png") || u.endsWith(".gif")
				|| u.endsWith(".webp");
	}
	private static String resolveUrl(javax.servlet.jsp.PageContext pc, Object urlObj) {
		if (urlObj == null)
			return null;
		String url = String.valueOf(urlObj);
		if (url == null || url.isEmpty())
			return null;
		javax.servlet.http.HttpServletRequest req = (javax.servlet.http.HttpServletRequest) pc.getRequest();
		String ctx = req.getContextPath();
		if (url.startsWith("http://") || url.startsWith("https://") || url.startsWith("//"))
			return url;
		if (url.startsWith("/"))
			return ctx + url;
		return url; // 상대경로 유지
	}
	private static void renderAttachments(javax.servlet.jsp.PageContext pc, javax.servlet.jsp.JspWriter out,
			Object bean) throws java.io.IOException {
		java.util.List<Object> list = new java.util.ArrayList<Object>();
		Object[] keys = new Object[]{getProp(bean, "attachments"), getProp(bean, "files"), getProp(bean, "images"),
				getProp(bean, "imageList"), getProp(bean, "imageUrls"), getProp(bean, "imageUrl"),
				getProp(bean, "imageFileName"), getProp(bean, "image"), getProp(bean, "fileUrl"),
				getProp(bean, "file")};
		for (Object k : keys) {
			if (k == null)
				continue;
			if (k instanceof java.util.Collection) {
				list.addAll((java.util.Collection) k);
			} else if (k.getClass().isArray()) {
				for (Object a : (Object[]) k)
					if (a != null)
						list.add(a);
			} else
				list.add(k);
		}
		if (list.isEmpty())
			return;
		out.write("<div class='att-list'>");
		for (Object item : list) {
			if (item == null)
				continue;
			Object urlObj = getProp(item, "url", "imageUrl", "path", "imagePath", "fileUrl", "downloadUrl");
			String url = resolveUrl(pc, (urlObj != null ? urlObj : item));
			if (url == null)
				continue;
			if (looksImageUrl(url)) {
				out.write("<div class='att att-img'><img src='" + h(url) + "' alt='attachment'/></div>");
			} else {
				String name = str(getProp(item, "name", "fileName", "originalName"));
				if (name == null || name.isEmpty())
					name = url;
				out.write("<div class='att att-file'><a href='" + h(url) + "'>" + h(name) + "</a></div>");
			}
		}
		out.write("</div>");
	}

	/* 댓글 렌더(작성자ID 노출 추가) */
	private static void renderComment(javax.servlet.jsp.PageContext pc, javax.servlet.jsp.JspWriter out, Object cmt,
			long articleId, int depth, boolean logged, String replyRel) throws java.io.IOException {
		String writer = str(getProp(cmt, "authorName", "writer", "name", "nickname", "userName"));
		// 댓글 작성자 ID 탐색
		String uid = str(getProp(cmt, "writerId", "userId", "memberId", "authorId", "createdBy", "loginId"));
		Object userObj = getProp(cmt, "writer", "author", "member", "user");
		if ((uid == null || uid.isEmpty()) && userObj != null) {
			uid = str(getProp(userObj, "id", "userId", "memberId", "loginId"));
		}

		Object created = getProp(cmt, "createdAt", "regDate", "writeDate", "created", "created_at", "writtenAt");
		String content = normalizeText(str(getProp(cmt, "content", "body", "text", "message")));
		Long cid = asLong(getProp(cmt, "id", "commentId", "commentNO", "commentNo"));
		boolean own = false;
		Object ownObj = getProp(cmt, "own", "mine", "editable");
		if (ownObj instanceof Boolean)
			own = (Boolean) ownObj;

		out.write("<div class='cmt' data-depth='" + depth + "'>");
		out.write("<div class='cmt-head'><strong>" + h(writer) + "</strong>");
		if (uid != null && !uid.isEmpty())
			out.write(" <span class='uid'>(@" + h(uid) + ")</span>");
		if (created != null)
			out.write("<span class='dot'>·</span><span class='time'>" + h(created) + "</span>");
		out.write("</div>");
		out.write("<div class='cmt-body'>" + h(content) + "</div>");
		renderAttachments(pc, out, cmt);

		out.write("<div class='cmt-actions'>");
		if (cid != null)
			out.write("<a href='javascript:void(0)' class='link' onclick=\"toggleReply('r-" + cid + "')\">답글</a>");
		if (own && cid != null) {
			javax.servlet.http.HttpServletRequest req = (javax.servlet.http.HttpServletRequest) pc.getRequest();
			String delHref = req.getContextPath() + "/article/comment/delete.do?id=" + cid;
			out.write("<a class='link' href='" + h(delHref) + "'>삭제</a>");
		}
		out.write("</div>");

		if (logged && cid != null) {
			String action = (replyRel != null && replyRel.length() > 0) ? replyRel : "comment/reply.do";
			out.write("<form id='r-" + cid + "' class='cmt-reply' method='post' action='" + h(action)
					+ "' style='display:none'>");
			out.write("<input type='hidden' name='articleNO' value='" + articleId + "'/>");
			out.write("<input type='hidden' name='parentId'  value='" + cid + "'/>");
			out.write("<textarea name='content' rows='3' placeholder='답글을 입력하세요' required></textarea>");
			out.write("<button type='submit'>답글 등록</button>");
			out.write("</form>");
		}

		java.util.List kids = null;
		Object k = getProp(cmt, "replies", "children", "childList", "replyList", "repliesList");
		if (k instanceof java.util.Collection)
			kids = new java.util.ArrayList((java.util.Collection) k);
		if (kids == null || kids.isEmpty()) {
			java.util.Map idx = (java.util.Map) pc.findAttribute("__CHILDREN_INDEX");
			if (idx != null && cid != null)
				kids = (java.util.List) idx.get(cid);
		}
		if (kids != null && !kids.isEmpty()) {
			out.write("<div class='cmt-children'>");
			for (Object child : (java.util.List) kids) {
				renderComment(pc, out, child, articleId, depth + 1, logged, replyRel);
			}
			out.write("</div>");
		}
		out.write("</div>");
	}%>

<%
/* -------------- 데이터 바인딩 -------------- */
Object article = request.getAttribute("article");
if (article == null)
	article = request.getAttribute("articleVO");
if (article == null)
	article = request.getAttribute("board");

Long articleId = null;
Object aobj = request.getAttribute("articleNO");
if (aobj == null)
	aobj = request.getAttribute("articleNo");
if (aobj == null)
	aobj = request.getParameter("articleNO");
if (aobj == null)
	aobj = request.getParameter("articleNo");
if (aobj != null)
	articleId = asLong(aobj);
if (articleId == null && article != null) {
	articleId = asLong(getProp(article, "articleNO", "articleNo", "id", "no"));
}

String title = str(getProp(article, "title", "articleTitle", "subject", "headline"));
String rawContent = str(getProp(article, "content", "articleContent", "body", "text"));
String content = normalizeText(rawContent);

/* 작성자 이름/ID 모두 추출 */
String writerName = str(getProp(article, "writer", "authorName", "name", "nickname", "userName", "memberId"));
String writerId = str(
		getProp(article, "writerId", "userId", "memberId", "authorId", "createdBy", "loginId", "writerNO", "writerNo"));
Object writerObj = getProp(article, "writer", "author", "member", "user");
if ((writerId == null || writerId.isEmpty()) && writerObj != null) {
	writerId = str(getProp(writerObj, "id", "userId", "memberId", "loginId"));
}
Object created = getProp(article, "createdAt", "regDate", "writeDate", "created", "created_at", "writtenAt");

/* 카테고리 */
String cat1 = str(getProp(article, "category", "categoryName", "cate"));
String cat2 = str(getProp(article, "subCategory", "subCategoryName", "subcate"));

/* 로그인 정보 / 소유권 판별 */
Object loginUser = session.getAttribute("loginUser");
Object member = session.getAttribute("member");
String loginId = str(getProp(loginUser, "id", "userId", "memberId", "loginId", "username"));
if (loginId.isEmpty())
	loginId = str(getProp(member, "id", "userId", "memberId", "loginId", "username"));
String loginName = str(getProp(loginUser, "name", "nickname", "userName", "memberId"));
if (loginName.isEmpty())
	loginName = str(getProp(member, "name", "nickname", "userName", "memberId"));

boolean ownArticle = false;
Object ownObj = getProp(article, "own", "mine", "editable");
if (ownObj instanceof Boolean)
	ownArticle = (Boolean) ownObj;
if (!ownArticle) {
	if (!loginId.isEmpty() && !str(writerId).isEmpty() && eq(loginId, writerId))
		ownArticle = true;
	else if (!loginName.isEmpty() && !str(writerName).isEmpty() && eq(loginName, writerName))
		ownArticle = true;
}
/* 관리자면 허용(선택) */
String role1 = str(getProp(loginUser, "role", "auth", "authority", "type"));
String role2 = str(getProp(member, "role", "auth", "authority", "type"));
boolean isAdmin = "ADMIN".equalsIgnoreCase(role1) || "ADMIN".equalsIgnoreCase(role2) || "admin".equalsIgnoreCase(role1)
		|| "admin".equalsIgnoreCase(role2);
if (isAdmin)
	ownArticle = true;

/* 댓글 데이터 */
java.util.List commentRoots = (java.util.List) request.getAttribute("commentRoots");
if (commentRoots == null)
	commentRoots = (java.util.List) request.getAttribute("comments");
if (commentRoots == null)
	commentRoots = (java.util.List) request.getAttribute("commentList");
java.util.List allComments = (java.util.List) request.getAttribute("allComments");
if (allComments == null)
	allComments = (java.util.List) request.getAttribute("comments");
if (allComments == null)
	allComments = (java.util.List) request.getAttribute("commentList");

/* 평평한 리스트만 온 경우, 인덱스/루트 구성 */
java.util.Map<Long, java.util.List<Object>> __children = new java.util.HashMap<Long, java.util.List<Object>>();
if (allComments != null) {
	for (Object c : allComments) {
		Long pid = asLong(getProp(c, "parentId", "parent_id", "parentNo", "parentNO"));
		Long cid = asLong(getProp(c, "id", "commentId", "commentNO", "commentNo"));
		if (pid != null && pid.longValue() != 0L) {
	java.util.List<Object> bucket = __children.get(pid);
	if (bucket == null) {
		bucket = new java.util.ArrayList<Object>();
		__children.put(pid, bucket);
	}
	bucket.add(c);
		}
	}
	if (commentRoots == null || commentRoots.isEmpty()) {
		commentRoots = new java.util.ArrayList<Object>();
		for (Object c : allComments) {
	Long pid = asLong(getProp(c, "parentId", "parent_id", "parentNo", "parentNO"));
	if (pid == null || pid.longValue() == 0L)
		commentRoots.add(c);
		}
	}
}
pageContext.setAttribute("__CHILDREN_INDEX", __children);

/* 로그인 여부/EL용 바인딩들 */
boolean LOGGED_IN = (session.getAttribute("isLogOn") != null) || (loginUser != null) || (member != null);
pageContext.setAttribute("OWN_ARTICLE", ownArticle);
pageContext.setAttribute("LOGGED_IN", LOGGED_IN);
pageContext.setAttribute("cat1", cat1);
pageContext.setAttribute("cat2", cat2);
pageContext.setAttribute("writerName", writerName);
pageContext.setAttribute("writerId", writerId);
pageContext.setAttribute("createdVal", created);
pageContext.setAttribute("titleVal", title);
pageContext.setAttribute("contentVal", content);
String referer = request.getHeader("Referer");
String backUrl = (referer != null && referer.length() > 0)
		? referer
		: (request.getContextPath() + "/board/listArticles.do");
%>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8" />
<title><%=h(title)%></title>
<style>
body {
	font-family: system-ui, -apple-system, Segoe UI, Roboto, Arial,
		sans-serif;
	margin: 0;
}

.wrap {
	max-width: 860px;
	margin: 32px auto;
	padding: 0 16px;
}

.breadcrumb {
	font-size: 13px;
	margin-bottom: 16px;
}

.breadcrumb .sep {
	margin: 0 6px;
}

.article-title {
	font-size: 28px;
	line-height: 1.25;
	margin: 8px 0 6px;
}

.meta {
	font-size: 13px;
	margin-bottom: 16px;
}

.meta .dot {
	margin: 0 6px;
}

.meta .uid {
	opacity: .7
}

.article-body {
	font-size: 16px;
	line-height: 1.8;
	white-space: pre-wrap;
	word-break: break-word;
}

.att-list {
	display: grid;
	grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
	gap: 8px;
	margin-top: 12px;
}

.att-img img {
	display: block;
	width: 100%;
	height: auto;
	border: 1px solid #ddd;
}

.att-file a {
	text-decoration: none;
	border-bottom: 1px solid #aaa;
}

.article-actions {
	margin: 20px 0;
	display: flex;
	gap: 8px;
}

.btn {
	padding: 8px 12px;
	border: 1px solid #bbb;
	background: #fff;
	cursor: pointer;
	text-decoration: none;
	display: inline-block;
}

.hr {
	height: 1px;
	background: #eee;
	margin: 24px 0;
}

.cmt-form textarea {
	width: 100%;
	box-sizing: border-box;
	padding: 10px;
	border: 1px solid #bbb;
}

.cmt-form button {
	margin-top: 8px;
	padding: 8px 12px;
	border: 1px solid #bbb;
	background: #fff;
	cursor: pointer;
}

.cmt-guard {
	padding: 12px;
	border: 1px dashed #bbb;
	font-size: 14px;
}

.cmt-list {
	margin-top: 12px;
}

.cmt {
	border-top: 1px solid #eee;
	padding: 12px 0;
}

.cmt:first-child {
	border-top: 0;
}

.cmt-head {
	font-size: 14px;
	margin-bottom: 6px;
}

.cmt-head .dot {
	margin: 0 6px;
}

.cmt-head .uid {
	opacity: .7
}

.cmt-body {
	font-size: 15px;
	white-space: pre-wrap;
	word-break: break-word;
}

.cmt-actions {
	margin-top: 6px;
	display: flex;
	gap: 10px;
}

.cmt-actions .link {
	text-decoration: none;
	border-bottom: 1px solid #aaa;
	font-size: 13px;
}

.cmt-children {
	margin-left: 16px;
	border-left: 2px solid #eee;
	padding-left: 12px;
	margin-top: 8px;
}

.cmt-reply textarea {
	width: 100%;
	box-sizing: border-box;
	padding: 8px;
	border: 1px solid #bbb;
}

.cmt-reply button {
	margin-top: 6px;
	padding: 6px 10px;
	border: 1px solid #bbb;
	background: #fff;
	cursor: pointer;
}

.back {
	margin: 28px 0 8px;
}

.back a {
	text-decoration: none;
	border-bottom: 1px solid #aaa;
}
</style>
<script>
  function toggleReply(id){
    var el=document.getElementById(id);
    if(!el) return;
    el.style.display=(el.style.display==='none'||el.style.display==='')?'block':'none';
  }
  function cleanAndSubmit(f){
    var ta=f.querySelector("textarea[name='content']");
    if(ta){
      var v=ta.value||"";
      v=v.replace(/^(?:\uFEFF|\s)*본문\s*/,'').replace(/[ \t]{3,}/g,'  ').trim();
      ta.value=v;
      if(!v){ alert('내용을 입력해 주세요.'); return false; }
    }
    return true;
  }
  function confirmDeleteArticle(href){
    if(confirm('정말로 이 게시글을 삭제할까요?')) location.href=href;
  }
</script>
</head>
<body>
	<div class="wrap">

		<!-- 카테고리 경로 -->
		<div class="breadcrumb">
			<span>전체</span>
			<c:if test="${not empty cat1}">
				<span class="sep">&gt;</span>
				<span><c:out value="${cat1}" /></span>
			</c:if>
			<c:if test="${not empty cat2}">
				<span class="sep">&gt;</span>
				<span><c:out value="${cat2}" /></span>
			</c:if>
		</div>

		<!-- 제목/메타 (작성자 이름 + @ID 표기) -->
		<h1 class="article-title"><%=h(title)%></h1>
		<div class="meta">
			<span><c:out value="${writerName}" /></span>
			<c:if test="${not empty writerId}">
				<span class="uid">(@<c:out value="${writerId}" />)
				</span>
			</c:if>
			<c:if test="${not empty createdVal}">
				<span class="dot">·</span>
				<span><%=h(created)%></span>
			</c:if>
			<c:if test="${not empty articleId}">
				<span class="dot">·</span>
				<span>No. <%=(articleId == null ? "" : String.valueOf(articleId))%></span>
			</c:if>
		</div>

		<!-- 본문 -->
		<div class="article-body"><%=h(content)%></div>
		<%
		renderAttachments(pageContext, out, article);
		%>

		<!-- 수정/삭제 (OWN_ARTICLE로 제어) -->
		<c:if test="${OWN_ARTICLE}">
			<div class="article-actions">
				<a class="btn"
					href="${CTX}/board/modArticleForm.do?articleNO=<%= (articleId==null? "" : String.valueOf(articleId)) %>">수정</a>
				<a class="btn" href="javascript:void(0)"
					onclick="confirmDeleteArticle('<c:out value='${CTX}'/>/board/removeArticle.do?articleNO=<%= (articleId==null? "" : String.valueOf(articleId)) %>')">삭제</a>
			</div>
		</c:if>

		<div class="hr"></div>

		<!-- 댓글 작성 (로그인 전용) -->
		<c:choose>
			<c:when test="${LOGGED_IN}">
				<form class="cmt-form" method="post"
					action="<c:out value='${actionCommentAdd}'/>"
					onsubmit="return cleanAndSubmit(this)">
					<input type="hidden" name="articleNO"
						value="<%=(articleId == null ? "" : String.valueOf(articleId))%>" />
					<textarea name="content" rows="4" placeholder="댓글을 입력하세요" required></textarea>
					<button type="submit">등록</button>
				</form>
			</c:when>
			<c:otherwise>
				<div class="cmt-guard">
					댓글 작성은 로그인 후 이용하세요. <a href="${CTX}/member/loginForm.do">로그인</a>
				</div>
			</c:otherwise>
		</c:choose>

		<!-- 댓글 목록 (무한 대댓글, 작성자ID 노출) -->
		<div class="cmt-list">
			<%
			boolean logged = LOGGED_IN;
			String replyRel = (String) pageContext.findAttribute("actionCommentReply");
			long aid = (articleId == null ? 0L : articleId.longValue());
			if (commentRoots != null) {
				for (Object c : commentRoots) {
					renderComment(pageContext, out, c, aid, 0, logged, replyRel);
				}
			}
			%>
		</div>

		<!-- 하단 '← 목록으로' -->
		<div class="back">
			<a href="<%=h(backUrl)%>">← 목록으로</a>
		</div>

	</div>
</body>
</html>
