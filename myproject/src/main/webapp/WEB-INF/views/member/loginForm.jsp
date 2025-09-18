<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
	isELIgnored="false"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8" />
<title>로그인 | WAVE 뉴스</title>

<!-- 로그인 실패 경고 -->
<c:if
	test="${error eq 'loginFailed' or param.error eq 'loginFailed' or param.result eq 'loginFailed'}">
	<script>
      document.addEventListener('DOMContentLoaded', function(){ alert('아이디 또는 비밀번호가 올바르지 않습니다.'); });
    </script>
</c:if>

<!-- 회원가입 에러(아이디 중복) → 가입 탭 열기 + 경고 -->
<c:if
	test="${signupError eq 'idExists' or param.signupError eq 'idExists'}">
	<script>
      document.addEventListener('DOMContentLoaded', function(){
        // 탭 전환은 아래 스크립트에서 처리 (signupTab 클릭)
        alert('이미 사용 중인 아이디입니다.');
      });
    </script>
</c:if>

<link rel="stylesheet" href="<c:url value='/resources/css/login.css'/>" />
<link rel="stylesheet" href="<c:url value='/resources/css/style.css'/>">
<style>
.hint-ok {
	color: #1e873e;
	font-size: 12px;
	margin-top: 4px;
}

.hint-bad {
	color: #c62828;
	font-size: 12px;
	margin-top: 4px;
}

.disabled {
	opacity: .6;
	pointer-events: none;
}
</style>
</head>

<body>
	<div class="login-bg">
		<div class="login-container">
			<div class="login-tabs">
				<button class="tab-btn active" id="loginTab" type="button">로그인</button>
				<button class="tab-btn" id="signupTab" type="button">회원가입</button>
			</div>

			<!-- 로그인 -->
			<form class="login-form" id="loginForm" method="post"
				action="<c:url value='/member/login.do'/>">
				<label for="login-id">아이디</label> <input type="text" id="login-id"
					name="id" required /> <label for="login-pw">비밀번호</label> <input
					type="password" id="login-pw" name="pwd" required />

				<button type="submit" class="login-action-btn">로그인</button>
			</form>

			<!-- 회원가입 -->
			<form class="signup-form" id="signupForm" method="post"
				style="display: none" action="<c:url value='/member/addMember.do'/>"
				onsubmit="return validateSignup();">

				<label for="signup-id">아이디</label> <input type="text" id="signup-id"
					name="id" required value="${signupId != null ? signupId : ''}"
					autocomplete="off" />
				<div id="idCheckMsg" aria-live="polite"></div>

				<label for="signup-pw">비밀번호</label> <input type="password"
					id="signup-pw" name="pwd" required /> <label for="signup-pw2">비밀번호
					확인</label> <input type="password" id="signup-pw2" required /> <label
					for="signup-name">이름</label> <input type="text" id="signup-name"
					name="name" required /> <label for="signup-email">이메일</label> <input
					type="email" id="signup-email" name="email" required />

				<button id="signupSubmit" type="submit" class="login-action-btn">회원가입</button>
			</form>
		</div>
	</div>

	<script>
    // 탭 전환
    const loginTab = document.getElementById('loginTab');
    const signupTab = document.getElementById('signupTab');
    const loginForm = document.getElementById('loginForm');
    const signupForm = document.getElementById('signupForm');

    function openLogin(){
      loginTab.classList.add('active');
      signupTab.classList.remove('active');
      loginForm.style.display = '';
      signupForm.style.display = 'none';
    }
    function openSignup(){
      signupTab.classList.add('active');
      loginTab.classList.remove('active');
      loginForm.style.display = 'none';
      signupForm.style.display = '';
    }

    loginTab.onclick = openLogin;
    signupTab.onclick = openSignup;
    
    // URL로 탭 선택: ?tab=signup 또는 #signup 이면 회원가입 탭 오픈
    (function () {
      try {
        var hs = (location.hash || '').toLowerCase();
        if (hs === '#signup' || hs === '#join') { openSignup(); return; }

        var p  = new URLSearchParams(location.search);
        var t  = ((p.get('tab') || p.get('t') || '').toLowerCase());
        if (t === 'signup' || t === 'join' || t === 'register') { openSignup(); }
      } catch (e) { /* no-op */ }
    })();

    // 서버가 signupError를 보냈다면 가입 탭부터 열기
    (function(){
      var hasSignupError = ${signupError != null ? 'true' : 'false'};
      if (hasSignupError) openSignup();
    })();

    // 회원가입 비밀번호 확인
    function validateSignup(){
      const p  = document.getElementById('signup-pw').value.trim();
      const p2 = document.getElementById('signup-pw2').value.trim();
      if(p !== p2){
        alert('비밀번호가 일치하지 않습니다.');
        return false;
      }
      // 아이디 중복 마지막 확인
      if (window.__idDup === true) {
        alert('이미 사용 중인 아이디입니다.');
        return false;
      }
      return true;
    }

    // === 아이디 실시간 중복 확인 ===
    const signupId = document.getElementById('signup-id');
    const idMsg = document.getElementById('idCheckMsg');
    const signupSubmit = document.getElementById('signupSubmit');
    window.__idDup = false; // true면 중복

    function setSubmitEnabled(enabled){
      if (enabled){
        signupSubmit.classList.remove('disabled');
        signupSubmit.disabled = false;
      } else {
        signupSubmit.classList.add('disabled');
        signupSubmit.disabled = true;
      }
    }

    let idTimer = null;
    async function checkIdAvailability(id){
      if (!id || id.length < 3){
        idMsg.className = 'hint-bad';
        idMsg.textContent = '아이디는 3자 이상 입력하세요.';
        window.__idDup = true;
        setSubmitEnabled(false);
        return;
      }
      try{
        const url = '<c:url value="/member/checkId.do"/>' + '?id=' + encodeURIComponent(id);
        const res = await fetch(url, { method: 'GET', headers: { 'Accept': 'text/plain' }});
        const txt = (await res.text()).trim();
        if (txt === 'OK'){
          idMsg.className = 'hint-ok';
          idMsg.textContent = '사용 가능한 아이디입니다.';
          window.__idDup = false;
          setSubmitEnabled(true);
        } else {
          idMsg.className = 'hint-bad';
          idMsg.textContent = '이미 사용 중인 아이디입니다.';
          window.__idDup = true;
          setSubmitEnabled(false);
        }
      } catch(e){
        idMsg.className = 'hint-bad';
        idMsg.textContent = '확인 중 오류가 발생했습니다. 다시 시도하세요.';
        window.__idDup = true;
        setSubmitEnabled(false);
      }
    }

    signupId.addEventListener('input', function(){
      clearTimeout(idTimer);
      const val = this.value.trim();
      idTimer = setTimeout(() => checkIdAvailability(val), 300); // 디바운스
    });

    // 초기값이 있으면 바로 검사
    if (signupId.value.trim().length > 0) {
      checkIdAvailability(signupId.value.trim());
    } else {
      setSubmitEnabled(false);
    }
  </script>
</body>
</html>
