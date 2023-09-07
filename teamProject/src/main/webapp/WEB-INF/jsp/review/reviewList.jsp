<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>review List</title>
<style type="text/css">
h2{ text-align:center;}

img {
		width: 250px;
		height: 300px;
		margin-left: 20px;
	}

</style>
</head>
<body>
<%@ include file="../menu.jsp" %>
<main>
<h2>REVIEW</h2>
<table>
	<c:forEach var="r" items="${reviewList}">
		<!-- 기존에 출력된 review 중복 출력 방지 -->
		<c:set var="reviewNum" value="${0}"></c:set>
		<c:if test="${r.reviewNum!=reviewNum}">
			<tr><td colspan="2">
				<a href="/review/get/${r.reviewNum}">
					<img src="${pageContext.request.contextPath}/reviewPhoto/${fn:split(r.reviewAttachNames, ',')[0]}">
				</a>
			</td></tr>
			<tr><td colspan="2">
				Review :<a href="/review/get/${r.reviewNum}">${r.reviewContents}</a>
			</td></tr>
			<tr>
				<th>상품명 : </th><td><a href="/item/detail/${r.itemNum}">${r.goods}</a>
			</tr>
			<tr>
				<th>구매자 : </th><td>${r.reviewAuthor}</td> 
			</tr>
			<tr>
				<th>❤️ :  </th><td>${r.reviewLikeCnt}</td>
			</tr>	
		</c:if>
		<c:set var="reviewNum" value="${r.reviewNum}"/>
	</c:forEach>
</table>	
<nav id="pagination">
<c:forEach var="pn" items="${pageInfo.navigatepageNums}">
    <c:choose>
        <c:when test="${pn == pageInfo.pageNum}">
            <span id="pageNum">${pn}</span>
        </c:when>
        <c:otherwise>
            <a href="javascript:void(0);" onclick="loadReviewList(${itemNum}, ${pn});">${pn}</a>
        </c:otherwise>
    </c:choose>
</c:forEach>
</nav>
</main>
</body>
</html>