<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" isELIgnored="false"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<c:url var="actionAdd" value="/article/comment/add.do" />
<c:url var="actionReply" value="/article/comment/reply.do" />

<!-- 외부 CSS 연결 (이미 존재하는 viewArticle.css 사용) -->
<link rel="stylesheet"
	href="<c:url value='/resources/css/viewArticle.css'/>" />

<div class="va-main">
	<div class="va-progress" id="vaProgress"></div>

	<div class="va-container">
		<!-- 머리 -->
		<header class="va-head">
			<div class="va-breadcrumb">
				<a href="<c:url value='/'/>">홈</a> <span class="sep">/</span>
				<!-- section 필드 의존 제거: 안전한 텍스트로 대체 -->
				<span>게시글</span>
			</div>
			<h1 class="va-title">${article.title}</h1>

			<div class="va-meta">
				<span>${article.authorName}</span> <span class="dot">·</span> <span><fmt:formatDate
						value="${article.publishedAt}" pattern="yyyy-MM-dd HH:mm" /></span> <span
					class="dot">·</span> <span>조회 ${article.views}</span>
			</div>

			<div class="va-actions">
				<form method="post"
					action="<c:url value='/article/bookmark/toggle.do'/>"
					class="va-inline">
					<input type="hidden" name="articleId" value="${article.id}" />
					<button class="va-btn is-outline" type="submit">북마크</button>
				</form>
				<a class="va-btn"
					href="<c:url value='/article/print.do'><c:param name='id' value='${article.id}'/></c:url>">인쇄</a>
				<a class="va-btn is-ghost"
					href="<c:url value='/article/share.do'><c:param name='id' value='${article.id}'/></c:url>">공유</a>
			</div>
		</header>

		<!-- 히어로 이미지 -->
		<c:if test="${not empty article.heroUrl}">
			<div class="va-hero">
				<img src="${article.heroUrl}" alt="hero" />
			</div>
		</c:if>

		<!-- 본문 -->
		<article class="va-article">
			<c:if test="${not empty article.html}">
        ${article.html}
      </c:if>
			<c:if test="${empty article.html}">
				<c:forEach var="p" items="${article.paragraphs}">
					<p>${p}</p>
				</c:forEach>
			</c:if>

			<c:forEach var="img" items="${article.images}">
				<figure style="margin: 14px 0">
					<img src="${img.url}" alt="${img.alt}" />
					<figcaption class="va-meta" style="margin-top: 6px">${img.caption}</figcaption>
				</figure>
			</c:forEach>
		</article>

		<!-- 태그 -->
		<c:if test="${not empty article.tags}">
			<div class="va-tags">
				<c:forEach var="tag" items="${article.tags}">
					<a class="va-chip"
						href="<c:url value='/tag.do'><c:param name='q' value='${tag}'/></c:url>">#${tag}</a>
				</c:forEach>
			</div>
		</c:if>

		<!-- 하단 액션: section 의존 제거, 안전한 목록 링크로 변경 -->
		<div class="va-bottom">
			<div class="va-flex"></div>
			<a class="va-btn is-outline" href="<c:url value='/board/list.do'/>">목록</a>
		</div>

		<!-- 댓글 쓰기 -->
		<section style="margin: 16px 0 24px">
			<h2 style="font-size: 1.2rem; margin: 0 0 10px">댓글</h2>

			<form method="post" action="${actionAdd}"
				enctype="multipart/form-data" class="va-card">
				<input type="hidden" name="articleId" value="${article.id}" />
				<div
					style="border: 1px solid var(- -line); border-radius: 12px; padding: 12px">
					<label class="sr-only" for="c-content">내용</label>
					<textarea id="c-content" name="content" rows="4"
						style="width: 100%; border: 1px solid var(- -line); border-radius: 10px; padding: 10px"
						placeholder="댓글을 입력하세요"></textarea>

					<!-- 사진 업로드(미리보기) -->
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
				<div style="border-top: 1px solid var(- -line); padding: 14px 0">
					<div class="va-meta" style="margin-bottom: 6px">
						<strong>${cmt.authorName}</strong> <span class="dot">·</span> <span><fmt:formatDate
								value="${cmt.createdAt}" pattern="yyyy-MM-dd HH:mm" /></span>
					</div>

					<div style="white-space: pre-wrap">${cmt.content}</div>

					<c:if test="${not empty cmt.attachments}">
						<div
							style="display: flex; gap: 8px; flex-wrap: wrap; margin-top: 8px">
							<c:forEach var="img" items="${cmt.attachments}">
								<a href="${img.url}" target="_blank"><img src="${img.url}"
									alt="${img.originalName}"
									style="width: 120px; height: 120px; object-fit: cover; border: 1px solid var(- -line); border-radius: 8px" /></a>
							</c:forEach>
						</div>
					</c:if>

					<div class="va-actions" style="margin-top: 8px">
						<a class="va-btn is-ghost" href="javascript:void(0)"
							onclick="toggleReplyForm('${cmt.id}')">답글</a>
						<c:if test="${cmt.own}">
							<a class="va-btn is-ghost"
								href="<c:url value='/article/comment/delete.do'><c:param name='id' value='${cmt.id}'/></c:url>">삭제</a>
						</c:if>
					</div>

					<!-- 답글 폼 -->
					<div id="reply-${cmt.id}" style="display: none; margin-top: 10px">
						<form method="post" action="${actionReply}"
							enctype="multipart/form-data"
							style="border: 1px solid var(- -line); border-radius: 12px; padding: 10px">
							<input type="hidden" name="articleId" value="${article.id}" /> <input
								type="hidden" name="parentId" value="${cmt.id}" />
							<textarea name="content" rows="3"
								style="width: 100%; border: 1px solid var(- -line); border-radius: 10px; padding: 10px"
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
							style="margin-top: 12px; padding-left: 14px; border-left: 2px solid var(- -line)">
							<c:forEach var="rp" items="${cmt.replies}">
								<div
									style="padding: 10px 0; border-top: 1px dashed var(- -line)">
									<div class="va-meta" style="margin-bottom: 6px">
										<strong>${rp.authorName}</strong> <span class="dot">·</span> <span><fmt:formatDate
												value="${rp.createdAt}" pattern="yyyy-MM-dd HH:mm" /></span>
									</div>
									<div style="white-space: pre-wrap">${rp.content}</div>
									<c:if test="${not empty rp.attachments}">
										<div
											style="display: flex; gap: 8px; flex-wrap: wrap; margin-top: 8px">
											<c:forEach var="img" items="${rp.attachments}">
												<a href="${img.url}" target="_blank"><img
													src="${img.url}" alt="${img.originalName}"
													style="width: 110px; height: 110px; object-fit: cover; border: 1px solid var(- -line); border-radius: 8px" /></a>
											</c:forEach>
										</div>
									</c:if>
									<div class="va-actions" style="margin-top: 6px">
										<c:if test="${rp.own}">
											<a class="va-btn is-ghost"
												href="<c:url value='/article/comment/delete.do'><c:param name='id' value='${rp.id}'/></c:url>">삭제</a>
										</c:if>
									</div>
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
    var p=sh>0? (st/sh*100):0;
    el.style.width=p+'%';
  }
  window.addEventListener('scroll', onScroll, {passive:true});
  onScroll();
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
    var box=document.querySelector(previewSel);
    if(!box) return;
    box.innerHTML='';
    var files=input.files||[];
    for(var i=0;i<files.length;i++){
      if(!files[i].type.match(/^image\\//)) continue;
      var r=new FileReader();
      r.onload=function(e){
        var img=new Image();
        img.src=e.target.result;
        img.style.width='96px'; img.style.height='96px';
        img.style.objectFit='cover';
        img.style.border='1px solid var(--line)';
        img.style.borderRadius='8px';
        box.appendChild(img);
      };
      r.readAsDataURL(files[i]);
    }
  }
  document.addEventListener('change', function(e){
    var t=e.target;
    if(t.classList && t.classList.contains('va-upload')){
      var sel=t.getAttribute('data-preview')||'';
      previewFiles(t, sel);
    }
  });
})();
</script>
