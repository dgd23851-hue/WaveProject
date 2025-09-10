<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" isELIgnored="false"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<c:url var="mypageAction" value="/member/mypage.do" />

<style>
/* ===== MyPage 전용 최소 스타일 (Tiles body 프래그먼트) ===== */
.mp-container {
	max-width: 1120px;
	margin: 0 auto;
	padding: 16px
}

.mp-grid {
	display: grid;
	grid-template-columns: 3fr 1fr;
	grid-gap: 16px
}

@media ( max-width :1024px) {
	.mp-grid {
		grid-template-columns: 1fr
	}
}

.mp-card {
	background: #fff;
	border: 1px solid #e5e7eb;
	border-radius: 16px;
	box-shadow: 0 1px 2px rgba(0, 0, 0, .04)
}

.mp-h {
	display: flex;
	align-items: center;
	justify-content: space-between;
	padding: 16px;
	border-bottom: 1px solid #e5e7eb
}

.mp-b {
	padding: 16px
}

.mp-badge {
	display: inline-flex;
	align-items: center;
	padding: .25rem .6rem;
	border-radius: 9999px;
	background: #f3f4f6;
	border: 1px solid #e5e7eb;
	color: #374151;
	font-size: 12px
}

.mp-muted {
	color: #6b7280;
	font-size: 12px
}

.mp-btn {
	display: inline-flex;
	align-items: center;
	gap: 6px;
	padding: 10px 14px;
	border-radius: 12px;
	background: #111;
	color: #fff;
	border: 0;
	cursor: pointer;
	text-decoration: none
}

.mp-btn.outline {
	background: #f9fafb;
	color: #111;
	border: 1px solid #e5e7eb
}

.mp-row {
	display: flex;
	align-items: center;
	justify-content: space-between;
	gap: 8px
}

.mp-chips {
	display: flex;
	flex-wrap: wrap;
	gap: 8px
}

.mp-metrics {
	display: grid;
	grid-template-columns: repeat(4, 1fr);
	gap: 12px;
	margin-top: 16px
}

@media ( max-width :640px) {
	.mp-metrics {
		grid-template-columns: repeat(2, 1fr)
	}
}

.mp-metric {
	border: 1px solid #e5e7eb;
	border-radius: 12px;
	padding: 12px;
	background: #fff
}

.mp-metric .k {
	font-weight: 700;
	font-size: 22px;
	margin-top: 2px
}

.mp-tabs {
	display: flex;
	gap: 8px
}

.mp-list {
	display: flex;
	flex-direction: column;
	gap: 10px
}

.mp-item {
	border: 1px solid #e5e7eb;
	border-radius: 12px;
	padding: 12px;
	background: #fff
}

.mp-search {
	width: 100%;
	padding: 10px;
	border: 1px solid #e5e7eb;
	border-radius: 12px
}

.mp-two {
	display: grid;
	grid-template-columns: 1fr auto;
	gap: 8px;
	align-items: center
}

.mp-form .field {
	margin-bottom: 10px
}

.mp-form input, .mp-form textarea {
	width: 100%;
	padding: 10px;
	border: 1px solid #e5e7eb;
	border-radius: 12px
}

.mp-sticky {
	position: sticky;
	top: 12px
}

.hidden {
	display: none
}

.mp-avatar {
	width: 80px;
	height: 80px;
	border-radius: 16px;
	object-fit: cover
}
</style>

<script>
function mpSwitchTab(name){
  var ids = ["bookmarks","history","comments"];
  ids.forEach(function(s){
    var t = document.getElementById("mp-tab-"+s);
    var p = document.getElementById("mp-pane-"+s);
    if(!t || !p) return;
    if(s===name){ t.classList.remove("outline"); p.classList.remove("hidden"); }
    else{ t.classList.add("outline"); p.classList.add("hidden"); }
  });
  location.hash = "#"+name;
}
function mpOnLoad(){
  var h = (location.hash||"").replace("#","");
  if(["history","comments"].indexOf(h)>=0) mpSwitchTab(h);
}
function mpFilterBookmarks(){
  var q = (document.getElementById("mp-bm-q").value||"").toLowerCase();
  var rows = document.querySelectorAll(".mp-bm-row");
  var empty = true;
  for(var i=0;i<rows.length;i++){
    var title = rows[i].getAttribute("data-title")||"";
    var show = title.indexOf(q)>=0;
    rows[i].style.display = show ? "" : "none";
    if(show) empty=false;
  }
  var emptyEl = document.getElementById("mp-bm-empty");
  if(emptyEl) emptyEl.style.display = empty ? "" : "none";
}
window.addEventListener("DOMContentLoaded", mpOnLoad);
</script>

<div class="mp-container">
	<div class="mp-grid">

		<!-- 메인 -->
		<section>
			<!-- 프로필 카드 -->
			<div class="mp-card">
				<div class="mp-h">
					<div>
						<h3 style="margin: 0; font-size: 18px; font-weight: 700">${me.name}</h3>
						<p class="mp-muted" style="margin: 4px 0 0">
							가입일
							<fmt:formatDate value="${me.joinedAt}" pattern="yyyy-MM-dd" />
							· 등급 ${me.tier}
						</p>
					</div>
					<a href="#mp-profile" class="mp-btn">프로필 편집</a>
				</div>
				<div class="mp-b">
					<div
						style="display: flex; gap: 16px; align-items: flex-start; flex-wrap: wrap">
						<img src="${me.avatarUrl}" class="mp-avatar" alt="avatar" />
						<div style="flex: 1">
							<div class="mp-chips">
								<c:forEach var="tname" items="${me.followingTopics}">
									<span class="mp-badge">${tname}</span>
								</c:forEach>
							</div>
							<p class="mp-muted" style="margin-top: 10px">관심 토픽 기반으로 추천이
								제공.</p>
						</div>
					</div>
					<div class="mp-metrics">
						<div class="mp-metric">
							<div class="mp-muted">북마크</div>
							<div class="k">${fn:length(bookmarks)}</div>
						</div>
						<div class="mp-metric">
							<div class="mp-muted">댓글</div>
							<div class="k">${fn:length(comments)}</div>
						</div>
						<div class="mp-metric">
							<div class="mp-muted">연속 읽기</div>
							<div class="k">${me.readingStreak}일</div>
						</div>
						<div class="mp-metric">
							<div class="mp-muted">알림</div>
							<div class="k">
								<!-- 간단히 총합(예: 3). 필요하면 서버에서 내려줘 -->
								3
							</div>
						</div>
					</div>
				</div>
			</div>

			<!-- 내 콘텐츠 -->
			<div class="mp-card" style="margin-top: 16px">
				<div class="mp-h">
					<div>내 콘텐츠</div>
					<div class="mp-tabs">
						<button id="mp-tab-bookmarks" class="mp-btn"
							onclick="mpSwitchTab('bookmarks')">북마크</button>
						<button id="mp-tab-history" class="mp-btn outline"
							onclick="mpSwitchTab('history')">열람기록</button>
						<button id="mp-tab-comments" class="mp-btn outline"
							onclick="mpSwitchTab('comments')">댓글</button>
					</div>
				</div>
				<div class="mp-b">

					<!-- 북마크 -->
					<div id="mp-pane-bookmarks">
						<div class="mp-two" style="margin-bottom: 10px">
							<input id="mp-bm-q" class="mp-search" placeholder="북마크 검색"
								oninput="mpFilterBookmarks()" />
						</div>
						<div class="mp-list">
							<c:forEach var="b" items="${bookmarks}">
								<div class="mp-item mp-bm-row"
									data-title="${fn:toLowerCase(b.title)}">
									<div
										style="display: flex; justify-content: space-between; gap: 10px; flex-wrap: wrap">
										<div>
											<div class="mp-chips" style="gap: 6px">
												<span class="mp-badge">${b.section}</span> <span
													class="mp-muted">저장 <fmt:formatDate
														value="${b.savedAt}" pattern="yyyy-MM-dd" /></span>
											</div>
											<div style="margin-top: 4px; font-weight: 600">${b.title}</div>
											<div class="mp-muted">예상 읽기 ${b.readingTime}분</div>
										</div>
										<div style="display: flex; gap: 8px; height: fit-content">
											<form method="post" action="${mypageAction}">
												<input type="hidden" name="action" value="removeBookmark" />
												<input type="hidden" name="id" value="${b.id}" />
												<button class="mp-btn outline" type="submit">삭제</button>
											</form>
											<a class="mp-btn outline"
												href="<c:url value='/article/view.do'><c:param name='id' value='${b.id}'/></c:url>">보러가기</a>
										</div>
									</div>
								</div>
							</c:forEach>
							<div id="mp-bm-empty" class="mp-muted" style="display: none">검색
								결과가 없어.</div>
						</div>
					</div>

					<!-- 열람기록 -->
					<div id="mp-pane-history" class="hidden">
						<div class="mp-list">
							<c:forEach var="h" items="${history}">
								<div class="mp-item">
									<div class="mp-chips" style="gap: 6px">
										<span class="mp-badge">${h.section}</span> <span
											class="mp-muted">읽음 ${h.readAt}</span>
									</div>
									<div style="margin-top: 4px; font-weight: 600">${h.title}</div>
								</div>
							</c:forEach>
						</div>
					</div>

					<!-- 댓글 -->
					<div id="mp-pane-comments" class="hidden">
						<div class="mp-list">
							<c:forEach var="cmt" items="${comments}">
								<div class="mp-item">
									<div class="mp-chips" style="gap: 6px">
										<span class="mp-badge">${cmt.section}</span> <span
											class="mp-muted">작성 ${cmt.commentedAt}</span>
									</div>
									<div style="margin-top: 4px; font-weight: 600">${cmt.articleTitle}</div>
									<div style="margin-top: 4px">${cmt.content}</div>
									<div style="margin-top: 8px; display: flex; gap: 8px">
										<a class="mp-btn outline"
											href="<c:url value='/comment/edit.do'><c:param name='id' value='${cmt.id}'/></c:url>">수정</a>
										<a class="mp-btn outline"
											href="<c:url value='/comment/delete.do'><c:param name='id' value='${cmt.id}'/></c:url>">삭제</a>
									</div>
								</div>
							</c:forEach>
						</div>
					</div>

				</div>
			</div>
		</section>

		<!-- 사이드(스티키) -->
		<aside class="mp-sticky">
			<!-- 관심 토픽 -->
			<div class="mp-card">
				<div class="mp-h">
					<div>관심 토픽 관리</div>
				</div>
				<div class="mp-b">
					<div class="mp-chips" style="gap: 8px">
						<c:forEach var="t" items="${allTopics}">
							<!-- 안전한 멤버십 체크 (EL contains 미사용) -->
							<c:set var="following" value="false" />
							<c:forEach var="ft" items="${me.followingTopics}">
								<c:if test="${ft eq t.name}">
									<c:set var="following" value="true" />
								</c:if>
							</c:forEach>

							<form method="post" action="${mypageAction}"
								style="display: inline">
								<input type="hidden" name="action" value="toggleTopic" /> <input
									type="hidden" name="topic" value="${t.name}" />
								<button type="submit" class="mp-badge"
									style="border-color:${following ? '#111' : '#e5e7eb'};background:${following ? '#111' : '#f3f4f6'};color:${following ? '#fff' : '#374151'}">
									${following ? '팔로잉' : '팔로우'} · ${t.name}</button>
							</form>
						</c:forEach>
					</div>
				</div>
			</div>

			<!-- 알림 설정 -->
			<div class="mp-card" style="margin-top: 16px">
				<div class="mp-h">
					<div>알림 설정</div>
				</div>
				<div class="mp-b">
					<form method="post" action="${mypageAction}" class="mp-form">
						<input type="hidden" name="action" value="saveNotify" /> <label
							class="mp-row"><span>속보(Breaking)</span><input
							type="checkbox" name="breaking" checked /></label> <label class="mp-row"><span>데일리
								다이제스트</span><input type="checkbox" name="dailyDigest" checked /></label> <label
							class="mp-row"><span>내 댓글에 답글</span><input
							type="checkbox" name="comments" checked /></label> <label class="mp-row"><span>프로모션/마케팅</span><input
							type="checkbox" name="marketing" /></label>
						<div>
							<button class="mp-btn" type="submit">저장</button>
						</div>
					</form>
				</div>
			</div>

			<!-- 프로필 수정 -->
			<div id="mp-profile" class="mp-card" style="margin-top: 16px">
				<div class="mp-h">
					<div>프로필</div>
				</div>
				<div class="mp-b">
					<form method="post" action="${mypageAction}" class="mp-form">
						<input type="hidden" name="action" value="saveProfile" />
						<div class="field">
							<label>이름</label> <input name="name" value="${me.name}" />
						</div>
						<div class="field">
							<label>이메일</label> <input type="email" name="email"
								value="${me.email}" />
						</div>
						<div class="field">
							<label>소개</label>
							<textarea name="bio" rows="3">${me.bio}</textarea>
						</div>
						<div style="display: flex; gap: 8px">
							<button class="mp-btn" type="submit">저장</button>
							<a class="mp-btn outline" href="<c:url value='/logout.do'/>">로그아웃</a>
						</div>
					</form>
				</div>
			</div>
		</aside>

	</div>
</div>
