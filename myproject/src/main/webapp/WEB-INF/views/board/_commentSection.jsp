<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<!-- 안전한 기사 ID 계산: article.id -> article.articleNO -> articleId -> param.articleNO -->
<c:set var="aid"
	value="${not empty article.id ? article.id : (not empty article.articleNO ? article.articleNO : (not empty articleId ? articleId : param.articleNO))}" />

<!-- 엔드포인트 URL들 (.do 방식 고정) -->
<c:url var="addUrl" value="/comment/add.do" />
<c:url var="delUrl" value="/comment/delete.do" />
<c:url var="viewUrl" value="/board/viewArticle.do" />
<c:url var="pingUrl" value="/comment/ping.do" />

<!-- ===== DEBUG 패널 (필요시 param.debug=1 로 노출) ===== -->
<c:set var="DEBUG" value="${param.debug eq '1'}" />
<c:if test="${DEBUG}">
	<div
		style="padding: 10px; margin: 10px 0; border: 1px dashed #bbb; background: #fffbe6; font-family: monospace;">
		DEBUG ctx=${pageContext.request.contextPath}, aid=${aid}, addUrl=<a
			href="${addUrl}" target="_blank">${addUrl}</a>, delUrl=<a
			href="${delUrl}" target="_blank">${delUrl}</a>, ping=<a
			href="${pingUrl}" target="_blank">${pingUrl}</a>
	</div>
</c:if>

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

.comment-form textarea {
	width: 100%;
	height: 90px;
	padding: 10px;
	resize: vertical;
	border: 1px solid #ccc;
	border-radius: 6px;
	font-size: 14px;
	margin-bottom: 10px;
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

.comment-item .actions .del {
	background: none;
	border: none;
	color: #d00;
	cursor: pointer;
	padding: 0;
}
</style>

<div class="comment-section">
	<h3>댓글</h3>

	<!-- 폼 대신 JS fetch 사용: 중첩 폼/액션 변조 문제를 원천 차단 -->
	<div class="comment-form">
		<textarea id="commentContent" placeholder="댓글을 입력하세요" required></textarea>
		<button id="commentSubmit" type="button" class="btn">등록</button>
		<c:if test="${DEBUG}">
			<!-- 디버그 전용 빠른 테스트 버튼 -->
			<button id="commentSubmitDebug" type="button" class="btn"
				style="background: #6c757d; margin-left: 8px;">등록(디버그)</button>
		</c:if>
	</div>

	<ul class="comment-list">
		<c:forEach var="c" items="${comments}">
			<li class="comment-item" data-id="${c.id}">
				<div class="meta">
					<b>${c.writer}</b>
					<c:if test="${not empty c.writeDate}"> | <fmt:formatDate
							value="${c.writeDate}" pattern="yyyy-MM-dd HH:mm" />
					</c:if>
				</div>
				<div class="content">${c.content}</div>
				<div class="actions">
					<button class="del" type="button" data-id="${c.id}">삭제</button>
				</div>
			</li>
		</c:forEach>
	</ul>
</div>

<script>
// 전역 에러를 콘솔로
window.onerror = function(msg, src, lineno, colno, err){
  console.log("[JS ERROR]", msg, src, lineno, colno, err);
};

(function(){
  var addUrl    = "${addUrl}";
  var delUrl    = "${delUrl}";
  var viewUrl   = "${viewUrl}";
  var aid       = "${aid}";
  var articleNO = "${param.articleNO}";
  var csrfName  = "${_csrf != null ? _csrf.parameterName : ''}";
  var csrfTok   = "${_csrf != null ? _csrf.token : ''}";
  var DEBUG     = ${DEBUG ? 'true' : 'false'};

  function toParams(obj){
    var p = new URLSearchParams();
    for (var k in obj) if (obj[k] !== undefined && obj[k] !== null && obj[k] !== "") p.set(k, obj[k]);
    if (csrfName && csrfTok) p.set(csrfName, csrfTok);
    return p.toString();
  }

  function postAdd(content){
    if(!aid){ alert("글 번호를 찾을 수 없습니다."); return; }
    if(!content || !content.trim()){ alert("내용을 입력하세요."); return; }
    var body = toParams({ articleId: aid, articleNO: articleNO, content: content });
    if (DEBUG) console.log("[DEBUG] POST", addUrl, "body=", body);
    return fetch(addUrl, {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8" },
      body: body
    }).then(function(res){
      if (DEBUG) console.log("[DEBUG] fetch status", res.status);
      return res.text();
    });
  }

  function postDelete(id){
    var body = toParams({ id: id, articleId: aid, articleNO: articleNO });
    if (DEBUG) console.log("[DEBUG] DELETE", delUrl, "body=", body);
    return fetch(delUrl, {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8" },
      body: body
    }).then(function(res){
      if (DEBUG) console.log("[DEBUG] delete status", res.status);
      return res.text();
    });
  }

  // 등록 버튼
  var submitBtn = document.getElementById("commentSubmit");
  if (submitBtn) {
    submitBtn.addEventListener("click", function(){
      var content = (document.getElementById("commentContent").value || "").trim();
      postAdd(content).then(function(){
        window.location.href = viewUrl + "?articleNO=" + (articleNO || aid);
      }).catch(function(e){
        alert("댓글 등록 실패: " + e);
        if (DEBUG) console.log("[DEBUG] add error", e);
      });
    });
  }

  // 디버그용 등록 버튼 (콘솔 로그만 추가)
  var submitDbgBtn = document.getElementById("commentSubmitDebug");
  if (submitDbgBtn) {
    submitDbgBtn.addEventListener("click", function(){
      var content = (document.getElementById("commentContent").value || "").trim();
      console.log("[DEBUG] click, posting...", addUrl, "aid=", aid, "content=", content);
      postAdd(content).then(function(txt){
        console.log("[DEBUG] response text len", (txt||'').length);
        window.location.href = viewUrl + "?articleNO=" + (articleNO || aid);
      }).catch(function(e){
        console.log("[DEBUG] fetch error", e);
        alert("댓글 등록 실패: " + e);
      });
    });
  }

  // 삭제 버튼 (이벤트 위임)
  var list = document.querySelector(".comment-list");
  if (list) {
    list.addEventListener("click", function(e){
      if (e.target && e.target.classList.contains("del")) {
        var id = e.target.getAttribute("data-id");
        if(!confirm("삭제하시겠습니까?")) return;
        postDelete(id).then(function(){
          // 즉시 제거 후 새로고침
          var li = e.target.closest(".comment-item");
          if (li) li.remove();
          window.location.href = viewUrl + "?articleNO=" + (articleNO || aid);
        }).catch(function(e){
          alert("삭제 실패: " + e);
          if (DEBUG) console.log("[DEBUG] delete error", e);
        });
      }
    });
  }

  if (DEBUG) {
    console.log("[DEBUG] ready. ctx='${pageContext.request.contextPath}', aid=", aid, "addUrl=", addUrl);
  }
})();
</script>
