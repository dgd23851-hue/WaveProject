<%@ page language="java" contentType="text/html; charset=UTF-8"
pageEncoding="UTF-8"
isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" /> 
<html>
<head>
<meta charset="UTF-8">
<title>회원 정보 출력창</title>
</head>
<body>
<form name="frm" action="${contextPath}/member/searchMemberList.do">
검색: <input type="text" name="name" />
      <input type="submit" value="검색">
</form>
<table border="1" align="center" width="100%" >
   <tr align=center   bgcolor="lightgreen">
      <td ><b>아이디</b></td>
      <td><b>비밀번호</b></td>
      <td><b>이름</b></td>
      <td><b>이메일</b></td>
      <td><b>가입일</b></td>
      <td><b>삭제</b></td>
   </tr>
   <c:forEach var="member" items="${membersList}">
   
	   <tr align="center">
	      <td>${member.id}</td>
	      <td>${member.pwd}</td>
	      
	      <c:url var="url2" value="/member/memberUpdateForm.do">
			<c:param name="id" value="${member.id}"/>
			<c:param name="pwd" value="${member.pwd}"/>
			<c:param name="name" value="${member.name}"/>
			<c:param name="email" value="${member.email}"/>
			<c:param name="joindate" value="${member.joindate}"/>
		  </c:url>	
	      <td><a href="${url2}">${member.name}</a></td>
	      
	      <td>${member.email}</td>
	      <td>${member.joindate}</td>
	      <c:url var="url1" value="/member/delete.do"><!-- pro14 urlTest.jsp 참고 -->
			<c:param name="id" value="${member.id}"/>
		  </c:url>	
	      <td><a href="${url1}">삭제</a></td>
	    </tr>
    
   </c:forEach> 
</table>
<a href="${contextPath}/member/memberForm.do"><h1 style="text-align:center">회원 가입</h1></a>
</body>
</html>
