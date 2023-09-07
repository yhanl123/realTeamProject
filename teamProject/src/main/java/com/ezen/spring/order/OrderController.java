package com.ezen.spring.order;

import java.util.*;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.SessionAttribute;
import org.springframework.web.bind.annotation.SessionAttributes;

import com.ezen.spring.cart.Cart;
import com.ezen.spring.cart.CartDAO;
import com.ezen.spring.item.Item;
import com.ezen.spring.item.ItemSvc;
import com.ezen.spring.member.Member;
import com.ezen.spring.member.MemberDAO;

@Controller
@RequestMapping("/order")
@SessionAttributes("memberID")
public class OrderController 
{
	@Autowired
	private OrderDAO orderDAO;
	
	@Autowired
	private CartDAO cartDAO;
	
	@Autowired
	private MemberDAO memberDAO;
	
	@Autowired
	private ItemSvc itemSvc;
	
	@GetMapping("/addorder")
	public String addOrder(@SessionAttribute(name="memberID",required = false) String memberID)
	{
		return "order/addOrderForm";
	}
	@PostMapping("/addForm") //주문 폼 보여주기 
	public String addForm(@SessionAttribute(name="memberID",required = false) String memberID,
								   @RequestParam List<Integer> cartNums, Model model){
		Member member = memberDAO.getMember(memberID);
		List<Cart> orderItemList = new ArrayList<>();
		for(int i=0;i<cartNums.size();i++) {
			Cart cart = cartDAO.getCartByCartNum(cartNums.get(i));
			orderItemList.add(cart);
		}
		model.addAttribute(member);
		model.addAttribute(orderItemList);
		return "order/addOrderForm";
	}
	
	@PostMapping("/add")
	@ResponseBody
	public Map<String, Object> addOrder(@SessionAttribute(name="memberID",required = false) String memberID, 
										@RequestBody List<Integer> cartNums,
										@RequestParam Order orderForm)
	{
		boolean ordered = false;
		
		java.sql.Date paymentDate = new java.sql.Date(new Date().getTime());
		int orderNum = orderDAO.getMaxOrderNum(); //마지막 orderNum 가져오기 
		if(orderNum == 0) {
			orderNum = 1;
		}
		else orderNum = orderNum+1;
		
		int itemPaymentAmount = 0; //최종 상품 결제 금액 
		for(int i=0;i<cartNums.size();i++) {
			Cart cart = cartDAO.getCartByCartNum(cartNums.get(i));
			//itemPaymentAmount += price * quantity; 
			
			Order order = new Order();
			order.setOrderNum(orderNum); //주문번호 
			order.setPaymentDate(paymentDate); //결제일 
			order.setItemNum(cart.getItemNum()); //상품번호 
			order.setOptionInformation(cart.getOptionInformation()); //cart에 옵션정보 변수 추가하기 
			order.setQuantity(cart.getQuantity()); //수량 
			order.setBuyer(memberID); //구매자 
			order.setPaymentMethod(orderForm.getPaymentMethod()); //결제방법 추가하기  
			
			//금액 관련 
			order.setItemSellingPrice(cart.getPrice()); //판매가 
			//쿠폰 금액 차감(수정예정) 
			//itemPaymentAmount = itemSellingPrice - coupon ... 등 (수정예정) 
			order.setItemPaymentAmount(itemPaymentAmount); //최종 결제한 금액(환불시에 사용되는 금액) 
			
			//배송 관련 
			order.setPayeeName(orderForm.getPayeeName()); //수취인명 
			order.setContact(orderForm.getContact()); //연락처 
			order.setShippingAddress(orderForm.getShippingAddress()); //배송지 주소 
			order.setShippingNote(orderForm.getShippingNote()); //배송 메모 
			
			boolean added = orderDAO.addOrder(order);
            if (added) { //주문 하면 카트 삭제
                ordered = true;
                cartDAO.delete(cart.getCartNum()); 
            }
		}
		int saveMoney = (int)(itemPaymentAmount * 0.03); //주문시 적립금 3퍼센트 적립
		
		Member buyer = memberDAO.getMember(memberID);
		int newSaveMoney = buyer.getSaveMoney()+saveMoney;
		
		buyer.setSaveMoney(newSaveMoney);
		
		ordered = memberDAO.updateSaveMoney(buyer);
		
		Map<String, Object> map = new HashMap<>();
		map.put("ordered", ordered);
		return map;
	}
/*	
	@PostMapping("/direct")  //장바구니 담기 아닌 바로 주문 버튼 눌렀을 때 메소드
	@ResponseBody
	public Map<String,Object> derectOrder(@SessionAttribute(name="memberID",required = false) String memberID,
										  @RequestParam("itemNum") int itemNum,
										  @RequestParam("quantity") int quantity)
	{
		Map<String, Object> map = new HashMap<>();
		
		if(memberID==null) { //로그인을 안했을 경우 add 불가능
			map.put("ordered",false);
			map.put("msg", "로그인을 해주세요.");
		}else {
			java.sql.Date date = new java.sql.Date(new Date().getTime());
			Item item = itemSvc.detailItem(itemNum);
			String goods = item.getGoods();
			int price = item.getPrice();
			
			Order o = new Order();
			o.setItemNum(itemNum);
			o.setPrice(price);
			o.setBuyer(memberID);
			o.setQuantity(quantity);
			o.setPaymentDate(date);
			
			
			boolean ordered = orderDAO.addOrder(o);
			
			if(ordered) {
				int paymentAmount = price * quantity;
				int saveMoney = (int)(paymentAmount * 0.03);
				int point = 100;
				
				Member orderUser = memberDAO.getMember(uid);
				int newSaveMoney = orderUser.getSaveMoney()+saveMoney;
				int newPoint = orderUser.getPoint()+point;
				
				orderUser.setSaveMoney(newSaveMoney);
				orderUser.setPoint(newPoint);
				
				memberDAO.updateUserSavingsAndPoints(orderUser);
			}
			map.put("ordered", ordered);
		}
		return map;
	}
	
	@GetMapping("/list")
	public String orderList(Model model, @SessionAttribute(name="userid",required = false) String uid)
	{
		List<Order> list = orderDAO.orderList(uid);
		model.addAttribute("list", list);
		model.addAttribute("uid", uid);
		return "itemOrder/orderList";
	}
*/
}