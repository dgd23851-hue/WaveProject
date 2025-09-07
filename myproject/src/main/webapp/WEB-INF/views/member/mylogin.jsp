<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <title>로그인 | WAVE 뉴스</title>
  <link rel="stylesheet" href="<c:url value='/resources/css/login.css'/>" />
</head>
<body>
  <div class="login-bg">
    <div class="login-container">
      <div class="login-tabs">
        <button class="tab-btn active" id="loginTab" type="button">로그인</button>
        <button class="tab-btn" id="signupTab" type="button">회원가입</button>
      </div>

      <!-- ★ 반드시 이 URL로 POST -->
      <form class="login-form" id="loginForm"
            method="post"
            action="<c:url value='/member/mylogin.do'/>">
        <label for="login-id">아이디</label>
        <input type="text" id="login-id" name="id" placeholder="아이디" required />

        <label for="login-pw">비밀번호</label>
        <input type="password" id="login-pw" name="pwd" placeholder="비밀번호" required />

        <button type="submit" class="login-action-btn">로그인</button>
      </form>

      <c:if test="${param.error == '1'}">
        <p style="color:#d33;margin-top:8px;">아이디 또는 비밀번호가 올바르지 않습니다.</p>
      </c:if>
    </div>
  </div>
</body>
</html>