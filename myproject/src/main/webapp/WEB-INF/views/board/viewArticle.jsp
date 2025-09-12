<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" isELIgnored="false"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ page
	import="java.util.*, java.lang.reflect.*, javax.servlet.http.HttpServletRequest"%>

<%!private static String esc(Object v) {
		if (v == null)
			return "";
		String s = String.valueOf(v);
		StringBuilder b = new StringBuilder(s.length() + 16);
		for (int i = 0; i < s.length(); i++) {
			char ch = s.charAt(i);
			switch (ch) {
				case '<' :
					b.append("&lt;");
					break;
				case '>' :
					b.append("&gt;");
					break;
				case '&' :
					b.append("&amp;");
					break;
				case '"' :
					b.append("&quot;");
					break;
				case '\'' :
					b.append("&#39;");
					break;
				default :
					b.append(ch);
			}
		}
		return b.toString();
	}
	private static String normalizeText(String s) {
		if (s == null)
			return "";
		s = s.replaceFirst("^(?:\\uFEFF|\\s)*본문\\s*", "");
		s = s.replaceAll("[ \\t]{3,}", "  ");
		return s.trim();
	}
	private static Object getProp(Object bean, String... names) {
		if (bean == null || names == null)
			return null;
		Class<?> z = bean.getClass();
		for (String n : names) {
			String base = n.substring(0, 1).toUpperCase() + n.substring(1);
			String[] getters = new String[]{"get" + base, "is" + base, n};
			for (String g : getters) {
				try {
					Method m = z.getMethod(g);
					return m.invoke(bean);
				} catch (Exception ignore) {
				}
			}
		}
		return null;
	}
	private static Long asLong(Object o) {
		if (o == null)
			return null;
		if (o instanceof Number)
			return ((Number) o).longValue();
		try {
			return Long.parseLong(String.valueOf(o));
		} catch (Exception e) {
			return null;
		}
	}
	private static int asInt(Object o, int dv) {
		if (o == null)
			return dv;
		if (o instanceof Number)
			return ((Number) o).intValue();
		try {
			return Integer.parseInt(String.valueOf(o));
		} catch (Exception e) {
			return dv;
		}
	}
	private static int countReplies(Object cmt) {
		Object listObj = getProp(cmt, "replies", "children");
		if (!(listObj instanceof java.util.Collection))
			return 0;
		java.util.Collection<?> coll = (java.util.Collection<?>) listObj;
		int sum = coll.size();
		for (Object x : coll)
			sum += countReplies(x);
		return sum;
	}
	private static void renderComment(javax.servlet.jsp.PageContext pc, javax.servlet.jsp.JspWriter out, Object cmt,
			long articleId, int depth, boolean logged, String replyAction) throws java.io.IOException {
		String writer = String.valueOf(
				Optional.ofNullable(getProp(cmt, "authorName", "writer", "name", "nickname", "userName", "memberId"))
						.orElse("익명"));
		Object created = Optional
				.ofNullable(getProp(cmt, "createdAt", "regDate", "writeDate", "created", "created_at", "writtenAt"))
				.orElse("");
		String content = normalizeText(
				String.valueOf(Optional.ofNullable(getProp(cmt, "content", "body", "text", "message")).orElse("")));
		Long cid = asLong(getProp(cmt, "id", "commentId", "commentNO", "commentNo"));
		int rCount = countReplies(cmt);

		out.write("<div class='cmt' data-depth='" + depth + "'>");
		out.write("<div class='cmt-head'><strong>" + esc(writer) + "</strong>");
		if (created != null && created.toString().length() > 0) {
			out.write("<span class='dot'>·</span><span class='time'>" + esc(created) + "</span>");
		}
		out.write("</div>");
		out.write("<div class='cmt-body'>" + esc(content).replace("\n", "<br/>") + "</div>");

		// actions
		out.write("<div class='cmt-actions'>");
		String rid = (cid == null ? ("x" + System.nanoTime()) : ("r-" + cid));
		out.write("<a href='javascript:void(0)' class='link' onclick=\"toggleReply('" + rid + "')\">답글</a>");
		if (rCount > 0 && cid != null) {
			out.write("<a href='javascript:void(0)' class='link' onclick=\"toggleChildren('ch-" + cid + "')\">답글 "
					+ rCount + "개 보기</a>");
		}

		// 삭제 링크(로그인 + 본인/관리자 가정: 서버단 검증 필수)
		Object ownObj = getProp(cmt, "own", "mine", "editable");
		boolean own = (ownObj instanceof Boolean) ? ((Boolean) ownObj) : false;
		if (own && cid != null) {
			String ctx = ((HttpServletRequest) pc.getRequest()).getContextPath();
			String delHref = ctx + "/article/comment/delete.do?id=" + cid;
			out.write("<a class='link danger' href='" + esc(delHref) + "'>삭제</a>");
		}
		out.write("</div>"); // actions

		// reply form
		if (logged) {
			String ctx = ((HttpServletRequest) pc.getRequest()).getContextPath();
			String action = (replyAction == null || replyAction.isEmpty())
					? (ctx + "/board/comment/reply.do")
					: (ctx + "/board/" + replyAction);
			out.write("<form class='cmt-reply hidden' id='" + rid + "' method='post' action='" + esc(action)
					+ "' onsubmit='return cleanAndSubmit(this)'>");
			out.write("<input type='hidden' name='articleNO' value='" + articleId + "'/>");
			if (cid != null)
				out.write("<input type='hidden' name='parentId' value='" + cid + "'/>");
			out.write("<textarea name='content' rows='3' placeholder='답글을 입력하세요' required></textarea>");
			out.write("<button type='submit'>등록</button>");
			out.write("</form>");
		}

		// children
		Object kids = getProp(cmt, "replies", "children");
		if (kids instanceof java.util.Collection) {
			out.write("<div class='cmt-children hidden' id='ch-" + cid + "'>");
			for (Object child : (java.util.Collection<?>) kids) {
				renderComment(pc, out, child, articleId, depth + 1, logged, replyAction);
			}
			out.write("</div>");
		}
		out.write("</div>"); // .cmt
	}%>

<%
	String loginId = null;
String loginName = null;
Object u = session.getAttribute("member");
if (u == null)
	u = session.getAttribute("loginUser");
if (u != null) {
	try {
		loginId = String.valueOf(u.getClass().getMethod("getId").invoke(u));
	} catch (Exception ignore) {
	}
	try {
		loginName = String.valueOf(u.getClass().getMethod("getName").invoke(u));
	} catch (Exception ignore) {
	}
	if (loginName == null || loginName.trim().isEmpty())
		loginName = loginId;
}
request.setAttribute("loginId", loginId);
%>
<c:set var="actionCommentAdd"
	value="${empty actionCommentAdd ? 'comment/add.do'   : actionCommentAdd}" />
<c:set var="actionCommentReply"
	value="${empty actionCommentReply ? 'comment/reply.do' : actionCommentReply}" />

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8" />
<title><c:out value="${article.title}" /> - 게시글</title>
<style>
/* layout */
.container {
	max-width: 960px;
	margin: 32px auto;
	padding: 0 16px;
	font-family: -apple-system, BlinkMacSystemFont, Segoe UI, Roboto,
		Helvetica, Arial, Apple SD Gothic Neo, Noto Sans KR, sans-serif;
}

.breadcrumb {
	color: #666;
	font-size: 13px;
	margin-bottom: 12px
}

.breadcrumb a {
	color: #666;
	text-decoration: none
}

.breadcrumb .sep {
	margin: 0 6px;
	color: #bbb
}

.header h1 {
	margin: 8px 0 6px;
	font-size: 26px;
	line-height: 1.3
}

.meta {
	color: #777;
	font-size: 13px;
	margin-bottom: 16px
}

.meta .dot {
	margin: 0 6px;
	color: #bbb
}

.actions {
	margin: 14px 0
}

.actions a {
	display: inline-block;
	margin-right: 8px;
	padding: 6px 10px;
	border: 1px solid #ddd;
	border-radius: 6px;
	text-decoration: none;
	color: #333
}

.actions a:hover {
	background: #f7f7f7
}

.actions .danger {
	border-color: #f2b7b7;
	color: #bb2d3b
}

.cover {
	margin: 18px 0
}

.cover img {
	max-width: 100%;
	border-radius: 8px
}

.content {
	font-size: 16px;
	line-height: 1.8;
	word-break: break-word;
	white-space: pre-wrap
}

/* back link */
.back {
	display: inline-block;
	margin-top: 24px;
	color: #333;
	text-decoration: none
}

.back:before {
	content: "← ";
}

/* comments */
.comments {
	margin-top: 48px
}

.comments h2 {
	font-size: 18px;
	margin: 0 0 12px
}

.cmt-form textarea {
	width: 100%;
	box-sizing: border-box;
	padding: 10px;
	border: 1px solid #ddd;
	border-radius: 8px;
	margin: 8px 0
}

.cmt-form button {
	padding: 8px 14px;
	border: 0;
	background: #222;
	color: #fff;
	border-radius: 8px;
	cursor: pointer
}

.cmt-guard {
	padding: 14px;
	border: 1px dashed #ddd;
	background: #fafafa;
	border-radius: 8px
}

.cmt {
	border-top: 1px solid #eee;
	padding: 12px 0
}

.cmt[data-depth="1"] {
	margin-left: 20px
}

.cmt[data-depth="2"] {
	margin-left: 40px
}

.cmt-head {
	font-size: 14px;
	margin-bottom: 6px
}

.cmt-head .dot {
	margin: 0 6px;
	color: #bbb
}

.cmt-body {
	font-size: 15px;
	line-height: 1.6
}

.cmt-actions {
	margin-top: 6px
}

.cmt-actions .link {
	margin-right: 8px;
	cursor: pointer;
	color: #3a6;
	text-decoration: none
}

.cmt-actions .danger {
	color: #bb2d3b
}

.cmt-reply textarea {
	width: 100%;
	padding: 8px;
	border: 1px solid #ddd;
	border-radius: 6px;
	margin: 8px 0
}

.cmt-reply button {
	padding: 6px 10px;
	border: 0;
	background: #444;
	color: #fff;
	border-radius: 6px;
	cursor: pointer
}

.cmt-children {
	border-left: 2px solid #f1f1f1;
	margin-left: 10px;
	padding-left: 12px
}

.hidden {
	display: none
}

/* more buttons */
.more-wrap {
	text-align: center;
	margin: 12px 0
}

.more-btn {
	border: 1px solid #ddd;
	background: #fff;
	padding: 8px 14px;
	border-radius: 8px;
	cursor: pointer
}
</style>
</head>
<body>
	<div class="container">

		<div class="breadcrumb">
			<a
				href="<c:out value='${pageContext.request.contextPath}'/>/board/listArticles.do">전체</a>
			<span class="sep">&gt;</span>
			<c:out value="${empty article.cat ? '-' : article.cat}" />
			<span class="sep">&gt;</span>
			<c:out value="${empty article.sub ? '-' : article.sub}" />
		</div>

		<div class="header">
			<h1>
				<c:out value="${article.title}" />
			</h1>
			<div class="meta">
				<c:set var="displayWriter"
					value="${empty article.writerName ? article.id : article.writerName}" />
				<span class="writer"><c:out value="${displayWriter}" /></span> <span
					class="dot">·</span> <span class="date"> <c:choose>
						<c:when test="${not empty wd and wd.time ne null}">
							<fmt:formatDate value="${wd}" pattern="yyyy-MM-dd HH:mm" />
						</c:when>
						<c:otherwise>
							<c:out value="${wd}" />
						</c:otherwise>
					</c:choose>
				</span>
			</div>
		</div>

		<c:if test="${not empty article.imageFileName}">
			<div class="cover">
				<c:choose>
					<c:when test="${fn:startsWith(article.imageFileName,'http')}">
						<img src="<c:out value='${article.imageFileName}'/>" alt="cover" />
					</c:when>
					<c:otherwise>
						<img
							src="<c:out value='${pageContext.request.contextPath}'/>/board/download.do?imageFileName=<c:out value='${article.imageFileName}'/>&amp;articleNO=<c:out value='${article.articleNO}'/>"
							alt="cover" />
					</c:otherwise>
				</c:choose>
			</div>
		</c:if>

		<div class="content">
			<c:out value="${article.content}" escapeXml="false" />
		</div>

		<div class="actions">
			<c:if test="${loginId == article.id || loginId == 'admin'}">
				<a
					href="<c:out value='${pageContext.request.contextPath}'/>/board/modArticleForm.do?articleNO=<c:out value='${article.articleNO}'/>">수정</a>
				<a class="danger"
					href="<c:out value='${pageContext.request.contextPath}'/>/board/removeArticle.do?articleNO=<c:out value='${article.articleNO}'/>"
					onclick="return confirm('삭제할까요?')">삭제</a>
			</c:if>
		</div>

		<a class="back"
			href="<c:out value='${pageContext.request.contextPath}'/>/board/listArticles.do">목록으로</a>

		<div class="comments">
			<h2>댓글</h2>

			<c:choose>
				<c:when
					test="${sessionScope.isLogOn or not empty sessionScope.loginUser or not empty sessionScope.member}">
					<form class="cmt-form" method="post"
						action="<c:out value='${actionCommentAdd}'/>"
						onsubmit="return cleanAndSubmit(this)">
						<input type="hidden" name="articleNO"
							value="<c:out value='${article.articleNO}'/>" />
						<textarea name="content" rows="4" placeholder="댓글을 입력하세요" required></textarea>
						<button type="submit">등록</button>
					</form>
				</c:when>
				<c:otherwise>
					<div class="cmt-guard">
						댓글 작성은 로그인 후 이용하세요. <a
							href="<c:out value='${pageContext.request.contextPath}'/>/member/loginForm.do">로그인</a>
					</div>
				</c:otherwise>
			</c:choose>

			<div class="cmt-list">
				<%
					List<?> roots = null;
				Object tmp = request.getAttribute("comments");
				if (tmp instanceof List<?>)
					roots = (List<?>) tmp;
				if (roots == null)
					roots = java.util.Collections.emptyList();
				int totalRoot = roots.size();
				int idx = 0;
				boolean logged = (request.getAttribute("loginId") != null);
				String replyRel = (String) pageContext.findAttribute("actionCommentReply");
				long aid = 0L;
				try {
					Object avo = request.getAttribute("article");
					Object idObj = null;
					if (avo != null) {
						try {
					idObj = avo.getClass().getMethod("getArticleNO").invoke(avo);
						} catch (Exception ignore) {
						}
						if (idObj == null)
					try {
						idObj = avo.getClass().getMethod("getId").invoke(avo);
					} catch (Exception ignore) {
					}
					}
					if (idObj != null)
						aid = Long.parseLong(String.valueOf(idObj));
				} catch (Exception ignore) {
				}
				for (Object c : roots) {
					idx++;
					boolean hide = idx > 10;
					if (hide)
						out.write("<div class='cmt-root hidden' data-idx='" + idx + "'>");
					else
						out.write("<div class='cmt-root' data-idx='" + idx + "'>");
					renderComment(pageContext, out, c, aid, 0, logged, replyRel);
					out.write("</div>");
				}
				%>
			</div>

			<c:if test="${fn:length(comments) > 10}">
				<div class="more-wrap">
					<button class="more-btn" onclick="showMore()">댓글 더보기</button>
				</div>
			</c:if>
		</div>

	</div>

	<script>
		function toggleReply(id) {
			var el = document.getElementById(id);
			if (!el)
				return;
			el.classList.toggle('hidden');
			if (!el.classList.contains('hidden')) {
				var ta = el.querySelector('textarea');
				if (ta)
					ta.focus();
			}
		}
		function toggleChildren(id) {
			var el = document.getElementById(id);
			if (!el)
				return;
			el.classList.toggle('hidden');
		}
		(function() {
			// 처음엔 루트 댓글 10개만 보이도록(서버가 data-idx 부여함)
			var roots = document.querySelectorAll('.cmt-root');
			for (var i = 0; i < roots.length; i++) {
				var n = parseInt(roots[i].getAttribute('data-idx') || '0', 10);
				if (n > 10)
					roots[i].classList.add('hidden');
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
				if (w)
					w.style.display = 'none';
			}
		}
		function cleanAndSubmit(form) {
			var ta = form.querySelector('textarea[name="content"]');
			if (!ta)
				return true;
			var s = ta.value || '';
			s = s.replace(/^(?:\uFEFF|\s)*본문\s*/, ''); // leading "본문" 제거
			s = s.replace(/[ \t]{3,}/g, '  ').trim();
			if (s.length === 0) {
				alert('내용을 입력하세요.');
				ta.focus();
				return false;
			}
			ta.value = s;
			return true;
		}
	</script>
</body>
</html>
