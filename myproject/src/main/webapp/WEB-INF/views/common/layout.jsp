<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" isELIgnored="false" %>
<%@ taglib uri="http://tiles.apache.org/tags-tiles" prefix="tiles" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <title><tiles:getAsString name="title" /></title>
  </head>
  <body>
    <div id="container">
      <c:if test="${empty hideHeader or not hideHeader}">
        <div id="header">
          <tiles:insertAttribute name="header" ignore="true"/>
        </div>
      </c:if>

      <%-- <div id="sidebar-left">
        <tiles:insertAttribute name="side"/>
      </div> --%>

      <div id="content">
        <tiles:insertAttribute name="body"/>
      </div>

      <div id="footer">
        <tiles:insertAttribute name="footer" ignore="true"/>
      </div>
    </div>
  </body>
</html>
