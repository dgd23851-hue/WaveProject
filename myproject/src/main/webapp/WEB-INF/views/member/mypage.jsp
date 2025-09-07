<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <title>마이페이지</title>
  <link rel="stylesheet" href="<c:url value='/resources/css/mypage.css'/>">
</head>
<body>
  <div class="mypage-wrap">
    <div class="mypage-side">
      <div class="profile-card">
        <div class="profile-img"></div>
        <div class="profile-name">
          <c:choose>
            <c:when test="${not empty sessionScope.member}">${sessionScope.member.name}</c:when>
            <c:otherwise>게스트</c:otherwise>
          </c:choose>
        </div>
        <div class="profile-desc">
          <c:choose>
            <c:when test="${not empty sessionScope.member}">로그인 중</c:when>
            <c:otherwise>로그인 없이 이용 중</c:otherwise>
          </c:choose>
        </div>

        <c:choose>
          <c:when test="${not empty sessionScope.member}">
            <a class="login-btn" href="<c:url value='/member/logout.do'/>"
               onclick="return confirm('로그아웃 하시겠습니까?');">로그아웃</a>
          </c:when>
          <c:otherwise>
            <a class="login-btn" href="<c:url value='/member/loginForm.do'/>">로그인</a>
          </c:otherwise>
        </c:choose>
      </div>

      <ul class="mypage-menu">
        <li class="on">마이페이지</li>
        <li>설정</li>
        <li>북마크</li>
      </ul>
    </div>

    <div class="mypage-main">
      <div class="cardbox">
        <div class="cardbox-title" id="card-title">내 마이페이지</div>
        <div class="card-section" id="mypage-section">
          <div class="mypage-info-box">
            <div class="info-title">어서오세요!</div>
            <div class="info-desc">
              <c:choose>
                <c:when test="${not empty sessionScope.member}">
                  <b>${sessionScope.member.name}</b>로 접속 중입니다.
                </c:when>
                <c:otherwise><b>게스트</b>로 접속 중입니다.</c:otherwise>
              </c:choose>
            </div>
          </div>
        </div>

        <div class="card-section" id="setting-section" style="display:none;">
          <form class="setting-form">
            <div class="form-group">
              <label for="name">이름 변경</label>
              <input type="text" id="name" name="name" placeholder="새 이름 입력">
            </div>
            <div class="form-group">
              <label for="email">이메일 변경</label>
              <input type="email" id="email" name="email" placeholder="새 이메일 입력">
            </div>
            <button type="submit" class="login-btn" style="margin-top:15px;">저장</button>
          </form>
        </div>

        <div class="card-section" id="bookmark-section" style="display:none;">
          <div class="empty-news"><div class="empty-msg">찜한 뉴스가 없습니다.</div></div>
        </div>
      </div>
    </div>
  </div>

  <footer class="mypage-footer">
    <div>ⓒ WAVE News | All rights reserved.</div>
  </footer>

  <script>
    document.querySelectorAll('.mypage-menu li').forEach(function (menu, idx) {
      menu.addEventListener('click', function () {
        document.querySelectorAll('.mypage-menu li').forEach(li => li.classList.remove('on'));
        menu.classList.add('on');
        document.getElementById('mypage-section').style.display  = (idx === 0) ? 'block' : 'none';
        document.getElementById('setting-section').style.display = (idx === 1) ? 'block' : 'none';
        document.getElementById('bookmark-section').style.display= (idx === 2) ? 'block' : 'none';
        document.getElementById('card-title').textContent =
          idx === 0 ? '내 마이페이지' : (idx === 1 ? '설정' : '북마크/관심 뉴스');
      });
    });
  </script>
</body>
</html>
