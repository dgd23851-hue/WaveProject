<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"
    isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="contextPath"  value="${pageContext.request.contextPath}"  />
<%
  request.setCharacterEncoding("UTF-8");
%>  
<!DOCTYPE html>
<html>
<head>
 <style>
   .cls1 {text-decoration:none;}
   .cls2{text-align:center; font-size:30px;}
  </style>
  <meta charset="UTF-8">
  <title>글목록창</title>
  <!-- jQuery CDN -->
	<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

</head>
<body>
<table align="center" border="1"  width="80%" id="board-table" >
 <thead>
  <tr height="10" align="center"  bgcolor="lightgreen">
     <td >글번호</td>
     <td >작성자</td>              
     <td >제목</td>
     <td >작성일</td>
  </tr>
 </thead>
 <tbody></tbody>
</table>
<script>
$(document).ready(function() {
	$.ajax({
		url: '<c:url value="/board/listArticlesJson.do"/>', 
	    method: 'GET',
	    dataType: 'json',
	    success: function(data) {
	      $('#status').text('');
	      console.log(data);
	      
	      if ($.isArray(data) && data.length > 0) {
	         var tbody = $('#board-table tbody');
	         data.forEach(function(board) {
	        	 var tr = $('<tr></tr>');
	             tr.append('<td>' + board.articleNO + '</td>');
	             tr.append('<td>' + board.id + '</td>');
	             tr.append('<td>' + board.title + '</td>');
	             tr.append('<td>' + board.content+ '</td>');
	             
	             tbody.append(tr);
	         });
	          
	      } else {
	          $('#status').text('데이터를 불러올 수 없습니다.');
	      }
	    },
	    error: function(xhr, status, error) {
	        $('#status').text('에러 발생: ' + error);
	    }
	});
  	
});
</script>	
</body>
</html>
