<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link href="/assets/css/star.css" rel="stylesheet"/>
<script src="script.js"></script>
<title>후기 상세보기</title>
<script src="https://code.jquery.com/jquery-3.7.0.min.js" integrity="sha256-2Pmvv0kuTBOenSvLm6bvfBSSHrUJ+3A7x6P5Ebd07/g=" crossorigin="anonymous"></script>
<script type="text/javascript">
	function delReview(reviewNum) {
		if(!confirm('정말 후기를 삭제하시겠습니까?')) return;
		
		$.ajax({
			url:'/review/delete/'+reviewNum,
			method:'get',
			cache:false,
			dataType:'json',
			success:function(res) {
				alert(res.deleted ? '삭제 성공':'삭제 에러');
				if(res.deleted){
					location.href="/item/list/page/1";
				}
			},
			error:function(xhr,status,err){
				alert('에러:' + err);
			}
		});
	}
	
	function likeReview(reviewNum) {
	    $.ajax({
	        url: '/review/like/' + reviewNum,
	        method: 'get',
	        cache: false,
	        dataType: 'json',
	        success: function(res) {
	            if(res.likeUpdated) location.reload();
	        },
	        error: function(xhr, status, err) {
	            alert('에러: ' + err);
	        }
	    });
	}
	
	window.onload = function() {
		var reviewStarCount = parseInt(${review.reviewStar});
	    var reviewStarsDiv = document.getElementById('reviewStars');
	    
	    for (var i = 1; i <= 5; i++) {
	        var star = document.createElement('span');
	        star.textContent = '★';
	        if (i <= reviewStarCount) {
	            star.classList.add('filled');
	        }
	        reviewStarsDiv.appendChild(star);
	    }
	};
</script>
<style type="text/css">
	.item-image {
		width: 200px;
		height: 400px;
	}
	    
	.attachment-container {
		display: flex;
		flex-wrap: wrap;
		justify-content: flex-start; 
	}
	
	.attachment-container img {
		margin-right: 10px;
	}
	
	#myform fieldset {
    display: inline-block;
    direction: rtl;
    border: 0;
	}
	
	#myform fieldset legend {
	    text-align: right;
	}
	
	#reviewStars {
	    font-size: 3em;
	    color: transparent;
	    text-shadow: 0 0 0 #f0f0f0;
	}
	
	.filled {
	    text-shadow: 0 0 0 rgba(250, 208, 0, 0.99);
	    color: rgba(250, 208, 0, 0.99);
	}

</style>
</head>
<body>
<%@ include file="../menu.jsp" %>
<main>
<h2>REVIEW</h2>
<div id="myform">
	<fieldset>
	    <div id="reviewStars"></div>
	</fieldset>
</div>
<table>
	<tr><th>내 용</th><td>${review.reviewContents}</td></tr>
	<tr><th>등록일</th><td>${review.reviewDate}</td></tr>
	<tr><th>작성자</th><td>${review.reviewAuthor}</td></tr>
	<tr><th>좋아요</th>
	<td>
        <span id="likeCount">${review.reviewLikeCnt}</span>
        <c:if test="${not empty memberID}">
        	<button title="좋아요" onclick="likeReview(${review.reviewNum})">❤️</button>
        </c:if>
    </td></tr>
	<tr>
		<th>첨부</th>
		<td>
			<c:forEach var="att" items="${review.reviewAttList}">
				<c:if test="${att!=null }">
					<img class="item-image" src="${pageContext.request.contextPath}/reviewPhoto/${att.reviewAttachName }">
				</c:if>
			</c:forEach>
		</td>
	</tr>
</table>
<p>
<c:if test="${memberID == review.reviewAuthor || memberID == 'Admin'}">
<button type="button" onclick="location.href='/review/update/${review.reviewNum}'">수정</button>
<button type="button" onclick="location.href='javascript:delReview(${review.reviewNum});'">삭제</button>
</c:if>
</main>
</body>
</html>