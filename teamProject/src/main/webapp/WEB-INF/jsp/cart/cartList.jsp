<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>장바구니 목록</title>
<style type="text/css">
	body {
		font-family: Arial, sans-serif;
		margin: 0;
		padding: 0;
		background-color: #f2f2f2;
	}

	main {
		width: 80%;
		margin: 0 auto;
		margin-top: 30px;
		background-color: #fff;
		padding: 20px;
		border: 1px solid #ccc;
		border-radius: 5px;
	}

	h5 {
		font-size: 18px;
		text-align: center;
		margin-bottom: 20px;
	}

	.product-container {
		display: flex;
		flex-wrap: wrap;
	}

	.product {
		flex-basis: 25%;
		flex-grow: 1;
		box-sizing: border-box;
		padding: 10px;
	}

	img {
		width: 250px;
		height: 300px;
		margin-left: 20px;
	}

	@media (min-width: 768px) {
		img {
			width: 350px;
			height: 475px;
		}
	}

	#pagination {
		margin-top: 20px;
		text-align: center;
	}

	#pagination a {
		display: inline-block;
		padding: 5px 10px;
		margin: 2px;
		background-color: #333;
		color: #fff;
		text-decoration: none;
		border-radius: 3px;
	}

	#pagination a:hover {
		background-color: #444;
	}
	
	

	button {
		padding: 10px 20px;
		background-color: #333;
		color: #fff;
		border: none;
		border-radius: 5px;
		cursor: pointer;
		margin-right: 10px;
		
	}

	button:hover {
		background-color: #444;
	}
	.product-image img {
	    max-width: 200px; /* 원하는 최대 너비 */
	    max-height: 200px; /* 원하는 최대 높이 */
	    width: 200;
	    height: 200;
	}
	h2 {text-align: center;}
	table {
        margin: auto; /* 이 줄 추가 */
    }
	th,td {  padding:0.2em 1em; text-align: center;}
	nav { text-align:center;}
	#tableContainer {
    max-width: 1000px; /* Or whatever maximum width you want */
    margin: auto;
    
	}	
	@media (max-width: 1000px) {
    #tableContainer {
        width: 100%;
    }
	}
</style>
<script src="https://code.jquery.com/jquery-3.7.0.min.js" integrity="sha256-2Pmvv0kuTBOenSvLm6bvfBSSHrUJ+3A7x6P5Ebd07/g=" crossorigin="anonymous"></script>
<script type="text/javascript">
function checkAll() {
    if($("#cboxAll").is(':checked')) {
        $("input[name=cartNum]").prop("checked", true);
    } else {
        $("input[name=cartNum]").prop("checked", false);
    }
}

function modifyQty(cartNum) { //수량 수정 
	if(!confirm('정말 수정하시겠습니까?')) return false;
	var quantity = $('#quantity'+cartNum).val();
	$.ajax({
		url:'/cart/update',
		method:'post',
		cache:false,
		dataType:'json',
		data: {
	            cartNum: cartNum,
	            quantity: quantity
	       	  },
		success:function(res){
			alert(res.updated ? '수정 완료':'수정 실패');
			location.reload();
		},
		error:function(xhr,status,err){
			error('에러:' + status+"/"+err);
		}
	});
}

function removeItem() {   
	   if(!confirm('선택된 상품을 장바구니에서 제거하시겠어요?')) return false;
	   
	   var selectedItems = $("input[name=cartNum]:checked");
	    if (selectedItems.length == 0) {
	        alert("삭제할 상품을 선택해주세요");
	        return false;
	    }
	    var cartnums = [];
	    selectedItems.each(function() {
	        cartnums.push($(this).val()); // 선택한 각 상품의 cartnum을 배열에 추가
	    });
	   var  formdata = $('#deleteForm').serialize();
	   
	   $.ajax({
	      url:'/cart/delete',
	      method:'Post',
	      data:JSON.stringify(cartnums),
	      cache:false,
	      contentType: 'application/json',
	      dataType:'json',
	      success:function(res){
	    	  if (res.deleted) {
	    	        alert('삭제 성공');
	    	        
	    	    } else {
	    	        alert('삭제 실패');
	    	    }
	    	    location.href="/cart/list";
	      },
	      error:function(xhr,status,err){
	         alert('에러:'+status+"/"+err);
	      }
	   });
	   
	   return false;
	}

function clearCart() {
	   if(!confirm('정말로 장바구니를 비울까요?')) return;
	   $.ajax({
	      url:'/cart/clear',
	      method:'get',
	      cache:false,
	      dataType:'json',
	      success:function(res){
	    	  if(res.msg){
			  		alert(res.msg);
			  }else{
		  	  		alert(res.cleared ? '장바구니 비우기 완료' : '장바구니 비우기 에러');
			  		location.href="/cart/list";
			  }
	      },
	      error:function(xhr,status,err){
	         alert('에러:'+status + '/' + err);
	      }
	   });
	   return false;
}
function add_Order(){ //결제
	if(!confirm("결제 하시겠습니까?")) return false;
	
	var selectedItems = $("input[name=cartNum]:checked");
    if (selectedItems.length == 0) {
        alert("결제할 상품을 선택해주세요");
        return false;
    }

    var cartnums = []; // 선택한 상품들의 cartnum을 담을 배열

    selectedItems.each(function() {
        cartnums.push($(this).val()); // 선택한 각 상품의 cartnum을 배열에 추가
    });

	$.ajax({
		url:"/order/add",
		method:'post', 
		contentType: 'application/json', // 요청의 Content-Type을 application/json으로 설정
		data:JSON.stringify(cartnums),
		success:function(res){
			alert(res.ordered ? '결제 완료' : '결제 실패');
			//location.href="/order/list";
		},
		error:function(xhr, status, err){
			alert(status + "/" + err);
		}
	});
}
function itemList(){
	location.href='/item/list/page/1';
}
</script>
</head>
<body>
<main>
<%@ include file="../menu.jsp" %>
<h2>${memberID}님의 장바구니</h2>

<div id="tableContainer">

<form id="deleteForm" method="post" action="/cart/delete" onsubmit="return removeItem();">
<table>
<tr>
<th>상품</th><th>상품번호</th><th>상품명</th><th>가격</th><th>수량</th>
<th><label>전체선택<input type="checkbox" id="cboxAll" name="cboxAll" onclick="checkAll();"></label></th>
</tr>
	<c:forEach var="c" items="${list}">
		<tr>
			<td class="product-image">
			 	<a href="/item/detail/${c.itemNum}">
				<img src="${pageContext.request.contextPath}/items/${c.fnames}"></a>
			</td>
			<td>${c.cartNum}</td>
			<td>${c.goods}</td>
			<td>${c.price}</td>
			<td>
			<input type="number" class="quantity" id="quantity${c.cartNum}" value="${c.quantity}" min="1" max="50">
			<button type="button" onclick="modifyQty(${c.cartNum});">수정</button>
			</td>
			<td><input type="checkbox" name="cartNum" value="${c.cartNum}"></td>
		</tr>
	</c:forEach>
</table>
	<p>
		<nav>
			<button type="button" onclick="javascript:itemList();">계속 쇼핑</button>
			<button type="button" onclick="javascript:add_Order();">결제</button>
			<button type="button" onclick="javascript:clearCart();">장바구니 비우기</button>
			<button type="submit">삭제</button>
		</nav>
</form>
</div>		
</main>
</body>
</html>