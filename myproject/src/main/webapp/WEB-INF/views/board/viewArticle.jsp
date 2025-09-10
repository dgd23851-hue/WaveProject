<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" isELIgnored="false"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<%-- 안전한 글 PK 계산 (id/articleNo/articleNO 중 존재하는 값) --%>
<c:set var="aid"
	value="${not empty article.articleNo ? article.articleNo
                     : (not empty article.articleNO ? article.articleNO : article.id)}" />

<%-- URL들 --%>
<c:url var="urlList" value="/board/listArticles.do" />
<c:url var="urlEdit" value="/board/modArticleForm.do">
	<c:param name="articleNO" value="${aid}" />
</c:url>
<c:url var="urlDelete" value="/board/removeArticle.do" />
<c:url var="urlAddCmt" value="/board/addComment.do" />
<%-- 댓글/답글 모두 여기로 (parentId로 구분) --%>

<link rel="stylesheet"
	href="<c:url value='/resources/css/viewArticle.css'/>" />

<div class="va-main">
	<div class="va-progress" id="vaProgress"></div>

	<div class="va-container">
		<!-- 헤더 -->
		<header class="va-head">
			<div class="va-breadcrumb">
				<a href="<c:url value='/'/>">홈</a> <span class="sep">/</span> <span>게시글</span>
			</div>

			<h1 class="va-title">${article.title}</h1>

			<div class="va-meta">
				<span> <c:out
						value="${not empty article.authorName ? article.authorName
                         : (not empty article.writerName ? article.writerName
                         : (not empty article.writer ? article.writer : article.writerId))}" />
				</span> <span class="dot">·</span> <span> <fmt:formatDate
						value="${not empty article.publishedAt ? article.publishedAt
                                   : (not empty article.regDate ? article.regDate : article.createdAt)}"
						pattern="yyyy-MM-dd HH:mm" />
				</span>
				<c:if test="${not empty article.views}">
					<span class="dot">·</span>
					<span>조회 ${article.views}</span>
				</c:if>
			</div>

			<!-- 액션: 수정/삭제 (소유자일 때만 표시) -->
			<c:if test="${article.own or article.isOwner}">
				<div class="va-actions" style="gap: 8px">
					<a class="va-btn is-outline" href="${urlEdit}">수정</a>

					<form method="post" action="${urlDelete}" class="va-inline"
						onsubmit="return confirm('정말 삭제할까요? 삭제 후 되돌릴 수 없습니다.');">
						<input type="hidden" name="articleNO" value="${aid}" />
						<c:if test="${not empty _csrf}">
							<input type="hidden" name="${_csrf.parameterName}"
								value="${_csrf.token}" />
						</c:if>
						<button type="submit" class="va-btn is-ghost">삭제</button>
					</form>
				</div>
			</c:if>
		</header>

		<!-- 히어로 이미지 -->
		<c:if test="${not empty article.heroUrl}">
			<div class="va-hero">
				<img src="${article.heroUrl}" alt="hero" />
			</div>
		</c:if>

		<!-- 본문 -->
		<article class="va-article">
			<c:choose>
				<c:when test="${not empty article.html}">
          ${article.html}
        </c:when>
				<c:otherwise>
					<c:forEach var="p" items="${article.paragraphs}">
						<p>${p}</p>
					</c:forEach>
				</c:otherwise>
			</c:choose>

			<c:if test="${not empty article.images}">
				<c:forEach var="img" items="${article.images}">
					<figure style="margin: 14px 0">
						<img src="${img.url}" alt="${img.alt}" />
						<figcaption class="va-meta" style="margin-top: 6px">${img.caption}</figcaption>
					</figure>
				</c:forEach>
			</c:if>

			<!-- 하단: 목록으로 -->
			<div style="margin-top: 24px">
				<a class="va-btn is-ghost" href="${urlList}">← 목록으로</a>
			</div>
		</article>

		<!-- 댓글 작성 -->
		<section style="margin: 24px 0">
			<h2 style="font-size: 1.2rem; margin: 0 0 10px">댓글</h2>

			<form method="post" action="${urlAddCmt}"
				enctype="multipart/form-data" class="va-card">
				<input type="hidden" name="article_no" value="${aid}" />

				<div
					style="border: 1px solid var(--line); border-radius: 12px; padding: 12px">
					<label class="sr-only" for="c-content">내용</label>
					<textarea id="c-content" name="content" rows="4"
						style="width: 100%; border: 1px solid var(--line); border-radius: 10px; padding: 10px"
						placeholder="댓글을 입력하세요"></textarea>

					<div
						style="margin-top: 10px; display: flex; align-items: center; gap: 8px; flex-wrap: wrap">
						<label class="va-btn is-outline"
							style="height: auto; padding: 8px 12px; cursor: pointer">
							사진 추가 <input type="file" name="photos" accept="image/*" multiple
							class="sr-only va-upload" data-preview="#c-preview">
						</label>
						<div id="c-preview"
							style="display: flex; gap: 8px; flex-wrap: wrap"></div>
						<button type="submit" class="va-btn">등록</button>
					</div>

					<c:if test="${not empty _csrf}">
						<input type="hidden" name="${_csrf.parameterName}"
							value="${_csrf.token}" />
					</c:if>
				</div>
			</form>
		</section>

		<!-- 댓글 리스트 -->
		<section style="margin: 16px 0 50px">
			<c:forEach var="cmt" items="${comments}">
				<div style="border-top: 1px solid var(--line); padding: 14px 0">
					<div class="va-meta" style="margin-bottom: 6px">
						<strong> <c:out
								value="${not empty cmt.authorName ? cmt.authorName
                             : (not empty cmt.writerName ? cmt.writerName
                             : (not empty cmt.writer ? cmt.writer : cmt.writerId))}" />
						</strong> <span class="dot">·</span> <span><fmt:formatDate
								value="${not empty cmt.createdAt ? cmt.createdAt : cmt.regDate}"
								pattern="yyyy-MM-dd HH:mm" /></span>
					</div>

					<div style="white-space: pre-wrap">${cmt.content}</div>

					<c:if test="${not empty cmt.attachments}">
						<div
							style="display: flex; gap: 8px; flex-wrap: wrap; margin-top: 8px">
							<c:forEach var="img" items="${cmt.attachments}">
								<a href="${img.url}" target="_blank"> <img src="${img.url}"
									alt="${img.originalName}"
									style="width: 120px; height: 120px; object-fit: cover; border: 1px solid var(--line); border-radius: 8px" />
								</a>
							</c:forEach>
						</div>
					</c:if>

					<div class="va-actions" style="margin-top: 8px">
						<a class="va-btn is-ghost" href="javascript:void(0)"
							onclick="toggleReplyForm('${cmt.id}')">답글</a>
					</div>

					<!-- 답글 폼 (같은 addComment.do로 전송, parentId 세팅) -->
					<div id="reply-${cmt.id}" style="display: none; margin-top: 10px">
						<form method="post" action="${urlAddCmt}"
							enctype="multipart/form-data"
							style="border: 1px solid var(--line); border-radius: 12px; padding: 10px">
							<input type="hidden" name="article_no" value="${aid}" /> <input
								type="hidden" name="parentId" value="${cmt.id}" />
							<textarea name="content" rows="3"
								style="width: 100%; border: 1px solid var(--line); border-radius: 10px; padding: 10px"
								placeholder="답글을 입력하세요"></textarea>
							<div
								style="margin-top: 8px; display: flex; align-items: center; gap: 8px; flex-wrap: wrap">
								<label class="va-btn is-outline"
									style="height: auto; padding: 8px 12px; cursor: pointer">
									사진 추가 <input type="file" name="photos" accept="image/*"
									multiple class="sr-only va-upload"
									data-preview="#r-preview-${cmt.id}">
								</label>
								<div id="r-preview-${cmt.id}"
									style="display: flex; gap: 8px; flex-wrap: wrap"></div>
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
							style="margin-top: 12px; padding-left: 14px; border-left: 2px solid var(--line)">
							<c:forEach var="rp" items="${cmt.replies}">
								<div
									style="padding: 10px 0; border-top: 1px dashed var(--line)">
									<div class="va-meta" style="margin-bottom: 6px">
										<strong> <c:out
												value="${not empty rp.authorName ? rp.authorName
                                     : (not empty rp.writerName ? rp.writerName
                                     : (not empty rp.writer ? rp.writer : rp.writerId))}" />
										</strong> <span class="dot">·</span> <span><fmt:formatDate
												value="${not empty rp.createdAt ? rp.createdAt : rp.regDate}"
												pattern="yyyy-MM-dd HH:mm" /></span>
									</div>
									<div style="white-space: pre-wrap">${rp.content}</div>
									<c:if test="${not empty rp.attachments}">
										<div
											style="display: flex; gap: 8px; flex-wrap: wrap; margin-top: 8px">
											<c:forEach var="img" items="${rp.attachments}">
												<a href="${img.url}" target="_blank"> <img
													src="${img.url}" alt="${img.originalName}"
													style="width: 110px; height: 110px; object-fit: cover; border: 1px solid var(--line); border-radius: 8px" />
												</a>
											</c:forEach>
										</div>
									</c:if>
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
/* 스크롤 진행바 */
(function(){
  var el=document.getElementById('vaProgress');
  function onScroll(){
    var h=document.documentElement, b=document.body;
    var st=(h.scrollTop||b.scrollTop), sh=(h.scrollHeight||b.scrollHeight)-h.clientHeight;
    el.style.width=(sh>0?(st/sh*100):0)+'%';
  }
  window.addEventListener('scroll', onScroll, {passive:true}); onScroll();
})();

/* 답글 폼 토글 */
function toggleReplyForm(id){
  var el=document.getElementById('reply-'+id);
  if(!el) return;
  el.style.display = (el.style.display==='none'||el.style.display==='') ? 'block' : 'none';
}

/* 이미지 미리보기 */
(function(){
  function previewFiles(input, previewSel){
    var box=document.querySelector(previewSel); if(!box) return;
    box.innerHTML='';
    var files=input.files||[];
    for(var i=0;i<files.length;i++){
      if(!files[i].type.match(/^image\//)) continue;
      (function(f){
        var r=new FileReader();
        r.onload=function(e){
          var img=new Image();
          img.src=e.target.result;
          img.style.width='96px'; img.style.height='96px'; img.style.objectFit='cover';
          img.style.border='1px solid var(--line)'; img.style.borderRadius='8px';
          box.appendChild(img);
        };
        r.readAsDataURL(f);
      })(files[i]);
    }
  }
  document.addEventListener('change', function(e){
    var t=e.target;
    if(t.classList && t.classList.contains('va-upload')){
      var sel=t.getAttribute('data-preview')||''; previewFiles(t, sel);
    }
  });
})();
</script>
