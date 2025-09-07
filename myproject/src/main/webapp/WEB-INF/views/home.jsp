<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
  request.setCharacterEncoding("UTF-8");
%>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>WAVE NEWS — Intro</title>

  <style>
    :root{
      --bg:#0b1020; --ink:#e5e7eb; --muted:#9aa3b2; --ring:#4f46e5; --ring2:#22d3ee;
    }
    @media (prefers-color-scheme: light){
      :root{ --bg:#ffffff; --ink:#0f172a; --muted:#64748b; --ring:#2563eb; --ring2:#06b6d4; }
    }

    *{box-sizing:border-box}
    html,body{height:100%}
    body{
      margin:0; background:radial-gradient(1200px 1200px at 50% -20%, rgba(79,70,229,.12), transparent 70%), var(--bg);
      color:var(--ink); font-family:system-ui,-apple-system,Segoe UI,Roboto,Pretendard,sans-serif;
    }

    /* 화면 중앙 고정 배치 */
    .stage{
      position:fixed; inset:0; display:grid; place-items:center; padding:24px;
    }
    .card{
      display:flex; flex-direction:column; align-items:center; gap:18px;
      background:rgba(255,255,255,.02); border:1px solid rgba(148,163,184,.15);
      border-radius:18px; padding:32px 28px 26px; backdrop-filter: blur(6px);
      box-shadow: 0 10px 40px rgba(0,0,0,.25); min-width: clamp(260px, 40vw, 420px);
      text-align:center;
    }
    .brand{ font-size:18px; font-weight:900; letter-spacing:.12em; text-transform:uppercase; opacity:.9; }

    /* 원회전 로딩 */
    .spinner{ width:64px; height:64px; position:relative; display:grid; place-items:center; }
    .spinner::before, .spinner::after{
      content:""; position:absolute; inset:0; border-radius:50%;
      border:4px solid transparent; border-top-color:var(--ring); animation:spin 1s linear infinite;
    }
    .spinner::after{ inset:8px; border-top-color:var(--ring2); animation-duration:1.35s; opacity:.85; }
    @keyframes spin { to { transform: rotate(360deg); } }

    .title{ margin:0; font-size:22px; font-weight:900; letter-spacing:-.3px; }
    .muted{ margin:0; color:var(--muted); font-size:14px; }
  </style>
</head>

<body>
  <main class="stage" role="main">
    <div class="card" aria-busy="true" aria-live="polite">
      <div class="brand">WAVE NEWS</div>
      <div class="spinner" aria-hidden="true"></div>
      <h1 class="title">로딩 중…</h1>
      <p class="muted">최신 기사를 준비하고 있어요</p>
      <noscript><p class="muted" style="margin-top:6px"><a href="<c:url value='/main.jsp'/>" style="color:inherit">여기를 눌러 계속하기</a></p></noscript>
    </div>
  </main>

  <script>
    (function(){
      // 이동 대상 (필요하면 '/main.do' 같은 컨트롤러 경로로 바꿔도 됨)
      var NEXT_URL = '<c:url value="/main.do"/>';
      setTimeout(function(){ location.replace(NEXT_URL); }, 1100);
    })();
  </script>
</body>
</html>
